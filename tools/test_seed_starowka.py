"""Testy transformacji OSM → SQL. Uruchomienie: python3 -m unittest discover -s tools"""

import io
import unittest

import overpy

from seed_starowka import emit, to_places

# Odpowiedź Overpass w kształcie, jaki zwraca `out center tags`.
PAYLOAD = {
    "version": 0.6,
    "elements": [
        {
            "type": "node",
            "id": 1,
            "lat": 54.3490,
            "lon": 18.6530,
            "tags": {
                "name": "Pod Łososiem",
                "amenity": "restaurant",
                "addr:street": "Szeroka",
                "addr:housenumber": "52/54",
            },
        },
        # Ten sam lokal zmapowany drugi raz jako obrys budynku.
        {
            "type": "way",
            "id": 2,
            "center": {"lat": 54.34901, "lon": 18.65301},
            "tags": {"name": "Pod Łososiem", "amenity": "restaurant"},
        },
        {
            "type": "node",
            "id": 3,
            "lat": 54.3500,
            "lon": 18.6540,
            "tags": {"name": "Drukarnia's Bar", "amenity": "bar"},
        },
        # Bez nazwy — nie da się o tym nic powiedzieć, więc pomijamy.
        {"type": "node", "id": 4, "lat": 54.3510, "lon": 18.6550, "tags": {"amenity": "cafe"}},
        # Poza kategoriami produktu.
        {
            "type": "node",
            "id": 5,
            "lat": 54.3520,
            "lon": 18.6560,
            "tags": {"name": "Apteka", "amenity": "pharmacy"},
        },
    ],
}


class SeedTransform(unittest.TestCase):
    def setUp(self) -> None:
        self.places = to_places(overpy.Result.from_json(PAYLOAD))

    def test_odsiewa_bezimienne_i_obce_kategorie(self) -> None:
        self.assertEqual([p.name for p in self.places], ["Drukarnia's Bar", "Pod Łososiem"])

    def test_zwija_ten_sam_lokal_zmapowany_dwa_razy(self) -> None:
        losos = [p for p in self.places if p.name == "Pod Łososiem"]
        self.assertEqual(len(losos), 1)
        self.assertEqual(losos[0].osm_ref, "node/1", "wygrywa wpis punktowy, bo pierwszy")

    def test_mapuje_tagi_na_kategorie_produktu(self) -> None:
        self.assertEqual({p.name: p.category for p in self.places},
                         {"Pod Łososiem": "food", "Drukarnia's Bar": "drinks"})

    def test_sklada_adres_z_ulicy_i_numeru(self) -> None:
        losos = next(p for p in self.places if p.name == "Pod Łososiem")
        self.assertEqual(losos.address, "Szeroka 52/54")

    def test_escapuje_apostrof_w_sql(self) -> None:
        out = io.StringIO()
        emit(self.places, out=out)
        self.assertIn("'Drukarnia''s Bar'", out.getvalue())

    def test_sql_jest_idempotentny(self) -> None:
        out = io.StringIO()
        emit(self.places, out=out)
        sql = out.getvalue()
        self.assertIn("on conflict (source, source_ref)", sql)
        self.assertIn("do update", sql)


if __name__ == "__main__":
    unittest.main()
