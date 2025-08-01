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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    widget.role == "teacher"
                        ? TeacherView(title: "Hello, $email", role: widget.role)
                        : StudentView(
                          title: "Hello, $email",
                          role: widget.role,
                        ),
          ),
        );
      }
    } catch (e) {
      String message = "An error occurred";
      if (e.toString().contains('user-not-found')) {
        message = "No user found for that email.";
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
      } else {
        message = "Login error: ${e.toString()}";
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
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
        child: Container(
          height: 450,
          width: 320,
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
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 30),
              TextField(
                controller: _emailController,
                style: TextStyle(color: Colors.deepPurple[900]),
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(color: Colors.deepPurple[400]),
                  filled: true,
                  fillColor: Colors.deepPurple[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.email, color: Colors.deepPurple[400]),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
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
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 5,
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
                        : Text("Login"),
              ),
              SizedBox(height: 15),
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
    );
  }
}
