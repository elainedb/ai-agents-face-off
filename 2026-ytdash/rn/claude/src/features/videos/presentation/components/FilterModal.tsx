import React, { useState } from 'react';
import {
  View,
  Text,
  Modal,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
} from 'react-native';

interface FilterModalProps {
  visible: boolean;
  onClose: () => void;
  channels: string[];
  countries: string[];
  selectedChannel: string | null;
  selectedCountry: string | null;
  onApply: (channel: string | null, country: string | null) => void;
}

export default function FilterModal({
  visible,
  onClose,
  channels,
  countries,
  selectedChannel,
  selectedCountry,
  onApply,
}: FilterModalProps) {
  const [channel, setChannel] = useState<string | null>(selectedChannel);
  const [country, setCountry] = useState<string | null>(selectedCountry);

  const handleApply = () => {
    onApply(channel, country);
    onClose();
  };

  const handleClearAll = () => {
    setChannel(null);
    setCountry(null);
  };

  return (
    <Modal
      visible={visible}
      animationType="slide"
      presentationStyle="pageSheet"
      onRequestClose={onClose}
    >
      <View style={styles.container}>
        <View style={styles.header}>
          <Text style={styles.headerTitle}>Filters</Text>
          <TouchableOpacity onPress={onClose}>
            <Text style={styles.closeButton}>Close</Text>
          </TouchableOpacity>
        </View>

        <ScrollView style={styles.content}>
          <Text style={styles.sectionTitle}>Source Channel</Text>
          <TouchableOpacity
            style={[styles.option, channel === null && styles.optionSelected]}
            onPress={() => setChannel(null)}
          >
            <Text style={[styles.optionText, channel === null && styles.optionTextSelected]}>
              All
            </Text>
          </TouchableOpacity>
          {channels.map((ch) => (
            <TouchableOpacity
              key={ch}
              style={[styles.option, channel === ch && styles.optionSelected]}
              onPress={() => setChannel(ch)}
            >
              <Text style={[styles.optionText, channel === ch && styles.optionTextSelected]}>
                {ch}
              </Text>
            </TouchableOpacity>
          ))}

          <Text style={[styles.sectionTitle, { marginTop: 24 }]}>Country</Text>
          <TouchableOpacity
            style={[styles.option, country === null && styles.optionSelected]}
            onPress={() => setCountry(null)}
          >
            <Text style={[styles.optionText, country === null && styles.optionTextSelected]}>
              All
            </Text>
          </TouchableOpacity>
          {countries.map((c) => (
            <TouchableOpacity
              key={c}
              style={[styles.option, country === c && styles.optionSelected]}
              onPress={() => setCountry(c)}
            >
              <Text style={[styles.optionText, country === c && styles.optionTextSelected]}>
                {c}
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
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: '600',
  },
  closeButton: {
    fontSize: 16,
    color: '#4285F4',
  },
  content: {
    flex: 1,
    padding: 16,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 12,
    color: '#333',
  },
  option: {
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderRadius: 8,
    marginBottom: 4,
  },
  optionSelected: {
    backgroundColor: '#4285F4',
  },
  optionText: {
    fontSize: 15,
    color: '#333',
  },
  optionTextSelected: {
    color: '#fff',
  },
  footer: {
    flexDirection: 'row',
    padding: 16,
    borderTopWidth: 1,
    borderTopColor: '#e0e0e0',
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
