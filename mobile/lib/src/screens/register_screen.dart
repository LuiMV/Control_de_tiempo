import 'package:flutter/material.dart';
import '../services/api.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _api = ApiService();
  final _nameCtr = TextEditingController();
  final _emailCtr = TextEditingController();
  final _passCtr = TextEditingController();
  bool _loading = false;

  void _register() async {
    setState(() => _loading = true);
    final success = await _api.register(
      _nameCtr.text,
      _emailCtr.text,
      _passCtr.text,
    );
    setState(() => _loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada correctamente')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrarse')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrarse')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _nameCtr, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: _emailCtr, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passCtr, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _register,
              child: _loading ? const CircularProgressIndicator() : const Text('Crear cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}

