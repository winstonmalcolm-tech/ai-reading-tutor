//54983ab0-573b-48e7-b360-d20f6862e205
//d8eff435-d205-4682-815a-46fccf227313

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import "package:flutter/material.dart";
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:vapi/vapi.dart';
import '../constants.dart';

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

class _HomeState extends State<Home> {

  var vapi = VapiClient(VapiClientKey);
  VapiCall? call;
  String extractedText = '';
  
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

  Future<void> startCall() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      print("Microphone permission denied");
      return;
    }

    try {
      final c = await vapi.start(assistantId: AssistantId);
      setState(() {
        call = c;
      });

      c.onEvent.listen((event) {
        // handle events
        print('Event: ${event.label}, value: ${event.value}');
      });
    } catch (e) {
      print('Failed to start call: $e');
      ScaffoldMessenger(child: const Text("Error Connecting to AI Tutor"),);
    }
  }

  Future<void> stopCall() async {
    if (call != null) {
      await call!.stop();
      call!.dispose();
      setState(() {
        call = null;
      });
    }
  }

  @override
  void dispose() {
    call?.dispose();
    vapi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Column(
          children: 
          [
            Row(
              children: [
                call == null
              ? ElevatedButton(
                  onPressed: startCall,
                  child: const Text('Start Voice Session'),
                )
              : ElevatedButton(
                  onPressed: stopCall,
                  child: const Text('End Voice Session'),
                ),
            
              ElevatedButton(
                onPressed: pickAndSendImage,
                child: const Text("Upload Image")
              ),

              ],
            ),
            
            Text(extractedText)
          ]
        ),
    );
  }
}