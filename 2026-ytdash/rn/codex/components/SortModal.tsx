import { useEffect, useState } from 'react';
import { Modal, StyleSheet, Text, TouchableOpacity, View } from 'react-native';

export type SortOptions = {
  field: 'published' | 'recorded';
  order: 'asc' | 'desc';
};

type SortModalProps = {
  visible: boolean;
  sortOptions: SortOptions;
  onApply: (sortOptions: SortOptions) => void;
  onClose: () => void;
};

function SelectionCard({
  active,
  description,
  label,
  onPress,
}: {
  active: boolean;
  description: string;
  label: string;
  onPress: () => void;
}) {
  return (
    <TouchableOpacity onPress={onPress} style={[styles.selectionCard, active && styles.selectionCardActive]}>
      <Text style={[styles.selectionTitle, active && styles.selectionTitleActive]}>{label}</Text>
      <Text style={[styles.selectionDescription, active && styles.selectionDescriptionActive]}>{description}</Text>
    </TouchableOpacity>
  );
}

export function SortModal({ onApply, onClose, sortOptions, visible }: SortModalProps) {
  const [draftSort, setDraftSort] = useState(sortOptions);

  useEffect(() => {
    setDraftSort(sortOptions);
  }, [sortOptions, visible]);

  return (
    <Modal animationType="slide" transparent={false} visible={visible}>
      <View style={styles.container}>
        <Text style={styles.title}>Sort Videos</Text>

        <Text style={styles.sectionTitle}>Sort By</Text>
        <SelectionCard
          active={draftSort.field === 'published'}
          description="Uses the YouTube publication date."
          label="Publication Date"
          onPress={() => setDraftSort((current) => ({ ...current, field: 'published' }))}
        />
        <SelectionCard
          active={draftSort.field === 'recorded'}
          description="Uses recording date when available, else publication date."
          label="Recording Date"
          onPress={() => setDraftSort((current) => ({ ...current, field: 'recorded' }))}
        />

        <Text style={styles.sectionTitle}>Order</Text>
        <SelectionCard
          active={draftSort.order === 'desc'}
          description="Newest videos first."
          label="Newest First"
          onPress={() => setDraftSort((current) => ({ ...current, order: 'desc' }))}
        />
        <SelectionCard
          active={draftSort.order === 'asc'}
          description="Oldest videos first."
          label="Oldest First"
          onPress={() => setDraftSort((current) => ({ ...current, order: 'asc' }))}
        />

        <View style={styles.previewBox}>
          <Text style={styles.previewLabel}>Current Selection</Text>
          <Text style={styles.previewText}>
            {draftSort.field === 'published' ? 'Publication Date' : 'Recording Date'} /{' '}
            {draftSort.order === 'desc' ? 'Newest First' : 'Oldest First'}
          </Text>
        </View>

        <TouchableOpacity
          onPress={() => {
            onApply(draftSort);
            onClose();
          }}
          style={styles.applyButton}>
          <Text style={styles.applyText}>Apply Sort</Text>
        </TouchableOpacity>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#ffffff',
    flex: 1,
    padding: 20,
    paddingTop: 28,
  },
  title: {
    color: '#111827',
    fontSize: 24,
    fontWeight: '700',
  },
  sectionTitle: {
    color: '#111827',
    fontSize: 18,
    fontWeight: '700',
    marginBottom: 12,
    marginTop: 24,
  },
  selectionCard: {
    backgroundColor: '#f3f4f6',
    borderRadius: 16,
    marginBottom: 12,
    padding: 16,
  },
  selectionCardActive: {
    backgroundColor: '#dbeafe',
    borderColor: '#4285F4',
    borderWidth: 1,
  },
  selectionTitle: {
    color: '#111827',
    fontSize: 16,
    fontWeight: '700',
  },
  selectionTitleActive: {
    color: '#1d4ed8',
  },
  selectionDescription: {
    color: '#6b7280',
    marginTop: 6,
  },
  selectionDescriptionActive: {
    color: '#1e40af',
  },
  previewBox: {
    backgroundColor: '#eff6ff',
    borderRadius: 16,
    marginTop: 12,
    padding: 16,
  },
  previewLabel: {
    color: '#1d4ed8',
    fontSize: 13,
    fontWeight: '700',
    marginBottom: 6,
    textTransform: 'uppercase',
  },
  previewText: {
    color: '#111827',
    fontSize: 16,
    fontWeight: '600',
  },
  applyButton: {
    alignItems: 'center',
    backgroundColor: '#4285F4',
    borderRadius: 14,
    marginTop: 'auto',
    paddingVertical: 16,
  },
  applyText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '700',
  },
});
