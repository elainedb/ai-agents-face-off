import React, { useState } from 'react';
import {
  View,
  Text,
  Modal,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
} from 'react-native';

export interface FilterOptions {
  channel: string | null;
  country: string | null;
}

interface FilterModalProps {
  visible: boolean;
  onClose: () => void;
  onApply: (filters: FilterOptions) => void;
  channels: string[];
  countries: string[];
  currentFilters: FilterOptions;
}

export default function FilterModal({
  visible,
  onClose,
  onApply,
  channels,
  countries,
  currentFilters,
}: FilterModalProps) {
  const [selectedChannel, setSelectedChannel] = useState<string | null>(
    currentFilters.channel
  );
  const [selectedCountry, setSelectedCountry] = useState<string | null>(
    currentFilters.country
  );

  const handleApply = () => {
    onApply({ channel: selectedChannel, country: selectedCountry });
    onClose();
  };

  const handleClear = () => {
    setSelectedChannel(null);
    setSelectedCountry(null);
  };

  const renderOption = (
    label: string,
    isSelected: boolean,
    onPress: () => void
  ) => (
    <TouchableOpacity
      key={label}
      style={[styles.option, isSelected && styles.optionSelected]}
      onPress={onPress}
    >
      <Text style={[styles.optionText, isSelected && styles.optionTextSelected]}>
        {label}
      </Text>
    </TouchableOpacity>
  );

  return (
    <Modal
      visible={visible}
      animationType="slide"
      presentationStyle="pageSheet"
      onRequestClose={onClose}
    >
      <View style={styles.container}>
        <Text style={styles.title}>Filters</Text>

        <ScrollView style={styles.scrollContent}>
          <Text style={styles.sectionTitle}>Source Channel</Text>
          <View style={styles.optionsRow}>
            {renderOption('All', selectedChannel === null, () =>
              setSelectedChannel(null)
            )}
            {channels.map((ch) =>
              renderOption(ch, selectedChannel === ch, () =>
                setSelectedChannel(ch)
              )
            )}
          </View>

          <Text style={styles.sectionTitle}>Country</Text>
          <View style={styles.optionsRow}>
            {renderOption('All', selectedCountry === null, () =>
              setSelectedCountry(null)
            )}
            {countries.map((c) =>
              renderOption(c, selectedCountry === c, () =>
                setSelectedCountry(c)
              )
            )}
          </View>
        </ScrollView>

        <View style={styles.footer}>
          <TouchableOpacity style={styles.clearButton} onPress={handleClear}>
            <Text style={styles.clearButtonText}>Clear All</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.applyButton} onPress={handleApply}>
            <Text style={styles.applyButtonText}>Apply Filters</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    paddingTop: 50,
  },
  title: {
    fontSize: 22,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 20,
    color: '#333',
  },
  scrollContent: {
    flex: 1,
    paddingHorizontal: 16,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginTop: 16,
    marginBottom: 8,
    color: '#555',
  },
  optionsRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  option: {
    paddingHorizontal: 14,
    paddingVertical: 8,
    borderRadius: 20,
    backgroundColor: '#f0f0f0',
    marginBottom: 4,
  },
  optionSelected: {
    backgroundColor: '#4285F4',
  },
  optionText: {
    fontSize: 14,
    color: '#333',
  },
  optionTextSelected: {
    color: '#fff',
    fontWeight: '600',
  },
  footer: {
    flexDirection: 'row',
    padding: 16,
    borderTopWidth: 1,
    borderTopColor: '#eee',
    gap: 12,
  },
  clearButton: {
    flex: 1,
    paddingVertical: 14,
    borderRadius: 8,
    backgroundColor: '#f0f0f0',
    alignItems: 'center',
  },
  clearButtonText: {
    fontSize: 16,
    color: '#666',
  },
  applyButton: {
    flex: 1,
    paddingVertical: 14,
    borderRadius: 8,
    backgroundColor: '#4285F4',
    alignItems: 'center',
  },
  applyButtonText: {
    fontSize: 16,
    color: '#fff',
    fontWeight: '600',
  },
});
