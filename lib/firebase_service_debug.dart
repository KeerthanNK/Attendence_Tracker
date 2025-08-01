import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServiceDebug {
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

    try {
      print('Adding subject: $subjectName for user: $currentUserId');
      
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
      
      print('Subject added successfully');
    } catch (e) {
      print('Error adding subject: $e');
      throw e;
    }
  }

  // Get all subjects for current user
  Stream<List<Map<String, dynamic>>> getSubjects() {
    if (currentUserId == null) return Stream.value([]);

    try {
      print('Getting subjects for user: $currentUserId');
      
      return _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('subjects')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            print('Received ${snapshot.docs.length} subjects');
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
    } catch (e) {
      print('Error getting subjects: $e');
      return Stream.error(e);
    }
  }

  // Mark present for a subject
  Future<void> markPresent(String subjectId) async {
    if (currentUserId == null) throw Exception('User not logged in');

    try {
      print('Marking present for subject: $subjectId, user: $currentUserId');
      
      final docRef = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('subjects')
          .doc(subjectId);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        print('Document exists: ${doc.exists}');
        
        if (doc.exists) {
          final data = doc.data()!;
          print('Current data: $data');
          
          final newTotal = (data['totalClasses'] ?? 0) + 1;
          final newPresent = (data['presentClasses'] ?? 0) + 1;
          
          print('Updating to total: $newTotal, present: $newPresent');
          
          transaction.update(docRef, {
            'totalClasses': newTotal,
            'presentClasses': newPresent,
          });
        } else {
          print('Document does not exist!');
          throw Exception('Subject document not found');
        }
      });
      
      print('Marked present successfully');
    } catch (e) {
      print('Error marking present: $e');
      throw e;
    }
  }

  // Mark absent for a subject
  Future<void> markAbsent(String subjectId) async {
    if (currentUserId == null) throw Exception('User not logged in');

    try {
      print('Marking absent for subject: $subjectId, user: $currentUserId');
      
      final docRef = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('subjects')
          .doc(subjectId);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        print('Document exists: ${doc.exists}');
        
        if (doc.exists) {
          final data = doc.data()!;
          print('Current data: $data');
          
          final newTotal = (data['totalClasses'] ?? 0) + 1;
          final newAbsent = (data['absentClasses'] ?? 0) + 1;
          
          print('Updating to total: $newTotal, absent: $newAbsent');
          
          transaction.update(docRef, {
            'totalClasses': newTotal,
            'absentClasses': newAbsent,
          });
        } else {
          print('Document does not exist!');
          throw Exception('Subject document not found');
        }
      });
      
      print('Marked absent successfully');
    } catch (e) {
      print('Error marking absent: $e');
      throw e;
    }
  }

  // Delete a subject
  Future<void> deleteSubject(String subjectId) async {
    if (currentUserId == null) throw Exception('User not logged in');

    try {
      print('Deleting subject: $subjectId for user: $currentUserId');
      
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('subjects')
          .doc(subjectId)
          .delete();
      
      print('Subject deleted successfully');
    } catch (e) {
      print('Error deleting subject: $e');
      throw e;
    }
  }

  // Update subject name
  Future<void> updateSubjectName(String subjectId, String newName) async {
    if (currentUserId == null) throw Exception('User not logged in');

    try {
      print('Updating subject name: $subjectId to $newName for user: $currentUserId');
      
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('subjects')
          .doc(subjectId)
          .update({'name': newName});
      
      print('Subject name updated successfully');
    } catch (e) {
      print('Error updating subject name: $e');
      throw e;
    }
  }

  // Reset attendance for a subject
  Future<void> resetAttendance(String subjectId) async {
    if (currentUserId == null) throw Exception('User not logged in');

    try {
      print('Resetting attendance for subject: $subjectId for user: $currentUserId');
      
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('subjects')
          .doc(subjectId)
          .update({'totalClasses': 0, 'presentClasses': 0, 'absentClasses': 0});
      
      print('Attendance reset successfully');
    } catch (e) {
      print('Error resetting attendance: $e');
      throw e;
    }
  }
} 