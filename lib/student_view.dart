import 'package:flutter/material.dart';
import 'package:attendencetracker/name.dart';
import 'package:attendencetracker/role_selection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_service_simple.dart';
import 'addsub.dart';
import 'showsub.dart';

class StudentView extends StatefulWidget {
  final String title;
  final String role;

  const StudentView({super.key, required this.title, required this.role});

  @override
  State<StudentView> createState() => _StudentViewState();
}

class _StudentViewState extends State<StudentView> with SingleTickerProviderStateMixin {
  final FirebaseServiceSimple _firebaseService = FirebaseServiceSimple();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
                  await _firebaseService.addSubject(subject);
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
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Student Dashboard",
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
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        shadowColor: Colors.deepPurpleAccent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: Icon(Icons.person),
              text: "Self Tracking",
            ),
            Tab(
              icon: Icon(Icons.school),
              text: "Teacher Marked",
            ),
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
          // Self Tracking Tab
          _buildSelfTrackingTab(),
          // Teacher Marked Tab
          _buildTeacherMarkedTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: _showAddSubjectModal,
                backgroundColor: Colors.deepPurple,
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSelfTrackingTab() {
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
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Loading subjects...",
                    style: TextStyle(fontSize: 16, color: Colors.deepPurple[600]),
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
                      color: Colors.deepPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.deepPurple[400],
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "No subjects added yet",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Tap the + button to add your first subject!",
                    style: TextStyle(fontSize: 16, color: Colors.deepPurple[600]),
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

  Widget _buildTeacherMarkedTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firebaseService.getTeacherMarkedAttendance(),
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
                    'Error Loading Teacher Attendance',
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
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Loading teacher attendance...",
                    style: TextStyle(fontSize: 16, color: Colors.deepPurple[600]),
                  ),
                ],
              ),
            ),
          );
        }

        final attendanceRecords = snapshot.data ?? [];

        if (attendanceRecords.isEmpty) {
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
                      color: Colors.deepPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.school,
                      size: 60,
                      color: Colors.deepPurple[400],
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "No teacher attendance records",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Teachers haven't marked your attendance yet",
                    style: TextStyle(fontSize: 16, color: Colors.deepPurple[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Group attendance by subject
        Map<String, List<Map<String, dynamic>>> groupedAttendance = {};
        for (var record in attendanceRecords) {
          String subjectName = record['subjectName'] ?? 'Unknown Subject';
          if (!groupedAttendance.containsKey(subjectName)) {
            groupedAttendance[subjectName] = [];
          }
          groupedAttendance[subjectName]!.add(record);
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: groupedAttendance.length,
          itemBuilder: (context, index) {
            String subjectName = groupedAttendance.keys.elementAt(index);
            List<Map<String, dynamic>> subjectRecords = groupedAttendance[subjectName]!;
            
            // Calculate attendance statistics
            int presentCount = subjectRecords.where((r) => r['status'] == 'present').length;
            int absentCount = subjectRecords.where((r) => r['status'] == 'absent').length;
            int totalClasses = presentCount + absentCount;
            double attendancePercentage = totalClasses > 0 ? (presentCount / totalClasses) * 100 : 0;

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
              child: InkWell(
                onTap: () => _showSubjectAttendanceDetails(subjectName, subjectRecords),
                borderRadius: BorderRadius.circular(20),
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
                              color: Colors.deepPurple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.school,
                              color: Colors.deepPurple,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subjectName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple[800],
                                  ),
                                ),
                                Text(
                                  "Teacher: ${subjectRecords.first['teacherName'] ?? 'Unknown'}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.deepPurple[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.deepPurple[400],
                            size: 16,
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildAttendanceStat(
                              "Present",
                              presentCount.toString(),
                              Colors.green,
                              Icons.check_circle,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildAttendanceStat(
                              "Absent",
                              absentCount.toString(),
                              Colors.red,
                              Icons.cancel,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildAttendanceStat(
                              "Total",
                              totalClasses.toString(),
                              Colors.blue,
                              Icons.assessment,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: attendancePercentage / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          attendancePercentage >= 75 ? Colors.green : 
                          attendancePercentage >= 50 ? Colors.orange : Colors.red,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Attendance: ${attendancePercentage.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.deepPurple[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAttendanceStat(String label, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubjectAttendanceDetails(String subjectName, List<Map<String, dynamic>> records) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
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
                      color: Colors.deepPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.school,
                      color: Colors.deepPurple,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subjectName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple[800],
                          ),
                        ),
                        Text(
                          "Attendance Details",
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
              
              // Attendance List
              Container(
                height: 400,
                child: ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final isPresent = record['status'] == 'present';
                    
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: (isPresent ? Colors.green : Colors.red).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (isPresent ? Colors.green : Colors.red).withValues(alpha: 0.3),
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: (isPresent ? Colors.green : Colors.red).withValues(alpha: 0.2),
                          child: Icon(
                            isPresent ? Icons.check_circle : Icons.cancel,
                            color: isPresent ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(
                          isPresent ? "Present" : "Absent",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isPresent ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                        subtitle: Text(
                          "Date: ${record['date']}",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: Text(
                          record['teacherName'] ?? 'Unknown Teacher',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
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
      },
    );
  }
}
