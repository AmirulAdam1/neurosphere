import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart'; // For checking the platform
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:neurosphere/firebase_options.dart';
import 'package:neurosphere/views/login_view.dart';
import 'package:neurosphere/views/register_view.dart';
import 'package:neurosphere/views/verify_email_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check the platform to handle environment variables accordingly
  final apiKey = _getApiKey();
  if (apiKey == null) {
    print('API key is missing.');
    return; // Handle missing API key (could show an error screen)
  }

  runApp(
    MaterialApp(
      title: 'Neurosphere',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
      routes: {
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              if (user.emailVerified) {
                return const ChatScreen(); // Go directly to the chat screen
              } else {
                return const VerifyEmailView(); // Email verification pending
              }
            } else {
              return const LoginView(); // Not logged in
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}

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

    // Replace 'INSERT_INPUT_HERE' with the user's actual message
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
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: Column(
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
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            message['isUserMessage']
                                ? Colors.blueAccent
                                : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        message['text'],
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: "Type a message..."),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
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
    );
  }
}

// Function to get the API Key depending on the platform
String? _getApiKey() {
  if (kIsWeb) {
    // For web, you could hardcode the API key here or load it from a different source like localStorage
    return 'AIzaSyBkY-RN0riSlTosManq56lXd5QtcKVOpdU'; // Replace with your method of retrieving the API key
  } else if (Platform.isAndroid || Platform.isIOS) {
    // Mobile platforms, we can use environment variables
    return Platform.environment['GEMINI_API_KEY'];
  } else {
    // For other platforms (desktop), handle accordingly (you can set environment variable or similar)
    return Platform.environment['GEMINI_API_KEY'];
  }
}
