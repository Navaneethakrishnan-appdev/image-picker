import 'dart:convert';
import 'dart:io';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class GeminiAiAssistant extends StatefulWidget {
  const GeminiAiAssistant({super.key});

  @override
  State<GeminiAiAssistant> createState() => _GeminiAiAssistantState();
}

class _GeminiAiAssistantState extends State<GeminiAiAssistant> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];
  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Gemini",
    profileImage: "assets/images/gemini-logo.png",
  );

  // List of allowed topics
  final List<String> allowedTopics = [
    // Physical Health & Exercise
    'yoga',
    'fitness',
    'exercise',
    'workout',
    'physical health',
    'physical activity',
    'strength training',
    'cardio',
    'flexibility',
    'stretching',

    // Nutrition & Diet
    'food',
    'nutrition',
    'diet',
    'healthy eating',
    'meal plan',
    'dietary',
    'supplements',
    'vitamins',
    'minerals',

    // Mental Health & Wellness
    'health',
    'wellness',
    'wellbeing',
    'mental health',
    'meditation',
    'mindfulness',
    'stress management',
    'sleep',
    'relaxation',
    'emotional health',

    // Lifestyle
    'lifestyle',
    'healthy living',
    'self-care',
    'work-life balance',
    'healthy habits',
    'preventive care',
    'holistic health',
    'alternative medicine',
    'natural remedies'
  ];

  // List of casual greetings and basic conversation
  final List<String> casualPhrases = [
    'hello',
    'hi',
    'hey',
    'good morning',
    'good afternoon',
    'good evening',
    'how are you',
    'how\'s it going',
    'what\'s up',
    'greetings',
    'thanks',
    'thank you',
    'bye',
    'goodbye',
    'see you',
    'nice to meet you',
    'pleasure to meet you'
  ];

  bool isCasualPhrase(String text) {
    String lowercaseText = text.toLowerCase();
    return casualPhrases.any((phrase) => lowercaseText.contains(phrase));
  }

  bool isHealthRelatedQuestion(String question) {
    String lowercaseQuestion = question.toLowerCase();

    // Allow casual phrases
    if (isCasualPhrase(lowercaseQuestion)) {
      return true;
    }

    // Check for health-related topics
    return allowedTopics.any((topic) => lowercaseQuestion.contains(topic));
  }

  void _onSend(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
      String question = chatMessage.text;

      // Check if the question is health-related or casual
      if (!isHealthRelatedQuestion(question)) {
        ChatMessage responseMessage = ChatMessage(
          text:
              "⚠️ I'm a yoga and fitness trainer assistant. I can help you with questions about yoga, fitness, food, exercise, health, and wellness. Feel free to ask anything about these topics!",
          user: geminiUser,
          createdAt: DateTime.now(),
        );
        setState(() {
          messages = [responseMessage, ...messages];
        });
        return;
      }

      // Add system prompt to guide Gemini's responses
      String systemPrompt =
          "You are a friendly health and wellness expert. For casual greetings, respond warmly and briefly. For health-related questions, provide detailed information about yoga, fitness, food, exercise, health, and wellness topics. If asked about other topics, politely redirect the conversation to health and wellness.";
      List<Part> parts = [
        Part.text(systemPrompt + "\n\nUser message: " + question)
      ];

      if (chatMessage.medias?.isNotEmpty ?? false) {
        for (var media in chatMessage.medias!) {
          if (media.type == MediaType.image) {
            parts.add(Part.inline(InlineData(
                data: base64Encode(File(media.url).readAsBytesSync()),
                mimeType: "image/jpeg")));
          }
        }
      }
      gemini.promptStream(parts: parts).listen((event) {
        print("Gemini event: $event");
        print("Gemini event content: ${event?.content}");
        print("Gemini event parts: ${event?.content?.parts}");
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          String response = event?.output ?? "";
          lastMessage.text += response;
          setState(() {
            messages = [lastMessage!, ...messages];
          });
        } else {
          String response = event?.output ?? "";
          ChatMessage responseMessage = ChatMessage(
            text: response,
            user: geminiUser,
            createdAt: DateTime.now(),
          );
          setState(() {
            messages = [responseMessage, ...messages];
          });
        }
      });
    } catch (e) {
      print("Error $e");
    }
  }

  void _sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: "Describe this picture?",
        medias: [
          ChatMedia(url: file.path, fileName: "", type: MediaType.image),
        ],
      );
      _onSend(chatMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Stack(
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
        DashChat(
          inputOptions: InputOptions(
            inputDecoration: InputDecoration(
              hintText: "Ask me something...",
              hintStyle: GoogleFonts.outfit(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(
                  color: Color(0xff129990),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(
                  color: Color(0xff129990),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(
                  color: Color(0xff9B7EBD),
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              prefixIcon: const Icon(
                Icons.chat_bubble_outline,
                color: Color(0xff129990),
              ),
            ),
            trailing: [
              IconButton(
                onPressed: _sendMediaMessage,
                icon: const Icon(
                  Icons.image,
                  color: Color(0xff129990),
                ),
              ),
            ],
          ),
          currentUser: currentUser,
          onSend: _onSend,
          messages: messages,
          messageOptions: MessageOptions(
            currentUserContainerColor: const Color(0xff129990),
            currentUserTextColor: Colors.white,
            containerColor: const Color(0xff9B7EBD),
            textColor: Colors.white,
            messageDecorationBuilder: (message, prev, next) {
              return BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: message.user.id == currentUser.id ? const Color(0xff129990) : const Color(0xff9B7EBD),
              );
            },
            messageTextBuilder: (message, prev, next) {
              return Text(
                message.text,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
