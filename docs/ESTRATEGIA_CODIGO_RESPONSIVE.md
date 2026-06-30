# Estrategia de Presentación de Código en Guías Educativas
## Ecosistema DevBrain — Guías con HTML/CSS/JS Vanilla

**Fecha:** Junio 2026  
**Alcance:** Todas las guías educativas (guia-jsp, Guia-Flask, guia-fastapi, guia-html-css-js, etc.)  
**Estado:** ✅ APROBADO — Estándar oficial

---

## Filosofía: "Código Legible en Cualquier Dispositivo"

El aprendiz debe poder:
1. ✅ **Leer** el código completo sin scroll horizontal en móvil
2. ✅ **Entender** la estructura visual con jerarquía clara
3. ✅ **Copiar** el código con un toque (botón copiar accesible)
4. ✅ **Comparar** fragmentos lado a lado en portátil/TV
5. ✅ **Seguir** la ruta del archivo (file header) siempre visible

---

## Problemas Actuales Identificados

| Problema | Impacto | Solución |
|----------|---------|----------|
| `container { max-width: 1200px }` fijo | Overflow en móvil | Usar `max-width: 100%` con padding responsive |
| Bloques de código sin `overflow-x: auto` | Scroll horizontal global | Wrapper con scroll controlado |
| Tipografía fija `font-size: 0.85rem` | Pequeño en TV, grande en móvil | Escala progresiva por breakpoint |
| `.code-window` sin responsive | Se rompe en 375px | Padding y font-size escalonado |
| Comparison boxes lado a lado | Inlegible en móvil | Stack vertical en móvil, horizontal en lg+ |
| File headers no visibles | No se sabe qué archivo se muestra | Header siempre visible con ícono + ruta |

---

## Sistema de Bloques de Código Responsive

### 1. Estructura HTML Base

```html
<!-- Bloque de código con file header -->
<div class="code-block">
  <div class="code-header">
    <div class="code-lang">
      <i class="fab fa-java"></i>
      <span>Java</span>
    </div>
    <div class="code-file">
      <i class="fas fa-file-code"></i>
      <span>src/main/java/ProductoDAO.java</span>
    </div>
    <button class="copy-btn" title="Copiar código">
      <i class="fas fa-copy"></i>
    </button>
  </div>
  <div class="code-body">
    <pre><code class="language-java">// Código aquí
public class ProductoDAO {
    public List&lt;Producto&gt; listar() {
        // ...
    }
}</code></pre>
  </div>
</div>
```

### 2. CSS Mobile-First

```css
/* ── Bloque de Código Responsive ────────────────────────────────────────── */
.code-block {
  border-radius: var(--radius-lg);
  overflow: hidden;
  margin: 1rem 0;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: var(--code-bg);
}

/* Header del código — SIEMPRE visible */
.code-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0.75rem;
  background: rgba(255, 255, 255, 0.05);
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  flex-wrap: wrap;
}

/* Lenguaje + ícono */
.code-lang {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  font-size: 0.75rem;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.7);
  font-family: var(--font-mono);
}

/* Ruta del archivo — se oculta en móvil si no hay espacio */
.code-file {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  font-size: 0.7rem;
  color: rgba(255, 255, 255, 0.5);
  font-family: var(--font-mono);
  flex: 1;
  min-width: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.code-file i {
  flex-shrink: 0;
}

/* Botón copiar */
.copy-btn {
  padding: 0.375rem 0.625rem;
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 0.25rem;
  color: rgba(255, 255, 255, 0.6);
  font-size: 0.7rem;
  cursor: pointer;
  transition: all 0.2s ease;
  flex-shrink: 0;
}

.copy-btn:hover {
  background: rgba(255, 255, 255, 0.15);
  color: white;
}

.copy-btn.copied {
  background: var(--success);
  color: white;
  border-color: var(--success);
}

/* Cuerpo del código — scroll horizontal controlado */
.code-body {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

.code-body pre {
  margin: 0;
  padding: 0.75rem 1rem;
  white-space: pre;
}

.code-body code {
  font-family: var(--font-mono);
  font-size: 0.8rem;
  line-height: 1.5;
  color: var(--code-text);
}

/* ── Responsive: Tablet sm: (640px+) ────────────────────────────────────── */
@media (min-width: 640px) {
  .code-header {
    padding: 0.625rem 1rem;
    gap: 0.75rem;
  }
  
  .code-lang {
    font-size: 0.8rem;
  }
  
  .code-file {
    font-size: 0.75rem;
  }
  
  .code-body pre {
    padding: 1rem 1.25rem;
  }
  
  .code-body code {
    font-size: 0.85rem;
    line-height: 1.6;
  }
}

/* ── Responsive: Portátil lg: (1024px+) ─────────────────────────────────── */
@media (min-width: 1024px) {
  .code-header {
    padding: 0.75rem 1.25rem;
  }
  
  .code-body pre {
    padding: 1.25rem 1.5rem;
  }
  
  .code-body code {
    font-size: 0.875rem;
  }
}

/* ── Responsive: Desktop xl: (1280px+) ──────────────────────────────────── */
@media (min-width: 1280px) {
  .code-body pre {
    padding: 1.5rem 2rem;
  }
  
  .code-body code {
    font-size: 0.9rem;
    line-height: 1.7;
  }
}
```

