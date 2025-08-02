import 'package:flutter/material.dart';
import 'package:attendencetracker/name.dart';
import 'package:attendencetracker/role_selection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_service_simple.dart';
import 'addsub.dart';
import 'showsub.dart';
import 'modals/enroll_student_modal.dart';
import 'modals/mark_attendance_modal.dart';
import 'modals/mark_student_attendance_modal.dart';

class TeacherView extends StatefulWidget {
  final String title;
  final String role;

  const TeacherView({super.key, required this.title, required this.role});

  @override
  State<TeacherView> createState() => _TeacherViewState();
}

class _TeacherViewState extends State<TeacherView>
    with SingleTickerProviderStateMixin {
  final FirebaseServiceSimple _firebaseService = FirebaseServiceSimple();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddSubjectModal() {
    final TextEditingController subjectController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AddSubjectModal(
            controller: subjectController,
            onSave: () async {
              final subject = subjectController.text.trim();
              if (subject.isEmpty) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a subject"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              } else {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                try {
                  await _firebaseService.addTeacherSubject(subject);
                  if (mounted) {
                    navigator.pop();
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text("Subject added: $subject"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    navigator.pop();
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text("Failed to add subject: ${e.toString()}"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              }
            },
          ),
        );
      },
    );
  }

  void _markPresent(String subjectId) async {
    try {
      await _firebaseService.markPresent(subjectId);
    } catch (e) {
      if (mounted) {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Failed to mark present: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _markAbsent(String subjectId) async {
    try {
      await _firebaseService.markAbsent(subjectId);
    } catch (e) {
      if (mounted) {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Failed to mark absent: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _deleteSubject(String subjectId) async {
    try {
      await _firebaseService.deleteSubject(subjectId);
      if (mounted) {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text("Subject deleted successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Failed to delete subject: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showEnrollStudentModal(String subjectId, String subjectName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return EnrollStudentModal(
          firebaseService: _firebaseService,
          subjectId: subjectId,
          subjectName: subjectName,
        );
      },
    );
  }

  void _showMarkAttendanceModal(String subjectId, String subjectName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return MarkAttendanceModal(
          firebaseService: _firebaseService,
          subjectId: subjectId,
          subjectName: subjectName,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.school, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Teacher Dashboard",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.title,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        elevation: 4,
        shadowColor: Colors.orangeAccent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: Icon(Icons.class_), text: "My Classes"),
            Tab(icon: Icon(Icons.subject), text: "Subjects"),
            Tab(icon: Icon(Icons.people), text: "Students"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              try {
                await _firebaseService.auth.signOut();
                if (mounted) {
                  navigator.pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => RoleSelectionPage(),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text("Failed to logout: ${e.toString()}"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Classes Tab (Personal tracking)
          _buildMyClassesTab(),
          // Subjects Tab (Teacher subjects with enrollment)
          _buildSubjectsTab(),
          // Students Tab (All students)
          _buildStudentsTab(),
        ],
      ),
      floatingActionButton: _getFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _getFloatingActionButton() {
    switch (_tabController.index) {
      case 0:
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: _showAddSubjectModal,
            backgroundColor: Colors.orange,
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        );
      case 1:
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: _showAddSubjectModal,
            backgroundColor: Colors.orange,
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        );
      case 2:
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => _showMarkStudentAttendanceModal(),
            backgroundColor: Colors.orange,
            child: const Icon(Icons.person_add, color: Colors.white, size: 28),
          ),
        );
      default:
        return Container();
    }
  }

  Widget _buildMyClassesTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firebaseService.getSubjects(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(24),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
                  SizedBox(height: 16),
                  Text(
                    'Error Loading Classes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(fontSize: 14, color: Colors.red[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Loading classes...",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final subjects = snapshot.data ?? [];

        if (subjects.isEmpty) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(32),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.school,
                      size: 60,
                      color: Colors.orange[400],
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "No classes added yet",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Tap the + button to add your first class!",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ShowSubjects(
          subjects: subjects,
          onAdd: _markPresent,
          onRemove: _markAbsent,
          onDelete: _deleteSubject,
        );
      },
    );
  }

  Widget _buildSubjectsTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firebaseService.getTeacherSubjects(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(24),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
                  SizedBox(height: 16),
                  Text(
                    'Error Loading Subjects',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(fontSize: 14, color: Colors.red[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Loading subjects...",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final subjects = snapshot.data ?? [];

        if (subjects.isEmpty) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(32),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.subject,
                      size: 60,
                      color: Colors.orange[400],
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "No subjects created yet",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Create subjects to enroll students and mark attendance",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final subject = subjects[index];
            return Container(
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.subject,
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
                                subject['name'] ?? 'Unknown Subject',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple[800],
                                ),
                              ),
                              Text(
                                "Teacher Subject",
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
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                () => _showEnrollStudentModal(
                                  subject['id'],
                                  subject['name'],
                                ),
                            icon: Icon(Icons.person_add, size: 18),
                            label: Text("Enroll Students"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              elevation: 2,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                () => _showMarkAttendanceModal(
                                  subject['id'],
                                  subject['name'],
                                ),
                            icon: Icon(Icons.checklist, size: 18),
                            label: Text("Mark Attendance"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStudentsTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firebaseService.getAllStudents(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(24),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
                  SizedBox(height: 16),
                  Text(
                    'Error Loading Students',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(fontSize: 14, color: Colors.red[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Loading students...",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final students = snapshot.data ?? [];

        if (students.isEmpty) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(32),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.people,
                      size: 60,
                      color: Colors.blue[400],
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "No students found",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Students need to sign up first",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  child: Icon(Icons.person, color: Colors.blue),
                ),
                title: Text(
                  student['name'] ?? 'Unknown',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(student['email'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _showMarkStudentAttendanceModal(),
                      icon: Icon(Icons.check_circle, color: Colors.green),
                      tooltip: 'Mark Present',
                    ),
                    IconButton(
                      onPressed: () => _showMarkStudentAttendanceModal(),
                      icon: Icon(Icons.cancel, color: Colors.red),
                      tooltip: 'Mark Absent',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMarkStudentAttendanceModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return MarkStudentAttendanceModal(firebaseService: _firebaseService);
      },
    );
  }
}
