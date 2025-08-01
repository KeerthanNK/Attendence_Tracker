import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Check if user is logged in
  bool get isUserLoggedIn => _auth.currentUser != null;

  // Get auth instance
  FirebaseAuth get auth => _auth;

  // Add a new subject
  Future<void> addSubject(String subjectName) async {
    if (currentUserId == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('subjects')
        .add({
          'name': subjectName,
          'totalClasses': 0,
          'presentClasses': 0,
          'absentClasses': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  // Get all subjects for current user
  Stream<List<Map<String, dynamic>>> getSubjects() {
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('subjects')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'name': data['name'] ?? '',
              'totalClasses': data['totalClasses'] ?? 0,
              'presentClasses': data['presentClasses'] ?? 0,
              'absentClasses': data['absentClasses'] ?? 0,
            };
          }).toList();
        });
  }

  // Mark present for a subject
  Future<void> markPresent(String subjectId) async {
    if (currentUserId == null) throw Exception('User not logged in');

    final docRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('subjects')
        .doc(subjectId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (doc.exists) {
        final data = doc.data()!;
        transaction.update(docRef, {
          'totalClasses': (data['totalClasses'] ?? 0) + 1,
          'presentClasses': (data['presentClasses'] ?? 0) + 1,
        });
      }
    });
  }

  // Mark absent for a subject
  Future<void> markAbsent(String subjectId) async {
    if (currentUserId == null) throw Exception('User not logged in');

    final docRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('subjects')
        .doc(subjectId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (doc.exists) {
        final data = doc.data()!;
        transaction.update(docRef, {
          'totalClasses': (data['totalClasses'] ?? 0) + 1,
          'absentClasses': (data['absentClasses'] ?? 0) + 1,
        });
      }
    });
  }

  // Delete a subject
  Future<void> deleteSubject(String subjectId) async {
    if (currentUserId == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('subjects')
        .doc(subjectId)
        .delete();
  }

  // Update subject name
  Future<void> updateSubjectName(String subjectId, String newName) async {
    if (currentUserId == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('subjects')
        .doc(subjectId)
        .update({'name': newName});
  }

  // Reset attendance for a subject
  Future<void> resetAttendance(String subjectId) async {
    if (currentUserId == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('subjects')
        .doc(subjectId)
        .update({'totalClasses': 0, 'presentClasses': 0, 'absentClasses': 0});
  }
}
