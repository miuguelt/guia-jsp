// =============================================================================
//  Punto de entrada de la aplicacion Flutter.
//  Inicializa los bindings de Flutter y ejecuta la app con ProviderScope.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() async {
  // Asegura que los bindings de Flutter esten inicializados
  // antes de usar cualquier plugin (SharedPreferences, etc.).
  WidgetsFlutterBinding.ensureInitialized();

  // Ejecuta la aplicacion dentro de un ProviderScope.
  // ProviderScope es el contenedor principal del estado de Riverpod
  // y debe estar en la raiz del arbol de widgets.
  runApp(
    const ProviderScope(
      child: InventarioApp(),
    ),
  );
}
