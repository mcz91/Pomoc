/**
 * Prezentacja wyników na mapie.
 *
 * ZASADA BABCI: aplikacja nigdy nie pokazuje średniej globalnej miejsca. Liczba
 * na pinezce jest zawsze czyjaś — najpierw moja własna ocena, potem wynik moich
 * znajomych ważony zbieżnością gustu. Gdy nie ma żadnego z tych sygnałów,
 * pinezka zostaje bez liczby; nie podstawiamy w to miejsce popularności.
 */

export type MapPlace = {
  id: string;
  name: string;
  category: 'food' | 'cafe' | 'drinks' | 'culture' | 'chill' | 'other';
  lon: number;
  lat: number;
  my_score: number | null;
  friend_score: number | null;
  friend_count: number;
  want_to_try: boolean;
};

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

const PALETTE = {
  mine: '#0E6E66',
  high: '#2E7D46',
  mid: '#A96A0C',
  low: '#C7402D',
  none: '#8A9698',
} as const;

export function pinColor(signal: Signal): string {
  if (signal.kind === 'none') return PALETTE.none;
  if (signal.kind === 'mine') return PALETTE.mine;
  if (signal.score >= 8) return PALETTE.high;
  if (signal.score >= 6) return PALETTE.mid;
  return PALETTE.low;
}
