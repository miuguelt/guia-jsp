// =============================================================================
//  Provider: UsuariosProvider (AsyncNotifier)
//  Gestiona el CRUD de usuarios: listar, crear, actualizar.
//  Solo accesible por usuarios con rol Administrador.
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';
import 'auth_provider.dart';

// ---------------------------------------------------------------------------
//  Notifier asincrono de usuarios
// ---------------------------------------------------------------------------

class UsuariosNotifier extends AsyncNotifier<List<Usuario>> {
  UsuarioService get _service => ref.read(usuarioServiceProvider);

  @override
  Future<List<Usuario>> build() async {
    return _authenticatedCall(() => _service.getAll());
  }

  /// Refresca la lista de usuarios desde la API.
  Future<void> fetchAll() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _authenticatedCall(() => _service.getAll()),
    );
  }

  /// Crea un nuevo usuario y actualiza la lista local.
  Future<void> create(Map<String, dynamic> data) async {
    await _authenticatedCall(() => _service.create(data));
    await fetchAll();
  }

  /// Actualiza un usuario existente y actualiza la lista local.
  Future<void> update(int id, Map<String, dynamic> data) async {
    await _authenticatedCall(() => _service.update(id, data));
    await fetchAll();
  }

  // -----------------------------------------------------------------------
  //  Metodo auxiliar: manejo de errores 401
  // -----------------------------------------------------------------------
  Future<T> _authenticatedCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        ref.read(authProvider.notifier).logout();
      }
      rethrow;
    }
  }
}

// ---------------------------------------------------------------------------
//  Providers
// ---------------------------------------------------------------------------

/// Provider del servicio de usuarios (Dio inyectado).
final usuarioServiceProvider = Provider<UsuarioService>((ref) {
  return UsuarioService(ref.read(dioProvider));
});

/// Provider del estado de usuarios (AsyncNotifier).
final usuariosProvider =
    AsyncNotifierProvider<UsuariosNotifier, List<Usuario>>(
  UsuariosNotifier.new,
);