---

## Comparison Boxes — "Antes vs Después"

### Estructura HTML

```html
<div class="comparison-box">
  <div class="comparison-item old">
    <h5><i class="fas fa-times-circle"></i> Antes (incorrecto)</h5>
    <div class="code-block">
      <!-- código antiguo -->
    </div>
  </div>
  <div class="comparison-arrow">
    <i class="fas fa-arrow-right"></i>
  </div>
  <div class="comparison-item new">
    <h5><i class="fas fa-check-circle"></i> Después (correcto)</h5>
    <div class="code-block">
      <!-- código nuevo -->
    </div>
  </div>
</div>
```

### CSS Mobile-First

```css
/* ── Comparison Box Responsive ──────────────────────────────────────────── */
.comparison-box {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin: 1.5rem 0;
  align-items: stretch;
}

.comparison-item {
  flex: 1;
  min-width: 0;
}

.comparison-item.old {
  border-left: 3px solid var(--danger);
  padding-left: 1rem;
}

.comparison-item.new {
  border-left: 3px solid var(--success);
  padding-left: 1rem;
}

.comparison-item h5 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.9rem;
  font-weight: 600;
  margin-bottom: 0.75rem;
}

.comparison-item.old h5 {
  color: var(--danger);
}

.comparison-item.new h5 {
  color: var(--success);
}

/* Flecha — oculta en móvil, visible en lg+ */
.comparison-arrow {
  display: none;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  color: var(--primary);
  padding: 0.5rem 0;
}

/* ── Responsive: Portátil lg: (1024px+) ─────────────────────────────────── */
@media (min-width: 1024px) {
  .comparison-box {
    flex-direction: row;
    align-items: flex-start;
    gap: 1.5rem;
  }
  
  .comparison-arrow {
    display: flex;
    flex-shrink: 0;
    padding: 2rem 0;
  }
}
```

---

## Feature Cards — Múltiples Ejemplos en Grid

### Estructura HTML

```html
<div class="feature-grid">
  <div class="feature-card">
    <h5>Records</h5>
    <p>Clases inmutables simplificadas</p>
    <div class="code-block">
      <!-- código -->
    </div>
  </div>
  <div class="feature-card">
    <h5>Pattern Matching</h5>
    <p>Validación de tipos simplificada</p>
    <div class="code-block">
      <!-- código -->
    </div>
  </div>
</div>
```

### CSS Mobile-First

