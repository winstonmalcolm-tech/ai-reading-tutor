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
          // 🌈 Animated background with a more subtle design
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

          // 🧾 SignInScreen takes full screen, with a clean layout
          SignInScreen(
            providers: providers,
            showAuthActionSwitch: true,
            headerBuilder: (context, constraints, _) => Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 80,
                color: Colors.greenAccent[400],
              ),
            ),
            subtitleBuilder: (context, action) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                action == AuthAction.signIn
                    ? 'Enter your email and password to sign in'
                    : 'Enter your email and password to register',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                ),
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

// 🎨 Refined Background Painter with smooth animated design
class BackgroundPainter extends CustomPainter {
  final double angle;
  BackgroundPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Circle positions and their movements
    final circle1 = Offset(
      size.width * 0.2 + sin(angle) * 50,
      size.height * 0.2 + cos(angle) * 50,
    );
    final circle2 = Offset(
      size.width * 0.8 + cos(angle) * 80,
      size.height * 0.3 + sin(angle) * 60,
    );
    final circle3 = Offset(
      size.width * 0.5 + sin(angle) * 100,
      size.height * 0.8 + cos(angle) * 90,
    );

    // Draw circle 1 (soft green tone)
    paint.color = Colors.greenAccent.withOpacity(0.3);
    canvas.drawCircle(circle1, 120, paint);

    // Draw circle 2 (cool blue tone)
    paint.color = Colors.blueAccent.withOpacity(0.2);
    canvas.drawCircle(circle2, 150, paint);

    // Draw circle 3 (purple tone)
    paint.color = Colors.purpleAccent.withOpacity(0.2);
    canvas.drawCircle(circle3, 180, paint);
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) =>
      oldDelegate.angle != angle;
}

