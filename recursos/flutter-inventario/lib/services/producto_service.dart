// =============================================================================
//  Servicio: ProductoService
//  CRUD de productos contra la API de FastAPI.
//  Metodos: getAll, getById, create, update, delete.
// =============================================================================

import 'package:dio/dio.dart';

import '../models/producto.dart';
import '../core/network/api_exceptions.dart';

class ProductoService {
  final Dio _dio;

  ProductoService(this._dio);

  /// Obtiene todos los productos con paginacion opcional y filtro por categoria.
  ///
  /// [page] numero de pagina (empieza en 1)
  /// [size] cantidad de elementos por pagina
  /// [categoria] filtro opcional por categoria
  Future<PaginatedResponse<Producto>> getAll({
    int page = 1,
    int size = 20,
    String? categoria,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'pagina': page,
        'tamano': size,
      };
      if (categoria != null && categoria.isNotEmpty) {
        queryParams['categoria'] = categoria;
      }

      final response = await _dio.get(
        '/productos/',
        queryParameters: queryParams,
      );

      return PaginatedResponse<Producto>.fromJson(
        response.data as Map<String, dynamic>,
        Producto.fromJson,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) rethrow;
      throw ApiException('Error al obtener productos: ${e.message}');
    }
  }

  /// Obtiene un producto por su [id].
  Future<Producto> getById(int id) async {
    try {
      final response = await _dio.get('/productos/$id');
      return Producto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) rethrow;
      throw ApiException('Error al obtener producto: ${e.message}');
    }
  }

  /// Crea un nuevo producto (requiere JWT).
  ///
  /// [data] mapa con campos: codigo, nombre, descripcion, precio, stock, categoria
  Future<Producto> create(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/productos/', data: data);
      return Producto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) rethrow;
      throw ApiException('Error al crear producto: ${e.message}');
    }
  }

  /// Actualiza un producto existente por [id] (requiere JWT).
  ///
  /// [data] mapa con los campos a actualizar
  Future<Producto> update(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/productos/$id', data: data);
      return Producto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) rethrow;
      throw ApiException('Error al actualizar producto: ${e.message}');
    }
  }

  /// Elimina un producto por [id] (requiere JWT).
  Future<void> delete(int id) async {
    try {
      await _dio.delete('/productos/$id');
    } on DioException catch (e) {
      if (e.error is ApiException) rethrow;
      throw ApiException('Error al eliminar producto: ${e.message}');
    }
  }
}
