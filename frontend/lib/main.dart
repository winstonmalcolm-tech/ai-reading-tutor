import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Boxhome(),
    );
  }
}

class Boxhome extends StatefulWidget {
  const Boxhome({super.key});

  @override
  State<Boxhome> createState() => _BoxhomeState();
}

class _BoxhomeState extends State<Boxhome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CarouselSlider(
            slideTransform: CubeTransform(perspectiveScale: -0.001),
            unlimitedMode: true,
            children: [
              Container(
                color: Colors.red,
                child: const Center(
                  child: Image(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/first.jpg'),
                  ),
                ),
              ),
              Container(
                color: Colors.green,
                child: const Center(
                  child: Image(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/second.jpg'),
                  ),
                ),
              ),
            ],
          ),

          Container(
            color: Colors.black,
            width: 50,
            height: 160,
            alignment: Alignment(1, 1),
          ),
        ],
      ),
    );
  }
}
