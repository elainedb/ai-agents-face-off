import { useEffect, useState } from 'react';
import { Modal, Pressable, StyleSheet, Text, View } from 'react-native';

import type { SortOptions } from '@/types/video';

type SortModalProps = {
  visible: boolean;
  sortOptions: SortOptions;
  onClose: () => void;
  onApply: (sortOptions: SortOptions) => void;
};

export function SortModal({ visible, sortOptions, onClose, onApply }: SortModalProps) {
  const [localSortOptions, setLocalSortOptions] = useState(sortOptions);

  useEffect(() => {
    setLocalSortOptions(sortOptions);
  }, [sortOptions, visible]);

  return (
    <Modal visible={visible} animationType="slide" presentationStyle="pageSheet" onRequestClose={onClose}>
      <View style={styles.container}>
        <Text style={styles.title}>Sort Videos</Text>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Sort By</Text>
          <SortOption
            label="Publication Date"
            description="Use the YouTube publication timestamp."
            selected={localSortOptions.field === 'publishedAt'}
            onPress={() => setLocalSortOptions((current) => ({ ...current, field: 'publishedAt' }))}
          />
          <SortOption
            label="Recording Date"
            description="Falls back to publication date when recording metadata is missing."
            selected={localSortOptions.field === 'recordingDate'}
            onPress={() => setLocalSortOptions((current) => ({ ...current, field: 'recordingDate' }))}
          />
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Order</Text>
          <SortOption
            label="Newest First"
            description="Descending by the selected date field."
            selected={localSortOptions.order === 'desc'}
            onPress={() => setLocalSortOptions((current) => ({ ...current, order: 'desc' }))}
          />
          <SortOption
            label="Oldest First"
            description="Ascending by the selected date field."
            selected={localSortOptions.order === 'asc'}
            onPress={() => setLocalSortOptions((current) => ({ ...current, order: 'asc' }))}
          />
        </View>

        <View style={styles.previewCard}>
          <Text style={styles.previewTitle}>Current Selection</Text>
          <Text style={styles.previewText}>
            {`${localSortOptions.field === 'publishedAt' ? 'Publication Date' : 'Recording Date'} • ${
              localSortOptions.order === 'desc' ? 'Newest First' : 'Oldest First'
            }`}
          </Text>
        </View>

        <Pressable onPress={() => onApply(localSortOptions)} style={styles.applyButton}>
          <Text style={styles.applyButtonText}>Apply Sort</Text>
        </Pressable>
      </View>
    </Modal>
  );
}

type SortOptionProps = {
  label: string;
  description: string;
  selected: boolean;
  onPress: () => void;
};

function SortOption({ label, description, selected, onPress }: SortOptionProps) {
  return (
    <Pressable onPress={onPress} style={[styles.optionRow, selected ? styles.optionRowSelected : null]}>
      <Text style={[styles.optionLabel, selected ? styles.optionLabelSelected : null]}>{label}</Text>
      <Text style={[styles.optionDescription, selected ? styles.optionDescriptionSelected : null]}>
        {description}
      </Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f7f9fc',
    paddingTop: 64,
    paddingHorizontal: 20,
    paddingBottom: 24,
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
    color: '#101828',
    marginBottom: 20,
  },
  section: {
    borderRadius: 20,
    backgroundColor: '#ffffff',
    padding: 18,
    marginBottom: 18,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#101828',
    marginBottom: 12,
  },
  optionRow: {
    borderRadius: 16,
    backgroundColor: '#f2f4f7',
    padding: 14,
    marginBottom: 10,
  },
  optionRowSelected: {
    backgroundColor: '#4285F4',
  },
  optionLabel: {
    fontSize: 16,
    fontWeight: '700',
    color: '#101828',
    marginBottom: 4,
  },
  optionLabelSelected: {
    color: '#ffffff',
  },
  optionDescription: {
    color: '#667085',
    lineHeight: 20,
  },
  optionDescriptionSelected: {
    color: '#dbe8ff',
  },
  previewCard: {
    borderRadius: 20,
    backgroundColor: '#ffffff',
    padding: 18,
    marginBottom: 18,
  },
  previewTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#101828',
    marginBottom: 8,
  },
  previewText: {
    color: '#475467',
    lineHeight: 20,
  },
  applyButton: {
    marginTop: 'auto',
    alignItems: 'center',
    borderRadius: 14,
    backgroundColor: '#4285F4',
    paddingVertical: 15,
  },
  applyButtonText: {
    color: '#ffffff',
    fontWeight: '700',
    fontSize: 16,
  },
});
