// =============================================================================
//  Servicio: AuthService
//  Encargado de la autenticacion contra la API de FastAPI.
//  Metodos: login, register, getProfile, getRoles.
// =============================================================================

import 'package:dio/dio.dart';

import '../models/auth_response.dart';
import '../models/usuario.dart';
import '../core/network/api_exceptions.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  /// Inicia sesion con [username] y [password].
  ///
  /// Retorna un [AuthResponse] con el token JWT y datos del usuario.
  /// Lanza [ApiException] si las credenciales son invalidas.
  Future<AuthResponse> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'username': username, 'password': password},
      );
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) rethrow;
      throw ApiException('Error al iniciar sesion: ${e.message}');
    }
  }

  /// Registra un nuevo usuario en el sistema.
  ///
  /// [username] nombre de usuario unico
  /// [password] contrasena (minimo 6 caracteres)
  /// [nombreCompleto] nombre completo del usuario
  /// [email] correo electronico valido
  /// [rolId] ID del rol (1=Administrador, 2=Auxiliar, 3=Consultor)
  ///
  /// Retorna el [Usuario] creado.
  Future<Usuario> register(
    String username,
    String password,
    String nombreCompleto,
    String email,
    int rolId,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'username': username,
          'password': password,
          'nombre_completo': nombreCompleto,
          'email': email,
          'rol_id': rolId,
        },
      );
      return Usuario.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) rethrow;
      throw ApiException('Error al registrar: ${e.message}');
    }
  }

  /// Obtiene el perfil del usuario autenticado (requiere JWT).
  Future<Usuario> getProfile() async {
    try {
      final response = await _dio.get('/auth/me');
      return Usuario.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) rethrow;
      throw ApiException('Error al obtener perfil: ${e.message}');
    }
  }

  /// Obtiene la lista de roles disponibles en el sistema.
  Future<List<Rol>> getRoles() async {
    try {
      final response = await _dio.get('/roles/');
      final data = response.data as List<dynamic>;
      return data
          .map((e) => Rol.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.error is ApiException) rethrow;
      throw ApiException('Error al obtener roles: ${e.message}');
    }
  }
}
