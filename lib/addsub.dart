import 'package:flutter/material.dart';

class AddSubjectModal extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSave;

  const AddSubjectModal({
    super.key,
    required this.controller,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "Subject Name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(onPressed: onSave, child: const Text("Save Subject")),
        ],
      ),
    );
  }
}
