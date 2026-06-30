import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inventario/core/network/api_exceptions.dart';
import 'package:flutter_inventario/models/producto.dart';
import 'package:flutter_inventario/services/producto_service.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';

void main() {
  late MockDio mockDio;
  late ProductoService productoService;

  setUp(() {
    mockDio = MockDio();
    productoService = ProductoService(mockDio);
  });

  group('ProductoService - getAll', () {
    test('retorna PaginatedResponse<Producto> en caso de exito', () async {
      final paginatedJson = <String, dynamic>{
        'items': [
          <String, dynamic>{
            'id': 1,
            'codigo': 'PROD-001',
            'nombre': 'Laptop',
            'precio': 4999.99,
            'stock': 10,
          },
          <String, dynamic>{
            'id': 2,
            'codigo': 'PROD-002',
            'nombre': 'Mouse',
            'precio': 49.99,
            'stock': 100,
          },
        ],
        'total': 2,
        'pagina': 1,
        'tamano': 20,
        'total_paginas': 1,
      };
      when(mockDio.get(
        '/productos/',
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
        data: paginatedJson,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/productos/'),
      ));

      final result = await productoService.getAll();

      expect(result, isA<PaginatedResponse<Producto>>());
      expect(result.items.length, 2);
      expect(result.total, 2);
      expect(result.pagina, 1);
      expect(result.items.first.nombre, 'Laptop');
    });

    test('incluye filtro categoria en query params', () async {
      when(mockDio.get(
        '/productos/',
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
        data: <String, dynamic>{
          'items': <dynamic>[],
          'total': 0,
          'pagina': 1,
          'tamano': 20,
          'total_paginas': 0,
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/productos/'),
      ));

      await productoService.getAll(categoria: 'Electronica');

      verify(mockDio.get(
        '/productos/',
        queryParameters: {
          'pagina': 1,
          'tamano': 20,
          'categoria': 'Electronica',
        },
      )).called(1);
    });

    test('no incluye categoria cuando es nula', () async {
      when(mockDio.get(
        '/productos/',
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
        data: <String, dynamic>{
          'items': <dynamic>[],
          'total': 0,
          'pagina': 1,
          'tamano': 20,
          'total_paginas': 0,
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/productos/'),
      ));

      await productoService.getAll();

      verify(mockDio.get(
        '/productos/',
        queryParameters: {
          'pagina': 1,
          'tamano': 20,
        },
      )).called(1);
    });

    test('lanza ApiException cuando falla', () async {
      when(mockDio.get(
        '/productos/',
        queryParameters: anyNamed('queryParameters'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/productos/'),
      ));

      expect(
        () => productoService.getAll(),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('ProductoService - getById', () {
    test('retorna Producto en caso de exito', () async {
      final productoJson = <String, dynamic>{
        'id': 1,
        'codigo': 'PROD-001',
        'nombre': 'Laptop Gamer',
        'precio': 4999.99,
        'stock': 10,
        'estado': true,
      };
      when(mockDio.get('/productos/1')).thenAnswer((_) async => Response(
        data: productoJson,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/productos/1'),
      ));

      final result = await productoService.getById(1);

      expect(result, isA<Producto>());
      expect(result.id, 1);
      expect(result.nombre, 'Laptop Gamer');
    });

    test('lanza ApiException cuando falla', () async {
      when(mockDio.get('/productos/1')).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/productos/1'),
      ));

      expect(
        () => productoService.getById(1),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('ProductoService - create', () {
    test('retorna Producto creado en caso de exito', () async {
      final data = <String, dynamic>{
        'codigo': 'PROD-NEW',
        'nombre': 'Nuevo Producto',
        'precio': 150.0,
        'stock': 20,
      };
      final createdJson = <String, dynamic>{
        'id': 10,
        'codigo': 'PROD-NEW',
        'nombre': 'Nuevo Producto',
        'precio': 150.0,
        'stock': 20,
        'estado': true,
      };
      when(mockDio.post(
        '/productos/',
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
        data: createdJson,
        statusCode: 201,
        requestOptions: RequestOptions(path: '/productos/'),
      ));

      final result = await productoService.create(data);

      expect(result, isA<Producto>());
      expect(result.id, 10);
      expect(result.nombre, 'Nuevo Producto');
    });

    test('lanza ApiException cuando falla', () async {
      when(mockDio.post(
        '/productos/',
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/productos/'),
      ));

      expect(
        () => productoService.create(<String, dynamic>{}),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('ProductoService - update', () {
    test('retorna Producto actualizado en caso de exito', () async {
      final data = <String, dynamic>{
        'nombre': 'Laptop Actualizada',
        'precio': 5499.99,
      };
      final updatedJson = <String, dynamic>{
        'id': 1,
        'codigo': 'PROD-001',
        'nombre': 'Laptop Actualizada',
        'precio': 5499.99,
        'stock': 10,
        'estado': true,
      };
      when(mockDio.put(
        '/productos/1',
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
        data: updatedJson,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/productos/1'),
      ));

      final result = await productoService.update(1, data);

      expect(result, isA<Producto>());
      expect(result.nombre, 'Laptop Actualizada');
      expect(result.precio, 5499.99);
    });

    test('lanza ApiException cuando falla', () async {
      when(mockDio.put(
        '/productos/1',
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/productos/1'),
      ));

      expect(
        () => productoService.update(1, <String, dynamic>{}),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('ProductoService - delete', () {
    test('ejecuta DELETE request correctamente', () async {
      when(mockDio.delete('/productos/1')).thenAnswer((_) async => Response(
        statusCode: 204,
        requestOptions: RequestOptions(path: '/productos/1'),
      ));

      await productoService.delete(1);

      verify(mockDio.delete('/productos/1')).called(1);
    });

    test('lanza ApiException cuando falla', () async {
      when(mockDio.delete('/productos/1')).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/productos/1'),
      ));

      expect(
        () => productoService.delete(1),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
