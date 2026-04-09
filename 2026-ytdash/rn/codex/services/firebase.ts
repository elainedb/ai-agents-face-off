import firebase from '@react-native-firebase/app';
import auth from '@react-native-firebase/auth';
import perf from '@react-native-firebase/perf';

// Firebase is auto-initialized by @react-native-firebase using
// google-services.json (Android) and GoogleService-Info.plist (iOS).
// This module re-exports the initialized instances for convenience.

export { firebase, auth, perf };
export default firebase;
