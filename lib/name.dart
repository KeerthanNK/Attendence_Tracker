import 'package:flutter/material.dart';
import 'package:attendencetracker/teacher_view.dart';
import 'package:attendencetracker/student_view.dart';
import 'package:attendencetracker/firebase_service_simple.dart';
import 'signup.dart';

class NamePage extends StatefulWidget {
  final String role;
  const NamePage({super.key, required this.role});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseServiceSimple _firebaseService = FirebaseServiceSimple();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please enter both email and password"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    // Debug: Check Firebase initialization
    setState(() {
      _isLoading = true;
    });

    try {
      print("Attempting login with email: $email and role: ${widget.role}");

      await _firebaseService.signInWithRoleVerification(
        email,
        password,
        widget.role,
      );

      // On successful login, navigate to appropriate view
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login successful! Welcome back."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );

        // Navigate after a short delay to show success message
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        widget.role == "teacher"
                            ? TeacherView(
                              title: "Hello, $email",
                              role: widget.role,
                            )
                            : StudentView(
                              title: "Hello, $email",
                              role: widget.role,
                            ),
              ),
            );
          }
        });
      }
    } catch (e) {
      String message = "An error occurred";
      if (e.toString().contains('user-not-found')) {
        message = "No user found for that email. Please sign up first.";
      } else if (e.toString().contains('wrong-password')) {
        message = "Wrong password provided for that user.";
      } else if (e.toString().contains('invalid-email')) {
        message = "The email address is not valid.";
      } else if (e.toString().contains('user-disabled')) {
        message = "This user account has been disabled.";
      } else if (e.toString().contains('too-many-requests')) {
        message = "Too many failed login attempts. Please try again later.";
      } else if (e.toString().contains('Invalid role')) {
        message =
            "This account is not registered as a ${widget.role}. Please sign up as a ${widget.role}.";
      } else if (e.toString().contains(
        'User account not properly configured',
      )) {
        message = "Account setup incomplete. Please try signing up first.";
      } else {
        message = "Login error: ${e.toString()}";
      }

      print("Login error details: $e");

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage(role: widget.role)),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: Text("Login - ${widget.role.toUpperCase()}"),
        backgroundColor:
            widget.role == "teacher" ? Colors.orange : Colors.deepPurple,
        elevation: 4,
        shadowColor:
            widget.role == "teacher"
                ? Colors.orangeAccent
                : Colors.deepPurpleAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: (widget.role == "teacher"
                            ? Colors.orange
                            : Colors.deepPurple)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    widget.role == "teacher" ? Icons.school : Icons.person,
                    size: 50,
                    color:
                        widget.role == "teacher"
                            ? Colors.orange
                            : Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Sign in to your ${widget.role} account",
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple[600]),
                ),
                SizedBox(height: 32),

                // Email Field
                TextField(
                  controller: _emailController,
                  style: TextStyle(color: Colors.deepPurple[900]),
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    labelStyle: TextStyle(color: Colors.deepPurple[400]),
                    filled: true,
                    fillColor: Colors.deepPurple[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.deepPurple[400],
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: Colors.deepPurple[900]),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: Colors.deepPurple[400]),
                    filled: true,
                    fillColor: Colors.deepPurple[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.lock, color: Colors.deepPurple[400]),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.deepPurple[400],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
                SizedBox(height: 32),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          widget.role == "teacher"
                              ? Colors.orange
                              : Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 5,
                      shadowColor:
                          widget.role == "teacher"
                              ? Colors.orangeAccent
                              : Colors.deepPurpleAccent,
                    ),
                    child:
                        _isLoading
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
                SizedBox(height: 20),

                // Sign Up Link
                TextButton(
                  onPressed: _navigateToSignUp,
                  child: Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(
                      color: Colors.deepPurple,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
