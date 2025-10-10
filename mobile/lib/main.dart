import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/app.dart';

void main() {
  // Asegura que los bindings de Flutter se inicialicen correctamente
  WidgetsFlutterBinding.ensureInitialized();

  // Envuelve toda la app en un ProviderScope (necesario para Riverpod)
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

