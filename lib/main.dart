import 'package:accounting/my_home_page.dart';
import 'package:accounting/screens/add_transaction.dart';
import 'package:accounting/screens/login.dart';
import 'package:accounting/screens/profile/profile.dart';
import 'package:accounting/screens/register.dart';
import 'package:accounting/screens/settings.dart';
import 'package:accounting/screens/welcome.dart';
import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'screens/main_shell.dart';
import 'services/api_service.dart';
import 'services/token_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiService.token = await TokenStorage.read();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enterprise Accounting',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainShell(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/add_transaction': (context) => const AddTransactionScreen(),
      },
    );
  }
}
