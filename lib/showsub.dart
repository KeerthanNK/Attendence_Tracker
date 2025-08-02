import 'package:flutter/material.dart';

class ShowSubjects extends StatelessWidget {
  final List<Map<String, dynamic>> subjects;
  final Function(String) onAdd;
  final Function(String) onRemove;
  final Function(String)? onDelete;

  const ShowSubjects({
    super.key,
    required this.subjects,
    required this.onAdd,
    required this.onRemove,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.book_outlined,
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
              "Tap the + button to add your first subject",
              style: TextStyle(fontSize: 16, color: Colors.deepPurple[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final String subjectId = subject['id'] as String;
        final String subjectName = subject['name'] as String;
        final int totalClasses = subject['totalClasses'] as int;
        final int presentClasses = subject['presentClasses'] as int;
        final int absentClasses = subject['absentClasses'] as int;

        double percentage =
            totalClasses > 0 ? (presentClasses / totalClasses) * 100 : 0.0;

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
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.book,
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
                            "Total Classes: $totalClasses",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.deepPurple[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onDelete != null)
                      IconButton(
                        onPressed:
                            () => _showDeleteDialog(
                              context,
                              subjectId,
                              subjectName,
                            ),
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red[400],
                        ),
                        tooltip: 'Delete Subject',
                      ),
                  ],
                ),
                SizedBox(height: 20),

                // Statistics Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        "Present",
                        presentClasses.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        "Absent",
                        absentClasses.toString(),
                        Icons.cancel,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Progress Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Attendance Rate",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple[700],
                          ),
                        ),
                        Text(
                          "${percentage.toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: percentage >= 85 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      color: percentage >= 85 ? Colors.green : Colors.red,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => onAdd(subjectId),
                        icon: Icon(Icons.add, size: 18),
                        label: Text("Present"),
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
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => onRemove(subjectId),
                        icon: Icon(Icons.remove, size: 18),
                        label: Text("Absent"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
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
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    String subjectId,
    String subjectName,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
              SizedBox(width: 12),
              Text(
                'Delete Subject',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "$subjectName"?\n\nThis action cannot be undone and all attendance data will be lost.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.deepPurple[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete!(subjectId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
