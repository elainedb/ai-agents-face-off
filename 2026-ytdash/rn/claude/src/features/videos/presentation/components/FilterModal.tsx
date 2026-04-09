import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Modal,
  TouchableOpacity,
  ScrollView,
  SafeAreaView,
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

export function FilterModal({
  visible,
  onClose,
  channels,
  countries,
  selectedChannel,
  selectedCountry,
  onApply,
}: FilterModalProps) {
  const [localChannel, setLocalChannel] = useState<string | null>(selectedChannel);
  const [localCountry, setLocalCountry] = useState<string | null>(selectedCountry);

  useEffect(() => {
    setLocalChannel(selectedChannel);
    setLocalCountry(selectedCountry);
  }, [selectedChannel, selectedCountry, visible]);

  const handleApply = () => {
    onApply(localChannel, localCountry);
    onClose();
  };

  const handleClear = () => {
    setLocalChannel(null);
    setLocalCountry(null);
  };

  return (
    <Modal visible={visible} animationType="slide" presentationStyle="pageSheet">
      <SafeAreaView style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity onPress={onClose}>
            <Text style={styles.cancelText}>Cancel</Text>
          </TouchableOpacity>
          <Text style={styles.headerTitle}>Filters</Text>
          <View style={{ width: 60 }} />
        </View>

        <ScrollView style={styles.content}>
          <Text style={styles.sectionTitle}>Source Channel</Text>
          <TouchableOpacity
            style={[styles.option, localChannel === null && styles.optionSelected]}
            onPress={() => setLocalChannel(null)}
          >
            <Text style={[styles.optionText, localChannel === null && styles.optionTextSelected]}>
              All
            </Text>
          </TouchableOpacity>
          {channels.map((ch) => (
            <TouchableOpacity
              key={ch}
              style={[styles.option, localChannel === ch && styles.optionSelected]}
              onPress={() => setLocalChannel(ch)}
            >
              <Text style={[styles.optionText, localChannel === ch && styles.optionTextSelected]}>
                {ch}
              </Text>
            </TouchableOpacity>
          ))}

          <Text style={[styles.sectionTitle, { marginTop: 24 }]}>Country</Text>
          <TouchableOpacity
            style={[styles.option, localCountry === null && styles.optionSelected]}
            onPress={() => setLocalCountry(null)}
          >
            <Text style={[styles.optionText, localCountry === null && styles.optionTextSelected]}>
              All
            </Text>
          </TouchableOpacity>
          {countries.map((c) => (
            <TouchableOpacity
              key={c}
              style={[styles.option, localCountry === c && styles.optionSelected]}
              onPress={() => setLocalCountry(c)}
            >
              <Text style={[styles.optionText, localCountry === c && styles.optionTextSelected]}>
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
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  cancelText: {
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
    color: '#212121',
    marginBottom: 8,
  },
  option: {
    paddingVertical: 10,
    paddingHorizontal: 12,
    borderRadius: 8,
    marginBottom: 4,
  },
  optionSelected: {
    backgroundColor: '#4285F4',
  },
  optionText: {
    fontSize: 15,
    color: '#212121',
  },
  optionTextSelected: {
    color: '#fff',
  },
  footer: {
    flexDirection: 'row',
    padding: 16,
    gap: 12,
    borderTopWidth: 1,
    borderTopColor: '#e0e0e0',
  },
  clearButton: {
    flex: 1,
    paddingVertical: 12,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#757575',
    alignItems: 'center',
  },
  clearButtonText: {
    fontSize: 16,
    color: '#757575',
  },
  applyButton: {
    flex: 1,
    paddingVertical: 12,
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
