"""
Script de validacion para la guia JSP + Flutter.
Verifica estructura, archivos criticos y funcionalidad basica.
Ejecutar: python validate_guide.py
"""
import os
import sys
from pathlib import Path


class GuideValidator:
    def __init__(self, guide_path):
        self.guide_path = Path(guide_path)
        self.errors = []
        self.warnings = []
        self.passed = []
    
    def validate_structure(self):
        """Valida la estructura de directorios."""
        print("\n[1/8] Validando estructura de directorios...")
        
        required_dirs = [
            "web",
            "web/css",
            "web/js",
            "web/img/flutter",
            "recursos",
            "recursos/codigo-ejemplo",
            "recursos/sql",
            "recursos/docker",
            "recursos/flutter-inventario",
            "recursos/flutter-inventario/lib/core",
            "recursos/flutter-inventario/lib/core/network",
            "recursos/flutter-inventario/lib/models",
            "recursos/flutter-inventario/lib/providers",
            "recursos/flutter-inventario/lib/services",
            "recursos/flutter-inventario/lib/screens",
            "recursos/flutter-inventario/lib/screens/productos",
            "recursos/flutter-inventario/lib/screens/usuarios",
            ".devbrain"
        ]
        
        for dir_path in required_dirs:
            full_path = self.guide_path / dir_path
            if full_path.exists() and full_path.is_dir():
                self.passed.append(f"Directorio existe: {dir_path}")
                print(f"   [OK] {dir_path}")
            else:
                self.errors.append(f"Directorio faltante: {dir_path}")
                print(f"   [MISSING] {dir_path}")
    
    def validate_web_files(self):
        """Valida archivos web criticos."""
        print("\n[2/8] Validando archivos web...")
        
        required_files = [
            "web/index.html",
            "web/flutter-guide.html",
            "web/simuladores.html",
            "web/css/styles.css",
            "web/js/main.js"
        ]
        
        for file_path in required_files:
            full_path = self.guide_path / file_path
            if full_path.exists():
                size = full_path.stat().st_size
                self.passed.append(f"Archivo existe: {file_path} ({size} bytes)")
                print(f"   [OK] {file_path} ({size} bytes)")
            else:
                self.errors.append(f"Archivo faltante: {file_path}")
                print(f"   [MISSING] {file_path}")
    
    def validate_resource_files(self):
        """Valida archivos de recursos."""
        print("\n[3/8] Validando recursos...")
        
        required_files = [
            "recursos/sql/inventario_db.sql",
            "recursos/docker/Dockerfile",
            "recursos/codigo-ejemplo/pom.xml",
            "recursos/flutter-inventario/pubspec.yaml",
            "recursos/flutter-inventario/lib/main.dart",
            "recursos/flutter-inventario/lib/app.dart",
            "recursos/flutter-inventario/openapi.json",
            "recursos/flutter-inventario/Dockerfile"
        ]
        
        for file_path in required_files:
            full_path = self.guide_path / file_path
            if full_path.exists():
                self.passed.append(f"Recurso existe: {file_path}")
                print(f"   [OK] {file_path}")
            else:
                self.errors.append(f"Recurso faltante: {file_path}")
                print(f"   [MISSING] {file_path}")
    
    def validate_java_files(self):
        """Valida archivos Java del proyecto."""
        print("\n[4/8] Validando archivos Java...")
        
        java_files = [
            "recursos/codigo-ejemplo/src/main/java/com/sena/inventario/modelo/Producto.java",
            "recursos/codigo-ejemplo/src/main/java/com/sena/inventario/modelo/Usuario.java",
            "recursos/codigo-ejemplo/src/main/java/com/sena/inventario/dao/ProductoDAO.java",
            "recursos/codigo-ejemplo/src/main/java/com/sena/inventario/controlador/ProductoServlet.java"
        ]
        
        for file_path in java_files:
            full_path = self.guide_path / file_path
            if full_path.exists():
                self.passed.append(f"Java file existe: {file_path}")
                print(f"   [OK] {file_path}")
            else:
                self.warnings.append(f"Java file faltante: {file_path}")
                print(f"   [WARN] {file_path}")
    
    def validate_devbrain(self):
        """Valida integracion DevBrain."""
        print("\n[5/8] Validando DevBrain...")
        
        devbrain_files = [
            ".devbrain/session-start.ps1",
            ".devbrain/session-end.ps1",
            ".devbrain/checkpoint.ps1",
            ".devbrain/integrity-check.ps1",
            ".devbrain/knowledge/lessons_learned.md"
        ]
        
        for file_path in devbrain_files:
            full_path = self.guide_path / file_path
            if full_path.exists():
                self.passed.append(f"DevBrain file existe: {file_path}")
                print(f"   [OK] {file_path}")
            else:
                self.warnings.append(f"DevBrain file faltante: {file_path}")
                print(f"   [WARN] {file_path}")
    
    def validate_documentation(self):
        """Valida documentacion."""
        print("\n[6/8] Validando documentacion...")
        
        docs = [
            ("README.md", 300),
            ("Guia_Aprendizaje_JSP_MVC.docx", 0)
        ]
        
        for file_name, min_lines in docs:
            full_path = self.guide_path / file_name
            if full_path.exists():
                if min_lines > 0 and file_name.endswith('.md'):
                    with open(full_path, 'r', encoding='utf-8') as f:
                        lines = len(f.readlines())
                    if lines >= min_lines:
                        self.passed.append(f"{file_name} tiene {lines} lineas (min: {min_lines})")
                        print(f"   [OK] {file_name} ({lines} lineas)")
                    else:
                        self.warnings.append(f"{file_name} tiene {lines} lineas (min: {min_lines})")
                        print(f"   [WARN] {file_name} ({lines} lineas, min: {min_lines})")
                else:
                    self.passed.append(f"{file_name} existe")
                    print(f"   [OK] {file_name}")
            else:
                self.errors.append(f"{file_name} faltante")
                print(f"   [MISSING] {file_name}")
    
    def validate_simulators(self):
        print("\n[7/8] Validando simuladores...")
        sim_file = self.guide_path / "web/simuladores.html"
        if sim_file.exists():
            with open(sim_file, 'r', encoding='utf-8') as f:
                content = f.read()
            jsp_simulators = ["Flujo MVC", "MVC Flow", "CRUD", "Inyecci", "SQL Injection", "Servlet Lifecycle", "Ciclo de Vida", "JDBC vs ORM", "JDBC vs ORM"]
            found_any = set()
            for keyword in jsp_simulators:
                if keyword in content:
                    found_any.add(keyword.split()[0])
            found_count = len(found_any)
            if found_count >= 5:
                self.passed.append(f"Simuladores: {found_count}/5 encontrados")
                print(f"   [OK] Simuladores: {found_count}/5 encontrados")
            else:
                self.warnings.append(f"Simuladores: {found_count}/5 encontrados")
                print(f"   [WARN] Simuladores: {found_count}/5 encontrados")
        else:
            self.errors.append("simuladores.html no existe")
    
    def validate_docker(self):
        print("\n[8/10] Validando Docker...")
        dockerfile = self.guide_path / "recursos/docker/Dockerfile"
        if dockerfile.exists():
            with open(dockerfile, 'r', encoding='utf-8') as f:
                content = f.read()
            checks = [("FROM", "Imagen base definida"), ("EXPOSE", "Puerto expuesto"), ("CMD", "Comando de inicio")]
            for keyword, desc in checks:
                if keyword in content:
                    self.passed.append(f"Dockerfile: {desc}"); print(f"   [OK] {desc}")
                else:
                    self.warnings.append(f"Dockerfile: {desc} faltante"); print(f"   [WARN] {desc}")
        else:
            self.errors.append("Dockerfile faltante")
        
        # Validar Dockerfile de Flutter
        flutter_dockerfile = self.guide_path / "recursos/flutter-inventario/Dockerfile"
        if flutter_dockerfile.exists():
            with open(flutter_dockerfile, 'r', encoding='utf-8') as f:
                content = f.read()
            flutter_checks = [("FROM", "Imagen base Flutter"), ("EXPOSE", "Puerto expuesto"), ("nginx", "Sirve con Nginx")]
            for keyword, desc in flutter_checks:
                if keyword in content:
                    self.passed.append(f"Flutter Dockerfile: {desc}"); print(f"   [OK] {desc}")
                else:
                    self.warnings.append(f"Flutter Dockerfile: {desc} faltante"); print(f"   [WARN] {desc}")
        else:
            self.warnings.append("Flutter Dockerfile no existe")

    def validate_flutter(self):
        """Valida assets especificos de Flutter."""
        print("\n[9/10] Validando Flutter assets...")
        
        flutter_svgs = [
            "web/img/flutter/arquitectura-flutter.svg",
            "web/img/flutter/flutter-api-flow.svg",
            "web/img/flutter/flutter-microservices.svg",
            "web/img/flutter/flutter-widgets.svg"
        ]
        
        for svg_path in flutter_svgs:
            full_path = self.guide_path / svg_path
            if full_path.exists():
                self.passed.append(f"SVG Flutter existe: {svg_path}")
                print(f"   [OK] {svg_path}")
            else:
                self.warnings.append(f"SVG Flutter faltante: {svg_path}")
                print(f"   [WARN] {svg_path}")
        
        flutter_core_files = [
            "recursos/flutter-inventario/lib/core/constants.dart",
            "recursos/flutter-inventario/lib/core/theme.dart",
            "recursos/flutter-inventario/lib/core/network/api_client.dart",
            "recursos/flutter-inventario/lib/core/network/api_exceptions.dart",
        ]
        
        for f in flutter_core_files:
            full_path = self.guide_path / f
            if full_path.exists():
                self.passed.append(f"Flutter core: {f}")
                print(f"   [OK] {f}")
            else:
                self.warnings.append(f"Flutter core faltante: {f}")
                print(f"   [WARN] {f}")
        
        flutter_screens = [
            "recursos/flutter-inventario/lib/screens/login_screen.dart",
            "recursos/flutter-inventario/lib/screens/home_screen.dart",
            "recursos/flutter-inventario/lib/screens/productos/productos_list_screen.dart",
            "recursos/flutter-inventario/lib/screens/productos/producto_form_screen.dart",
            "recursos/flutter-inventario/lib/screens/usuarios/usuarios_list_screen.dart",
        ]
        
        for f in flutter_screens:
            full_path = self.guide_path / f
            if full_path.exists():
                self.passed.append(f"Flutter screen: {f}")
                print(f"   [OK] {f}")
            else:
                self.warnings.append(f"Flutter screen faltante: {f}")
                print(f"   [WARN] {f}")
        
        flutter_providers = [
            "recursos/flutter-inventario/lib/providers/auth_provider.dart",
            "recursos/flutter-inventario/lib/providers/productos_provider.dart",
        ]
        
        for f in flutter_providers:
            full_path = self.guide_path / f
            if full_path.exists():
                self.passed.append(f"Flutter provider: {f}")
                print(f"   [OK] {f}")
            else:
                self.warnings.append(f"Flutter provider faltante: {f}")
                print(f"   [WARN] {f}")
        
        # Verificar OpenAPI spec
        oas_file = self.guide_path / "recursos/flutter-inventario/openapi.json"
        if oas_file.exists():
            import json
            try:
                with open(oas_file, 'r', encoding='utf-8') as f:
                    spec = json.load(f)
                paths_count = len(spec.get('paths', {}))
                schemas_count = len(spec.get('components', {}).get('schemas', {}))
                if paths_count >= 5:
                    self.passed.append(f"OpenAPI spec: {paths_count} paths, {schemas_count} schemas")
                    print(f"   [OK] OpenAPI: {paths_count} paths, {schemas_count} schemas")
                else:
                    self.warnings.append(f"OpenAPI spec: solo {paths_count} paths")
                    print(f"   [WARN] OpenAPI: solo {paths_count} paths")
            except json.JSONDecodeError:
                self.warnings.append("OpenAPI spec: JSON invalido")
                print(f"   [WARN] OpenAPI spec: JSON invalido")
        
        # Verificar Flutter Docker Compose
        compose_file = self.guide_path / "docker-compose.fullstack.yml"
        if compose_file.exists():
            with open(compose_file, 'r', encoding='utf-8') as f:
                content = f.read()
            if 'flutter' in content and 'recursos/flutter-inventario' in content:
                self.passed.append("Flutter service en docker-compose.fullstack.yml")
                print(f"   [OK] Flutter service en docker-compose")
            else:
                self.warnings.append("Flutter service no encontrado en docker-compose.fullstack.yml")
                print(f"   [WARN] Flutter service no encontrado en docker-compose")

    def validate_flutter_guide_content(self):
        """Valida contenido de la guia web Flutter."""
        print("\n[10/10] Validando contenido de flutter-guide.html...")
        guide_file = self.guide_path / "web/flutter-guide.html"
        if guide_file.exists():
            with open(guide_file, 'r', encoding='utf-8') as f:
                content = f.read()
            keywords = [
                "Instalacion", "Flutter", "Dart", "OpenAPI", "Microservicios",
                "Widgets", "Riverpod", "GoRouter", "Dio", "FastAPI",
                "identificacion", "reflexion", "ejercicios", "evidencias"
            ]
            found = sum(1 for k in keywords if k in content)
            if found >= len(keywords) * 0.8:
                self.passed.append(f"Contenido Flutter: {found}/{len(keywords)} keywords encontradas")
                print(f"   [OK] Contenido Flutter: {found}/{len(keywords)} keywords")
            else:
                self.warnings.append(f"Contenido Flutter: solo {found}/{len(keywords)} keywords")
                print(f"   [WARN] Contenido Flutter: {found}/{len(keywords)} keywords")
            
            if 'quiz-container' in content:
                self.passed.append("Quiz interactivo presente en flutter-guide.html")
                print(f"   [OK] Quiz interactivo presente")
        else:
            self.errors.append("flutter-guide.html no existe")
            print(f"   [MISSING] flutter-guide.html")

    def run(self):
        """Ejecuta todas las validaciones."""
        print("=" * 50)
        print("  Validador de Guia JSP + Flutter - DevBrain")
        print("=" * 50)
        print(f"\nRuta: {self.guide_path}")

        self.validate_structure()
        self.validate_web_files()
        self.validate_resource_files()
        self.validate_java_files()
        self.validate_devbrain()
        self.validate_documentation()
        self.validate_simulators()
        self.validate_docker()
        self.validate_flutter()
        self.validate_flutter_guide_content()
        
        # Resumen
        print("\n" + "=" * 50)
        print("  Resumen de Validacion")
        print("=" * 50)
        
        total = len(self.passed) + len(self.warnings) + len(self.errors)
        percentage = (len(self.passed) / total * 100) if total > 0 else 0
        
        print(f"\nTotal de verificaciones: {total}")
        print(f"Aprobadas: {len(self.passed)}")
        print(f"Advertencias: {len(self.warnings)}")
        print(f"Errores: {len(self.errors)}")
        print(f"Porcentaje: {percentage:.1f}%")
        
        if percentage >= 90:
            print("\n✅ EXCELENTE: La guia cumple con el estandar")
            return 0
        elif percentage >= 70:
            print("\n⚠️ ACEPTABLE: La guia necesita mejoras menores")
            return 0
        else:
            print("\n❌ INSUFICIENTE: La guia necesita mejoras significativas")
            return 1


if __name__ == "__main__":
    guide_path = sys.argv[1] if len(sys.argv) > 1 else "."
    validator = GuideValidator(guide_path)
    exit_code = validator.run()
    sys.exit(exit_code)
