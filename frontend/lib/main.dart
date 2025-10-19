import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/auth.dart';
import 'package:frontend/screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vapi/vapi.dart' show VapiClient;
import 'firebase_options.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  
  await VapiClient.platformInitialized.future;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reader', debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/auth' : '/home',
      routes: {
        '/auth': (context) => const Auth(),
        '/home': (context) => const Home(),
      },
    );
  }
}
