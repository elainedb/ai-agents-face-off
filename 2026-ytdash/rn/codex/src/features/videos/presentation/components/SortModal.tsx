import { Modal, Pressable, StyleSheet, Text, View } from 'react-native';

import type { SortField, SortOrder, SortOptions } from '@/src/features/videos/presentation/stores/videos-store';

interface SortModalProps {
  visible: boolean;
  sortOptions: SortOptions;
  onClose: () => void;
  onApply: (sortBy: SortField, sortOrder: SortOrder) => void;
}

const Option = ({
  title,
  description,
  selected,
  onPress,
}: {
  title: string;
  description: string;
  selected: boolean;
  onPress: () => void;
}) => (
  <Pressable style={[styles.option, selected && styles.optionSelected]} onPress={onPress}>
    <Text style={[styles.optionTitle, selected && styles.optionTitleSelected]}>{title}</Text>
    <Text style={[styles.optionDescription, selected && styles.optionDescriptionSelected]}>
      {description}
    </Text>
  </Pressable>
);

export function SortModal({ visible, sortOptions, onClose, onApply }: SortModalProps) {
  return (
    <Modal animationType="slide" presentationStyle="pageSheet" visible={visible} onRequestClose={onClose}>
      <View style={styles.container}>
        <Text style={styles.title}>Sort Videos</Text>
        <Text style={styles.sectionTitle}>Sort By</Text>
        <Option
          title="Publication Date"
          description="Use the YouTube publish timestamp."
          selected={sortOptions.sortBy === 'publishedAt'}
          onPress={() => onApply('publishedAt', sortOptions.sortOrder)}
        />
        <Option
          title="Recording Date"
          description="Use recording date and fall back to publication date."
          selected={sortOptions.sortBy === 'recordingDate'}
          onPress={() => onApply('recordingDate', sortOptions.sortOrder)}
        />

        <Text style={styles.sectionTitle}>Order</Text>
        <Option
          title="Newest First"
          description="Most recent videos at the top."
          selected={sortOptions.sortOrder === 'desc'}
          onPress={() => onApply(sortOptions.sortBy, 'desc')}
        />
        <Option
          title="Oldest First"
          description="Earliest videos at the top."
          selected={sortOptions.sortOrder === 'asc'}
          onPress={() => onApply(sortOptions.sortBy, 'asc')}
        />

        <View style={styles.preview}>
          <Text style={styles.previewLabel}>Current Selection</Text>
          <Text style={styles.previewText}>
            {sortOptions.sortBy === 'publishedAt' ? 'Published' : 'Recorded'} /{' '}
            {sortOptions.sortOrder === 'desc' ? 'Newest First' : 'Oldest First'}
          </Text>
        </View>

        <Pressable style={styles.applyButton} onPress={onClose}>
          <Text style={styles.applyButtonText}>Apply Sort</Text>
        </Pressable>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F4F7FB',
    paddingTop: 56,
    paddingHorizontal: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: '800',
    color: '#14213D',
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#14213D',
    marginBottom: 12,
    marginTop: 8,
  },
  option: {
    borderRadius: 18,
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: '#D8E2F0',
    padding: 16,
    marginBottom: 12,
  },
  optionSelected: {
    backgroundColor: '#4285F4',
    borderColor: '#4285F4',
  },
  optionTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: '#14213D',
  },
  optionTitleSelected: {
    color: '#FFFFFF',
  },
  optionDescription: {
    marginTop: 6,
    color: '#51627F',
  },
  optionDescriptionSelected: {
    color: '#EAF2FF',
  },
  preview: {
    marginTop: 24,
    borderRadius: 18,
    backgroundColor: '#14213D',
    padding: 18,
  },
  previewLabel: {
    color: '#A7B9D4',
    fontSize: 12,
    fontWeight: '700',
    textTransform: 'uppercase',
  },
  previewText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '700',
    marginTop: 6,
  },
  applyButton: {
    marginTop: 'auto',
    marginBottom: 32,
    borderRadius: 18,
    backgroundColor: '#4285F4',
    paddingVertical: 16,
    alignItems: 'center',
  },
  applyButtonText: {
    color: '#FFFFFF',
    fontWeight: '700',
    fontSize: 16,
  },
});
