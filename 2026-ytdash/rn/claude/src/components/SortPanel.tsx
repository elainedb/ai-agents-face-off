import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { SortDirection, SortKey } from '../domain/types';

type Option = { key: SortKey; direction: SortDirection; label: string };

// Labels must END with the exact regex keyword the flows match on ("newest"/"desc"), no trailing
// punctuation — Maestro's `text:` match is a full-string `matches()`, not a substring search.
const OPTIONS: Option[] = [
  { key: 'date', direction: 'desc', label: 'Date — newest' },
  { key: 'date', direction: 'asc', label: 'Date — oldest' },
  { key: 'title', direction: 'asc', label: 'Title — A to Z' },
  { key: 'title', direction: 'desc', label: 'Title — Z to A' },
];

type Props = {
  sortKey: SortKey | null;
  sortDirection: SortDirection;
  onSelect: (key: SortKey, direction: SortDirection) => void;
};

export function SortPanel({ sortKey, sortDirection, onSelect }: Props) {
  return (
    <View testID="sort_panel" style={styles.container}>
      {OPTIONS.map((opt) => {
        const isSelected = opt.key === sortKey && opt.direction === sortDirection;
        return (
          <Pressable
            key={opt.label}
            style={[styles.option, isSelected && styles.optionSelected]}
            onPress={() => onSelect(opt.key, opt.direction)}
          >
            <Text style={styles.optionText}>{opt.label}</Text>
          </Pressable>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 16 },
  option: {
    paddingVertical: 14,
    paddingHorizontal: 16,
    borderRadius: 8,
    backgroundColor: '#f3f4f6',
    marginBottom: 8,
  },
  optionSelected: {
    backgroundColor: '#dbeafe',
  },
  optionText: {
    fontSize: 16,
  },
});
