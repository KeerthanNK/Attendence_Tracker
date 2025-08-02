# Firebase Deployment Guide

## Fixing "Permission Missing" Error

The "permission missing" error occurs when Firestore security rules are not properly deployed or configured. Follow these steps to fix it:

### Step 1: Deploy Firestore Security Rules

1. **Go to Firebase Console**
   - Visit [https://console.firebase.google.com](https://console.firebase.google.com)
   - Select your project

2. **Navigate to Firestore Database**
   - Click on "Firestore Database" in the left sidebar
   - Click on the "Rules" tab

3. **Replace the Rules**
   - Copy the contents of `firestore_rules.txt` from this project
   - Replace the existing rules with the new ones
   - Click "Publish" to deploy the rules

### Step 2: Verify User Role

Make sure you are signed in as a **teacher**:

1. **Sign out** if you're currently signed in
2. **Sign up** as a teacher with a new email
3. **Or sign in** with an existing teacher account

### Step 3: Test the Connection

1. **Use the Debug Tool**
   - Click the bug icon (🐛) in the role selection page
   - This will test your Firebase connection and permissions
   - Look for any error messages

2. **Check the Test Results**
   - ✅ **Firebase Auth: Connected** - Authentication is working
   - ✅ **Firestore: Connected** - Database connection is working
   - ✅ **User Role: teacher** - You're signed in as a teacher
   - ✅ **Teacher subject creation: SUCCESS** - Permissions are correct

### Step 4: Common Issues and Solutions

#### Issue: "Permission denied" when creating subjects
**Solution:**
- Make sure you're signed in as a teacher
- Verify the Firestore rules are deployed
- Check that your user document has `role: 'teacher'`

#### Issue: "User document not found"
**Solution:**
- Sign up again as a teacher
- The user document should be created automatically

#### Issue: "Firestore rules not deployed"
**Solution:**
- Go to Firebase Console → Firestore Database → Rules
- Copy and paste the rules from `firestore_rules.txt`
- Click "Publish"

### Step 5: Manual User Role Check

If you're still having issues, manually check your user role:

1. **Go to Firebase Console**
2. **Navigate to Firestore Database**
3. **Look for the `users` collection**
4. **Find your user document**
5. **Verify it has `role: 'teacher'`**

If the role is missing or incorrect:
1. **Delete the user document**
2. **Sign up again as a teacher**
3. **The correct role should be set automatically**

### Step 6: Alternative Rules (if still having issues)

If the above doesn't work, try these temporary rules for testing:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow all access for testing (REMOVE IN PRODUCTION)
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**⚠️ WARNING:** These rules allow all authenticated users to read/write everything. Only use for testing and remove immediately after fixing the issue.

### Step 7: Verify the Fix

After deploying the correct rules:

1. **Sign in as a teacher**
2. **Try to add a subject**
3. **Should work without permission errors**

### Troubleshooting Checklist

- [ ] Firestore rules deployed from `firestore_rules.txt`
- [ ] Signed in as a teacher (not student)
- [ ] User document exists in Firestore with `role: 'teacher'`
- [ ] Internet connection is stable
- [ ] Firebase project is properly configured
- [ ] App is using the correct Firebase project

### Still Having Issues?

1. **Check the debug tool** (bug icon) for specific error messages
2. **Look at Firebase Console logs** for detailed error information
3. **Verify your Firebase configuration** in `lib/firebase_options.dart`
4. **Make sure you're using the correct Firebase project**

The most common cause is that the Firestore security rules haven't been deployed yet. Make sure to copy the rules from `firestore_rules.txt` and publish them in the Firebase Console. 