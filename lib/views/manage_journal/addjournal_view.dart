import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddJournalView extends StatefulWidget {
  const AddJournalView({super.key});

  @override
  State<AddJournalView> createState() => _AddJournalViewState();
}

class _AddJournalViewState extends State<AddJournalView> {
  final _titleController = TextEditingController();
  final _thoughtsController = TextEditingController();
  String _selectedEmotion = '';

  final List<Map<String, dynamic>> _emotions = [
    {'emoji': '😀', 'label': 'Happy'},
    {'emoji': '😢', 'label': 'Sad'},
    {'emoji': '😡', 'label': 'Angry'},
    {'emoji': '😰', 'label': 'Anxious'},
    {'emoji': '😌', 'label': 'Calm'},
  ];

  Future<void> _submitJournal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _titleController.text.isNotEmpty) {
      final journalData = {
        'uid': user.uid,
        'title': _titleController.text.trim(),
        'thoughts': _thoughtsController.text.trim(),
        'emotion': _selectedEmotion,
        'timestamp': Timestamp.now(),
      };
      await FirebaseFirestore.instance.collection('journals').add(journalData);
      Navigator.pop(context);
    }
  }

  Widget _buildEmotionSelector() {
    return Wrap(
      spacing: 10,
      children: _emotions.map((emotion) {
        final isSelected = _selectedEmotion == emotion['emoji'];
        return GestureDetector(
          onTap: () => setState(() => _selectedEmotion = emotion['emoji']),
          child: Chip(
            label: Text('${emotion['emoji']} ${emotion['label']}'),
            backgroundColor: isSelected ? Colors.blueAccent : Colors.grey[300],
            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Journal Entry'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              const Text("How are you feeling today?"),
              const SizedBox(height: 8),
              _buildEmotionSelector(),
              const SizedBox(height: 20),
              TextField(
                controller: _thoughtsController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Write your thoughts...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitJournal,
                  child: const Text('Save Entry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
