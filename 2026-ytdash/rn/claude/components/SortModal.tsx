import React, { useState, useEffect } from 'react';
import {
  Modal,
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
} from 'react-native';

export interface SortOptions {
  field: 'publishedAt' | 'recordingDate';
  order: 'desc' | 'asc';
}

interface SortModalProps {
  visible: boolean;
  onClose: () => void;
  onApply: (options: SortOptions) => void;
  sortOptions: SortOptions;
}

export default function SortModal({
  visible,
  onClose,
  onApply,
  sortOptions,
}: SortModalProps) {
  const [field, setField] = useState<SortOptions['field']>(sortOptions.field);
  const [order, setOrder] = useState<SortOptions['order']>(sortOptions.order);

  useEffect(() => {
    setField(sortOptions.field);
    setOrder(sortOptions.order);
  }, [sortOptions]);

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

  const fieldLabel = field === 'publishedAt' ? 'Published' : 'Recorded';
  const orderLabel = order === 'desc' ? 'Newest First' : 'Oldest First';

  return (
    <Modal
      visible={visible}
      animationType="slide"
      presentationStyle="pageSheet"
      onRequestClose={onClose}
    >
      <View style={styles.container}>
        <Text style={styles.header}>Sort Options</Text>

        <View style={styles.content}>
          <Text style={styles.sectionTitle}>Sort By</Text>
          {renderOption(
            'Publication Date',
            'When the video was uploaded to YouTube',
            field === 'publishedAt',
            () => setField('publishedAt')
          )}
          {renderOption(
            'Recording Date',
            'When the video was actually recorded',
            field === 'recordingDate',
            () => setField('recordingDate')
          )}

          <Text style={styles.sectionTitle}>Order</Text>
          {renderOption(
            'Newest First',
            'Most recent videos at the top',
            order === 'desc',
            () => setOrder('desc')
          )}
          {renderOption(
            'Oldest First',
            'Oldest videos at the top',
            order === 'asc',
            () => setOrder('asc')
          )}

          <View style={styles.preview}>
            <Text style={styles.previewTitle}>Current Selection</Text>
            <Text style={styles.previewText}>
              {fieldLabel}, {orderLabel}
            </Text>
          </View>
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
    marginTop: 16,
  },
  option: {
    padding: 16,
    borderRadius: 8,
    backgroundColor: '#f5f5f5',
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
    color: '#888',
    marginTop: 2,
  },
  optionDescSelected: {
    color: '#ddd',
  },
  preview: {
    marginTop: 24,
    padding: 16,
    backgroundColor: '#f0f4ff',
    borderRadius: 8,
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
    padding: 20,
    borderTopWidth: 1,
    borderTopColor: '#eee',
  },
  applyButton: {
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
