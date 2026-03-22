import { useEffect, useState } from 'react';
import { Modal, ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';

export type Filters = {
  channelName: string;
  country: string;
};

type FilterModalProps = {
  visible: boolean;
  filters: Filters;
  channelOptions: string[];
  countryOptions: string[];
  onApply: (filters: Filters) => void;
  onClose: () => void;
};

function FilterChip({
  active,
  label,
  onPress,
}: {
  active: boolean;
  label: string;
  onPress: () => void;
}) {
  return (
    <TouchableOpacity onPress={onPress} style={[styles.optionChip, active && styles.optionChipActive]}>
      <Text style={[styles.optionText, active && styles.optionTextActive]}>{label}</Text>
    </TouchableOpacity>
  );
}

export function FilterModal({
  channelOptions,
  countryOptions,
  filters,
  onApply,
  onClose,
  visible,
}: FilterModalProps) {
  const [draftFilters, setDraftFilters] = useState(filters);

  useEffect(() => {
    setDraftFilters(filters);
  }, [filters, visible]);

  return (
    <Modal animationType="slide" presentationStyle="pageSheet" transparent={false} visible={visible}>
      <View style={styles.container}>
        <Text style={styles.title}>Filter Videos</Text>

        <ScrollView contentContainerStyle={styles.scrollContent}>
          <Text style={styles.sectionTitle}>Source Channel</Text>
          <View style={styles.optionWrap}>
            <FilterChip
              active={draftFilters.channelName === 'All'}
              label="All"
              onPress={() => setDraftFilters((current) => ({ ...current, channelName: 'All' }))}
            />
            {channelOptions.map((option) => (
              <FilterChip
                active={draftFilters.channelName === option}
                key={option}
                label={option}
                onPress={() => setDraftFilters((current) => ({ ...current, channelName: option }))}
              />
            ))}
          </View>

          <Text style={styles.sectionTitle}>Country</Text>
          <View style={styles.optionWrap}>
            <FilterChip
              active={draftFilters.country === 'All'}
              label="All"
              onPress={() => setDraftFilters((current) => ({ ...current, country: 'All' }))}
            />
            {countryOptions.map((option) => (
              <FilterChip
                active={draftFilters.country === option}
                key={option}
                label={option}
                onPress={() => setDraftFilters((current) => ({ ...current, country: option }))}
              />
            ))}
          </View>
        </ScrollView>

        <View style={styles.footer}>
          <TouchableOpacity
            onPress={() => setDraftFilters({ channelName: 'All', country: 'All' })}
            style={[styles.footerButton, styles.secondaryButton]}>
            <Text style={styles.secondaryButtonText}>Clear All</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => {
              onApply(draftFilters);
              onClose();
            }}
            style={[styles.footerButton, styles.primaryButton]}>
            <Text style={styles.primaryButtonText}>Apply Filters</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#ffffff',
    flex: 1,
    paddingHorizontal: 20,
    paddingTop: 28,
  },
  title: {
    color: '#111827',
    fontSize: 24,
    fontWeight: '700',
  },
  scrollContent: {
    paddingBottom: 24,
  },
  sectionTitle: {
    color: '#111827',
    fontSize: 18,
    fontWeight: '700',
    marginBottom: 14,
    marginTop: 28,
  },
  optionWrap: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
  },
  optionChip: {
    backgroundColor: '#f3f4f6',
    borderRadius: 999,
    paddingHorizontal: 14,
    paddingVertical: 10,
  },
  optionChipActive: {
    backgroundColor: '#4285F4',
  },
  optionText: {
    color: '#374151',
    fontWeight: '600',
  },
  optionTextActive: {
    color: '#ffffff',
  },
  footer: {
    flexDirection: 'row',
    gap: 12,
    paddingBottom: 24,
    paddingTop: 12,
  },
  footerButton: {
    alignItems: 'center',
    borderRadius: 12,
    flex: 1,
    paddingVertical: 14,
  },
  secondaryButton: {
    backgroundColor: '#e5e7eb',
  },
  secondaryButtonText: {
    color: '#111827',
    fontWeight: '700',
  },
  primaryButton: {
    backgroundColor: '#4285F4',
  },
  primaryButtonText: {
    color: '#ffffff',
    fontWeight: '700',
  },
});
