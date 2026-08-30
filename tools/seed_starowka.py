#!/usr/bin/env python3
"""Seed miejsc gastro dla Gdańska (Starówka) z OpenStreetMap.

Pobiera lokale z Overpass API, mapuje tagi OSM na kategorie produktu, deduplikuje
i wypisuje idempotentny SQL (upsert po source_ref).

    python3 tools/seed_starowka.py > supabase/seed/gdansk_starowka.sql
    psql "$DATABASE_URL" -f supabase/seed/gdansk_starowka.sql

Ponowny przebieg aktualizuje nazwy i adresy miejsc z OSM, a miejsc dodanych przez
użytkowników (source='user') nie dotyka.
"""

from __future__ import annotations

import json
import sys
import time
import urllib.parse
import urllib.request
from dataclasses import dataclass

# Główne Miasto, Stare Miasto i Wyspa Spichrzów. Świadomie ciasny bbox: kill-test
# mierzy gęstość jednej sceny, nie pokrycie aglomeracji.
BBOX = (54.3400, 18.6380, 54.3600, 18.6720)  # south, west, north, east

ENDPOINTS = (
    "https://overpass-api.de/api/interpreter",
    "https://overpass.kumi.systems/api/interpreter",
    "https://overpass.private.coffee/api/interpreter",
)

# Tag OSM → kategoria produktu. Kategorie spoza tej mapy pomijamy.
CATEGORY_BY_AMENITY = {
    "restaurant": "food",
    "fast_food": "food",
    "food_court": "food",
    "cafe": "cafe",
    "ice_cream": "cafe",
    "bar": "drinks",
    "pub": "drinks",
    "biergarten": "drinks",
    "nightclub": "drinks",
}

QUERY = """
[out:json][timeout:90];
(
  node["amenity"~"^({kinds})$"]({s},{w},{n},{e});
  way["amenity"~"^({kinds})$"]({s},{w},{n},{e});
);
out center tags;
"""


@dataclass(frozen=True)
class Place:
    osm_ref: str
    name: str
    category: str
    lon: float
    lat: float
    address: str | None


def fetch() -> list[dict]:
    """Pobiera surowe elementy z pierwszego działającego mirrora Overpass."""
    south, west, north, east = BBOX
    query = QUERY.format(
        kinds="|".join(CATEGORY_BY_AMENITY), s=south, w=west, n=north, e=east
    )
    last_error: Exception | None = None
    for endpoint in ENDPOINTS:
        for attempt in range(3):
            try:
                request = urllib.request.Request(
                    endpoint,
                    data=urllib.parse.urlencode({"data": query}).encode(),
                    headers={"User-Agent": "mapa-znajomych-seed/1.0"},
                )
                with urllib.request.urlopen(request, timeout=120) as response:
                    return json.load(response)["elements"]
            except Exception as error:  # mirror padł albo rate-limit
                last_error = error
                print(
                    f"-- {endpoint} próba {attempt + 1}: {error}",
                    file=sys.stderr,
                )
                time.sleep(2**attempt)
    raise SystemExit(f"żaden mirror Overpass nie odpowiedział: {last_error}")


def build_address(tags: dict) -> str | None:
    street, number = tags.get("addr:street"), tags.get("addr:housenumber")
    if not street:
        return None
    return f"{street} {number}".strip() if number else street


def to_places(elements: list[dict]) -> list[Place]:
    """Odsiewa bezimienne obiekty i zwija duplikaty OSM (ten sam lokal jako node i way)."""
    seen: dict[tuple[str, int, int], Place] = {}
    for element in elements:
        tags = element.get("tags", {})
        name = (tags.get("name") or "").strip()
        category = CATEGORY_BY_AMENITY.get(tags.get("amenity", ""))
        if not name or category is None:
            continue

        center = element.get("center", element)
        lon, lat = center.get("lon"), center.get("lat")
        if lon is None or lat is None:
            continue

        # Klucz zwijania: nazwa + siatka ~11 m. Ten sam lokal zmapowany dwa razy
        # (punkt i budynek) trafia do jednego wpisu.
        key = (name.casefold(), round(lat * 10_000), round(lon * 10_000))
        if key in seen:
            continue
        seen[key] = Place(
            osm_ref=f"{element['type']}/{element['id']}",
            name=name[:120],
            category=category,
            lon=lon,
            lat=lat,
            address=build_address(tags),
        )
    return sorted(seen.values(), key=lambda place: (place.category, place.name))


def sql_literal(value: str | None) -> str:
    return "null" if value is None else "'" + value.replace("'", "''") + "'"


def emit(places: list[Place]) -> None:
    counts: dict[str, int] = {}
    for place in places:
        counts[place.category] = counts.get(place.category, 0) + 1

    print("-- Seed: Gdańsk Starówka, dane z OpenStreetMap (ODbL).")
    print(f"-- bbox: {BBOX}")
    print(f"-- miejsc: {len(places)} " + ", ".join(f"{k}={v}" for k, v in sorted(counts.items())))
    print("begin;")
    print(
        "insert into places (city, name, category, geom, address, source, source_ref, status)\nvalues"
    )
    rows = [
        "  ('gdansk', {name}, '{category}', st_point({lon}, {lat})::geography, "
        "{address}, 'osm', {ref}, 'active')".format(
            name=sql_literal(place.name),
            category=place.category,
            lon=place.lon,
            lat=place.lat,
            address=sql_literal(place.address),
            ref=sql_literal(place.osm_ref),
        )
        for place in places
    ]
    print(",\n".join(rows))
    # Odświeżenie nie rusza miejsc dodanych przez użytkowników — mają inny source.
    print(
        "on conflict (source, source_ref) where source_ref is not null do update\n"
        "  set name = excluded.name,\n"
        "      address = excluded.address,\n"
        "      geom = excluded.geom,\n"
        "      updated_at = now();"
    )
    print("commit;")


if __name__ == "__main__":
    found = to_places(fetch())
    if not found:
        raise SystemExit("Overpass nie zwrócił żadnego lokalu — sprawdź bbox i zapytanie")
    emit(found)
    print(f"-- gotowe: {len(found)} miejsc", file=sys.stderr)
