import 'package:flutter/material.dart';
import 'package:playon/features/shell/presentation/pages/shell_page.dart';

void main() {
  runApp(const PlayOnApp());
}

class PlayOnApp extends StatelessWidget {
  const PlayOnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlayON',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
        ),
      ),
      home: const ShellPage(),
    );
  }
}