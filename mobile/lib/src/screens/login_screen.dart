import 'package:flutter/material.dart';
import '../services/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final apiProvider = Provider((ref) => ApiService());
final storage = FlutterSecureStorage();

class LoginScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtr = TextEditingController();
  final _passCtr = TextEditingController();
  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);
    final api = ref.read(apiProvider);
    try {
      final res = await api.login(_emailCtr.text, _passCtr.text);
      final data = res.data;
      await storage.write(key: 'access_token', value: data['access']);
      await storage.write(key: 'refresh_token', value: data['refresh']);
      ref.read(isAuthenticatedProvider.notifier).state = true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Spacer(),
            TextField(controller: _emailCtr, decoration: InputDecoration(labelText: 'Email')),
            SizedBox(height:8),
            TextField(controller: _passCtr, obscureText: true, decoration: InputDecoration(labelText: 'Password')),
            SizedBox(height:16),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading ? CircularProgressIndicator() : Text('Ingresar'),
            ),
            Spacer(),
          ],
        ),
      )),
    );
  }
}
