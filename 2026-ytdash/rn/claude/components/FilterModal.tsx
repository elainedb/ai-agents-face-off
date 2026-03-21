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
  const [selectedChannel, setSelectedChannel] = useState<string | null>(currentFilters.channel);
  const [selectedCountry, setSelectedCountry] = useState<string | null>(currentFilters.country);

  const handleApply = () => {
    onApply({ channel: selectedChannel, country: selectedCountry });
    onClose();
  };

  const handleClearAll = () => {
    setSelectedChannel(null);
    setSelectedCountry(null);
  };

  return (
    <Modal
      visible={visible}
      animationType="slide"
      presentationStyle="pageSheet"
      onRequestClose={onClose}
    >
      <View style={styles.container}>
        <Text style={styles.header}>Filters</Text>

        <ScrollView style={styles.scrollView}>
          <Text style={styles.sectionTitle}>Source Channel</Text>
          <TouchableOpacity
            style={[styles.option, selectedChannel === null && styles.optionSelected]}
            onPress={() => setSelectedChannel(null)}
          >
            <Text style={[styles.optionText, selectedChannel === null && styles.optionTextSelected]}>
              All
            </Text>
          </TouchableOpacity>
          {channels.map(channel => (
            <TouchableOpacity
              key={channel}
              style={[styles.option, selectedChannel === channel && styles.optionSelected]}
              onPress={() => setSelectedChannel(channel)}
            >
              <Text style={[styles.optionText, selectedChannel === channel && styles.optionTextSelected]}>
                {channel}
              </Text>
            </TouchableOpacity>
          ))}

          <Text style={styles.sectionTitle}>Country</Text>
          <TouchableOpacity
            style={[styles.option, selectedCountry === null && styles.optionSelected]}
            onPress={() => setSelectedCountry(null)}
          >
            <Text style={[styles.optionText, selectedCountry === null && styles.optionTextSelected]}>
              All
            </Text>
          </TouchableOpacity>
          {countries.map(country => (
            <TouchableOpacity
              key={country}
              style={[styles.option, selectedCountry === country && styles.optionSelected]}
              onPress={() => setSelectedCountry(country)}
            >
              <Text style={[styles.optionText, selectedCountry === country && styles.optionTextSelected]}>
                {country}
              </Text>
            </TouchableOpacity>
          ))}
        </ScrollView>

        <View style={styles.footer}>
          <TouchableOpacity style={styles.clearButton} onPress={handleClearAll}>
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
    paddingTop: 20,
  },
  header: {
    fontSize: 22,
    fontWeight: 'bold',
    textAlign: 'center',
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  scrollView: {
    flex: 1,
    padding: 16,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginTop: 16,
    marginBottom: 8,
    color: '#333',
  },
  option: {
    paddingVertical: 10,
    paddingHorizontal: 16,
    borderRadius: 8,
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
    borderWidth: 1,
    borderColor: '#ccc',
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
