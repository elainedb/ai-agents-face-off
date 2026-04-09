import { Modal, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { useEffect, useState } from 'react';

interface FilterModalProps {
  visible: boolean;
  selectedChannel: string | null;
  selectedCountry: string | null;
  channels: string[];
  countries: string[];
  onClose: () => void;
  onApply: (filters: { channelName: string | null; country: string | null }) => void;
  onClear: () => void;
}

export function FilterModal({
  visible,
  selectedChannel,
  selectedCountry,
  channels,
  countries,
  onClose,
  onApply,
  onClear,
}: FilterModalProps) {
  const [channelName, setChannelName] = useState<string | null>(selectedChannel);
  const [country, setCountry] = useState<string | null>(selectedCountry);

  useEffect(() => {
    setChannelName(selectedChannel);
    setCountry(selectedCountry);
  }, [selectedChannel, selectedCountry, visible]);

  const renderOption = (
    label: string,
    value: string | null,
    selectedValue: string | null,
    onSelect: (next: string | null) => void,
  ) => (
    <Pressable
      key={label}
      onPress={() => onSelect(value)}
      style={[styles.option, selectedValue === value && styles.optionSelected]}>
      <Text style={[styles.optionText, selectedValue === value && styles.optionTextSelected]}>
        {label}
      </Text>
    </Pressable>
  );

  return (
    <Modal visible={visible} animationType="slide" onRequestClose={onClose}>
      <View style={styles.container}>
        <Text style={styles.title}>Filters</Text>
        <ScrollView contentContainerStyle={styles.content}>
          <Text style={styles.sectionTitle}>Source Channel</Text>
          {renderOption('All', null, channelName, setChannelName)}
          {channels.map((item) => renderOption(item, item, channelName, setChannelName))}

          <Text style={styles.sectionTitle}>Country</Text>
          {renderOption('All', null, country, setCountry)}
          {countries.map((item) => renderOption(item, item, country, setCountry))}
        </ScrollView>

        <View style={styles.footer}>
          <Pressable
            onPress={() => {
              setChannelName(null);
              setCountry(null);
              onClear();
              onClose();
            }}
            style={[styles.footerButton, styles.secondaryButton]}>
            <Text style={styles.secondaryButtonText}>Clear All</Text>
          </Pressable>
          <Pressable
            onPress={() => {
              onApply({ channelName, country });
              onClose();
            }}
            style={[styles.footerButton, styles.primaryButton]}>
            <Text style={styles.primaryButtonText}>Apply Filters</Text>
          </Pressable>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f4f7fb',
    paddingTop: 56,
  },
  title: {
    fontSize: 26,
    fontWeight: '700',
    color: '#102030',
    paddingHorizontal: 20,
  },
  content: {
    padding: 20,
    paddingBottom: 120,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '700',
    marginTop: 18,
    marginBottom: 12,
    color: '#24384d',
  },
  option: {
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: '#cad7e6',
    backgroundColor: '#fff',
    marginBottom: 10,
  },
  optionSelected: {
    backgroundColor: '#4285F4',
    borderColor: '#4285F4',
  },
  optionText: {
    color: '#1a2f45',
    fontWeight: '600',
  },
  optionTextSelected: {
    color: '#fff',
  },
  footer: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    flexDirection: 'row',
    gap: 12,
    padding: 20,
    backgroundColor: '#fff',
    borderTopWidth: 1,
    borderTopColor: '#dde5ef',
  },
  footerButton: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 14,
    borderRadius: 14,
  },
  secondaryButton: {
    backgroundColor: '#eef2f7',
  },
  secondaryButtonText: {
    color: '#1a2f45',
    fontWeight: '700',
  },
  primaryButton: {
    backgroundColor: '#4285F4',
  },
  primaryButtonText: {
    color: '#fff',
    fontWeight: '700',
  },
});
