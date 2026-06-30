import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inventario/core/constants.dart';
import 'package:flutter_inventario/core/network/api_client.dart';
import 'package:flutter_inventario/core/network/api_exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ApiClient - configuracion', () {
    test('configura URL base correcta', () {
      final dio = createApiClient();
      expect(dio.options.baseUrl, AppConstants.apiBaseUrl);
    });

    test('configura Content-Type como application/json', () {
      final dio = createApiClient();
      expect(dio.options.headers['Content-Type'], 'application/json');
    });

    test('configura timeouts de conexion y recepcion', () {
      final dio = createApiClient();
      expect(dio.options.connectTimeout, const Duration(seconds: 15));
      expect(dio.options.receiveTimeout, const Duration(seconds: 15));
    });
  });

  group('ApiClient - interceptores', () {
    test('registra tres interceptores (token, errores, log)', () {
      final dio = createApiClient();
      expect(dio.interceptors.length, 3);
    });
  });

  group('ApiClient - interceptor de token', () {
    test('agrega header Authorization cuando existe token', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.tokenKey: 'test-jwt-token',
      });
      final dio = createApiClient();
      final options = RequestOptions(path: '/test');

      final interceptor = dio.interceptors[0] as InterceptorsWrapper;
      interceptor.onRequest(options, RequestInterceptorHandler());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(options.headers['Authorization'], 'Bearer test-jwt-token');
    });

    test('omite header Authorization cuando no hay token', () async {
      SharedPreferences.setMockInitialValues({});
      final dio = createApiClient();
      final options = RequestOptions(path: '/test');

      final interceptor = dio.interceptors[0] as InterceptorsWrapper;
      interceptor.onRequest(options, RequestInterceptorHandler());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(options.headers.containsKey('Authorization'), isFalse);
    });
  });

  group('ApiClient - interceptor de error', () {
    test('elimina token de SharedPreferences en error 401', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.tokenKey: 'token-a-eliminar',
        AppConstants.userKey: '{}',
      });
      final dio = createApiClient();
      final errOptions = RequestOptions(path: '/test');
      final dioError = DioException(
        requestOptions: errOptions,
        response: Response(
          statusCode: 401,
          requestOptions: errOptions,
        ),
      );

      final interceptor = dio.interceptors[1] as InterceptorsWrapper;
      interceptor.onError(dioError, ErrorInterceptorHandler());
      await Future.delayed(const Duration(milliseconds: 50));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AppConstants.tokenKey), isNull);
      expect(prefs.getString(AppConstants.userKey), isNull);
    });

    test('NO elimina token en errores que no son 401', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.tokenKey: 'token-conservado',
        AppConstants.userKey: '{}',
      });
      final dio = createApiClient();
      final errOptions = RequestOptions(path: '/test');
      final dioError = DioException(
        requestOptions: errOptions,
        response: Response(
          statusCode: 400,
          requestOptions: errOptions,
        ),
      );

      final interceptor = dio.interceptors[1] as InterceptorsWrapper;
      interceptor.onError(dioError, ErrorInterceptorHandler());
      await Future.delayed(const Duration(milliseconds: 50));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AppConstants.tokenKey), 'token-conservado');
    });

    test('convierte el error en ApiException dentro de un DioException', () async {
      SharedPreferences.setMockInitialValues({});
      final dio = createApiClient();
      final errOptions = RequestOptions(path: '/test');
      final dioError = DioException(
        requestOptions: errOptions,
        response: Response(
          statusCode: 404,
          requestOptions: errOptions,
        ),
      );

      ErrorInterceptorHandler? capturedHandler;
      final interceptorWrapper = dio.interceptors[1] as InterceptorsWrapper;

      DioException? rejectedError;
      interceptorWrapper.onError(
        dioError,
        ErrorInterceptorHandler()
          ..reject = (e) {
            rejectedError = e;
          },
      );
      await Future.delayed(const Duration(milliseconds: 50));

      expect(rejectedError?.error, isA<ApiException>());
    });
  });
}