```css
/* ── Feature Grid Responsive ────────────────────────────────────────────── */
.feature-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1rem;
  margin: 1.5rem 0;
}

.feature-card {
  background: var(--bg-primary);
  border: 1px solid var(--border-light);
  border-radius: var(--radius-lg);
  padding: 1.25rem;
  transition: all 0.2s ease;
}

.feature-card:hover {
  border-color: var(--primary);
  box-shadow: var(--shadow-md);
  transform: translateY(-2px);
}

.feature-card h5 {
  font-size: 1rem;
  font-weight: 700;
  color: var(--text-primary);
  margin-bottom: 0.5rem;
}

.feature-card > p {
  font-size: 0.875rem;
  color: var(--text-secondary);
  margin-bottom: 1rem;
  line-height: 1.5;
}

/* ── Responsive: Tablet sm: (640px+) ────────────────────────────────────── */
@media (min-width: 640px) {
  .feature-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 1.25rem;
  }
}

/* ── Responsive: Portátil lg: (1024px+) ─────────────────────────────────── */
@media (min-width: 1024px) {
  .feature-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 1.5rem;
  }
  
  .feature-card {
    padding: 1.5rem;
  }
}

/* ── Responsive: Desktop xl: (1280px+) ──────────────────────────────────── */
@media (min-width: 1280px) {
  .feature-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}
```

---

## Tech Modules — Acordeón de Tecnología

### Estructura HTML

```html
<div class="tech-module" id="module-jdk">
  <div class="module-header">
    <div class="module-icon java">
      <i class="fab fa-java"></i>
    </div>
    <div class="module-info">
      <h3>JDK 21</h3>
      <p class="module-subtitle">Versión LTS con Records y Virtual Threads</p>
    </div>
    <button type="button" class="module-toggle">
      <i class="fas fa-chevron-down"></i>
    </button>
  </div>
  <div class="module-content">
    <!-- Contenido con code blocks -->
  </div>
</div>
```

### CSS Mobile-First

```css
/* ── Tech Module Responsive ─────────────────────────────────────────────── */
.tech-module {
  background: var(--bg-primary);
  border: 1px solid var(--border-light);
  border-radius: var(--radius-lg);
  margin: 1rem 0;
  overflow: hidden;
  transition: all 0.3s ease;
}

.tech-module.active {
  border-color: var(--primary);
  box-shadow: var(--shadow-md);
}

.module-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem;
  cursor: pointer;
  transition: background 0.2s ease;
}

.module-header:hover {
  background: var(--bg-tertiary);
}

.module-icon {
  width: 40px;
  height: 40px;
  border-radius: var(--radius-sm);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.25rem;
  color: white;
  flex-shrink: 0;
}

.module-icon.java { background: linear-gradient(135deg, #f89820, #e76f00); }
.module-icon.jakarta { background: linear-gradient(135deg, #4a2c8a, #7c3aed); }
.module-icon.postgres { background: linear-gradient(135deg, #336791, #1d4e89); }

.module-info {
  flex: 1;
  min-width: 0;
}

.module-info h3 {
  font-size: 1rem;
  font-weight: 700;
  color: var(--text-primary);
  margin: 0;
  line-height: 1.2;
}

.module-subtitle {
  font-size: 0.8rem;
  color: var(--text-muted);
  margin: 0.25rem 0 0;
}

.module-toggle {
  width: 32px;
  height: 32px;
  border: none;
  background: var(--bg-tertiary);
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--text-secondary);
  transition: all 0.2s ease;
  flex-shrink: 0;
}

.tech-module.active .module-toggle {
  background: var(--primary);
  color: white;
  transform: rotate(180deg);
}

.module-content {
  display: none;
  padding: 1rem;
  border-top: 1px solid var(--border-light);
}

.tech-module.active .module-content {
  display: block;
}

/* ── Responsive: Tablet sm: (640px+) ────────────────────────────────────── */
@media (min-width: 640px) {
  .module-header {
    padding: 1.25rem;
    gap: 1rem;
  }
  
  .module-icon {
    width: 48px;
    height: 48px;
    font-size: 1.5rem;
  }
  
  .module-info h3 {
    font-size: 1.125rem;
  }
  
  .module-subtitle {
    font-size: 0.875rem;
  }
  
  .module-content {
    padding: 1.25rem;
  }
}

/* ── Responsive: Portátil lg: (1024px+) ─────────────────────────────────── */
@media (min-width: 1024px) {
  .module-header {
    padding: 1.5rem;
  }
  
  .module-content {
    padding: 1.5rem;
  }
}
```

---

