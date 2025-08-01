# Firebase Web Setup for Attendance Tracker

This document describes the Firebase web configuration that has been added to the Flutter project.

## Configuration Files

### 1. `web/firebase_config.js`
This file contains the Firebase web SDK configuration with the following services:
- Firebase App initialization
- Firebase Analytics
- Firebase Authentication
- Firebase Firestore

### 2. `web/index.html`
Updated to include the Firebase SDK script that loads the configuration.

### 3. `pubspec.yaml`
Added Firebase Analytics dependency for web support.

## Firebase Configuration

The Firebase project is configured with the following details:
- **Project ID**: student-tracker-f829a
- **Web App ID**: 1:103907075856:web:e95ce5b7e499c3152ae795
- **API Key**: AIzaSyBZGyVhnJsw5__ncSlxzginU26i6Dsjggc
- **Auth Domain**: student-tracker-f829a.firebaseapp.com
- **Storage Bucket**: student-tracker-f829a.firebasestorage.app
- **Messaging Sender ID**: 103907075856
- **Measurement ID**: G-TRH84FM7L6

## Testing Firebase Web

A test page has been created at `web/firebase_test.html` that you can use to verify:
- Firebase App initialization
- Firebase Analytics setup
- Firebase Auth setup
- Firebase Firestore setup

To test the web configuration:
1. Run `flutter run -d chrome`
2. Navigate to `http://localhost:8080/firebase_test.html`

## Running the Web App

To run the Flutter web app with Firebase:

```bash
flutter run -d chrome --web-port 8080
```

## Dependencies

The following Firebase dependencies have been added:
- `firebase_core: ^4.0.0`
- `firebase_auth: ^6.0.0`
- `cloud_firestore: ^6.0.0`
- `firebase_analytics: ^12.0.0`

## Features

The Firebase web setup provides:
- ✅ Firebase App initialization
- ✅ Firebase Analytics for web tracking
- ✅ Firebase Authentication for user management
- ✅ Firebase Firestore for data storage
- ✅ Cross-platform compatibility (web, mobile)

## Security Rules

Make sure to configure appropriate Firebase Security Rules in the Firebase Console for:
- Firestore Database
- Authentication
- Storage (if used)

## Troubleshooting

If you encounter issues:
1. Check the browser console for JavaScript errors
2. Verify the Firebase configuration in `web/firebase_config.js`
3. Ensure all dependencies are installed with `flutter pub get`
4. Test with the provided test page at `web/firebase_test.html` 