import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class DebugLoginPage extends StatefulWidget {
  const DebugLoginPage({super.key});

  @override
  State<DebugLoginPage> createState() => _DebugLoginPageState();
}

class _DebugLoginPageState extends State<DebugLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _checkFirebaseStatus();
  }

  void _checkFirebaseStatus() async {
    try {
      // Check if Firebase is initialized
      final app = Firebase.app();
      setState(() {
        _debugInfo += '✅ Firebase App initialized: ${app.name}\n';
      });

      // Check auth instance
      final auth = FirebaseAuth.instance;
      setState(() {
        _debugInfo += '✅ Firebase Auth instance created\n';
      });

      // Check current user
      final user = auth.currentUser;
      setState(() {
        _debugInfo += 'Current user: ${user?.email ?? 'None'}\n';
      });
    } catch (e) {
      setState(() {
        _debugInfo += '❌ Firebase Error: ${e.toString()}\n';
      });
    }
  }

  void _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _debugInfo += '❌ Please enter both email and password\n';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _debugInfo += '🔄 Attempting login...\n';
    });

    try {
      print("Firebase Auth instance: ${_auth}");
      print("Attempting login with email: $email");

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      setState(() {
        _isLoading = false;
        _debugInfo += '✅ Login successful!\n';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _debugInfo += '❌ Firebase Auth Error: ${e.code} - ${e.message}\n';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _debugInfo += '❌ General Error: ${e.toString()}\n';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Debug Login"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading ? CircularProgressIndicator() : Text("Login"),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _debugInfo,
                    style: TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
