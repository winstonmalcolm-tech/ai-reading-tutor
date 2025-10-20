import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:vapi/vapi.dart';
import '../constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:math';
enum SupportedLanguage { 
  english, 
  spanish, 
  french 
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {

  var vapi = VapiClient(VapiClientKey);
  VapiCall? call;
  String extractedText = '';
  bool isLoading = false;
  
  final userId = FirebaseAuth.instance.currentUser?.uid;
  //final conversationId = 
  final sessionId = const Uuid().v4(); // Use uuid package

  Future<void> pickAndSendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      setState(() => extractedText = 'No image selected.');
      return;
    }

    final file = File(pickedFile.path);
    final dio = Dio();

    final formData = FormData.fromMap({
      'apikey': 'K82630750088957', // Replace with your OCR.space key
      'language': 'eng',
      'file': await MultipartFile.fromFile(file.path),
    });

    try {
      final response = await dio.post(
        'https://api.ocr.space/parse/image',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      final parsedText = response.data['ParsedResults']?[0]?['ParsedText'] ?? 'No text found';
      setState(() => extractedText = parsedText);

      call?.send({
        "type": "add-message",
        "message": {
          "role": "user",
          "content": "The user uploaded a file with the text contents, `$extractedText`",
        },
      });

      ScaffoldMessenger(child: const Text("Image uploaded successfully"),);

    } catch (e) {
      setState(() => extractedText = 'Error uploading image');

      call?.send({
        "type": "add-message",
        "message": {
          "role": "system",
          "content": "There is an error reading the user uploaded file.",
        },
      });
    }
    // print(extractedText);
  }

  String getLocale(SupportedLanguage lang) {
    switch (lang) {
      case SupportedLanguage.english: return 'en-US';
      case SupportedLanguage.spanish: return 'es-ES';
      case SupportedLanguage.french: return 'fr-FR';
    }
  }
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Call state
  bool _isMuted = false;
  int _seconds = 0;
  Timer? _timer;

  // Chat messages
  List<Map<String, dynamic>> messages = [];

  late final AnimationController _animationController;

  String get _formattedTime {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _seconds = 0);
  }

  Future<void> startCall() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) return;

    try {

      setState(() {
        isLoading = true;
      });

      final c = await vapi.start(
        assistantId: AssistantId,
      );

      setState(() {
        call = c;
        isLoading = false;
      });

      
      _startTimer();
    } catch (e) {
      _stopTimer();
      ScaffoldMessenger(child: const Text("Error Connecting to AI Tutor"),);
    }
  }

  Future<void> stopCall() async {
    if (call != null) {
      await call!.stop();
      call!.dispose();
      setState(() => call = null);
      _stopTimer();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final text = _messageController.text.trim();
    setState(() {
      messages.add({
        'text': text,
        'isUser': true,
        'time': TimeOfDay.now(),
      });
    });

    call?.send({
        "type": "add-message",
        "message": {
          "role": "user",
          "content": text,
        },
      });

    _messageController.clear();
    _scrollToBottom();
  }

  @override
  void initState() {
    super.initState();
    _animationController =
    AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..repeat();
  }

  @override
  void dispose() {
    call?.dispose();
    vapi.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset(
              'assets/auth_child_1.png',
              height: 40,
            ),
            const SizedBox(width: 8),
            const Text(
              "Rocket Learners",
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.pink),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/auth');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: BackgroundPainter(_animationController.value * 2 * pi),
              );
            },
          ),
          // Content above background
          Column(
            children: [
              // Call bar
              Container(
                color: Colors.blue,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formattedTime,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                              _isMuted ? Icons.mic_off : Icons.mic,
                              color: Colors.white),
                          onPressed: () =>
                              setState(() => _isMuted = !_isMuted),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (call == null) {
                              startCall();
                            } else {
                              stopCall();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: call == null
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: isLoading ? SizedBox( width: 10, height: 10, child: CircularProgressIndicator(color: Colors.white)) : Row(
                              children: [
                                Icon(
                                    call == null ? Icons.call : Icons.call_end,
                                    color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  call == null ? "Start Call" : "End Call",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Chat messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isUser = msg['isUser'] as bool;
                    final time = msg['time'] as TimeOfDay;
                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.greenAccent : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg['text'],
                              style: TextStyle(
                                  color: isUser ? Colors.white : Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${time.format(context)}",
                              style: TextStyle(
                                color:
                                isUser ? Colors.white70 : Colors.black54,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Send message bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.black87.withOpacity(0.8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.upload_file, color: Colors.white),
                      onPressed: pickAndSendImage,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Type a message...",
                          hintStyle: TextStyle(color: Colors.white60),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.greenAccent),
                      onPressed: sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 🎨 Animated colorful background
class BackgroundPainter extends CustomPainter {
  final double angle;
  BackgroundPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Calculate dynamic radii with sine function for expansion/contraction
    final radius1 = 120 + sin(angle * 2) * 30; // circle1 radius
    final radius2 = 150 + cos(angle * 1.5) * 40; // circle2 radius
    final radius3 = 180 + sin(angle) * 50; // circle3 radius

    // Calculate moving positions
    final circle1 =
    Offset(size.width * 0.2 + sin(angle) * 40, size.height * 0.2 + cos(angle) * 40);
    final circle2 =
    Offset(size.width * 0.8 + cos(angle) * 60, size.height * 0.3 + sin(angle) * 50);
    final circle3 =
    Offset(size.width * 0.4 + sin(angle * 1.2) * 70, size.height * 0.8 + cos(angle * 1.3) * 70);

    // Draw circles
    paint.color = Colors.greenAccent.withOpacity(0.3);
    canvas.drawCircle(circle1, radius1, paint);

    paint.color = Colors.blueAccent.withOpacity(0.25);
    canvas.drawCircle(circle2, radius2, paint);

    paint.color = Colors.purpleAccent.withOpacity(0.25);
    canvas.drawCircle(circle3, radius3, paint);
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) =>
      oldDelegate.angle != angle;
}
