import { Modal, Pressable, StyleSheet, Text, View } from 'react-native';
import { useEffect, useState } from 'react';

import { SortOptions } from '@/src/features/videos/presentation/stores/videos-store';

interface SortModalProps {
  visible: boolean;
  selectedSort: SortOptions;
  onClose: () => void;
  onApply: (sort: SortOptions) => void;
}

export function SortModal({ visible, selectedSort, onClose, onApply }: SortModalProps) {
  const [sortBy, setSortBy] = useState<SortOptions['sortBy']>(selectedSort.sortBy);
  const [sortOrder, setSortOrder] = useState<SortOptions['sortOrder']>(selectedSort.sortOrder);

  useEffect(() => {
    setSortBy(selectedSort.sortBy);
    setSortOrder(selectedSort.sortOrder);
  }, [selectedSort, visible]);

  const renderChoice = <T extends string>(
    label: string,
    description: string,
    value: T,
    selectedValue: T,
    onSelect: (next: T) => void,
  ) => (
    <Pressable
      key={label}
      onPress={() => onSelect(value)}
      style={[styles.choice, selectedValue === value && styles.choiceSelected]}>
      <Text style={[styles.choiceLabel, selectedValue === value && styles.choiceLabelSelected]}>
        {label}
      </Text>
      <Text
        style={[
          styles.choiceDescription,
          selectedValue === value && styles.choiceDescriptionSelected,
        ]}>
        {description}
      </Text>
    </Pressable>
  );

  return (
    <Modal visible={visible} animationType="slide" onRequestClose={onClose}>
      <View style={styles.container}>
        <Text style={styles.title}>Sort Videos</Text>
        <View style={styles.content}>
          <Text style={styles.sectionTitle}>Sort By</Text>
          {renderChoice(
            'Publication Date',
            'Sort using the YouTube publish date.',
            'publishedDate',
            sortBy,
            setSortBy,
          )}
          {renderChoice(
            'Recording Date',
            'Uses recording date when available, otherwise publication date.',
            'recordingDate',
            sortBy,
            setSortBy,
          )}

          <Text style={styles.sectionTitle}>Order</Text>
          {renderChoice('Newest First', 'Most recent videos first.', 'descending', sortOrder, setSortOrder)}
          {renderChoice('Oldest First', 'Earliest videos first.', 'ascending', sortOrder, setSortOrder)}

          <View style={styles.preview}>
            <Text style={styles.previewTitle}>Current Selection</Text>
            <Text style={styles.previewText}>
              {sortBy === 'publishedDate' ? 'Published date' : 'Recording date'} /{' '}
              {sortOrder === 'descending' ? 'Newest first' : 'Oldest first'}
            </Text>
          </View>
        </View>

        <View style={styles.footer}>
          <Pressable
            onPress={() => {
              onApply({ sortBy, sortOrder });
              onClose();
            }}
            style={styles.applyButton}>
            <Text style={styles.applyButtonText}>Apply Sort</Text>
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
    gap: 12,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#24384d',
    marginTop: 6,
  },
  choice: {
    borderRadius: 16,
    borderWidth: 1,
    borderColor: '#cad7e6',
    backgroundColor: '#fff',
    padding: 16,
    gap: 4,
  },
  choiceSelected: {
    borderColor: '#4285F4',
    backgroundColor: '#4285F4',
  },
  choiceLabel: {
    fontSize: 16,
    fontWeight: '700',
    color: '#15324f',
  },
  choiceLabelSelected: {
    color: '#fff',
  },
  choiceDescription: {
    color: '#51667d',
    fontSize: 13,
  },
  choiceDescriptionSelected: {
    color: '#e7f0ff',
  },
  preview: {
    marginTop: 14,
    backgroundColor: '#eef2f7',
    borderRadius: 16,
    padding: 16,
    gap: 6,
  },
  previewTitle: {
    color: '#15324f',
    fontWeight: '700',
  },
  previewText: {
    color: '#51667d',
  },
  footer: {
    marginTop: 'auto',
    backgroundColor: '#fff',
    padding: 20,
    borderTopWidth: 1,
    borderTopColor: '#dde5ef',
  },
  applyButton: {
    backgroundColor: '#4285F4',
    borderRadius: 14,
    paddingVertical: 14,
    alignItems: 'center',
  },
  applyButtonText: {
    color: '#fff',
    fontWeight: '700',
  },
});
