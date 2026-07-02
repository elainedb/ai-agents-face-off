import React from 'react';
import { ActivityIndicator, StyleSheet, View } from 'react-native';

export function LoadingView() {
  return (
    <View testID="loading_indicator" style={styles.container}>
      <ActivityIndicator size="large" />
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
