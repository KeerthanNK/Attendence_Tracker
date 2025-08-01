import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseConnectionTest extends StatefulWidget {
  const FirebaseConnectionTest({super.key});

  @override
  State<FirebaseConnectionTest> createState() => _FirebaseConnectionTestState();
}

class _FirebaseConnectionTestState extends State<FirebaseConnectionTest> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _status = 'Checking connection...';
  List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _testFirebaseConnection();
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
    print(message);
  }

  Future<void> _testFirebaseConnection() async {
    try {
      _addLog('🔍 Testing Firebase Connection...');
      
      // Test 1: Check if user is authenticated
      final user = _auth.currentUser;
      if (user != null) {
        _addLog('✅ User authenticated: ${user.email}');
        _addLog('✅ User ID: ${user.uid}');
      } else {
        _addLog('❌ No user authenticated');
        setState(() {
          _status = 'User not authenticated';
        });
        return;
      }

      // Test 2: Check Firestore connection
      _addLog('🔍 Testing Firestore connection...');
      final testDoc = await _firestore.collection('test').doc('connection').get();
      _addLog('✅ Firestore connection successful');

      // Test 3: Check if user document exists
      _addLog('🔍 Checking user document...');
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        _addLog('✅ User document exists');
      } else {
        _addLog('⚠️ User document does not exist (will be created when first subject is added)');
      }

      // Test 4: Check subjects collection
      _addLog('🔍 Checking subjects collection...');
      final subjectsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('subjects')
          .get();
      
      _addLog('✅ Subjects collection accessible');
      _addLog('📊 Found ${subjectsSnapshot.docs.length} subjects');

      // Test 5: Try to add a test subject
      _addLog('🔍 Testing subject creation...');
      final testSubjectRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('subjects')
          .add({
        'name': 'Test Subject',
        'totalClasses': 0,
        'presentClasses': 0,
        'absentClasses': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      _addLog('✅ Test subject created with ID: ${testSubjectRef.id}');

      // Test 6: Try to update the test subject
      _addLog('🔍 Testing subject update...');
      await testSubjectRef.update({
        'totalClasses': 1,
        'presentClasses': 1,
      });
      _addLog('✅ Test subject updated successfully');

      // Test 7: Delete the test subject
      _addLog('🔍 Cleaning up test subject...');
      await testSubjectRef.delete();
      _addLog('✅ Test subject deleted successfully');

      setState(() {
        _status = '✅ All Firebase tests passed! Your attendance data is connected to Firebase.';
      });

    } catch (e) {
      _addLog('❌ Firebase test failed: $e');
      setState(() {
        _status = '❌ Firebase connection failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Connection Test'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _status.contains('✅') ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _status.contains('✅') ? Colors.green : Colors.red,
                ),
              ),
              child: Text(
                _status,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _status.contains('✅') ? Colors.green[800] : Colors.red[800],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Test Logs:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _logs.map((log) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        log,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    )).toList(),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _logs.clear();
                        _status = 'Checking connection...';
                      });
                      _testFirebaseConnection();
                    },
                    child: Text('Run Test Again'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: Text('Back to App'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 