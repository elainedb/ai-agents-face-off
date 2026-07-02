import { useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import { SOURCE_CHANNELS } from '../../data/channels';

// Replaces the video list while open (cross-framework-setup.md §D.2) so option labels never
// collide with list-item titles that a black-box selector can't disambiguate by occlusion.
export function FilterPanel({ current, onApply, onCancel }: { current: string | null; onApply: (category: string | null) => void; onCancel: () => void }) {
  const [pending, setPending] = useState<string | null>(current);
  const labels = Array.from(new Set(SOURCE_CHANNELS.map((c) => c.label)));

  return (
    <View style={styles.container}>
      <Text style={styles.heading}>Filter by category</Text>
      <Pressable onPress={() => setPending(null)} style={[styles.option, pending === null && styles.optionSelected]}>
        <Text style={styles.optionText}>All</Text>
      </Pressable>
      {labels.map((label) => (
        <Pressable key={label} onPress={() => setPending(label)} style={[styles.option, pending === label && styles.optionSelected]}>
          <Text style={styles.optionText}>{label}</Text>
        </Pressable>
      ))}
      <View style={styles.actions}>
        <Pressable onPress={onCancel} style={styles.secondaryButton}>
          <Text style={styles.secondaryButtonText}>Cancel</Text>
        </Pressable>
        <Pressable testID="filter_apply_button" onPress={() => onApply(pending)} style={styles.primaryButton}>
          <Text style={styles.primaryButtonText}>Apply</Text>
        </Pressable>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 16, gap: 8 },
  heading: { fontSize: 18, fontWeight: '700', marginBottom: 8 },
  option: { padding: 14, borderRadius: 6, backgroundColor: '#f2f2f2' },
  optionSelected: { backgroundColor: '#d2e3fc' },
  optionText: { fontSize: 15 },
  actions: { flexDirection: 'row', justifyContent: 'flex-end', gap: 12, marginTop: 24 },
  secondaryButton: { paddingVertical: 10, paddingHorizontal: 20 },
  secondaryButtonText: { color: '#555' },
  primaryButton: { backgroundColor: '#1a73e8', paddingVertical: 10, paddingHorizontal: 24, borderRadius: 6 },
  primaryButtonText: { color: '#fff', fontWeight: '600' },
});
