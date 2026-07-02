import React from 'react';
import { FlatList, Pressable, StyleSheet, Text, View } from 'react-native';

type Props = {
  categories: string[];
  selected: string | null;
  onSelect: (category: string | null) => void;
};

export function FilterPanel({ categories, selected, onSelect }: Props) {
  const options = [null, ...categories];
  return (
    <View testID="filter_panel" style={styles.container}>
      <FlatList
        data={options}
        keyExtractor={(item) => item ?? '__all__'}
        renderItem={({ item }) => {
          const isSelected = item === selected;
          return (
            <Pressable
              style={[styles.option, isSelected && styles.optionSelected]}
              onPress={() => onSelect(item)}
            >
              <Text style={styles.optionText}>{item ?? 'All'}</Text>
            </Pressable>
          );
        }}
      />
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
