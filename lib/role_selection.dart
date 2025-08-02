import 'package:flutter/material.dart';
import 'package:attendencetracker/name.dart';
import 'package:attendencetracker/firebase_connection_test.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: Text("Select Your Role"),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        shadowColor: Colors.deepPurpleAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FirebaseConnectionTest(),
                ),
              );
            },
            tooltip: 'Test Firebase Connection',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome to Attendance Tracker",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              Text(
                "Please select your role to continue:",
                style: TextStyle(fontSize: 18, color: Colors.deepPurple[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: _buildRoleCard(
                      context,
                      "Teacher",
                      Icons.school,
                      Colors.orange,
                      "Manage attendance for your classes",
                      () => _navigateToLogin(context, "teacher"),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _buildRoleCard(
                      context,
                      "Student",
                      Icons.person,
                      Colors.blue,
                      "Track your own attendance",
                      () => _navigateToLogin(context, "student"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String description,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context, String role) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => NamePage(role: role)),
    );
  }
}
