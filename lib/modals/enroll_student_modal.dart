import 'package:flutter/material.dart';
import '../firebase_service_simple.dart';

// Modal for enrolling students in a subject
class EnrollStudentModal extends StatefulWidget {
  final FirebaseServiceSimple firebaseService;
  final String subjectId;
  final String subjectName;

  const EnrollStudentModal({
    super.key,
    required this.firebaseService,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<EnrollStudentModal> createState() => _EnrollStudentModalState();
}

class _EnrollStudentModalState extends State<EnrollStudentModal> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  void _enrollStudent() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter student email"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.firebaseService.enrollStudentInSubject(widget.subjectId, email);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Student enrolled successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to enroll student: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 24),
          
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_add,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Enroll Student",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple[800],
                      ),
                    ),
                    Text(
                      "Subject: ${widget.subjectName}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.deepPurple[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          
          // Email Input
          TextField(
            controller: _emailController,
            style: TextStyle(color: Colors.deepPurple[900]),
            decoration: InputDecoration(
              labelText: "Student Email",
              labelStyle: TextStyle(color: Colors.deepPurple[400]),
              hintText: "Enter student's registered email",
              hintStyle: TextStyle(color: Colors.deepPurple[300]),
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
          SizedBox(height: 32),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.deepPurple[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.deepPurple[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _enrollStudent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    elevation: 3,
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
                          "Enroll",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
} 