import { useState } from 'react';
import {
  Modal,
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
} from 'react-native';

export interface SortOptions {
  field: 'publishedAt' | 'recordingDate';
  order: 'newest' | 'oldest';
}

interface SortModalProps {
  visible: boolean;
  onClose: () => void;
  onApply: (options: SortOptions) => void;
  currentSort: SortOptions;
}

export default function SortModal({
  visible,
  onClose,
  onApply,
  currentSort,
}: SortModalProps) {
  const [field, setField] = useState<SortOptions['field']>(currentSort.field);
  const [order, setOrder] = useState<SortOptions['order']>(currentSort.order);

  const handleApply = () => {
    onApply({ field, order });
    onClose();
  };

  const renderOption = (
    label: string,
    description: string,
    isSelected: boolean,
    onPress: () => void
  ) => (
    <TouchableOpacity
      style={[styles.option, isSelected && styles.optionSelected]}
      onPress={onPress}
    >
      <Text style={[styles.optionLabel, isSelected && styles.optionLabelSelected]}>
        {label}
      </Text>
      <Text style={[styles.optionDesc, isSelected && styles.optionDescSelected]}>
        {description}
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
        <Text style={styles.title}>Sort Options</Text>

        <Text style={styles.sectionTitle}>Sort By</Text>
        {renderOption(
          'Publication Date',
          'When the video was published on YouTube',
          field === 'publishedAt',
          () => setField('publishedAt')
        )}
        {renderOption(
          'Recording Date',
          'When the video was originally recorded',
          field === 'recordingDate',
          () => setField('recordingDate')
        )}

        <Text style={styles.sectionTitle}>Order</Text>
        {renderOption(
          'Newest First',
          'Most recent videos at the top',
          order === 'newest',
          () => setOrder('newest')
        )}
        {renderOption(
          'Oldest First',
          'Oldest videos at the top',
          order === 'oldest',
          () => setOrder('oldest')
        )}

        <View style={styles.preview}>
          <Text style={styles.previewTitle}>Current Selection</Text>
          <Text style={styles.previewText}>
            {field === 'publishedAt' ? 'Published' : 'Recorded'} —{' '}
            {order === 'newest' ? 'Newest First' : 'Oldest First'}
          </Text>
        </View>

        <View style={styles.footer}>
          <TouchableOpacity style={styles.applyButton} onPress={handleApply}>
            <Text style={styles.applyButtonText}>Apply Sort</Text>
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
    paddingHorizontal: 16,
  },
  title: {
    fontSize: 22,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 20,
    color: '#333',
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginTop: 20,
    marginBottom: 10,
    color: '#333',
  },
  option: {
    padding: 14,
    borderRadius: 8,
    backgroundColor: '#f0f0f0',
    marginBottom: 8,
  },
  optionSelected: {
    backgroundColor: '#4285F4',
  },
  optionLabel: {
    fontSize: 15,
    fontWeight: '600',
    color: '#333',
  },
  optionLabelSelected: {
    color: '#fff',
  },
  optionDesc: {
    fontSize: 12,
    color: '#666',
    marginTop: 2,
  },
  optionDescSelected: {
    color: 'rgba(255,255,255,0.8)',
  },
  preview: {
    marginTop: 24,
    padding: 14,
    borderRadius: 8,
    backgroundColor: '#f8f8f8',
    borderWidth: 1,
    borderColor: '#eee',
  },
  previewTitle: {
    fontSize: 13,
    fontWeight: '600',
    color: '#666',
    marginBottom: 4,
  },
  previewText: {
    fontSize: 15,
    color: '#333',
  },
  footer: {
    marginTop: 'auto',
    paddingVertical: 16,
  },
  applyButton: {
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
