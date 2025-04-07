import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map> _messages = [];

  // Send message function with API integration
  Future<void> sendMessage(String message) async {
    setState(() {
      _messages.add({"text": message, "isUserMessage": true});
    });

    final apiKey = _getApiKey();
    if (apiKey == null) {
      print('API key is missing.');
      return; // Handle missing API key (you could show a dialog here)
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 1,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: 'text/plain',
      ),
      systemInstruction: Content.system(
        'You are a compassionate mental health therapist, offering support and understanding. During the first few interactions, focus on gentle and open-ended questions to understand the user\'s feelings or situation without overwhelming them. Keep responses simple, calm, and comforting. Offer just enough guidance to make the user feel heard and safe.\n\nIf the user needs to provide additional information or if there’s something they haven’t thought of that may help, gently prompt them in a non-intrusive manner. Avoid overwhelming them with too much advice or information in the beginning.\n\nIf a situation requires professional intervention, kindly advise the user to consult with a licensed mental health professional. Always prioritize creating a safe, supportive, and non-judgmental space for the user.',
      ),
    );

    final chat = model.startChat(history: []);
    final content = Content.text(message);

    try {
      final response = await chat.sendMessage(content);
      setState(() {
        _messages.add({"text": response.text, "isUserMessage": false});
      });
    } catch (e) {
      print("Error while sending message: $e");
      setState(() {
        _messages.add({
          "text":
              "Sorry, there was an error with the system. Please try again later.",
          "isUserMessage": false,
        });
      });
    }
  }

  // Logout function
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Health Chatbot'),
        backgroundColor: Colors.blueAccent,
        elevation: 2,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  var message = _messages[index];
                  return Align(
                    alignment:
                        message['isUserMessage']
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ChatBubble(
                        message: message['text'],
                        isUserMessage: message['isUserMessage'],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.blue[50],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.blueAccent),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        sendMessage(_controller.text);
                        _controller.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom ChatBubble Widget with Pointy Tail
class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUserMessage;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isUserMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BubblePainter(isUserMessage),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isUserMessage ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUserMessage ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// Custom Painter for Pointy Chat Bubble Tail
class BubblePainter extends CustomPainter {
  final bool isUserMessage;

  BubblePainter(this.isUserMessage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()..color = isUserMessage ? Colors.blueAccent : Colors.grey[300]!;
    final path = Path();

    // Bubble shape
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(15),
      ),
    );

    // Tail shape (pointy part)
    if (isUserMessage) {
      path.moveTo(size.width - 10, size.height);
      path.lineTo(size.width + 5, size.height - 10);
      path.lineTo(size.width - 10, size.height - 20);
    } else {
      path.moveTo(10, size.height);
      path.lineTo(-5, size.height - 10);
      path.lineTo(10, size.height - 20);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// Function to get the API Key depending on the platform
String? _getApiKey() {
  if (kIsWeb) {
    return 'AIzaSyBkY-RN0riSlTosManq56lXd5QtcKVOpdU'; // Replace with your method of retrieving the API key
  } else if (Platform.isAndroid || Platform.isIOS) {
    return Platform.environment['GEMINI_API_KEY'];
  } else {
    return Platform.environment['GEMINI_API_KEY'];
  }
}
