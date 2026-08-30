import { useCallback, useEffect, useState } from 'react';
import { ActivityIndicator, Pressable, StyleSheet, Text, View } from 'react-native';

import {
  Bucket,
  Duel,
  answer,
  finalPosition,
  isSettled,
  pivotPosition,
  remainingDuels,
  skip,
  startDuels,
} from '../lib/ranking';
import { supabase } from '../lib/supabase';

type Rival = { place_id: string; name: string; pos: number };

type Props = {
  place: { id: string; name: string };
  category: string;
  onDone: (score: number) => void;
  onCancel: () => void;
};

const BUCKETS: { key: Bucket; label: string; hint: string }[] = [
  { key: 'liked', label: 'Było dobrze', hint: 'wrócę i polecę' },
  { key: 'fine', label: 'Było OK', hint: 'nie żałuję, nie tęsknię' },
  { key: 'disliked', label: 'Słabo', hint: 'nie wrócę' },
];

/**
 * Ocenianie bez gwiazdek: najpierw kubełek, potem seria pojedynków z miejscami,
 * które już masz w rankingu. Ocena 0–10 jest wynikiem pozycji, nie deklaracji —
 * dlatego opisuje twój gust, a nie uśredniony gust internetu.
 */
export default function RankingFlow({ place, category, onDone, onCancel }: Props) {
  const [bucket, setBucket] = useState<Bucket | null>(null);
  const [duel, setDuel] = useState<Duel | null>(null);
  const [rival, setRival] = useState<Rival | null>(null);
  const [busy, setBusy] = useState(false);

  const commit = useCallback(
    async (finished: Duel, chosen: Bucket) => {
      setBusy(true);
      const { data, error } = await supabase.rpc('rank_place', {
        cat: category,
        target_place: place.id,
        b: chosen,
        pos: finalPosition(finished),
      });
      setBusy(false);
      if (error) {
        setBusy(false);
        return;
      }
      onDone(Number(data));
    },
    [category, onDone, place.id],
  );

  const chooseBucket = useCallback(
    async (chosen: Bucket) => {
      setBusy(true);
      setBucket(chosen);

      const { count } = await supabase
        .from('rankings')
        .select('place_id', { count: 'exact', head: true })
        .eq('category', category)
        .eq('bucket', chosen);

      const fresh = startDuels(count ?? 0);
      setBusy(false);
      if (isSettled(fresh)) {
        await commit(fresh, chosen);
        return;
      }
      setDuel(fresh);
    },
    [category, commit],
  );

  // Rywala do każdego pojedynku wskazuje baza — klient trzyma wyłącznie przedział.
  useEffect(() => {
    if (!duel || !bucket || isSettled(duel)) return;
    let current = true;
    (async () => {
      const { data } = await supabase.rpc('rank_pivot', {
        cat: category,
        b: bucket,
        lo_pos: pivotPosition(duel),
        hi_pos: pivotPosition(duel),
      });
      if (current) setRival(data?.[0] ?? null);
    })();
    return () => {
      current = false;
    };
  }, [duel, bucket, category]);

  const respond = useCallback(
    async (subjectWon: boolean) => {
      if (!duel || !bucket) return;
      const next = answer(duel, subjectWon);
      if (isSettled(next)) {
        await commit(next, bucket);
        return;
      }
      setDuel(next);
    },
    [bucket, commit, duel],
  );

  const skipDuel = useCallback(async () => {
    if (!duel || !bucket) return;
    await commit(skip(duel), bucket);
  }, [bucket, commit, duel]);

  if (busy) return <ActivityIndicator style={styles.center} size="large" />;

  if (!bucket || !duel) {
    return (
      <View style={styles.sheet}>
        <Text style={styles.title}>{place.name}</Text>
        <Text style={styles.lead}>Jak było?</Text>
        {BUCKETS.map((option) => (
          <Pressable
            key={option.key}
            style={styles.option}
            onPress={() => chooseBucket(option.key)}
            accessibilityRole="button"
          >
            <Text style={styles.optionLabel}>{option.label}</Text>
            <Text style={styles.optionHint}>{option.hint}</Text>
          </Pressable>
        ))}
        <Pressable onPress={onCancel} accessibilityRole="button">
          <Text style={styles.quiet}>Później</Text>
        </Pressable>
      </View>
    );
  }

  return (
    <View style={styles.sheet}>
      <Text style={styles.lead}>Które lepsze?</Text>
      <Text style={styles.progress}>
        Zostało najwyżej {remainingDuels(duel)} {remainingDuels(duel) === 1 ? 'pytanie' : 'pytania'}
      </Text>

      <Pressable style={styles.duel} onPress={() => respond(true)} accessibilityRole="button">
        <Text style={styles.duelName}>{place.name}</Text>
      </Pressable>

      <Text style={styles.versus}>vs</Text>

      <Pressable style={styles.duel} onPress={() => respond(false)} accessibilityRole="button">
        <Text style={styles.duelName}>{rival?.name ?? '…'}</Text>
      </Pressable>

      <Pressable onPress={skipDuel} accessibilityRole="button">
        <Text style={styles.quiet}>Trudno powiedzieć — pomiń</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  center: { flex: 1, justifyContent: 'center' },
  sheet: { padding: 24, gap: 12 },
  title: { fontSize: 22, fontWeight: '700', color: '#232F33' },
  lead: { fontSize: 17, color: '#5E6D71', marginBottom: 4 },
  progress: { fontSize: 13, color: '#8A9698' },
  option: {
    borderWidth: 1,
    borderColor: '#D7DDD8',
    borderRadius: 12,
    padding: 16,
    backgroundColor: '#FBFCFA',
  },
  optionLabel: { fontSize: 17, fontWeight: '600', color: '#232F33' },
  optionHint: { fontSize: 13, color: '#8A9698', marginTop: 2 },
  duel: {
    borderWidth: 2,
    borderColor: '#0E6E66',
    borderRadius: 12,
    padding: 20,
    alignItems: 'center',
    backgroundColor: '#FBFCFA',
  },
  duelName: { fontSize: 18, fontWeight: '600', color: '#232F33', textAlign: 'center' },
  versus: { textAlign: 'center', color: '#8A9698', fontSize: 13 },
  quiet: { textAlign: 'center', color: '#5E6D71', paddingVertical: 12 },
});
