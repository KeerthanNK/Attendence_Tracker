import 'package:flutter/material.dart';

class ShowSubjects extends StatelessWidget {
  final List<String> subjects;
  final List<int> totalClasses;
  final List<int> presentClasses;
  final List<int> absentClasses;
  final Function(int) onAdd;
  final Function(int) onRemove;

  const ShowSubjects({
    super.key,
    required this.subjects,
    required this.totalClasses,
    required this.presentClasses,
    required this.absentClasses,
    required this.onAdd,
    required this.onRemove,
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
        double percentage =
            totalClasses[index] > 0
                ? (presentClasses[index] / totalClasses[index]) * 100
                : 0.0;

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
                          subjects[index],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text("Total Classes: ${totalClasses[index]}"),
                        Text("Present: ${presentClasses[index]}"),
                        Text("Absent: ${absentClasses[index]}"),
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
                          onPressed: () => onAdd(index),
                          icon: const Icon(Icons.add_circle),
                          color: Colors.green,
                          iconSize: 30,
                        ),
                      ),
                      Tooltip(
                        message: 'Mark Absent',
                        child: IconButton(
                          onPressed: () => onRemove(index),
                          icon: const Icon(Icons.remove_circle),
                          color: Colors.red,
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
}
