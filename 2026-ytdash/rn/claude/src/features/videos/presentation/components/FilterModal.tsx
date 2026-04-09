import React, { useState } from 'react';
import {
  Modal,
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  SafeAreaView,
} from 'react-native';

interface FilterModalProps {
  visible: boolean;
  onClose: () => void;
  onApply: (channelName: string | null, country: string | null) => void;
  channels: string[];
  countries: string[];
  selectedChannel: string | null;
  selectedCountry: string | null;
}

export function FilterModal({
  visible,
  onClose,
  onApply,
  channels,
  countries,
  selectedChannel,
  selectedCountry,
}: FilterModalProps) {
  const [channel, setChannel] = useState<string | null>(selectedChannel);
  const [country, setCountry] = useState<string | null>(selectedCountry);

  const handleApply = () => {
    onApply(channel, country);
    onClose();
  };

  const handleClear = () => {
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
      <SafeAreaView style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity onPress={onClose}>
            <Text style={styles.closeButton}>Cancel</Text>
          </TouchableOpacity>
          <Text style={styles.headerTitle}>Filters</Text>
          <View style={{ width: 60 }} />
        </View>

        <ScrollView style={styles.content}>
          <Text style={styles.sectionTitle}>Source Channel</Text>
          <TouchableOpacity
            style={[styles.option, !channel && styles.optionSelected]}
            onPress={() => setChannel(null)}
          >
            <Text style={[styles.optionText, !channel && styles.optionTextSelected]}>All</Text>
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

          <Text style={styles.sectionTitle}>Country</Text>
          <TouchableOpacity
            style={[styles.option, !country && styles.optionSelected]}
            onPress={() => setCountry(null)}
          >
            <Text style={[styles.optionText, !country && styles.optionTextSelected]}>All</Text>
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
          <TouchableOpacity style={styles.clearButton} onPress={handleClear}>
            <Text style={styles.clearButtonText}>Clear All</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.applyButton} onPress={handleApply}>
            <Text style={styles.applyButtonText}>Apply Filters</Text>
          </TouchableOpacity>
        </View>
      </SafeAreaView>
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
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  closeButton: {
    fontSize: 16,
    color: '#4285F4',
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '600',
  },
  content: {
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
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderRadius: 8,
    marginBottom: 4,
    backgroundColor: '#f5f5f5',
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
    backgroundColor: '#f5f5f5',
    alignItems: 'center',
  },
  clearButtonText: {
    fontSize: 16,
    color: '#666',
    fontWeight: '600',
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
