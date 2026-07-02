import { useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import { SortDirection } from '../../domain/types';

// Sort option labels must END with the keyword Maestro's `text:` regex matches on
// (cross-framework-setup.md §D.3): "Date — Newest" ends with "Newest", "Date — Oldest" ends with
// "Oldest" — neither collides with the other's pattern.
export function SortPanel({ current, onApply, onCancel }: { current: SortDirection | null; onApply: (direction: SortDirection | null) => void; onCancel: () => void }) {
  const [pending, setPending] = useState<SortDirection | null>(current);

  return (
    <View style={styles.container}>
      <Text style={styles.heading}>Sort by date</Text>
      <Pressable onPress={() => setPending('desc')} style={[styles.option, pending === 'desc' && styles.optionSelected]}>
        <Text style={styles.optionText}>Date — Newest</Text>
      </Pressable>
      <Pressable onPress={() => setPending('asc')} style={[styles.option, pending === 'asc' && styles.optionSelected]}>
        <Text style={styles.optionText}>Date — Oldest</Text>
      </Pressable>
      <View style={styles.actions}>
        <Pressable onPress={onCancel} style={styles.secondaryButton}>
          <Text style={styles.secondaryButtonText}>Cancel</Text>
        </Pressable>
        <Pressable testID="sort_apply_button" onPress={() => onApply(pending)} style={styles.primaryButton}>
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
