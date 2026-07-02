import React, { useState } from 'react';
import { Platform, Pressable, StatusBar, StyleSheet, Text, View } from 'react-native';

import type { SortKey } from '../../domain/models';

const OPTIONS: { key: SortKey; label: string }[] = [
  { key: 'date-desc', label: 'Date — newest' },
  { key: 'date-asc', label: 'Date — oldest' },
  { key: 'title-asc', label: 'Title A-Z' },
];

type Props = {
  currentSort: SortKey;
  onApply: (key: SortKey) => void;
  onClose: () => void;
};

export function SortPanel({ currentSort, onApply, onClose }: Props) {
  const [selected, setSelected] = useState<SortKey>(currentSort);

  return (
    <View testID="sort_panel" style={styles.container}>
      <Text style={styles.heading}>Sort by</Text>
      {OPTIONS.map((opt) => (
        <Pressable key={opt.key} style={styles.option} onPress={() => setSelected(opt.key)}>
          <Text style={[styles.optionText, selected === opt.key && styles.optionSelected]}>{opt.label}</Text>
        </Pressable>
      ))}
      <View style={styles.actions}>
        <Pressable testID="sort_apply_button" style={styles.applyButton} onPress={() => onApply(selected)}>
          <Text style={styles.applyText}>Apply</Text>
        </Pressable>
        <Pressable style={styles.cancelButton} onPress={onClose}>
          <Text style={styles.cancelText}>Cancel</Text>
        </Pressable>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    padding: 16,
    paddingTop: (Platform.OS === 'android' ? StatusBar.currentHeight ?? 24 : 0) + 16,
  },
  heading: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 16,
  },
  option: {
    paddingVertical: 12,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#ddd',
  },
  optionText: {
    fontSize: 16,
  },
  optionSelected: {
    fontWeight: '700',
    color: '#1a73e8',
  },
  actions: {
    flexDirection: 'row',
    marginTop: 24,
    gap: 12,
  },
  applyButton: {
    backgroundColor: '#1a73e8',
    paddingVertical: 12,
    paddingHorizontal: 20,
    borderRadius: 6,
  },
  applyText: {
    color: 'white',
    fontWeight: '600',
  },
  cancelButton: {
    paddingVertical: 12,
    paddingHorizontal: 20,
  },
  cancelText: {
    color: '#666',
  },
});
