import 'package:flutter/material.dart';
import 'package:attendencetracker/name.dart';
import 'package:attendencetracker/firebase_service_simple.dart';

class SignUpPage extends StatefulWidget {
  final String role;
  const SignUpPage({super.key, required this.role});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FirebaseServiceSimple _firebaseService = FirebaseServiceSimple();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _handleSignUp() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please fill in all fields"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    if (password != confirmPassword) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Passwords do not match"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    if (password.length < 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Password must be at least 6 characters long"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _firebaseService.createUserWithRole(email, password, widget.role);
      // On successful sign up, navigate to login page
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Account created successfully! Please login."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NamePage(role: widget.role)),
        );
      }
    } catch (e) {
      String message = "An error occurred";
      if (e.toString().contains('weak-password')) {
        message = "The password provided is too weak.";
      } else if (e.toString().contains('email-already-in-use')) {
        message = "The account already exists for that email.";
      } else if (e.toString().contains('invalid-email')) {
        message = "The email address is not valid.";
      } else {
        message = "Failed to sign up. Please try again.";
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: Text("Sign Up - ${widget.role.toUpperCase()}"),
        backgroundColor: widget.role == "teacher" ? Colors.orange : Colors.deepPurple,
        elevation: 4,
        shadowColor: widget.role == "teacher" ? Colors.orangeAccent : Colors.deepPurpleAccent,
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
                    color: (widget.role == "teacher" ? Colors.orange : Colors.deepPurple).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    widget.role == "teacher" ? Icons.school : Icons.person,
                    size: 50,
                    color: widget.role == "teacher" ? Colors.orange : Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Join as ${widget.role}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.deepPurple[600],
                  ),
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
                    prefixIcon: Icon(Icons.email, color: Colors.deepPurple[400]),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.deepPurple[400],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
                SizedBox(height: 20),
                
                // Confirm Password Field
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  style: TextStyle(color: Colors.deepPurple[900]),
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    labelStyle: TextStyle(color: Colors.deepPurple[400]),
                    filled: true,
                    fillColor: Colors.deepPurple[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.deepPurple[400]),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.deepPurple[400],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
                SizedBox(height: 32),
                
                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.role == "teacher" ? Colors.orange : Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 5,
                      shadowColor: widget.role == "teacher" ? Colors.orangeAccent : Colors.deepPurpleAccent,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            "Create Account",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 20),
                
                // Back to Login
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Already have an account? Login",
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
