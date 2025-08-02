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
  Future<void> createUserWithRole(
    String email,
    String password,
    String role,
  ) async {
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
  Future<bool> signInWithRoleVerification(
    String email,
    String password,
    String expectedRole,
  ) async {
    try {
      // Sign in with Firebase Auth
      await auth.signInWithEmailAndPassword(email: email, password: password);

      // Get user's actual role from Firestore
      final actualRole = await getUserRole();

      // If no role found, create the user document with the expected role
      if (actualRole == null) {
        final user = auth.currentUser;
        if (user != null) {
          await firestore.collection('users').doc(user.uid).set({
            'email': email,
            'role': expectedRole,
            'createdAt': FieldValue.serverTimestamp(),
          });
          print("Created user document with role: $expectedRole");
          return true;
        }
      }

      // If role doesn't match, sign out and throw error
      if (actualRole != null && actualRole != expectedRole) {
        await auth.signOut();
        throw Exception(
          "Invalid role. Expected $expectedRole but found $actualRole",
        );
      }

      print(
        "User signed in successfully with role: ${actualRole ?? expectedRole}",
      );
      return true;
    } catch (e) {
      print("Error signing in with role verification: $e");
      rethrow;
    }
  }

  // Get teacher's subjects
  Stream<List<Map<String, dynamic>>> getTeacherSubjects() {
    final user = auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return firestore
        .collection('teacherSubjects')
        .where('teacherId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          print("Getting teacher subjects for user: ${user.uid}");
          final subjects =
              snapshot.docs.map((doc) {
                final data = doc.data();
                return {
                  'id': doc.id,
                  'name': data['name'] ?? '',
                  'teacherId': data['teacherId'] ?? '',
                  'createdAt': data['createdAt'],
                };
              }).toList();
          print("Received ${subjects.length} teacher subjects");
          return subjects;
        });
  }

  // Add teacher subject
  Future<void> addTeacherSubject(String name) async {
    final user = auth.currentUser;
    if (user == null) throw Exception("User not authenticated");

    try {
      await firestore.collection('teacherSubjects').add({
        'name': name,
        'teacherId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("Teacher subject added: $name");
    } catch (e) {
      print("Error adding teacher subject: $e");
      rethrow;
    }
  }

  // Get students enrolled in a specific subject
  Stream<List<Map<String, dynamic>>> getEnrolledStudents(String subjectId) {
    return firestore
        .collection('teacherSubjects')
        .doc(subjectId)
        .collection('enrolledStudents')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'studentId': data['studentId'] ?? '',
              'studentEmail': data['studentEmail'] ?? '',
              'studentName': data['studentName'] ?? '',
              'enrolledAt': data['enrolledAt'],
            };
          }).toList();
        });
  }

  // Enroll student in a subject
  Future<void> enrollStudentInSubject(
    String subjectId,
    String studentEmail,
  ) async {
    final user = auth.currentUser;
    if (user == null) throw Exception("Teacher not authenticated");

    print("DEBUG: Starting enrollment process");
    print("DEBUG: Teacher UID: ${user.uid}");
    print("DEBUG: Subject ID: $subjectId");
    print("DEBUG: Student Email: $studentEmail");

    try {
      // First, find the student by email
      print("DEBUG: Searching for student with email: $studentEmail");
      final studentsQuery =
          await firestore
              .collection('users')
              .where('email', isEqualTo: studentEmail)
              .where('role', isEqualTo: 'student')
              .get();

      print(
        "DEBUG: Found ${studentsQuery.docs.length} students with this email",
      );

      if (studentsQuery.docs.isEmpty) {
        throw Exception(
          "Student with email $studentEmail not found or not registered as student",
        );
      }

      final studentDoc = studentsQuery.docs.first;
      final studentId = studentDoc.id;
      final studentData = studentDoc.data();

      print(
        "DEBUG: Student found - ID: $studentId, Name: ${studentData['name']}",
      );

      // Check if student is already enrolled
      print("DEBUG: Checking if student is already enrolled");
      final existingEnrollment =
          await firestore
              .collection('teacherSubjects')
              .doc(subjectId)
              .collection('enrolledStudents')
              .where('studentId', isEqualTo: studentId)
              .get();

      print(
        "DEBUG: Found ${existingEnrollment.docs.length} existing enrollments",
      );

      if (existingEnrollment.docs.isNotEmpty) {
        throw Exception("Student is already enrolled in this subject");
      }

      // Enroll the student
      print(
        "DEBUG: Attempting to add student to enrolledStudents subcollection",
      );
      await firestore
          .collection('teacherSubjects')
          .doc(subjectId)
          .collection('enrolledStudents')
          .add({
            'studentId': studentId,
            'studentEmail': studentEmail,
            'studentName': studentData['name'] ?? studentEmail.split('@')[0],
            'enrolledAt': FieldValue.serverTimestamp(),
          });

      print("DEBUG: Student enrolled successfully");
      print("Student enrolled in subject: $studentEmail in subject $subjectId");
    } catch (e) {
      print("DEBUG: Error occurred during enrollment: $e");
      print("Error enrolling student: $e");
      rethrow;
    }
  }

  // Mark attendance for enrolled students
  Future<void> markEnrolledStudentAttendance(
    String subjectId,
    String studentId,
    String status,
  ) async {
    final teacher = auth.currentUser;
    if (teacher == null) throw Exception("Teacher not authenticated");

    try {
      // Get teacher name
      final teacherDoc =
          await firestore.collection('users').doc(teacher.uid).get();
      final teacherName =
          teacherDoc.data()?['name'] ??
          teacher.email?.split('@')[0] ??
          'Unknown Teacher';

      // Get subject name
      final subjectDoc =
          await firestore.collection('teacherSubjects').doc(subjectId).get();
      final subjectName = subjectDoc.data()?['name'] ?? 'Unknown Subject';

      await firestore.collection('teacherAttendance').add({
        'studentId': studentId,
        'teacherId': teacher.uid,
        'teacherName': teacherName,
        'subjectId': subjectId,
        'subjectName': subjectName,
        'status': status, // 'present' or 'absent'
        'date': FieldValue.serverTimestamp(),
      });

      print(
        "Marked attendance for enrolled student: $studentId, subject: $subjectName, status: $status",
      );
    } catch (e) {
      print("Error marking enrolled student attendance: $e");
      rethrow;
    }
  }

  // Get teacher-marked attendance for current student (now includes subjectId)
  Stream<List<Map<String, dynamic>>> getTeacherMarkedAttendance() {
    final user = auth.currentUser;
    if (user == null) return Stream.value([]);
    return firestore
        .collection('teacherAttendance')
        .where('studentId', isEqualTo: user.uid)
        // Temporarily removed orderBy to avoid index requirement
        // .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          print("Getting teacher attendance for student: ${user.uid}");
          final attendance =
              snapshot.docs.map((doc) {
                final data = doc.data();
                return {
                  'id': doc.id,
                  'subjectName': data['subjectName'] ?? '',
                  'teacherName': data['teacherName'] ?? '',
                  'status': data['status'] ?? 'unknown',
                  'date':
                      data['date'] != null
                          ? (data['date'] as Timestamp)
                              .toDate()
                              .toString()
                              .split(' ')[0]
                          : 'Unknown',
                  'teacherId': data['teacherId'] ?? '',
                  'subjectId': data['subjectId'] ?? '',
                };
              }).toList();

          // Sort in memory instead of in query
          attendance.sort((a, b) => b['date'].compareTo(a['date']));

          print("Received ${attendance.length} teacher attendance records");
          return attendance;
        });
  }

  // Get all students for teacher to mark attendance
  Stream<List<Map<String, dynamic>>> getAllStudents() {
    return firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'email': data['email'] ?? '',
              'name': data['name'] ?? data['email']?.split('@')[0] ?? 'Unknown',
            };
          }).toList();
        });
  }

  // Mark attendance for a student (teacher function) - DEPRECATED, use markEnrolledStudentAttendance
  Future<void> markStudentAttendance(
    String studentId,
    String subjectName,
    String status,
  ) async {
    final teacher = auth.currentUser;
    if (teacher == null) throw Exception("Teacher not authenticated");

    try {
      // Get teacher name
      final teacherDoc =
          await firestore.collection('users').doc(teacher.uid).get();
      final teacherName =
          teacherDoc.data()?['name'] ??
          teacher.email?.split('@')[0] ??
          'Unknown Teacher';

      await firestore.collection('teacherAttendance').add({
        'studentId': studentId,
        'teacherId': teacher.uid,
        'teacherName': teacherName,
        'subjectName': subjectName,
        'status': status, // 'present' or 'absent'
        'date': FieldValue.serverTimestamp(),
      });

      print(
        "Marked attendance for student: $studentId, subject: $subjectName, status: $status",
      );
    } catch (e) {
      print("Error marking student attendance: $e");
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
          final subjects =
              snapshot.docs.map((doc) {
                final data = doc.data();
                final present = data['present'] ?? 0;
                final absent = data['absent'] ?? 0;
                final totalClasses = present + absent;

                return {
                  'id': doc.id,
                  'name': data['name'] ?? '',
                  'presentClasses': present,
                  'absentClasses': absent,
                  'totalClasses': totalClasses,
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
          .update({'present': 0, 'absent': 0});
      print("Subject reset: $subjectId");
    } catch (e) {
      print("Error resetting subject: $e");
      rethrow;
    }
  }
}
