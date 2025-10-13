import 'providers/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/api.dart';
import 'screens/register_screen.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLogged = ref.watch(sessionProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Control de Uso del Móvil',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: isLogged ? DashboardScreen() : LoginScreen(),

      routes: {
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}


