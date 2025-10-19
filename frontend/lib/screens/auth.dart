import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  final providers = [EmailAuthProvider()];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌈 Animated background
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final angle = _animationController.value * 2 * pi;
              return CustomPaint(
                painter: BackgroundPainter(angle),
                size: MediaQuery.of(context).size,
              );
            },
          ),

          // 🧾 SignInScreen takes full screen
          SignInScreen(
            providers: providers,
            showAuthActionSwitch: true,
            headerBuilder: (context, constraints, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 60,
                color: Colors.greenAccent[400],
              ),
            ),
            subtitleBuilder: (context, action) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                action == AuthAction.signIn
                    ? 'Enter your email and password to sign in'
                    : 'Enter your email and password to register',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            sideBuilder: (context, shrinkOffset) => Container(),
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                Navigator.pushReplacementNamed(context, '/home');
              }),
              AuthStateChangeAction<UserCreated>((context, state) {
                Navigator.pushReplacementNamed(context, '/home');
              }),
            ],
          ),
        ],
      ),
    );
  }
}

// 🎨 Animated Background Painter
class BackgroundPainter extends CustomPainter {
  final double angle;
  BackgroundPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final circle1 = Offset(
      size.width * 0.2 + sin(angle) * 40,
      size.height * 0.2 + cos(angle) * 40,
    );
    final circle2 = Offset(
      size.width * 0.8 + cos(angle) * 60,
      size.height * 0.3 + sin(angle) * 50,
    );
    final circle3 = Offset(
      size.width * 0.4 + sin(angle) * 70,
      size.height * 0.8 + cos(angle) * 70,
    );

    paint.color = Colors.greenAccent.withOpacity(0.3);
    canvas.drawCircle(circle1, 120, paint);

    paint.color = Colors.blueAccent.withOpacity(0.25);
    canvas.drawCircle(circle2, 150, paint);

    paint.color = Colors.purpleAccent.withOpacity(0.25);
    canvas.drawCircle(circle3, 180, paint);
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) =>
      oldDelegate.angle != angle;
}
