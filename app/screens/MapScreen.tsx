import MapLibreGL from '@maplibre/maplibre-react-native';
import { useCallback, useEffect, useState } from 'react';
import { ActivityIndicator, StyleSheet, Text, View } from 'react-native';

import { supabase } from '../lib/supabase';
import { MapPlace, pinColor, scoreLabel, signalCaption, signalOf } from '../lib/scores';

// Kafle bez klucza i bez limitu — zamiana na własny hosting PMTiles nie rusza kodu.
const STYLE_URL = 'https://tiles.openfreemap.org/styles/liberty';

// Długi Targ; kill-test toczy się w promieniu spaceru od tego punktu.
const STAROWKA: [number, number] = [18.6534, 54.3487];

type Props = {
  onSelect: (place: MapPlace) => void;
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
    setError(null);
    setPlaces(data ?? []);
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

        {places.map((place) => {
          const signal = signalOf(place);
          return (
            <MapLibreGL.MarkerView
              key={place.id}
              id={place.id}
              coordinate={[place.lon, place.lat]}
            >
              <Pin
                place={place}
                color={pinColor(signal)}
                label={scoreLabel(signal)}
                onPress={() => onSelect(place)}
              />
            </MapLibreGL.MarkerView>
          );
        })}
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

function Pin({
  place,
  color,
  label,
  onPress,
}: {
  place: MapPlace;
  color: string;
  label: string;
  onPress: () => void;
}) {
  const signal = signalOf(place);
  return (
    <View
      accessibilityRole="button"
      accessibilityLabel={`${place.name}. ${signalCaption(signal)}`}
      onTouchEnd={onPress}
      style={[styles.pin, { backgroundColor: color }, label === '' && styles.pinEmpty]}
    >
      {/* Brak liczby jest informacją samą w sobie: nikt z twoich tu nie był. */}
      {label !== '' && <Text style={styles.pinText}>{label}</Text>}
      {place.want_to_try && <View style={styles.wantDot} />}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  map: { flex: 1 },
  overlay: { position: 'absolute', top: '50%', alignSelf: 'center' },
  pin: {
    minWidth: 34,
    height: 26,
    paddingHorizontal: 6,
    borderRadius: 13,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 2,
    borderColor: '#FBFCFA',
  },
  pinEmpty: { minWidth: 14, height: 14, borderRadius: 7, opacity: 0.75 },
  pinText: { color: '#FBFCFA', fontWeight: '700', fontSize: 13 },
  wantDot: {
    position: 'absolute',
    top: -3,
    right: -3,
    width: 9,
    height: 9,
    borderRadius: 5,
    backgroundColor: '#C7402D',
    borderWidth: 1.5,
    borderColor: '#FBFCFA',
  },
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
