import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'addjournal_view.dart';

class JournalView extends StatefulWidget {
  const JournalView({super.key});

  @override
  State<JournalView> createState() => _JournalViewState();
}

class _JournalViewState extends State<JournalView> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journal Entries'),
        backgroundColor: Colors.blueAccent,
      ),
      body: user == null
          ? const Center(child: Text('User not logged in.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('journals')
                  .where('uid', isEqualTo: user!.uid) //  ❗️no .orderBy()
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No journal entries yet.'));
                }

                // ---- sort entries locally by timestamp ----
                final journals = snapshot.data!.docs.toList()
                  ..sort((a, b) {
                    final tsA = (a['timestamp'] as Timestamp).toDate();
                    final tsB = (b['timestamp'] as Timestamp).toDate();
                    return tsB.compareTo(tsA); // newest first
                  });

                return ListView.builder(
                  itemCount: journals.length,
                  itemBuilder: (context, index) {
                    final entry =
                        journals[index].data() as Map<String, dynamic>;
                    final timestamp =
                        (entry['timestamp'] as Timestamp).toDate();

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(entry['emotion'] ?? '',
                                    style: const TextStyle(fontSize: 28)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    entry['title'] ?? 'Untitled',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(entry['thoughts'] ?? '',
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 10),
                            Text(
                              '${timestamp.day}/${timestamp.month}/${timestamp.year} '
                              '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddJournalView()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
