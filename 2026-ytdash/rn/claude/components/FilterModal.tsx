import React, { useState, useEffect } from 'react';
import {
  Modal,
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
} from 'react-native';

export interface Filters {
  channel: string | null;
  country: string | null;
}

interface FilterModalProps {
  visible: boolean;
  onClose: () => void;
  onApply: (filters: Filters) => void;
  filters: Filters;
  channels: string[];
  countries: string[];
}

export default function FilterModal({
  visible,
  onClose,
  onApply,
  filters,
  channels,
  countries,
}: FilterModalProps) {
  const [selectedChannel, setSelectedChannel] = useState<string | null>(filters.channel);
  const [selectedCountry, setSelectedCountry] = useState<string | null>(filters.country);

  useEffect(() => {
    setSelectedChannel(filters.channel);
    setSelectedCountry(filters.country);
  }, [filters]);

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
        <Text style={styles.header}>Filters</Text>

        <ScrollView style={styles.content}>
          <Text style={styles.sectionTitle}>Source Channel</Text>
          <View style={styles.optionsRow}>
            {renderOption('All', selectedChannel === null, () => setSelectedChannel(null))}
            {channels.map(ch =>
              renderOption(ch, selectedChannel === ch, () => setSelectedChannel(ch))
            )}
          </View>

          <Text style={styles.sectionTitle}>Country</Text>
          <View style={styles.optionsRow}>
            {renderOption('All', selectedCountry === null, () => setSelectedCountry(null))}
            {countries.map(c =>
              renderOption(c, selectedCountry === c, () => setSelectedCountry(c))
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
  },
  header: {
    fontSize: 20,
    fontWeight: 'bold',
    padding: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  content: {
    flex: 1,
    padding: 20,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 12,
    marginTop: 8,
  },
  optionsRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginBottom: 20,
  },
  option: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
    backgroundColor: '#f0f0f0',
  },
  optionSelected: {
    backgroundColor: '#4285F4',
  },
  optionText: {
    color: '#333',
    fontSize: 14,
  },
  optionTextSelected: {
    color: '#fff',
  },
  footer: {
    flexDirection: 'row',
    padding: 20,
    borderTopWidth: 1,
    borderTopColor: '#eee',
    gap: 12,
  },
  clearButton: {
    flex: 1,
    paddingVertical: 14,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#ccc',
    alignItems: 'center',
  },
  clearButtonText: {
    color: '#666',
    fontSize: 16,
  },
  applyButton: {
    flex: 1,
    paddingVertical: 14,
    borderRadius: 8,
    backgroundColor: '#4285F4',
    alignItems: 'center',
  },
  applyButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
});
