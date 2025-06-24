import 'package:flutter/material.dart';
import 'package:attendencetracker/main.dart';

class NamePage extends StatefulWidget {
  @override
  _NamePageState createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  final TextEditingController _nameController = TextEditingController();

  void _handleSave() {
    String name = _nameController.text.trim();

    if (name.isEmpty) {
      // Show snackbar if name is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter your name"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      // Proceed to next page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(title: "Hello, $name"),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(" Self Attendance Tracker"),
      ),
      body: Center(
        child: Container(
          height: 350,
          width: 300,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 22),
              Text(
                "Enter your name",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.all(11.0),
                child: TextField(
                  controller: _nameController,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: "Ex : Gokul sai H",
                    hintStyle: TextStyle(
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                      fontSize: 15,
                    ),
                    filled: true,
                    fillColor: Colors.blue[600],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      gapPadding: 10,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 45),
              ElevatedButton(onPressed: _handleSave, child: Text("Save")),
            ],
          ),
        ),
      ),
    );
  }
}
