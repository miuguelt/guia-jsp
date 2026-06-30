import 'package:dio/dio.dart';
import 'package:flutter_inventario/services/auth_service.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([
  MockSpec<Dio>(),
  MockSpec<AuthService>(),
])
void main() {}
