import { useEffect, useState } from 'react';
import { Modal, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';

import type { Filters } from '@/types/video';

type FilterModalProps = {
  visible: boolean;
  filters: Filters;
  channels: string[];
  countries: string[];
  onClose: () => void;
  onApply: (filters: Filters) => void;
};

export function FilterModal({
  visible,
  filters,
  channels,
  countries,
  onClose,
  onApply,
}: FilterModalProps) {
  const [localFilters, setLocalFilters] = useState(filters);

  useEffect(() => {
    setLocalFilters(filters);
  }, [filters, visible]);

  return (
    <Modal visible={visible} animationType="slide" presentationStyle="pageSheet" onRequestClose={onClose}>
      <View style={styles.container}>
        <Text style={styles.title}>Filters</Text>
        <ScrollView contentContainerStyle={styles.content}>
          <FilterSection
            title="Source Channel"
            values={['All', ...channels]}
            selectedValue={localFilters.channelName}
            onSelect={(value) => setLocalFilters((current) => ({ ...current, channelName: value }))}
          />
          <FilterSection
            title="Country"
            values={['All', ...countries]}
            selectedValue={localFilters.country}
            onSelect={(value) => setLocalFilters((current) => ({ ...current, country: value }))}
          />
        </ScrollView>
        <View style={styles.footer}>
          <Pressable
            onPress={() => setLocalFilters({ channelName: 'All', country: 'All' })}
            style={[styles.footerButton, styles.clearButton]}>
            <Text style={styles.clearButtonText}>Clear All</Text>
          </Pressable>
          <Pressable onPress={() => onApply(localFilters)} style={[styles.footerButton, styles.applyButton]}>
            <Text style={styles.applyButtonText}>Apply Filters</Text>
          </Pressable>
        </View>
      </View>
    </Modal>
  );
}

type FilterSectionProps = {
  title: string;
  values: string[];
  selectedValue: string;
  onSelect: (value: string) => void;
};

function FilterSection({ title, values, selectedValue, onSelect }: FilterSectionProps) {
  return (
    <View style={styles.section}>
      <Text style={styles.sectionTitle}>{title}</Text>
      <View style={styles.optionsContainer}>
        {values.map((value) => {
          const selected = value === selectedValue;
          return (
            <Pressable
              key={`${title}-${value}`}
              onPress={() => onSelect(value)}
              style={[styles.optionChip, selected ? styles.optionChipSelected : null]}>
              <Text style={[styles.optionChipText, selected ? styles.optionChipTextSelected : null]}>
                {value}
              </Text>
            </Pressable>
          );
        })}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f7f9fc',
    paddingTop: 64,
    paddingHorizontal: 20,
    paddingBottom: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
    color: '#101828',
    marginBottom: 20,
  },
  content: {
    gap: 24,
    paddingBottom: 20,
  },
  section: {
    borderRadius: 20,
    backgroundColor: '#ffffff',
    padding: 18,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#101828',
    marginBottom: 14,
  },
  optionsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
  },
  optionChip: {
    borderRadius: 999,
    backgroundColor: '#eaecf0',
    paddingHorizontal: 14,
    paddingVertical: 10,
  },
  optionChipSelected: {
    backgroundColor: '#4285F4',
  },
  optionChipText: {
    color: '#344054',
    fontWeight: '600',
  },
  optionChipTextSelected: {
    color: '#ffffff',
  },
  footer: {
    flexDirection: 'row',
    gap: 12,
    marginTop: 'auto',
  },
  footerButton: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 14,
    paddingVertical: 14,
  },
  clearButton: {
    backgroundColor: '#e4e7ec',
  },
  clearButtonText: {
    color: '#101828',
    fontWeight: '700',
  },
  applyButton: {
    backgroundColor: '#4285F4',
  },
  applyButtonText: {
    color: '#ffffff',
    fontWeight: '700',
  },
});
