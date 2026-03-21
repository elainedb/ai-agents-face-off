import firebase from '@react-native-firebase/app';
import auth from '@react-native-firebase/auth';

// Firebase is auto-initialized by @react-native-firebase using
// google-services.json (Android) and GoogleService-Info.plist (iOS).
// This module re-exports the initialized instances for convenience.

export { firebase, auth };
export default firebase;
