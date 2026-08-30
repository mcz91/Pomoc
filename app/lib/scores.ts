/**
 * Prezentacja wyników na mapie.
 *
 * ZASADA BABCI: aplikacja nigdy nie pokazuje średniej globalnej miejsca. Liczba
 * na pinezce jest zawsze czyjaś — najpierw moja własna ocena, potem wynik moich
 * znajomych ważony zbieżnością gustu. Gdy nie ma żadnego z tych sygnałów,
 * pinezka zostaje bez liczby; nie podstawiamy w to miejsce popularności.
 */

import { z } from 'zod';

export const CATEGORIES = ['food', 'cafe', 'drinks', 'culture', 'chill', 'other'] as const;
export type Category = (typeof CATEGORIES)[number];

/**
 * Kształt wiersza z `map_places`. Walidujemy go na granicy, bo RPC zwraca `any`,
 * a cicho zgubione pole (np. friend_score) objawiłoby się jako pinezka bez
 * liczby — czyli fałszywym komunikatem "nikt tu nie był".
 */
export const MapPlaceSchema = z.object({
  id: z.guid(),
  name: z.string(),
  category: z.enum(CATEGORIES),
  lon: z.number(),
  lat: z.number(),
  my_score: z.number().nullable(),
  friend_score: z.coerce.number().nullable(),
  friend_count: z.number().int().nonnegative(),
  want_to_try: z.boolean(),
});

export type MapPlace = z.infer<typeof MapPlaceSchema>;

export function parseMapPlaces(rows: unknown): MapPlace[] {
  return z.array(MapPlaceSchema).parse(rows ?? []);
}

export type Signal =
  | { kind: 'mine'; score: number }
  | { kind: 'friends'; score: number; count: number }
  | { kind: 'none' };

export function signalOf(place: MapPlace): Signal {
  if (place.my_score !== null) return { kind: 'mine', score: place.my_score };
  if (place.friend_score !== null && place.friend_count > 0) {
    return { kind: 'friends', score: place.friend_score, count: place.friend_count };
  }
  return { kind: 'none' };
}

export function scoreLabel(signal: Signal): string {
  return signal.kind === 'none' ? '' : signal.score.toFixed(1);
}

/** Zdanie pod nazwą lokalu — mówi, czyja to ocena, nie tylko jaka. */
export function signalCaption(signal: Signal): string {
  switch (signal.kind) {
    case 'mine':
      return 'Twoja ocena';
    case 'friends':
      return signal.count === 1
        ? 'Ocena 1 znajomego, ważona gustem'
        : `Ocena ${signal.count} znajomych, ważona gustem`;
    case 'none':
      return 'Nikt z twoich jeszcze tu nie był';
  }
}

/** Ton pinezki. Nazwy, nie kolory — paletę trzyma warstwa mapy. */
export type Tone = 'mine' | 'high' | 'mid' | 'low' | 'none';

export function toneOf(signal: Signal): Tone {
  if (signal.kind === 'none') return 'none';
  if (signal.kind === 'mine') return 'mine';
  if (signal.score >= 8) return 'high';
  if (signal.score >= 6) return 'mid';
  return 'low';
}

export const TONE_COLORS: Record<Tone, string> = {
  mine: '#0E6E66',
  high: '#2E7D46',
  mid: '#A96A0C',
  low: '#C7402D',
  none: '#8A9698',
};

export type PlaceFeature = GeoJSON.Feature<
  GeoJSON.Point,
  { id: string; name: string; category: Category; label: string; tone: Tone; wantToTry: boolean }
>;

/** Mapa dostaje jedno źródło GeoJSON i sama klastruje — bez markerów per lokal. */
export function toFeatureCollection(
  places: MapPlace[],
): GeoJSON.FeatureCollection<GeoJSON.Point, PlaceFeature['properties']> {
  return {
    type: 'FeatureCollection',
    features: places.map((place) => {
      const signal = signalOf(place);
      return {
        type: 'Feature',
        id: place.id,
        geometry: { type: 'Point', coordinates: [place.lon, place.lat] },
        properties: {
          id: place.id,
          name: place.name,
          category: place.category,
          label: scoreLabel(signal),
          tone: toneOf(signal),
          wantToTry: place.want_to_try,
        },
      };
    }),
  };
}
