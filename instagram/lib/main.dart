// lib/main.dart

import 'package:flutter/material.dart';
import 'package:instagram/screens/main_navigation_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram Clone',
      debugShowCheckedModeBanner: false,
      // 앱 전체 테마를 어둡게 설정 (영상 참고)
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black, // 기본 배경색
        primaryColor: Colors.black,
      ),
      home: const MainNavigationScreen(), // 앱이 시작될 때 보여줄 화면
    );
  }
}