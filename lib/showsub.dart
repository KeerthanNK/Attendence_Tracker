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
      return const Center(
        child: Text("No subjects added yet.", style: TextStyle(fontSize: 18)),
      );
    }

    return ListView.builder(
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
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: Colors.deepPurple.shade100,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subjectName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text("Total Classes: $totalClasses"),
                        Text("Present: $presentClasses"),
                        Text("Absent: $absentClasses"),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey.shade300,
                          color: percentage >= 85 ? Colors.green : Colors.red,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Attendance: ${percentage.toStringAsFixed(1)}%",
                          style: TextStyle(
                            color: percentage >= 85 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Buttons
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: 'Mark Present',
                        child: IconButton(
                          onPressed: () => onAdd(subjectId),
                          icon: const Icon(Icons.add_circle),
                          color: Colors.green,
                          iconSize: 30,
                        ),
                      ),
                      Tooltip(
                        message: 'Mark Absent',
                        child: IconButton(
                          onPressed: () => onRemove(subjectId),
                          icon: const Icon(Icons.remove_circle),
                          color: Colors.red,
                          iconSize: 30,
                        ),
                      ),
                      if (onDelete != null)
                        Tooltip(
                          message: 'Delete Subject',
                          child: IconButton(
                            onPressed:
                                () => _showDeleteDialog(
                                  context,
                                  subjectId,
                                  subjectName,
                                ),
                            icon: const Icon(Icons.delete),
                            color: Colors.orange,
                            iconSize: 30,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
          title: const Text('Delete Subject'),
          content: Text(
            'Are you sure you want to delete "$subjectName"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete!(subjectId);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
