import assert from 'node:assert/strict';
import test from 'node:test';

import type { MapPlace } from './scores.ts';
import {
  TONE_COLORS,
  parseMapPlaces,
  scoreLabel,
  signalCaption,
  signalOf,
  toFeatureCollection,
  toneOf,
} from './scores.ts';

const base: MapPlace = {
  id: '11111111-1111-1111-1111-111111111111',
  name: 'Lokal',
  category: 'food',
  lon: 18.6534,
  lat: 54.3487,
  my_score: null,
  friend_score: null,
  friend_count: 0,
  want_to_try: false,
};

test('własna ocena bije wynik znajomych', () => {
  const signal = signalOf({ ...base, my_score: 9.1, friend_score: 4.2, friend_count: 3 });
  assert.deepEqual(signal, { kind: 'mine', score: 9.1 });
  assert.equal(scoreLabel(signal), '9.1');
  assert.equal(signalCaption(signal), 'Twoja ocena');
});

test('bez własnej oceny liczy się wynik znajomych i mówimy, czyj jest', () => {
  const signal = signalOf({ ...base, friend_score: 8.4, friend_count: 3 });
  assert.deepEqual(signal, { kind: 'friends', score: 8.4, count: 3 });
  assert.equal(signalCaption(signal), 'Ocena 3 znajomych, ważona gustem');
});

test('brak sygnału to brak liczby, nie zero i nie średnia', () => {
  const signal = signalOf(base);
  assert.deepEqual(signal, { kind: 'none' });
  assert.equal(scoreLabel(signal), '');
  assert.equal(signalCaption(signal), 'Nikt z twoich jeszcze tu nie był');
});

test('wynik znajomych bez ani jednego znajomego nie jest sygnałem', () => {
  // Zabezpieczenie przed liczbą znikąd: score bez licznika to niespójna odpowiedź.
  assert.deepEqual(signalOf({ ...base, friend_score: 7.0, friend_count: 0 }), { kind: 'none' });
});

test('ton pinezki oddziela moje oceny od cudzych i progi jakości', () => {
  assert.equal(toneOf(signalOf({ ...base, my_score: 2.0 })), 'mine');
  assert.equal(toneOf(signalOf({ ...base, friend_score: 8.0, friend_count: 1 })), 'high');
  assert.equal(toneOf(signalOf({ ...base, friend_score: 6.0, friend_count: 1 })), 'mid');
  assert.equal(toneOf(signalOf({ ...base, friend_score: 5.9, friend_count: 1 })), 'low');
  assert.equal(toneOf(signalOf(base)), 'none');
  assert.equal(Object.keys(TONE_COLORS).length, 5);
});

test('kolekcja GeoJSON niesie współrzędne w kolejności [lon, lat]', () => {
  const collection = toFeatureCollection([{ ...base, my_score: 7.5 }]);
  assert.equal(collection.features.length, 1);
  assert.deepEqual(collection.features[0]!.geometry.coordinates, [18.6534, 54.3487]);
  assert.equal(collection.features[0]!.properties.label, '7.5');
  assert.equal(collection.features[0]!.properties.category, 'food');
});

test('odpowiedź serwera jest walidowana, a nie zakładana', () => {
  // PostgREST potrafi zwrócić numeric jako string — to musi przejść.
  const parsed = parseMapPlaces([{ ...base, friend_score: '8.9', friend_count: 2 }]);
  assert.equal(parsed[0]!.friend_score, 8.9);

  assert.deepEqual(parseMapPlaces(null), []);
  assert.throws(() => parseMapPlaces([{ ...base, category: 'nieznana' }]));
  assert.throws(() => parseMapPlaces([{ ...base, id: 'nie-uuid' }]));
  assert.throws(() => parseMapPlaces([{ ...base, friend_count: -1 }]));
});
