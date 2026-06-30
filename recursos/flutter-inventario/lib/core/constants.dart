/// Constantes globales de la aplicacion.
///
/// Centraliza todas las configuraciones como URL base,
/// claves de almacenamiento y configuraciones generales.
class AppConstants {
  // =========================================================================
  //  API
  // =========================================================================
  /// URL base de la API REST de FastAPI.
  /// Debe coincidir con el servidor donde corre el backend.
  static const String apiBaseUrl = 'http://localhost:8000/api';

  // =========================================================================
  //  Almacenamiento local (SharedPreferences)
  // =========================================================================
  /// Clave para guardar el token JWT en SharedPreferences.
  static const String tokenKey = 'auth_token';

  /// Clave para guardar los datos del usuario autenticado en JSON.
  static const String userKey = 'auth_user';

  // =========================================================================
  //  Paginacion
  // =========================================================================
  /// Cantidad de elementos por pagina en listas paginadas.
  static const int pageSize = 20;
}
