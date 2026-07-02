import React from 'react';
import { StyleSheet, Text, View } from 'react-native';

export function EmptyView() {
  return (
    <View testID="empty_view" style={styles.container}>
      <Text>No videos found.</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
