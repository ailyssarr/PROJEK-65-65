import 'package:flutter/material.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'pages/login_page.dart';
import 'pages/home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await NotificationService.init(); // <-- inisialisasi notif

  runApp(const FoodMateApp());
}

class FoodMateApp extends StatelessWidget {
  const FoodMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedIn = HiveService.isLoggedIn();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoodMate',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: loggedIn ? const HomeShell() : const LoginPage(),
    );
  }
}
