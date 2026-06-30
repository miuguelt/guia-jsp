# ============================================
# DOCKERFILE MULTI-STAGE
# Sistema de Inventario JSP + MVC | SENA ADSO
# Build: Maven → WAR → Tomcat 10.1 + JDK 21
# ============================================

# ---- Stage 1: Build ----
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app

# Copiar solo pom.xml primero para cachear dependencias
COPY recursos/codigo-ejemplo/pom.xml .
RUN mvn dependency:resolve -B

# Copiar código fuente y compilar
COPY recursos/codigo-ejemplo/src ./src
RUN mvn clean package -DskipTests -B

# ---- Stage 2: Run ----
FROM tomcat:10.1-jdk21-temurin

LABEL maintainer="ADSO SENA <adso@sena.edu.co>"
LABEL version="1.0"
LABEL description="Sistema de Inventario JSP MVC - SENA ADSO"

# Eliminar apps por defecto
RUN rm -rf /usr/local/tomcat/webapps/*

# Configurar zona horaria
ENV TZ=America/Bogota
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Copiar WAR generado desde la etapa de build
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Health check para Coolify
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Variables de entorno para conexión BD (Coolify las inyecta)
ENV DB_HOST=localhost
ENV DB_PORT=5432
ENV DB_NAME=inventario_db
ENV DB_USER=postgres
ENV DB_PASSWORD=postgres

EXPOSE 8080

CMD ["catalina.sh", "run"]
