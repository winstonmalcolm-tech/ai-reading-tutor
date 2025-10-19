import "package:flutter/material.dart";
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  @override
  Widget build(BuildContext context) {
    final providers = [EmailAuthProvider()];

    return Scaffold(
      body: SignInScreen(
        providers: providers,
        actions: [
          AuthStateChangeAction<SignedIn>((context, state) {
            Navigator.pushReplacementNamed(context, '/home');
          }),
        ],
      ),
    );
  }
}