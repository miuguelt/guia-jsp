import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import 'api_exceptions.dart';

/// Crea y configura una instancia singleton de [Dio] para toda la app.
///
/// Incluye:
/// - URL base desde [AppConstants.apiBaseUrl]
/// - Interceptor que agrega el token JWT del almacenamiento local
/// - Interceptor que maneja errores HTTP y los convierte en [ApiException]
/// - Interceptor de log para depuracion en consola
Dio createApiClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // -----------------------------------------------------------------------
  //  Interceptor 1: Agrega el token JWT a cada peticion
  // -----------------------------------------------------------------------
  // Lee el token desde SharedPreferences y lo inyecta como
  // encabezado Authorization: Bearer <token>
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(AppConstants.tokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );

  // -----------------------------------------------------------------------
  //  Interceptor 2: Manejo centralizado de errores HTTP
  // -----------------------------------------------------------------------
  // Convierte errores de Dio/DioException en ApiException y
  // limpia el token si el servidor responde 401 (no autorizado).
  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (error, handler) async {
        final statusCode = error.response?.statusCode;
        String message;

        switch (statusCode) {
          case 400:
            message = 'Solicitud invalida';
            break;
          case 401:
            // Token invalido o expirado -> limpiar almacenamiento local.
            // El estado en memoria del AuthNotifier se limpia aparte
            // cuando los providers detecten el error 401 en sus metodos.
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove(AppConstants.tokenKey);
            await prefs.remove(AppConstants.userKey);
            message = 'Sesion expirada. Inicie sesion nuevamente.';
            break;
          case 403:
            message = 'Acceso denegado. No tiene permisos suficientes.';
            break;
          case 404:
            message = 'Recurso no encontrado';
            break;
          case 422:
            final detail = error.response?.data;
            if (detail is Map && detail.containsKey('detail')) {
              final detailVal = detail['detail'];
              if (detailVal is List && detailVal.isNotEmpty) {
                message = detailVal[0]['msg'] ?? 'Error de validacion';
              } else {
                message = detailVal.toString();
              }
            } else {
              message = 'Error de validacion de datos';
            }
            break;
          case 500:
            message = 'Error interno del servidor';
            break;
          default:
            message = 'Error de conexion. Verifique el servidor.';
        }

        handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            error: ApiException(message, statusCode: statusCode),
            type: error.type,
          ),
        );
      },
    ),
  );

  // -----------------------------------------------------------------------
  //  Interceptor 3: Log de depuracion
  // -----------------------------------------------------------------------
  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
    ),
  );

  return dio;
}

/// Provider de Riverpod que expone la instancia singleton de [Dio].
final dioProvider = Provider<Dio>((ref) {
  return createApiClient();
});
