import { StatusBar } from 'expo-status-bar';
import { useState } from 'react';
import { Modal, StyleSheet, View } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import 'react-native-url-polyfill/auto';

import MapScreen, { SelectedPlace } from './screens/MapScreen';
import RankingFlow from './screens/RankingFlow';

export default function App() {
  const [ranking, setRanking] = useState<SelectedPlace | null>(null);

  return (
    <SafeAreaProvider>
      <View style={styles.root}>
        <StatusBar style="auto" />
        <MapScreen onSelect={setRanking} />

        <Modal visible={ranking !== null} animationType="slide" presentationStyle="pageSheet">
          {ranking && (
            <RankingFlow
              place={ranking}
              category={ranking.category}
              onDone={() => setRanking(null)}
              onCancel={() => setRanking(null)}
            />
          )}
        </Modal>
      </View>
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: '#F1F3F0' },
});