## Container y Layout Principal

### CSS Mobile-First

```css
/* ── Container Responsive ───────────────────────────────────────────────── */
.container {
  width: 100%;
  max-width: 100%;
  padding: 0 1rem;
  margin: 0 auto;
}

@media (min-width: 640px) {
  .container {
    padding: 0 1.25rem;
  }
}

@media (min-width: 1024px) {
  .container {
    padding: 0 1.5rem;
    max-width: 1280px;
  }
}

@media (min-width: 1280px) {
  .container {
    padding: 0 2rem;
    max-width: 1440px;
  }
}

@media (min-width: 1536px) {
  .container {
    max-width: 1680px;
  }
}

/* ── Main Content ───────────────────────────────────────────────────────── */
.main-content {
  margin-top: var(--header-height);
  padding-bottom: 2rem;
}

@media (min-width: 768px) {
  .main-content {
    padding-bottom: 3rem;
  }
}

/* ── Section Spacing ────────────────────────────────────────────────────── */
.section {
  padding: 2rem 0;
}

@media (min-width: 640px) {
  .section {
    padding: 2.5rem 0;
  }
}

@media (min-width: 1024px) {
  .section {
    padding: 3rem 0;
  }
}

@media (min-width: 1536px) {
  .section {
    padding: 4rem 0;
  }
}
```

---

## Tipografía Responsive

```css
/* ── Tipografía Escalonada ──────────────────────────────────────────────── */
:root {
  --text-xs: 0.75rem;    /* 12px */
  --text-sm: 0.875rem;   /* 14px */
  --text-base: 1rem;     /* 16px */
  --text-lg: 1.125rem;   /* 18px */
  --text-xl: 1.25rem;    /* 20px */
  --text-2xl: 1.5rem;    /* 24px */
  --text-3xl: 1.875rem;  /* 30px */
  --text-4xl: 2.25rem;   /* 36px */
}

/* Títulos responsive */
h1 {
  font-size: var(--text-2xl);
  line-height: 1.2;
}

h2 {
  font-size: var(--text-xl);
  line-height: 1.3;
}

h3 {
  font-size: var(--text-lg);
  line-height: 1.4;
}

p {
  font-size: var(--text-sm);
  line-height: 1.7;
}

@media (min-width: 640px) {
  h1 { font-size: var(--text-3xl); }
  h2 { font-size: var(--text-2xl); }
  h3 { font-size: var(--text-xl); }
  p  { font-size: var(--text-base); }
}

@media (min-width: 1024px) {
  h1 { font-size: var(--text-4xl); }
  h2 { font-size: var(--text-3xl); }
}

@media (min-width: 1536px) {
  h1 { font-size: clamp(2.5rem, 4vw, 3.75rem); }
}
```

---

## Checklist Pre-Entrega para Guías

### Estructura
- [ ] Sin scroll horizontal en 375px
- [ ] Todo código legible sin zoom en móvil
- [ ] File headers visibles en todos los bloques
- [ ] Botón copiar accesible (min 44px touch target)

### Código
- [ ] Bloques en wrapper con `overflow-x: auto`
- [ ] Font-size escala: 0.8rem → 0.85rem → 0.875rem → 0.9rem
- [ ] Padding escala: 0.75rem → 1rem → 1.25rem → 1.5rem
- [ ] Comparison boxes: stack en móvil, row en lg+

### Layout
- [ ] Container usa `max-width: 100%` con padding responsive
- [ ] Feature grids: 1 → 2 → 3 columnas
- [ ] Tech modules: acordeón funcional en móvil
- [ ] Sidebar: drawer en móvil, fixed en lg+

### Visual
- [ ] Bordes diferenciados entre grupos
- [ ] Sombras sutiles en hover
- [ ] Colores consistentes con tema SENA (verde #00664a)

---

## Referencias

- **Estrategia Global:** `docs/RESPONSIVE_MOBILE_FIRST_STRATEGY.md`
- **AGENTS.md:** Reglas de codificación DevBrain
- **Proyecto referencia:** `guia-jsp/` (primera implementación)

---

*Última actualización: Junio 2026*
