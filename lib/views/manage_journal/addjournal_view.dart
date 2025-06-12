import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddJournalView extends StatefulWidget {
  final String? docId;
  final String? existingContent;

  const AddJournalView({super.key, this.docId, this.existingContent});

  @override
  State<AddJournalView> createState() => _AddJournalViewState();
}

class _AddJournalViewState extends State<AddJournalView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.existingContent);
    super.initState();
  }

  Future<void> saveJournal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final journalRef = FirebaseFirestore.instance.collection('journal_entries');
    final content = _controller.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some content.')),
      );
      return;
    }

    try {
      if (widget.docId != null) {
        await journalRef.doc(widget.docId).update({
          'content': content,
          'timestamp': Timestamp.now(),
        });
      } else {
        await journalRef.add({
          'userId': user.uid,
          'content': content,
          'timestamp': Timestamp.now(),
        });
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving entry: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.docId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Entry' : 'New Journal Entry'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Write your thoughts here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.blue[50],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: saveJournal,
              icon: const Icon(Icons.save),
              label: Text(isEditing ? 'Update' : 'Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
