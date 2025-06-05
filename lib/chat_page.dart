import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/get_open_router_response.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController chatController = TextEditingController();
  String answer = '';

  @override
  void dispose() {
    chatController.dispose();
    super.dispose();
  }

  List<ChatMessage> messages = [];

  void _talkToAi() async {
    final userText = chatController.text;
    setState(() {
      messages.add(ChatMessage(text: userText, isUser: true));
    });

    try {
      String aiReply = await getOpenRouterResponse(userText);
      setState(() {
        messages.add(ChatMessage(text: aiReply, isUser: false));
      });
    } catch (e) {
      setState(() {
        messages.add(ChatMessage(text: 'Error: $e', isUser: false));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff129990), Color(0xff9B7EBD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'AI Assistant',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.navigate_before, size: 35, color: Colors.white),
        ),
        actions: [
          IconButton(
            tooltip: 'Clear Chat',
            icon: const Icon(Icons.cleaning_services, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(
                    'Clear Chat?',
                    style: GoogleFonts.outfit(),
                  ),
                  content: Text(
                    'This will delete the entire conversation.',
                    style: GoogleFonts.outfit(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.outfit(
                          color: const Color(0xff129990),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          messages.clear();
                        });
                        Navigator.of(ctx).pop();
                      },
                      child: Text(
                        'Clear',
                        style: GoogleFonts.outfit(
                          color: const Color(0xff129990),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Opacity(
                opacity: 0.1,
                child: Text(
                  'Welcome to\nYoga and Fitness\nTrainer',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff129990),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];
                      if (!message.isUser && message.text.startsWith('Error:')) {
                        return const SizedBox.shrink(); // Hide error messages
                      }
                      return Align(
                        alignment: message.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: message.isUser
                                ? const Color(0xff129990)
                                : const Color(0xff9B7EBD),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            message.text,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: TextField(
                    style: GoogleFonts.outfit(color: Colors.black87),
                    controller: chatController,
                    decoration: InputDecoration(
                      hintText: 'Ask me something...',
                      hintStyle: GoogleFonts.outfit(color: Colors.grey[600]),
                      prefixIcon: const Icon(
                        Icons.chat_bubble_outline,
                        color: Color(0xff129990),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Color(0xff129990),
                          size: 28,
                        ),
                        onPressed: () {
                          if (chatController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a message!'),
                              ),
                            );
                            return;
                          }
                          FocusScope.of(context).unfocus();
                          _talkToAi();
                          chatController.clear();
                        },
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(
                          color: Color(0xff129990),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(
                          color: Color(0xff129990),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(
                          color: Color(0xff9B7EBD),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
