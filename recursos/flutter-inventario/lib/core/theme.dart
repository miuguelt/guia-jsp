import 'package:flutter/material.dart';

/// Tema corporativo SENA para la aplicacion.
///
/// Define la paleta de colores, tipografia y estilos globales
/// para mantener consistencia visual en toda la app.
class AppTheme {
  // =========================================================================
  //  Colores SENA
  // =========================================================================
  /// Color primario: verde institucional SENA.
  static const Color primaryColor = Color(0xFF00664A);
  /// Color secundario: verde claro para acentos.
  static const Color secondaryColor = Color(0xFF008C6E);
  /// Color de fondo general.
  static const Color backgroundColor = Color(0xFFF5F5F5);
  /// Color de superficie (tarjetas, contenedores).
  static const Color surfaceColor = Colors.white;
  /// Color para texto sobre fondo oscuro.
  static const Color onPrimaryColor = Colors.white;
  /// Color de error.
  static const Color errorColor = Color(0xFFB00020);

  // =========================================================================
  //  Tema de Material Design
  // =========================================================================
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: onPrimaryColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        elevation: 2,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimaryColor,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: surfaceColor,
      ),
    );
  }
}
