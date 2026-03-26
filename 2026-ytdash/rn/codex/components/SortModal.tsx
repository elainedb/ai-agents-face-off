import { useEffect, useState } from 'react';
import { Modal, Pressable, StyleSheet, Text, View } from 'react-native';

export type SortOptions = {
  field: 'published' | 'recorded';
  order: 'asc' | 'desc';
};

type Props = {
  initialSort: SortOptions;
  onApply: (sort: SortOptions) => void;
  onClose: () => void;
  visible: boolean;
};

export default function SortModal({ initialSort, onApply, onClose, visible }: Props) {
  const [localSort, setLocalSort] = useState(initialSort);

  useEffect(() => {
    setLocalSort(initialSort);
  }, [initialSort, visible]);

  return (
    <Modal animationType="slide" presentationStyle="pageSheet" visible={visible}>
      <View style={styles.container}>
        <Text style={styles.title}>Sort Videos</Text>

        <Text style={styles.sectionTitle}>Sort By</Text>
        <SortOption
          description="Uses each video's publish timestamp."
          label="Publication Date"
          onPress={() => setLocalSort((current) => ({ ...current, field: 'published' }))}
          selected={localSort.field === 'published'}
        />
        <SortOption
          description="Falls back to publish date when recording date is missing."
          label="Recording Date"
          onPress={() => setLocalSort((current) => ({ ...current, field: 'recorded' }))}
          selected={localSort.field === 'recorded'}
        />

        <Text style={styles.sectionTitle}>Order</Text>
        <SortOption
          description="Newest videos first."
          label="Newest First"
          onPress={() => setLocalSort((current) => ({ ...current, order: 'desc' }))}
          selected={localSort.order === 'desc'}
        />
        <SortOption
          description="Oldest videos first."
          label="Oldest First"
          onPress={() => setLocalSort((current) => ({ ...current, order: 'asc' }))}
          selected={localSort.order === 'asc'}
        />

        <View style={styles.previewBox}>
          <Text style={styles.previewTitle}>Current Selection</Text>
          <Text style={styles.previewText}>
            {localSort.field === 'published' ? 'Publication Date' : 'Recording Date'} ·{' '}
            {localSort.order === 'desc' ? 'Newest First' : 'Oldest First'}
          </Text>
        </View>

        <Pressable onPress={() => onApply(localSort)} style={styles.applyButton}>
          <Text style={styles.applyText}>Apply Sort</Text>
        </Pressable>
        <Pressable onPress={onClose} style={styles.closeButton}>
          <Text style={styles.closeText}>Close</Text>
        </Pressable>
      </View>
    </Modal>
  );
}

type SortOptionProps = {
  description: string;
  label: string;
  onPress: () => void;
  selected: boolean;
};

function SortOption({ description, label, onPress, selected }: SortOptionProps) {
  return (
    <Pressable onPress={onPress} style={[styles.option, selected && styles.optionSelected]}>
      <Text style={[styles.optionLabel, selected && styles.optionLabelSelected]}>{label}</Text>
      <Text style={[styles.optionDescription, selected && styles.optionLabelSelected]}>{description}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#f7f9fc',
    flex: 1,
    paddingHorizontal: 20,
    paddingTop: 60,
  },
  title: {
    color: '#14213d',
    fontSize: 24,
    fontWeight: '700',
    marginBottom: 20,
  },
  sectionTitle: {
    color: '#22304a',
    fontSize: 18,
    fontWeight: '700',
    marginBottom: 10,
    marginTop: 12,
  },
  option: {
    backgroundColor: '#e7ecf3',
    borderRadius: 12,
    marginBottom: 10,
    padding: 14,
  },
  optionSelected: {
    backgroundColor: '#4285F4',
  },
  optionLabel: {
    color: '#22304a',
    fontSize: 15,
    fontWeight: '700',
    marginBottom: 4,
  },
  optionLabelSelected: {
    color: '#ffffff',
  },
  optionDescription: {
    color: '#52627a',
    fontSize: 13,
  },
  previewBox: {
    backgroundColor: '#ffffff',
    borderRadius: 14,
    marginTop: 16,
    padding: 16,
  },
  previewTitle: {
    color: '#22304a',
    fontWeight: '700',
    marginBottom: 6,
  },
  previewText: {
    color: '#52627a',
  },
  applyButton: {
    alignItems: 'center',
    backgroundColor: '#4285F4',
    borderRadius: 12,
    marginTop: 24,
    paddingVertical: 14,
  },
  applyText: {
    color: '#ffffff',
    fontWeight: '700',
  },
  closeButton: {
    alignItems: 'center',
    marginTop: 16,
  },
  closeText: {
    color: '#52627a',
    fontWeight: '600',
  },
});
