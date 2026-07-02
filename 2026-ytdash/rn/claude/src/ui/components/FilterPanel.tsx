import React, { useState } from 'react';
import { Platform, Pressable, StatusBar, StyleSheet, Text, View } from 'react-native';

type Props = {
  categories: string[];
  currentFilter: string | null;
  onApply: (label: string | null) => void;
  onClose: () => void;
};

export function FilterPanel({ categories, currentFilter, onApply, onClose }: Props) {
  const [selected, setSelected] = useState<string | null>(currentFilter);

  return (
    <View testID="filter_panel" style={styles.container}>
      <Text style={styles.heading}>Filter by category</Text>
      <Pressable style={styles.option} onPress={() => setSelected(null)}>
        <Text style={[styles.optionText, selected === null && styles.optionSelected]}>All</Text>
      </Pressable>
      {categories.map((c) => (
        <Pressable key={c} style={styles.option} onPress={() => setSelected(c)}>
          <Text style={[styles.optionText, selected === c && styles.optionSelected]}>{c}</Text>
        </Pressable>
      ))}
      <View style={styles.actions}>
        <Pressable testID="filter_apply_button" style={styles.applyButton} onPress={() => onApply(selected)}>
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
    textTransform: 'capitalize',
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
