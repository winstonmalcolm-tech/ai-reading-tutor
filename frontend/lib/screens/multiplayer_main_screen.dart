import "package:flutter/material.dart";

class MultiplayMainScreen extends StatefulWidget {
  const MultiplayMainScreen({super.key});

  @override
  State<MultiplayMainScreen> createState() => _MultiplayMainScreenState();
}

class _MultiplayMainScreenState extends State<MultiplayMainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Multiplayer Games"),
      ),
      body: Center(
        child: ListView(
          children: [
            ListTile(
              title: const Text("Spelling Bee"),
              subtitle: const Text("2 players"),
              onTap: () {
                // Navigate to game room 1
                
              },
            )
          ],
        ),
      ),
    );
  }
}