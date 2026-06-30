// =============================================================================
//  Modelo: AuthResponse
//  Representa la respuesta del endpoint de autenticacion.
//  Contiene el token JWT y los datos del usuario autenticado.
// =============================================================================

import 'usuario.dart';

class AuthResponse {
  /// Token JWT para autenticar peticiones posteriores.
  final String accessToken;

  /// Tipo de token (siempre "bearer").
  final String tokenType;

  /// Datos del usuario que inicio sesion.
  final Usuario usuario;

  const AuthResponse({
    required this.accessToken,
    this.tokenType = 'bearer',
    required this.usuario,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
      usuario: Usuario.fromJson(json['usuario'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'usuario': usuario.toJson(),
    };
  }

  @override
  String toString() =>
      'AuthResponse(usuario: ${usuario.username}, token: ${accessToken.length} chars)';
}
