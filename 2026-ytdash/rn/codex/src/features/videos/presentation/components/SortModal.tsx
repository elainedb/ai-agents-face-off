import { useEffect, useState } from 'react';
import { Modal, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';

import type { SortOptions } from '@/src/features/videos/presentation/stores/videos-store';

interface SortModalProps {
  visible: boolean;
  sortOptions: SortOptions;
  onClose: () => void;
  onApply: (sortBy: SortOptions['sortBy'], sortOrder: SortOptions['sortOrder']) => void;
}

function SortOption({
  title,
  description,
  selected,
  onPress,
}: {
  title: string;
  description: string;
  selected: boolean;
  onPress: () => void;
}) {
  return (
    <Pressable style={[styles.option, selected && styles.selectedOption]} onPress={onPress}>
      <Text style={[styles.optionTitle, selected && styles.selectedText]}>{title}</Text>
      <Text style={[styles.optionDescription, selected && styles.selectedText]}>{description}</Text>
    </Pressable>
  );
}

export function SortModal({ visible, sortOptions, onClose, onApply }: SortModalProps) {
  const [localSort, setLocalSort] = useState<SortOptions>(sortOptions);

  useEffect(() => {
    setLocalSort(sortOptions);
  }, [sortOptions, visible]);

  return (
    <Modal animationType="slide" presentationStyle="pageSheet" visible={visible}>
      <View style={styles.container}>
        <Text style={styles.title}>Sort Videos</Text>
        <ScrollView contentContainerStyle={styles.content}>
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Sort By</Text>
            <SortOption
              title="Publication Date"
              description="Use the YouTube publish date."
              selected={localSort.sortBy === 'publishedDate'}
              onPress={() => setLocalSort((current) => ({ ...current, sortBy: 'publishedDate' }))}
            />
            <SortOption
              title="Recording Date"
              description="Falls back to publication date when missing."
              selected={localSort.sortBy === 'recordingDate'}
              onPress={() => setLocalSort((current) => ({ ...current, sortBy: 'recordingDate' }))}
            />
          </View>
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Order</Text>
            <SortOption
              title="Newest First"
              description="Descending dates."
              selected={localSort.sortOrder === 'descending'}
              onPress={() => setLocalSort((current) => ({ ...current, sortOrder: 'descending' }))}
            />
            <SortOption
              title="Oldest First"
              description="Ascending dates."
              selected={localSort.sortOrder === 'ascending'}
              onPress={() => setLocalSort((current) => ({ ...current, sortOrder: 'ascending' }))}
            />
          </View>
          <View style={styles.preview}>
            <Text style={styles.sectionTitle}>Current Selection</Text>
            <Text style={styles.previewText}>
              {localSort.sortBy === 'publishedDate' ? 'Publication Date' : 'Recording Date'} /
              {' '}
              {localSort.sortOrder === 'descending' ? 'Newest First' : 'Oldest First'}
            </Text>
          </View>
        </ScrollView>
        <View style={styles.footer}>
          <Pressable
            style={styles.applyButton}
            onPress={() => {
              onApply(localSort.sortBy, localSort.sortOrder);
              onClose();
            }}>
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
    backgroundColor: '#f6f8ff',
    paddingTop: 24,
  },
  title: {
    fontSize: 28,
    fontWeight: '800',
    color: '#13203a',
    paddingHorizontal: 20,
  },
  content: {
    padding: 20,
    gap: 24,
  },
  section: {
    gap: 12,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#20304f',
  },
  option: {
    borderRadius: 16,
    padding: 16,
    backgroundColor: '#e8eefc',
    gap: 4,
  },
  selectedOption: {
    backgroundColor: '#4285F4',
  },
  optionTitle: {
    fontWeight: '700',
    color: '#22324f',
  },
  optionDescription: {
    color: '#50607f',
  },
  selectedText: {
    color: '#ffffff',
  },
  preview: {
    backgroundColor: '#ffffff',
    borderRadius: 16,
    padding: 16,
    gap: 8,
  },
  previewText: {
    color: '#455778',
    fontWeight: '600',
  },
  footer: {
    padding: 20,
  },
  applyButton: {
    borderRadius: 16,
    paddingVertical: 16,
    alignItems: 'center',
    backgroundColor: '#4285F4',
  },
  applyButtonText: {
    color: '#ffffff',
    fontWeight: '700',
  },
});
