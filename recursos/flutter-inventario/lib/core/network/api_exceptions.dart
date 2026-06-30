/// Excepcion personalizada para errores de la API.
///
/// Encapsula el codigo HTTP y un mensaje descriptivo
/// para facilitar el manejo de errores en la capa de UI.
class ApiException implements Exception {
  /// Codigo HTTP de la respuesta (400, 401, 404, 500, etc.).
  final int? statusCode;

  /// Mensaje descriptivo del error.
  final String message;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
