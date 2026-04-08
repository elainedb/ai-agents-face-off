import { Modal, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { useEffect, useState } from 'react';

import type { FilterOptions } from '@/src/features/videos/presentation/stores/videos-store';

interface FilterModalProps {
  visible: boolean;
  filters: FilterOptions;
  availableChannels: string[];
  availableCountries: string[];
  onClose: () => void;
  onApply: (filters: FilterOptions) => void;
  onClear: () => void;
}

function OptionChip({
  label,
  selected,
  onPress,
}: {
  label: string;
  selected: boolean;
  onPress: () => void;
}) {
  return (
    <Pressable
      onPress={onPress}
      style={[styles.option, selected && styles.optionSelected]}>
      <Text style={[styles.optionText, selected && styles.optionTextSelected]}>{label}</Text>
    </Pressable>
  );
}

export function FilterModal({
  visible,
  filters,
  availableChannels,
  availableCountries,
  onClose,
  onApply,
  onClear,
}: FilterModalProps) {
  const [localFilters, setLocalFilters] = useState<FilterOptions>(filters);

  useEffect(() => {
    setLocalFilters(filters);
  }, [filters, visible]);

  return (
    <Modal animationType="slide" presentationStyle="pageSheet" visible={visible}>
      <View style={styles.container}>
        <Text style={styles.title}>Filter Videos</Text>
        <ScrollView contentContainerStyle={styles.content}>
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Source Channel</Text>
            <OptionChip
              label="All"
              selected={localFilters.channelName === null}
              onPress={() => setLocalFilters((current) => ({ ...current, channelName: null }))}
            />
            {availableChannels.map((channel) => (
              <OptionChip
                key={channel}
                label={channel}
                selected={localFilters.channelName === channel}
                onPress={() =>
                  setLocalFilters((current) => ({ ...current, channelName: channel }))
                }
              />
            ))}
          </View>
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Country</Text>
            <OptionChip
              label="All"
              selected={localFilters.country === null}
              onPress={() => setLocalFilters((current) => ({ ...current, country: null }))}
            />
            {availableCountries.map((country) => (
              <OptionChip
                key={country}
                label={country}
                selected={localFilters.country === country}
                onPress={() => setLocalFilters((current) => ({ ...current, country }))}
              />
            ))}
          </View>
        </ScrollView>
        <View style={styles.footer}>
          <Pressable
            style={[styles.footerButton, styles.clearButton]}
            onPress={() => {
              setLocalFilters({ channelName: null, country: null });
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
    backgroundColor: '#f6f8ff',
    paddingTop: 24,
  },
  title: {
    fontSize: 28,
    fontWeight: '800',
    color: '#13203a',
    paddingHorizontal: 20,
  },
  content: {
    padding: 20,
    gap: 24,
  },
  section: {
    gap: 12,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#20304f',
  },
  option: {
    paddingHorizontal: 14,
    paddingVertical: 12,
    backgroundColor: '#e8eefc',
    borderRadius: 14,
  },
  optionSelected: {
    backgroundColor: '#4285F4',
  },
  optionText: {
    color: '#2d416c',
    fontWeight: '600',
  },
  optionTextSelected: {
    color: '#ffffff',
  },
  footer: {
    flexDirection: 'row',
    gap: 12,
    padding: 20,
  },
  footerButton: {
    flex: 1,
    borderRadius: 16,
    paddingVertical: 16,
    alignItems: 'center',
  },
  clearButton: {
    backgroundColor: '#ffffff',
    borderWidth: 1,
    borderColor: '#ced8f0',
  },
  applyButton: {
    backgroundColor: '#4285F4',
  },
  clearButtonText: {
    color: '#304567',
    fontWeight: '700',
  },
  applyButtonText: {
    color: '#ffffff',
    fontWeight: '700',
  },
});
