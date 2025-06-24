import 'package:attendencetracker/name.dart';
import 'package:flutter/material.dart';
import 'addsub.dart';
import 'showsub.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: NamePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> subjects = [];
  final List<int> totalClasses = [];
  final List<int> presentClasses = [];
  final List<int> absentClasses = [];

  void _showAddSubjectModal() {
    final TextEditingController subjectController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
            onSave: () {
              final subject = subjectController.text.trim();
              if (subject.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please enter a subject"),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              } else {
                Navigator.pop(context);
                setState(() {
                  subjects.add(subject);
                  totalClasses.add(0);
                  presentClasses.add(0);
                  absentClasses.add(0);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Subject added: $subject")),
                );
              }
            },
          ),
        );
      },
    );
  }

  void _markPresent(int index) {
    setState(() {
      totalClasses[index]++;
      presentClasses[index]++;
    });
  }

  void _markAbsent(int index) {
    setState(() {
      totalClasses[index]++;
      absentClasses[index]++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.deepPurple,
      ),
      body: ShowSubjects(
        subjects: subjects,
        totalClasses: totalClasses,
        presentClasses: presentClasses,
        absentClasses: absentClasses,
        onAdd: _markPresent,
        onRemove: _markAbsent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSubjectModal,
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
