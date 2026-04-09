import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Modal,
  TouchableOpacity,
  SafeAreaView,
} from 'react-native';
import { SortOptions } from '../stores/videos-store';

interface SortModalProps {
  visible: boolean;
  onClose: () => void;
  currentSort: SortOptions;
  onApply: (sortBy: SortOptions['sortBy'], sortOrder: SortOptions['sortOrder']) => void;
}

export function SortModal({ visible, onClose, currentSort, onApply }: SortModalProps) {
  const [sortBy, setSortBy] = useState(currentSort.sortBy);
  const [sortOrder, setSortOrder] = useState(currentSort.sortOrder);

  useEffect(() => {
    setSortBy(currentSort.sortBy);
    setSortOrder(currentSort.sortOrder);
  }, [currentSort, visible]);

  const handleApply = () => {
    onApply(sortBy, sortOrder);
    onClose();
  };

  return (
    <Modal visible={visible} animationType="slide" presentationStyle="pageSheet">
      <SafeAreaView style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity onPress={onClose}>
            <Text style={styles.cancelText}>Cancel</Text>
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
            <Text
              style={[styles.optionText, sortBy === 'publishedDate' && styles.optionTextSelected]}
            >
              Publication Date
            </Text>
            <Text
              style={[styles.optionDesc, sortBy === 'publishedDate' && styles.optionDescSelected]}
            >
              When the video was published on YouTube
            </Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.option, sortBy === 'recordingDate' && styles.optionSelected]}
            onPress={() => setSortBy('recordingDate')}
          >
            <Text
              style={[styles.optionText, sortBy === 'recordingDate' && styles.optionTextSelected]}
            >
              Recording Date
            </Text>
            <Text
              style={[styles.optionDesc, sortBy === 'recordingDate' && styles.optionDescSelected]}
            >
              When the video was recorded (falls back to publication date)
            </Text>
          </TouchableOpacity>

          <Text style={[styles.sectionTitle, { marginTop: 24 }]}>Order</Text>
          <TouchableOpacity
            style={[styles.option, sortOrder === 'descending' && styles.optionSelected]}
            onPress={() => setSortOrder('descending')}
          >
            <Text
              style={[styles.optionText, sortOrder === 'descending' && styles.optionTextSelected]}
            >
              Newest First
            </Text>
            <Text
              style={[styles.optionDesc, sortOrder === 'descending' && styles.optionDescSelected]}
            >
              Most recent videos at the top
            </Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.option, sortOrder === 'ascending' && styles.optionSelected]}
            onPress={() => setSortOrder('ascending')}
          >
            <Text
              style={[styles.optionText, sortOrder === 'ascending' && styles.optionTextSelected]}
            >
              Oldest First
            </Text>
            <Text
              style={[styles.optionDesc, sortOrder === 'ascending' && styles.optionDescSelected]}
            >
              Oldest videos at the top
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
  optionDesc: {
    fontSize: 12,
    color: '#757575',
    marginTop: 2,
  },
  optionDescSelected: {
    color: '#e3f2fd',
  },
  preview: {
    marginTop: 24,
    padding: 12,
    backgroundColor: '#f5f5f5',
    borderRadius: 8,
  },
  previewTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: '#212121',
    marginBottom: 4,
  },
  previewText: {
    fontSize: 14,
    color: '#616161',
  },
  footer: {
    padding: 16,
    borderTopWidth: 1,
    borderTopColor: '#e0e0e0',
  },
  applyButton: {
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
