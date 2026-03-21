import React, { useState } from 'react';
import {
  View,
  Text,
  Modal,
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
  onApply: (sort: SortOptions) => void;
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

  const fieldLabel = field === 'publishedAt' ? 'Publication Date' : 'Recording Date';
  const orderLabel = order === 'newest' ? 'Newest First' : 'Oldest First';

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

          <TouchableOpacity
            style={[styles.option, field === 'publishedAt' && styles.optionSelected]}
            onPress={() => setField('publishedAt')}
          >
            <Text style={[styles.optionText, field === 'publishedAt' && styles.optionTextSelected]}>
              Publication Date
            </Text>
            <Text style={[styles.optionDesc, field === 'publishedAt' && styles.optionDescSelected]}>
              When the video was published on YouTube
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.option, field === 'recordingDate' && styles.optionSelected]}
            onPress={() => setField('recordingDate')}
          >
            <Text style={[styles.optionText, field === 'recordingDate' && styles.optionTextSelected]}>
              Recording Date
            </Text>
            <Text style={[styles.optionDesc, field === 'recordingDate' && styles.optionDescSelected]}>
              When the video was originally recorded
            </Text>
          </TouchableOpacity>

          <Text style={styles.sectionTitle}>Order</Text>

          <TouchableOpacity
            style={[styles.option, order === 'newest' && styles.optionSelected]}
            onPress={() => setOrder('newest')}
          >
            <Text style={[styles.optionText, order === 'newest' && styles.optionTextSelected]}>
              Newest First
            </Text>
            <Text style={[styles.optionDesc, order === 'newest' && styles.optionDescSelected]}>
              Most recent videos at the top
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.option, order === 'oldest' && styles.optionSelected]}
            onPress={() => setOrder('oldest')}
          >
            <Text style={[styles.optionText, order === 'oldest' && styles.optionTextSelected]}>
              Oldest First
            </Text>
            <Text style={[styles.optionDesc, order === 'oldest' && styles.optionDescSelected]}>
              Oldest videos at the top
            </Text>
          </TouchableOpacity>

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
    marginBottom: 8,
  },
  optionSelected: {
    backgroundColor: '#4285F4',
  },
  optionText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
  },
  optionTextSelected: {
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
    padding: 16,
    backgroundColor: '#f5f5f5',
    borderRadius: 8,
  },
  previewTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
    marginBottom: 4,
  },
  previewText: {
    fontSize: 14,
    color: '#666',
  },
  footer: {
    padding: 16,
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
    fontSize: 16,
    color: '#fff',
    fontWeight: '600',
  },
});
