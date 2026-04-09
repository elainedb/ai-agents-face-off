import { Modal, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { useEffect, useState } from 'react';

import type { FilterOptions } from '@/src/features/videos/presentation/stores/videos-store';

interface FilterModalProps {
  visible: boolean;
  filters: FilterOptions;
  channels: string[];
  countries: string[];
  onClose: () => void;
  onApply: (filters: FilterOptions) => void;
  onClear: () => void;
}

const Option = ({
  label,
  selected,
  onPress,
}: {
  label: string;
  selected: boolean;
  onPress: () => void;
}) => (
  <Pressable style={[styles.option, selected && styles.optionSelected]} onPress={onPress}>
    <Text style={[styles.optionText, selected && styles.optionTextSelected]}>{label}</Text>
  </Pressable>
);

export function FilterModal({
  visible,
  filters,
  channels,
  countries,
  onClose,
  onApply,
  onClear,
}: FilterModalProps) {
  const [localFilters, setLocalFilters] = useState(filters);

  useEffect(() => {
    setLocalFilters(filters);
  }, [filters, visible]);

  return (
    <Modal animationType="slide" presentationStyle="pageSheet" visible={visible} onRequestClose={onClose}>
      <View style={styles.container}>
        <Text style={styles.title}>Filter Videos</Text>
        <ScrollView contentContainerStyle={styles.content}>
          <Text style={styles.sectionTitle}>Source Channel</Text>
          <Option
            label="All"
            selected={!localFilters.channelName}
            onPress={() => setLocalFilters((current) => ({ ...current, channelName: null }))}
          />
          {channels.map((channel) => (
            <Option
              key={channel}
              label={channel}
              selected={localFilters.channelName === channel}
              onPress={() => setLocalFilters((current) => ({ ...current, channelName: channel }))}
            />
          ))}

          <Text style={styles.sectionTitle}>Country</Text>
          <Option
            label="All"
            selected={!localFilters.country}
            onPress={() => setLocalFilters((current) => ({ ...current, country: null }))}
          />
          {countries.map((country) => (
            <Option
              key={country}
              label={country}
              selected={localFilters.country === country}
              onPress={() => setLocalFilters((current) => ({ ...current, country }))}
            />
          ))}
        </ScrollView>
        <View style={styles.footer}>
          <Pressable
            style={[styles.footerButton, styles.clearButton]}
            onPress={() => {
              onClear();
              onClose();
            }}>
            <Text style={styles.clearButtonText}>Clear All</Text>
          </Pressable>
          <Pressable
            style={[styles.footerButton, styles.applyButton]}
            onPress={() => {
              onApply(localFilters);
              onClose();
            }}>
            <Text style={styles.applyButtonText}>Apply Filters</Text>
          </Pressable>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F4F7FB',
    paddingTop: 56,
  },
  title: {
    fontSize: 28,
    fontWeight: '800',
    paddingHorizontal: 20,
    color: '#14213D',
  },
  content: {
    padding: 20,
    paddingBottom: 120,
    gap: 12,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#14213D',
    marginTop: 16,
    marginBottom: 6,
  },
  option: {
    borderRadius: 16,
    borderWidth: 1,
    borderColor: '#C9D5EA',
    backgroundColor: '#FFFFFF',
    padding: 14,
  },
  optionSelected: {
    backgroundColor: '#4285F4',
    borderColor: '#4285F4',
  },
  optionText: {
    color: '#14213D',
    fontWeight: '600',
  },
  optionTextSelected: {
    color: '#FFFFFF',
  },
  footer: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    flexDirection: 'row',
    gap: 12,
    padding: 20,
    backgroundColor: '#FFFFFF',
    borderTopWidth: 1,
    borderColor: '#DCE4F4',
  },
  footerButton: {
    flex: 1,
    borderRadius: 16,
    paddingVertical: 14,
    alignItems: 'center',
  },
  clearButton: {
    backgroundColor: '#EEF2F9',
  },
  clearButtonText: {
    color: '#22304A',
    fontWeight: '700',
  },
  applyButton: {
    backgroundColor: '#4285F4',
  },
  applyButtonText: {
    color: '#FFFFFF',
    fontWeight: '700',
  },
});
