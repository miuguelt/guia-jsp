# =============================================================================
# Dockerfile multi-etapa para Flutter Web
# =============================================================================
# Este Dockerfile compila la app Flutter a web estática y la sirve con Nginx.
#
# Uso:
#   docker build -t flutter-inventario .
#   docker run -p 3000:80 flutter-inventario
# =============================================================================

# ---------------------------------------------------------------------------
# Etapa 1 — Compilación de la aplicación Flutter
# ---------------------------------------------------------------------------
FROM ghcr.io/cirruslabs/flutter:3.27.0 AS build

# Directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiar primero solo el archivo de dependencias para cachear layers
COPY pubspec.yaml ./
COPY pubspec.lock* ./

# Descargar dependencias de Dart/Flutter
RUN flutter pub get

# Copiar el resto del código fuente
COPY . .

# ARG para inyectar URL de API via --dart-define (Coolify / docker-compose)
ARG API_BASE_URL=http://localhost:8000/api

# Construir la aplicación para web con optimización de producción
RUN flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL

# ---------------------------------------------------------------------------
# Etapa 2 — Servir con Nginx
# ---------------------------------------------------------------------------
FROM nginx:alpine

# Copiar el build de Flutter web al directorio servido por Nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Copiar configuración personalizada de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Puerto de exposición
EXPOSE 80

# Iniciar Nginx en primer plano
CMD ["nginx", "-g", "daemon off;"]
