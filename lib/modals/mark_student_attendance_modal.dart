import 'package:flutter/material.dart';
import '../firebase_service_simple.dart';

// Modal for marking student attendance (legacy)
class MarkStudentAttendanceModal extends StatefulWidget {
  final FirebaseServiceSimple firebaseService;

  const MarkStudentAttendanceModal({
    super.key,
    required this.firebaseService,
  });

  @override
  State<MarkStudentAttendanceModal> createState() => _MarkStudentAttendanceModalState();
}

class _MarkStudentAttendanceModalState extends State<MarkStudentAttendanceModal> {
  String? selectedStudentId;
  String? selectedSubject;
  List<Map<String, dynamic>> students = [];
  List<String> subjects = ['Mathematics', 'Physics', 'Chemistry', 'English', 'History'];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final studentsStream = widget.firebaseService.getAllStudents();
      await for (final studentsList in studentsStream) {
        if (mounted) {
          setState(() {
            students = studentsList;
          });
        }
      }
    } catch (e) {
      print("Error loading students: $e");
    }
  }

  void _markAttendance(String status) async {
    if (selectedStudentId == null || selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select both student and subject"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      await widget.firebaseService.markStudentAttendance(
        selectedStudentId!,
        selectedSubject!,
        status,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Attendance marked: $status"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to mark attendance: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
          ),
        );
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
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_add,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mark Student Attendance",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple[800],
                      ),
                    ),
                    Text(
                      "Select student and subject",
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
          
          // Student Dropdown
          DropdownButtonFormField<String>(
            value: selectedStudentId,
            decoration: InputDecoration(
              labelText: "Select Student",
              labelStyle: TextStyle(color: Colors.deepPurple[400]),
              filled: true,
              fillColor: Colors.deepPurple[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(Icons.person, color: Colors.deepPurple[400]),
            ),
            items: students.map((student) {
              return DropdownMenuItem<String>(
                value: student['id'] as String,
                child: Text(student['name'] ?? 'Unknown'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedStudentId = value;
              });
            },
          ),
          SizedBox(height: 20),
          
          // Subject Dropdown
          DropdownButtonFormField<String>(
            value: selectedSubject,
            decoration: InputDecoration(
              labelText: "Select Subject",
              labelStyle: TextStyle(color: Colors.deepPurple[400]),
              filled: true,
              fillColor: Colors.deepPurple[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(Icons.book, color: Colors.deepPurple[400]),
            ),
            items: subjects.map((subject) {
              return DropdownMenuItem(
                value: subject,
                child: Text(subject),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedSubject = value;
              });
            },
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
                  onPressed: () => _markAttendance('present'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    elevation: 3,
                  ),
                  child: Text(
                    "Present",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _markAttendance('absent'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    elevation: 3,
                  ),
                  child: Text(
                    "Absent",
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