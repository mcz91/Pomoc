import MapLibreGL from '@maplibre/maplibre-react-native';
import { useCallback, useEffect, useMemo, useState } from 'react';
import { ActivityIndicator, StyleSheet, Text, View } from 'react-native';

import {
  MapPlace,
  PlaceFeature,
  TONE_COLORS,
  parseMapPlaces,
  toFeatureCollection,
} from '../lib/scores';
import { supabase } from '../lib/supabase';

// Kafle bez klucza i bez limitu — zamiana na własny hosting PMTiles nie rusza kodu.
const STYLE_URL = 'https://tiles.openfreemap.org/styles/liberty';

// Długi Targ; kill-test toczy się w promieniu spaceru od tego punktu.
const STAROWKA: [number, number] = [18.6534, 54.3487];

// Kolor pinezki wybiera silnik stylów po właściwości `tone` — bez przeliczania w JS.
const TONE_MATCH: (string | string[])[] = [
  'match',
  ['get', 'tone'],
  'mine',
  TONE_COLORS.mine,
  'high',
  TONE_COLORS.high,
  'mid',
  TONE_COLORS.mid,
  'low',
  TONE_COLORS.low,
  TONE_COLORS.none,
];

export type SelectedPlace = Pick<PlaceFeature['properties'], 'id' | 'name' | 'category'>;

type Props = {
  onSelect: (place: SelectedPlace) => void;
};

export default function MapScreen({ onSelect }: Props) {
  const [places, setPlaces] = useState<MapPlace[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async (bounds: { ne: number[]; sw: number[] }) => {
    const { data, error: queryError } = await supabase.rpc('map_places', {
      west: bounds.sw[0],
      south: bounds.sw[1],
      east: bounds.ne[0],
      north: bounds.ne[1],
      cat: 'food',
    });

    if (queryError) {
      setError('Nie udało się wczytać miejsc. Pociągnij mapę, żeby spróbować ponownie.');
      return;
    }
    try {
      setPlaces(parseMapPlaces(data));
      setError(null);
    } catch {
      // Zmieniony kształt odpowiedzi jest błędem, nie pustą mapą — nie udajemy,
      // że w tej okolicy po prostu nikogo nie było.
      setError('Nieoczekiwana odpowiedź serwera. Zaktualizuj aplikację.');
    }
  }, []);

  useEffect(() => {
    load({ sw: [18.638, 54.34], ne: [18.672, 54.36] }).finally(() => setLoading(false));
  }, [load]);

  const onRegionChange = useCallback(
    async (feature: { properties?: { visibleBounds?: number[][] } }) => {
      const bounds = feature.properties?.visibleBounds;
      if (!bounds) return;
      await load({ ne: bounds[0], sw: bounds[1] });
    },
    [load],
  );

  const collection = useMemo(() => toFeatureCollection(places), [places]);

  const onPress = useCallback(
    (event: { features?: { properties?: Record<string, unknown> }[] }) => {
      const hit = event.features?.[0]?.properties;
      // Kliknięcie w klaster obsługuje mapa (zoom), nas interesuje pojedynczy lokal.
      if (!hit || typeof hit.id !== 'string') return;
      onSelect(hit as SelectedPlace);
    },
    [onSelect],
  );

  return (
    <View style={styles.container}>
      <MapLibreGL.MapView
        style={styles.map}
        mapStyle={STYLE_URL}
        onRegionDidChange={onRegionChange}
        logoEnabled={false}
        attributionPosition={{ bottom: 8, right: 8 }}
      >
        <MapLibreGL.Camera defaultSettings={{ centerCoordinate: STAROWKA, zoomLevel: 15.5 }} />

        {/* Klastrowanie robi silnik mapy: setki lokali to jedno źródło danych,
            a nie setki komponentów Reacta. */}
        <MapLibreGL.ShapeSource
          id="places"
          shape={collection}
          cluster
          clusterRadius={45}
          clusterMaxZoomLevel={16}
          onPress={onPress}
        >
          <MapLibreGL.CircleLayer
            id="clusters"
            filter={['has', 'point_count']}
            style={{
              circleColor: '#232F33',
              circleOpacity: 0.9,
              circleRadius: ['step', ['get', 'point_count'], 16, 10, 20, 30, 26],
              circleStrokeWidth: 2,
              circleStrokeColor: '#FBFCFA',
            }}
          />
          <MapLibreGL.SymbolLayer
            id="cluster-count"
            filter={['has', 'point_count']}
            style={{
              textField: ['get', 'point_count_abbreviated'],
              textSize: 13,
              textColor: '#FBFCFA',
              textFont: ['Noto Sans Bold'],
            }}
          />

          {/* Lokal bez sygnału jest mniejszy i bez etykiety — brak liczby to
              informacja sama w sobie, nie miejsce na średnią z internetu. */}
          <MapLibreGL.CircleLayer
            id="place-dot"
            filter={['!', ['has', 'point_count']]}
            style={{
              circleColor: TONE_MATCH,
              circleRadius: ['case', ['==', ['get', 'tone'], 'none'], 6, 14],
              circleStrokeWidth: 2,
              circleStrokeColor: '#FBFCFA',
            }}
          />
          <MapLibreGL.SymbolLayer
            id="place-score"
            filter={['all', ['!', ['has', 'point_count']], ['!=', ['get', 'label'], '']]}
            style={{
              textField: ['get', 'label'],
              textSize: 12,
              textColor: '#FBFCFA',
              textFont: ['Noto Sans Bold'],
              textAllowOverlap: true,
            }}
          />
          <MapLibreGL.CircleLayer
            id="want-to-try"
            filter={['all', ['!', ['has', 'point_count']], ['==', ['get', 'wantToTry'], true]]}
            style={{
              circleColor: '#C7402D',
              circleRadius: 4,
              circleTranslate: [12, -12],
              circleStrokeWidth: 1.5,
              circleStrokeColor: '#FBFCFA',
            }}
          />
        </MapLibreGL.ShapeSource>
      </MapLibreGL.MapView>

      {loading && <ActivityIndicator style={styles.overlay} size="large" />}
      {error && (
        <View style={styles.banner}>
          <Text style={styles.bannerText}>{error}</Text>
        </View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  map: { flex: 1 },
  overlay: { position: 'absolute', top: '50%', alignSelf: 'center' },
  banner: {
    position: 'absolute',
    left: 16,
    right: 16,
    bottom: 32,
    backgroundColor: '#232F33',
    borderRadius: 10,
    padding: 12,
  },
  bannerText: { color: '#FBFCFA', fontSize: 14 },
});
