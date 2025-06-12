import 'dart:async';
import 'package:flutter/material.dart';
import '../Screens/homePage.dart'; 

class ResultSplashScreen extends StatefulWidget {
  final bool success;

  const ResultSplashScreen({super.key, required this.success});

  @override
  State<ResultSplashScreen> createState() => _ResultSplashScreenState();
}

class _ResultSplashScreenState extends State<ResultSplashScreen>
    with SingleTickerProviderStateMixin {
  late bool showCheck;

  @override
  void initState() {
    super.initState();
    showCheck = false;

    Timer(const Duration(seconds: 2), () {
      setState(() {
        showCheck = true;
      });
    });

    Timer(const Duration(seconds: 4), () {
      if (widget.success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      } else {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = widget.success ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: bgColor.withOpacity(0.1),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: showCheck
              ? Icon(
                  widget.success ? Icons.check_circle_outline : Icons.error_outline,
                  key: const ValueKey('check'),
                  size: 100,
                  color: bgColor,
                )
              : CircleAvatar(
                  key: const ValueKey('face'),
                  backgroundColor: bgColor,
                  radius: 50,
                  child: const Icon(
                    Icons.tag_faces,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
