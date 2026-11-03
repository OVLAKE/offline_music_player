import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'services/player_service.dart';
import 'screens/home_page.dart'; // Add this import

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => PlayerService(),
      child: const OfflineMusicApp(),
    ),
  );
}

class OfflineMusicApp extends StatelessWidget {
  const OfflineMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline Music',
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomePage(), // Change this line to load the HomePage
    );
  }
}