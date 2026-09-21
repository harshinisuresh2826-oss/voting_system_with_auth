import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/voting_service.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => VotingService(),
      child: const VotePulseApp(),
    ),
  );
}

class VotePulseApp extends StatelessWidget {
  const VotePulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VotePulse — Full-Stack Voting System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF050814),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00F2FE),
          secondary: Color(0xFF00F5A0),
          surface: Color(0xFF0D1326),
        ),
        fontFamily: 'SpaceGrotesk',
      ),
      home: const HomeScreen(),
    );
  }
}
