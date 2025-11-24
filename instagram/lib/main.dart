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
      // 앱 전체 테마를 밝게 설정
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white, // 기본 배경색
        primaryColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // 앱바 배경 흰색
          elevation: 0, // 그림자 없음
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black), // 뒤로가기 등 아이콘 검은색
          titleTextStyle: TextStyle( // 앱바 제목 스타일
            color: Colors.black,
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: DefaultTextStyle(
        style: const TextStyle(
          // Provide common emoji-capable fonts as fallbacks. Order matters —
          // system-specific names first, then common cross-platform fonts.
          // On Windows: 'Segoe UI Emoji' or 'Segoe UI Symbol'
          // On macOS/iOS: 'Apple Color Emoji' (system) — usually doesn't need to be listed
          // On Android/Linux: 'Noto Color Emoji' / system fallbacks
          fontFamilyFallback: [
            'Segoe UI Emoji',
            'Segoe UI Symbol',
            'Noto Color Emoji',
            'Apple Color Emoji',
          ],
        ),
          child: MainNavigationScreen(key: mainNavKey), // 앱 시작 화면
      ),
    );
  }
}