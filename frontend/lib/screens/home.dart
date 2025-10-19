//54983ab0-573b-48e7-b360-d20f6862e205
//d8eff435-d205-4682-815a-46fccf227313

import "package:flutter/material.dart";
import 'package:permission_handler/permission_handler.dart';
import 'package:vapi/vapi.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  var vapi = VapiClient("");
  VapiCall? call;

  Future<void> startCall() async {

    final status = await Permission.microphone.request();
if (!status.isGranted) {
  print("Microphone permission denied");
  return;
}

    try {
      final c = await vapi.start(assistantId: '');
      setState(() {
        call = c;
      });
      c.onEvent.listen((event) {
        // handle events
        print('Event: ${event.label}, value: ${event.value}');
      });
    } catch (e) {
      print('Failed to start call: $e');
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
      body: Center(
          child: call == null
            ? ElevatedButton(
                onPressed: startCall,
                child: const Text('Start Voice Session'),
              )
            : ElevatedButton(
                onPressed: stopCall,
                child: const Text('End Voice Session'),
              ),
        ),
    );
  }
}