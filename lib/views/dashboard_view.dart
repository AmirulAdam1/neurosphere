import 'package:flutter/material.dart';
import 'package:neurosphere/views/chat_view.dart';
import 'package:neurosphere/views/manage_journal/journal_view.dart';
import 'package:neurosphere/views/profile_view.dart';
import 'package:neurosphere/views/sos_location_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_DashboardItem> items = [
      _DashboardItem(title: 'Profile', icon: Icons.person, widget: const ProfileView()),
      _DashboardItem(title: 'Chatbot', icon: Icons.chat_bubble_outline, widget: const ChatScreen()),
      _DashboardItem(title: 'Journal', icon: Icons.book_outlined, widget: const JournalView()),
      _DashboardItem(title: 'SOS Map', icon: Icons.location_on, widget: const SosLocationView()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Neurosphere Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: List.generate(items.length, (index) {
          final item = items[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => item.widget),
            ),
            child: Card(
              margin: const EdgeInsets.all(12.0),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, size: 50, color: Colors.blueAccent),
                  const SizedBox(height: 10),
                  Text(item.title, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _DashboardItem {
  final String title;
  final IconData icon;
  final Widget widget;

  _DashboardItem({required this.title, required this.icon, required this.widget});
}
