import 'package:flutter/material.dart';
import '../firebase_service_simple.dart';

// Modal for marking attendance for enrolled students
class MarkAttendanceModal extends StatefulWidget {
  final FirebaseServiceSimple firebaseService;
  final String subjectId;
  final String subjectName;

  const MarkAttendanceModal({
    super.key,
    required this.firebaseService,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<MarkAttendanceModal> createState() => _MarkAttendanceModalState();
}

class _MarkAttendanceModalState extends State<MarkAttendanceModal> {
  List<Map<String, dynamic>> enrolledStudents = [];

  @override
  void initState() {
    super.initState();
    _loadEnrolledStudents();
  }

  void _loadEnrolledStudents() {
    widget.firebaseService.getEnrolledStudents(widget.subjectId).listen((students) {
      if (mounted) {
        setState(() {
          enrolledStudents = students;
        });
      }
    });
  }

  void _markAttendance(String studentId, String status) async {
    try {
      await widget.firebaseService.markEnrolledStudentAttendance(
        widget.subjectId,
        studentId,
        status,
      );

      if (mounted) {
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
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.checklist,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mark Attendance",
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
          
          // Enrolled Students List
          if (enrolledStudents.isEmpty)
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.people_outline, size: 50, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    "No students enrolled",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Enroll students first to mark attendance",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Container(
              height: 300,
              child: ListView.builder(
                itemCount: enrolledStudents.length,
                itemBuilder: (context, index) {
                  final student = enrolledStudents[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.withValues(alpha: 0.1),
                        child: Icon(Icons.person, color: Colors.blue, size: 20),
                      ),
                      title: Text(
                        student['studentName'] ?? 'Unknown',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(student['studentEmail'] ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _markAttendance(student['studentId'], 'present'),
                            icon: Icon(Icons.check_circle, color: Colors.green),
                            tooltip: 'Present',
                          ),
                          IconButton(
                            onPressed: () => _markAttendance(student['studentId'], 'absent'),
                            icon: Icon(Icons.cancel, color: Colors.red),
                            tooltip: 'Absent',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          
          SizedBox(height: 16),
          
          // Close Button
          SizedBox(
            width: double.infinity,
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
                "Close",
                style: TextStyle(
                  color: Colors.deepPurple[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 