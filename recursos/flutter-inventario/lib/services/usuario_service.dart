// =============================================================================
//  Servicio: UsuarioService
//  CRUD de usuarios contra la API de FastAPI.
//  Solo accesible por usuarios con rol Administrador.
// =============================================================================

import 'package:dio/dio.dart';

import '../models/usuario.dart';
import '../core/network/api_exceptions.dart';

class UsuarioService {
  final Dio _dio;

  UsuarioService(this._dio);

  /// Obtiene la lista de todos los usuarios (requiere rol Admin).
  Future<List<Usuario>> getAll() async {
    try {
      final response = await _dio.get('/usuarios/');
      final data = response.data as List<dynamic>;
      return data
          .map((e) => Usuario.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.error is ApiException) rethrow;
      throw ApiException('Error al obtener usuarios: ${e.message}');
    }
  }

  /// Obtiene un usuario por [id] (requiere rol Admin).
  Future<Usuario> getById(int id) async {
    try {
      final response = await _dio.get('/usuarios/$id');
      return Usuario.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) rethrow;
      throw ApiException('Error al obtener usuario: ${e.message}');
    }
  }

  /// Crea un nuevo usuario (requiere rol Admin).
  ///
  /// [data] mapa con campos: username, nombre_completo, email, rol_id
  Future<Usuario> create(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/auth/register', data: data);
      return Usuario.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) rethrow;
      throw ApiException('Error al crear usuario: ${e.message}');
    }
  }

  /// Actualiza un usuario por [id] (requiere rol Admin).
  ///
  /// [data] mapa con campos: username, nombre_completo, email, rol_id
  Future<Usuario> update(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/usuarios/$id', data: data);
      return Usuario.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) rethrow;
      throw ApiException('Error al actualizar usuario: ${e.message}');
    }
  }
}
