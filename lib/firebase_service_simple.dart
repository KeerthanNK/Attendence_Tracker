import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServiceSimple {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Get current user's role from Firestore
  Future<String?> getUserRole() async {
    try {
      final user = auth.currentUser;
      if (user == null) return null;

      final userDoc = await firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        return userDoc.data()?['role'] as String?;
      }
      return null;
    } catch (e) {
      print("Error getting user role: $e");
      return null;
    }
  }

  // Create user with role in Firestore
  Future<void> createUserWithRole(String email, String password, String role) async {
    try {
      // Create Firebase Auth user
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user data with role in Firestore
      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("User created with role: $role");
    } catch (e) {
      print("Error creating user with role: $e");
      rethrow;
    }
  }

  // Sign in and verify role
  Future<bool> signInWithRoleVerification(String email, String password, String expectedRole) async {
    try {
      // Sign in with Firebase Auth
      await auth.signInWithEmailAndPassword(email: email, password: password);
      
      // Get user's actual role from Firestore
      final actualRole = await getUserRole();
      
      if (actualRole == null) {
        // If no role found, sign out and throw error
        await auth.signOut();
        throw Exception("User account not properly configured");
      }
      
      if (actualRole != expectedRole) {
        // If role doesn't match, sign out and throw error
        await auth.signOut();
        throw Exception("Invalid role. Expected $expectedRole but found $actualRole");
      }
      
      print("User signed in successfully with role: $actualRole");
      return true;
    } catch (e) {
      print("Error signing in with role verification: $e");
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getSubjects() {
    final user = auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('subjects')
        .snapshots()
        .map((snapshot) {
      print("Getting subjects for user: ${user.uid}");
      final subjects = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'present': data['present'] ?? 0,
          'absent': data['absent'] ?? 0,
        };
      }).toList();
      print("Received ${subjects.length} subjects");
      return subjects;
    });
  }

  Future<void> addSubject(String name) async {
    final user = auth.currentUser;
    if (user == null) throw Exception("User not authenticated");

    try {
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('subjects')
          .add({
        'name': name,
        'present': 0,
        'absent': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("Subject added: $name");
    } catch (e) {
      print("Error adding subject: $e");
      rethrow;
    }
  }

  Future<void> markPresent(String subjectId) async {
    final user = auth.currentUser;
    if (user == null) throw Exception("User not authenticated");

    try {
      final docRef = firestore
          .collection('users')
          .doc(user.uid)
          .collection('subjects')
          .doc(subjectId);

      final doc = await docRef.get();
      if (!doc.exists) throw Exception("Subject not found");

      final currentPresent = doc.data()?['present'] ?? 0;
      await docRef.update({'present': currentPresent + 1});
      print("Marked present for subject: $subjectId");
    } catch (e) {
      print("Error marking present: $e");
      rethrow;
    }
  }

  Future<void> markAbsent(String subjectId) async {
    final user = auth.currentUser;
    if (user == null) throw Exception("User not authenticated");

    try {
      final docRef = firestore
          .collection('users')
          .doc(user.uid)
          .collection('subjects')
          .doc(subjectId);

      final doc = await docRef.get();
      if (!doc.exists) throw Exception("Subject not found");

      final currentAbsent = doc.data()?['absent'] ?? 0;
      await docRef.update({'absent': currentAbsent + 1});
      print("Marked absent for subject: $subjectId");
    } catch (e) {
      print("Error marking absent: $e");
      rethrow;
    }
  }

  Future<void> deleteSubject(String subjectId) async {
    final user = auth.currentUser;
    if (user == null) throw Exception("User not authenticated");

    try {
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('subjects')
          .doc(subjectId)
          .delete();
      print("Subject deleted: $subjectId");
    } catch (e) {
      print("Error deleting subject: $e");
      rethrow;
    }
  }

  Future<void> updateSubject(String subjectId, String newName) async {
    final user = auth.currentUser;
    if (user == null) throw Exception("User not authenticated");

    try {
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('subjects')
          .doc(subjectId)
          .update({'name': newName});
      print("Subject updated: $subjectId");
    } catch (e) {
      print("Error updating subject: $e");
      rethrow;
    }
  }

  Future<void> resetSubject(String subjectId) async {
    final user = auth.currentUser;
    if (user == null) throw Exception("User not authenticated");

    try {
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('subjects')
          .doc(subjectId)
          .update({
        'present': 0,
        'absent': 0,
      });
      print("Subject reset: $subjectId");
    } catch (e) {
      print("Error resetting subject: $e");
      rethrow;
    }
  }
}
