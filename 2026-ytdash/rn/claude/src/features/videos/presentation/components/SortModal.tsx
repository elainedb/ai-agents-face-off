import React, { useState } from 'react';
import {
  Modal,
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  SafeAreaView,
} from 'react-native';

type SortBy = 'publishedDate' | 'recordingDate';
type SortOrder = 'ascending' | 'descending';

interface SortModalProps {
  visible: boolean;
  onClose: () => void;
  onApply: (sortBy: SortBy, sortOrder: SortOrder) => void;
  currentSortBy: SortBy;
  currentSortOrder: SortOrder;
}

export function SortModal({
  visible,
  onClose,
  onApply,
  currentSortBy,
  currentSortOrder,
}: SortModalProps) {
  const [sortBy, setSortBy] = useState<SortBy>(currentSortBy);
  const [sortOrder, setSortOrder] = useState<SortOrder>(currentSortOrder);

  const handleApply = () => {
    onApply(sortBy, sortOrder);
    onClose();
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
          <Text style={styles.headerTitle}>Sort</Text>
          <View style={{ width: 60 }} />
        </View>

        <View style={styles.content}>
          <Text style={styles.sectionTitle}>Sort By</Text>
          <TouchableOpacity
            style={[styles.option, sortBy === 'publishedDate' && styles.optionSelected]}
            onPress={() => setSortBy('publishedDate')}
          >
            <Text style={[styles.optionText, sortBy === 'publishedDate' && styles.optionTextSelected]}>
              Publication Date
            </Text>
            <Text style={[styles.optionDesc, sortBy === 'publishedDate' && styles.optionDescSelected]}>
              When the video was published on YouTube
            </Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.option, sortBy === 'recordingDate' && styles.optionSelected]}
            onPress={() => setSortBy('recordingDate')}
          >
            <Text style={[styles.optionText, sortBy === 'recordingDate' && styles.optionTextSelected]}>
              Recording Date
            </Text>
            <Text style={[styles.optionDesc, sortBy === 'recordingDate' && styles.optionDescSelected]}>
              When the video was recorded (falls back to publication date)
            </Text>
          </TouchableOpacity>

          <Text style={styles.sectionTitle}>Order</Text>
          <TouchableOpacity
            style={[styles.option, sortOrder === 'descending' && styles.optionSelected]}
            onPress={() => setSortOrder('descending')}
          >
            <Text style={[styles.optionText, sortOrder === 'descending' && styles.optionTextSelected]}>
              Newest First
            </Text>
            <Text style={[styles.optionDesc, sortOrder === 'descending' && styles.optionDescSelected]}>
              Most recent videos appear at the top
            </Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.option, sortOrder === 'ascending' && styles.optionSelected]}
            onPress={() => setSortOrder('ascending')}
          >
            <Text style={[styles.optionText, sortOrder === 'ascending' && styles.optionTextSelected]}>
              Oldest First
            </Text>
            <Text style={[styles.optionDesc, sortOrder === 'ascending' && styles.optionDescSelected]}>
              Oldest videos appear at the top
            </Text>
          </TouchableOpacity>

          <View style={styles.preview}>
            <Text style={styles.previewTitle}>Current Selection</Text>
            <Text style={styles.previewText}>
              {sortBy === 'publishedDate' ? 'Publication Date' : 'Recording Date'},{' '}
              {sortOrder === 'descending' ? 'Newest First' : 'Oldest First'}
            </Text>
          </View>
        </View>

        <View style={styles.footer}>
          <TouchableOpacity style={styles.applyButton} onPress={handleApply}>
            <Text style={styles.applyButtonText}>Apply Sort</Text>
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
    fontWeight: '500',
  },
  optionTextSelected: {
    color: '#fff',
  },
  optionDesc: {
    fontSize: 12,
    color: '#888',
    marginTop: 2,
  },
  optionDescSelected: {
    color: 'rgba(255,255,255,0.8)',
  },
  preview: {
    marginTop: 24,
    padding: 16,
    backgroundColor: '#f0f7ff',
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
    color: '#4285F4',
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
