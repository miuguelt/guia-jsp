# Reglas de Presentación de Código (Estándar Probado)

## Estilo de Código en Bloques HTML `<pre><code>`

Todo bloque de código debe seguir este estándar **exactamente como se ve en `inventario_app.dart`**:

### Reglas Absolutas

1. **Cada línea lógica en su propia línea** — NO código concatenado en una sola línea dentro de `<pre><code>`. Cada statement, instrucción, declaración debe tener su propio `\n`.

2. **Indentación visible con newlines reales** — Usar `\n` literales, NO espacios inline para simular indentación. Ejemplo correcto:
```html
<pre><code class="language-java">public class Producto {
    private int id;
    private String nombre;
}
</code></pre>
```

3. **Etiquetas HTML escapadas** — `<` → `&lt;`, `>` → `&gt;`, `&` → `&amp;` en bloque `language-xml`/`language-jsp`.

4. **Comentarios separados con `// ---`** para secciones dentro del código.

5. **Sin scroll horizontal** — El CSS ya fuerza `white-space: pre-wrap` con `overflow-x: hidden`. Confiar en esto, NO usar `<pre style="...">` inline.

### Indentación por Lenguaje

| Lenguaje | Tamaño | Ejemplo |
|----------|--------|---------|
| Java, Dart, JavaScript, TypeScript | 4 espacios | `    private int id;` |
| Python | 4 espacios | `    def metodo(self):` |
| XML, HTML, JSP | 4 espacios | `    <dependency>` |
| YAML | 2 espacios | `  version: '3.8'` |
| SQL | 4 espacios para columnas | `    id SERIAL PRIMARY KEY,` |
| Bash/PowerShell | 0 (comandos al inicio) | `mvn clean package` |
| Dockerfile | 0 (instrucciones al inicio) | `FROM tomcat:10.1` |

### Separación Visual

- Usar `// --- Título ---` en comentarios para separar secciones dentro del código
- Líneas en blanco entre métodos/bloques lógicos
- En SQL, separar CREATE TABLE / INSERT con líneas en blanco y comentarios

### Lo que NO hacer

- ❌ NO poner código en una sola línea: `public record Producto(    int id,    String nombre) {`
- ❌ NO concatenar comandos: `docker build -t app .# Verificardocker images`
- ❌ NO mezclar comentarios con código en la misma línea sin newline
- ❌ NO usar `\n` inline dentro de `<pre><code>` — usar newlines reales
- ❌ NO usar `<br>` dentro de bloques de código

### Inspiración

El estándar probado y aprobado está en `flutter-guide/sections/01-inicio.html` bloque `inventario_app.dart`. Todo bloque de código en el sitio debe verse igual de limpio.
