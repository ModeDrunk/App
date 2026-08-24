import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno - IMPORTANTE: await
  try {
    await dotenv.load(fileName: ".env");
    print('✅ .env cargado correctamente');
  } catch (e) {
    print('❌ Error cargando .env: $e');
    // Si no existe .env, crear uno por defecto
    await dotenv.load();
  }

  runApp(
    const ProviderScope(
      child: ModoBorrachoApp(),
    ),
  );
}
