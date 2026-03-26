import { useEffect, useState } from 'react';
import { Modal, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';

export type FilterState = {
  channel: string;
  country: string;
};

type Props = {
  availableChannels: string[];
  availableCountries: string[];
  initialFilters: FilterState;
  onApply: (filters: FilterState) => void;
  onClose: () => void;
  visible: boolean;
};

export default function FilterModal({
  availableChannels,
  availableCountries,
  initialFilters,
  onApply,
  onClose,
  visible,
}: Props) {
  const [localFilters, setLocalFilters] = useState(initialFilters);

  useEffect(() => {
    setLocalFilters(initialFilters);
  }, [initialFilters, visible]);

  const renderOptions = (
    title: string,
    options: string[],
    selectedValue: string,
    onSelect: (value: string) => void
  ) => (
    <View style={styles.section}>
      <Text style={styles.sectionTitle}>{title}</Text>
      {['All', ...options].map((option) => {
        const selected = option === selectedValue;
        return (
          <Pressable
            key={`${title}-${option}`}
            onPress={() => onSelect(option)}
            style={[styles.option, selected && styles.optionSelected]}>
            <Text style={[styles.optionText, selected && styles.optionTextSelected]}>{option}</Text>
          </Pressable>
        );
      })}
    </View>
  );

  return (
    <Modal animationType="slide" presentationStyle="pageSheet" visible={visible}>
      <View style={styles.container}>
        <Text style={styles.title}>Filter Videos</Text>
        <ScrollView contentContainerStyle={styles.content}>
          {renderOptions('Source Channel', availableChannels, localFilters.channel, (value) =>
            setLocalFilters((current) => ({ ...current, channel: value }))
          )}
          {renderOptions('Country', availableCountries, localFilters.country, (value) =>
            setLocalFilters((current) => ({ ...current, country: value }))
          )}
        </ScrollView>
        <View style={styles.footer}>
          <Pressable
            onPress={() => setLocalFilters({ channel: 'All', country: 'All' })}
            style={[styles.footerButton, styles.clearButton]}>
            <Text style={styles.clearText}>Clear All</Text>
          </Pressable>
          <Pressable onPress={() => onApply(localFilters)} style={[styles.footerButton, styles.applyButton]}>
            <Text style={styles.applyText}>Apply Filters</Text>
          </Pressable>
        </View>
        <Pressable onPress={onClose} style={styles.closeButton}>
          <Text style={styles.closeText}>Close</Text>
        </Pressable>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#f7f9fc',
    flex: 1,
    paddingHorizontal: 20,
    paddingTop: 60,
    paddingBottom: 24,
  },
  title: {
    color: '#14213d',
    fontSize: 24,
    fontWeight: '700',
    marginBottom: 20,
  },
  content: {
    paddingBottom: 16,
  },
  section: {
    marginBottom: 24,
  },
  sectionTitle: {
    color: '#22304a',
    fontSize: 18,
    fontWeight: '700',
    marginBottom: 10,
  },
  option: {
    backgroundColor: '#e7ecf3',
    borderRadius: 12,
    marginBottom: 8,
    paddingHorizontal: 14,
    paddingVertical: 12,
  },
  optionSelected: {
    backgroundColor: '#4285F4',
  },
  optionText: {
    color: '#22304a',
    fontWeight: '600',
  },
  optionTextSelected: {
    color: '#ffffff',
  },
  footer: {
    flexDirection: 'row',
    gap: 12,
  },
  footerButton: {
    alignItems: 'center',
    borderRadius: 12,
    flex: 1,
    paddingVertical: 14,
  },
  clearButton: {
    backgroundColor: '#e7ecf3',
  },
  applyButton: {
    backgroundColor: '#4285F4',
  },
  clearText: {
    color: '#22304a',
    fontWeight: '700',
  },
  applyText: {
    color: '#ffffff',
    fontWeight: '700',
  },
  closeButton: {
    alignItems: 'center',
    marginTop: 16,
  },
  closeText: {
    color: '#52627a',
    fontWeight: '600',
  },
});
