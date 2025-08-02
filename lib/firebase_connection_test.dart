import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service_simple.dart';

class FirebaseConnectionTest extends StatefulWidget {
  @override
  _FirebaseConnectionTestState createState() => _FirebaseConnectionTestState();
}

class _FirebaseConnectionTestState extends State<FirebaseConnectionTest> {
  String _status = 'Testing Firebase connection...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    try {
      // Test Firebase Auth
      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;

      setState(() {
        _status =
            'Firebase Auth: ${currentUser != null ? "Connected" : "No user signed in"}\n';
      });

      // Test Firestore basic connection
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('test').doc('connection').get();

      setState(() {
        _status += '\nFirestore: Connected';
      });

      // Test user role if signed in
      if (currentUser != null) {
        try {
          final userDoc = await firestore.collection('users').doc(currentUser.uid).get();
          if (userDoc.exists) {
            final role = userDoc.data()?['role'];
            setState(() {
              _status += '\nUser Role: $role';
            });

            // Test teacher subject creation if user is teacher
            if (role == 'teacher') {
              setState(() {
                _status += '\n\nTesting teacher subject creation...';
              });

              try {
                // Test creating a temporary subject
                final testSubject = await firestore.collection('teacherSubjects').add({
                  'name': 'Test Subject',
                  'teacherId': currentUser.uid,
                  'createdAt': FieldValue.serverTimestamp(),
                });

                setState(() {
                  _status += '\n✅ Teacher subject creation: SUCCESS';
                });

                // Clean up - delete the test subject
                await testSubject.delete();
                setState(() {
                  _status += '\n✅ Test subject cleaned up';
                });

              } catch (e) {
                setState(() {
                  _status += '\n❌ Teacher subject creation: FAILED';
                  _status += '\nError: $e';
                });
              }
            }
          } else {
            setState(() {
              _status += '\nUser document not found in Firestore';
            });
          }
        } catch (e) {
          setState(() {
            _status += '\nError checking user role: $e';
          });
        }
      }

      setState(() {
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Connection Test'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Status:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    if (_isLoading)
                      Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Text('Testing...'),
                        ],
                      )
                    else
                      Text(
                        _status,
                        style: TextStyle(fontSize: 14),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Troubleshooting Tips:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Make sure you are signed in as a teacher\n'
                      '2. Check that Firestore security rules are deployed\n'
                      '3. Verify your Firebase project configuration\n'
                      '4. Ensure you have proper internet connection',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _testConnection,
                child: Text('Retest Connection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
