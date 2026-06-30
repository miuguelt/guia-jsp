/**
 * JSP Simuladores Pro - Modo Modular
 * 4 nuevos simuladores siguendo el patron DevBrain.
 * Carga: DOMContentLoaded
 */

const SIMULADORES_JSP = {
    init() {
        this.renderRequestLifecycle();
        this.renderSecurityValidator();
        this.renderJSTLBuilder();
        this.renderSessionSimulator();
    },

    // ── Simulador 1: Request Lifecycle (Servlet -> JSP) ──────────────
    renderRequestLifecycle() {
        const containers = document.querySelectorAll('.sim-lifecycle-container');
        containers.forEach(container => {
            container.innerHTML = `
                <div class="simulator-card glass-panel" style="padding:20px;margin-bottom:20px;background:var(--bg-alt);border-radius:12px;border:1px solid var(--border);">
                    <div class="sim-header" style="display:flex;align-items:center;gap:12px;margin-bottom:16px;">
                        <span style="font-size:1.5rem;">🔄</span>
                        <h3 style="margin:0;">Ciclo de Petición: Servlet → JSP</h3>
                    </div>
                    <div class="sim-body">
                        <div class="lifecycle-steps" style="display:flex;flex-direction:column;gap:8px;">
                            <div class="lifecycle-step" data-step="1" style="display:flex;align-items:flex-start;gap:12px;padding:10px;background:var(--bg);border:1px solid var(--border);border-radius:8px;transition:all 0.3s;">
                                <div class="step-number" style="width:28px;height:28px;display:flex;align-items:center;justify-content:center;background:var(--primary);color:white;border-radius:50%;font-weight:700;font-size:0.85rem;flex-shrink:0;">1</div>
                                <div class="step-content">
                                    <strong>Cliente HTTP</strong>
                                    <p style="margin:2px 0 0;font-size:0.8rem;color:var(--text-muted);font-family:monospace;">GET /productos/lista</p>
                                </div>
                            </div>
                            <div class="lifecycle-step" data-step="2" style="display:flex;align-items:flex-start;gap:12px;padding:10px;background:var(--bg);border:1px solid var(--border);border-radius:8px;transition:all 0.3s;">
                                <div class="step-number" style="width:28px;height:28px;display:flex;align-items:center;justify-content:center;background:var(--primary);color:white;border-radius:50%;font-weight:700;font-size:0.85rem;flex-shrink:0;">2</div>
                                <div class="step-content">
                                    <strong>Tomcat (Servlet Container)</strong>
                                    <p style="margin:2px 0 0;font-size:0.8rem;color:var(--text-muted);font-family:monospace;">Recibe petición y busca el Servlet mapeado</p>
                                </div>
                            </div>
                            <div class="lifecycle-step" data-step="3" style="display:flex;align-items:flex-start;gap:12px;padding:10px;background:var(--bg);border:1px solid var(--border);border-radius:8px;transition:all 0.3s;">
                                <div class="step-number" style="width:28px;height:28px;display:flex;align-items:center;justify-content:center;background:var(--primary);color:white;border-radius:50%;font-weight:700;font-size:0.85rem;flex-shrink:0;">3</div>
                                <div class="step-content">
                                    <strong>Servlet (Controlador)</strong>
                                    <p style="margin:2px 0 0;font-size:0.8rem;color:var(--text-muted);font-family:monospace;">ProductoServlet.doGet() procesa la petición</p>
                                </div>
                            </div>
                            <div class="lifecycle-step" data-step="4" style="display:flex;align-items:flex-start;gap:12px;padding:10px;background:var(--bg);border:1px solid var(--border);border-radius:8px;transition:all 0.3s;">
                                <div class="step-number" style="width:28px;height:28px;display:flex;align-items:center;justify-content:center;background:var(--primary);color:white;border-radius:50%;font-weight:700;font-size:0.85rem;flex-shrink:0;">4</div>
                                <div class="step-content">
                                    <strong>DAO (Modelo)</strong>
                                    <p style="margin:2px 0 0;font-size:0.8rem;color:var(--text-muted);font-family:monospace;">ProductoDAO.listarTodos() → SELECT * FROM productos</p>
                                </div>
                            </div>
                            <div class="lifecycle-step" data-step="5" style="display:flex;align-items:flex-start;gap:12px;padding:10px;background:var(--bg);border:1px solid var(--border);border-radius:8px;transition:all 0.3s;">
                                <div class="step-number" style="width:28px;height:28px;display:flex;align-items:center;justify-content:center;background:var(--primary);color:white;border-radius:50%;font-weight:700;font-size:0.85rem;flex-shrink:0;">5</div>
                                <div class="step-content">
                                    <strong>PostgreSQL</strong>
                                    <p style="margin:2px 0 0;font-size:0.8rem;color:var(--text-muted);font-family:monospace;">Ejecuta consulta y retorna resultados</p>
                                </div>
                            </div>
                            <div class="lifecycle-step" data-step="6" style="display:flex;align-items:flex-start;gap:12px;padding:10px;background:var(--bg);border:1px solid var(--border);border-radius:8px;transition:all 0.3s;">
                                <div class="step-number" style="width:28px;height:28px;display:flex;align-items:center;justify-content:center;background:var(--primary);color:white;border-radius:50%;font-weight:700;font-size:0.85rem;flex-shrink:0;">6</div>
                                <div class="step-content">
                                    <strong>JSP (Vista)</strong>
                                    <p style="margin:2px 0 0;font-size:0.8rem;color:var(--text-muted);font-family:monospace;">RequestDispatcher.forward() → lista.jsp con JSTL</p>
                                </div>
                            </div>
                            <div class="lifecycle-step" data-step="7" style="display:flex;align-items:flex-start;gap:12px;padding:10px;background:var(--bg);border:1px solid var(--border);border-radius:8px;transition:all 0.3s;">
                                <div class="step-number" style="width:28px;height:28px;display:flex;align-items:center;justify-content:center;background:var(--primary);color:white;border-radius:50%;font-weight:700;font-size:0.85rem;flex-shrink:0;">7</div>
                                <div class="step-content">
                                    <strong>Respuesta HTTP 200</strong>
                                    <p style="margin:2px 0 0;font-size:0.8rem;color:var(--text-muted);font-family:monospace;">HTML renderizado enviado al cliente</p>
                                </div>
                            </div>
                        </div>
                        <button class="btn" style="margin-top:16px;padding:10px 20px;background:var(--primary);color:white;border:none;border-radius:6px;cursor:pointer;font-weight:600;" onclick="SIMULADORES_JSP.animateLifecycle()">Animar Flujo +75 XP</button>
                        <div id="lifecycle-feedback" style="margin-top:10px;font-weight:600;"></div>
                    </div>
                </div>
            `;
        });
    },

    animateLifecycle() {
        const steps = document.querySelectorAll('.sim-lifecycle-container .lifecycle-step');
        const feedback = document.getElementById('lifecycle-feedback');
        steps.forEach((step, index) => {
            setTimeout(() => {
                step.style.background = 'rgba(137, 180, 250, 0.15)';
                step.style.borderColor = 'var(--primary)';
                step.style.transform = 'translateX(8px)';
                if (index === steps.length - 1) {
                    feedback.innerHTML = '<span style="color:#16a34a;">✅ Ciclo completado!</span>';
                    if (window.confetti) confetti({ particleCount: 100, spread: 70 });
                }
            }, index * 400);
        });
        setTimeout(() => {
            steps.forEach(step => {
                step.style.background = '';
                step.style.borderColor = '';
                step.style.transform = '';
            });
            feedback.innerHTML = '';
        }, steps.length * 400 + 2000);
    },

    // ── Simulador 2: CRUD Security Validator ──────────────────────────
    renderSecurityValidator() {
        const containers = document.querySelectorAll('.sim-security-container');
        containers.forEach(container => {
            container.innerHTML = `
                <div class="simulator-card glass-panel" style="padding:20px;margin-bottom:20px;background:var(--bg-alt);border-radius:12px;border:1px solid var(--border);">
                    <div class="sim-header" style="display:flex;align-items:center;gap:12px;margin-bottom:16px;">
                        <span style="font-size:1.5rem;">🔒</span>
                        <h3 style="margin:0;">CRUD Security: SQL Injection vs PreparedStatement</h3>
                    </div>
                    <div class="sim-body">
                        <div class="sim-input-group" style="margin-bottom:12px;">
                            <label style="display:block;font-size:0.8rem;color:var(--text-muted);margin-bottom:4px;">Nombre del producto a buscar:</label>
                            <div style="display:flex;gap:8px;">
                                <input type="text" id="security-input" value="Laptop' OR '1'='1" style="flex:1;padding:8px;background:var(--bg);border:1px solid var(--border);border-radius:5px;color:var(--text);font-family:monospace;font-size:0.85rem;">
                                <button class="btn" style="padding:8px 16px;background:var(--danger);color:white;border:none;border-radius:5px;cursor:pointer;font-weight:600;" onclick="SIMULADORES_JSP.runAttack()">Ejecutar</button>
                            </div>
                        </div>
                        <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;">
                            <div style="padding:12px;border-radius:8px;border:1px solid var(--border);background:var(--bg);">
                                <div style="font-size:0.7rem;color:var(--text-muted);text-transform:uppercase;margin-bottom:8px;">❌ Statement Vulnerable</div>
                                <div id="security-vuln-output" style="font-family:monospace;font-size:0.8rem;color:#f43f5e;min-height:60px;white-space:pre-wrap;">SELECT * FROM productos WHERE nombre = 'Laptop' OR '1'='1'
⚠️ TODOS los registros expuestos!</div>
                            </div>
                            <div style="padding:12px;border-radius:8px;border:1px solid var(--border);background:var(--bg);">
                                <div style="font-size:0.7rem;color:var(--text-muted);text-transform:uppercase;margin-bottom:8px;">✅ PreparedStatement Seguro</div>
                                <div id="security-safe-output" style="font-family:monospace;font-size:0.8rem;color:#16a34a;min-height:60px;white-space:pre-wrap;">SELECT * FROM productos WHERE nombre = ?
Parámetros: ['Laptop' OR '1'='1']
🔒 Inyección bloqueada - 0 resultados</div>
                            </div>
                        </div>
                        <button class="btn" style="margin-top:12px;padding:8px 16px;background:var(--primary);color:white;border:none;border-radius:5px;cursor:pointer;font-weight:600;" onclick="SIMULADORES_JSP.checkSecurity()">Validar +50 XP</button>
                        <div id="security-feedback" style="margin-top:8px;font-weight:600;"></div>
                    </div>
                </div>
            `;
        });
    },

    runAttack() {
        const input = document.getElementById('security-input').value;
        const vulnEl = document.getElementById('security-vuln-output');
        const safeEl = document.getElementById('security-safe-output');
        
        const isInjection = /('|"|;|--|\bOR\b|\bAND\b|\bUNION\b)/i.test(input);
        
        if (isInjection) {
            vulnEl.innerHTML = `SELECT * FROM productos WHERE nombre = '${input}'\n⚠️ <span style="color:#f43f5e;">INYECCIÓN EXITOSA! TODOS los registros expuestos!</span>`;
            safeEl.innerHTML = `SELECT * FROM productos WHERE nombre = ?\nParámetros: ['${input}']\n🔒 <span style="color:#16a34a;">Inyección bloqueada - 0 resultados</span>`;
        } else {
            vulnEl.innerHTML = `SELECT * FROM productos WHERE nombre = '${input}'\n✅ Consulta normal ejecutada`;
            safeEl.innerHTML = `SELECT * FROM productos WHERE nombre = ?\nParámetros: ['${input}']\n✅ Consulta segura ejecutada`;
        }
    },

    checkSecurity() {
        const feedback = document.getElementById('security-feedback');
        feedback.innerHTML = '<span style="color:#16a34a;">✅ Validación de seguridad completada! +50 XP</span>';
        if (window.confetti) confetti({ particleCount: 50, spread: 50 });
    },

    // ── Simulador 3: JSTL Expression Builder ──────────────────────────
    renderJSTLBuilder() {
        const containers = document.querySelectorAll('.sim-jstl-container');
        containers.forEach(container => {
            container.innerHTML = `
                <div class="simulator-card glass-panel" style="padding:20px;margin-bottom:20px;background:var(--bg-alt);border-radius:12px;border:1px solid var(--border);">
                    <div class="sim-header" style="display:flex;align-items:center;gap:12px;margin-bottom:16px;">
                        <span style="font-size:1.5rem;">🏷️</span>
                        <h3 style="margin:0;">JSTL Expression Builder</h3>
                    </div>
                    <div class="sim-body">
                        <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;">
                            <div>
                                <label style="display:block;font-size:0.8rem;color:var(--text-muted);margin-bottom:4px;">Datos (Java en Servlet):</label>
                                <textarea id="jstl-context" style="width:100%;min-height:100px;padding:8px;background:var(--bg);border:1px solid var(--border);border-radius:5px;color:var(--text);font-family:monospace;font-size:0.8rem;">request.setAttribute("productos", lista);
request.setAttribute("total", 150);
request.setAttribute("categoria", "Electrónica");</textarea>
                            </div>
                            <div>
                                <label style="display:block;font-size:0.8rem;color:var(--text-muted);margin-bottom:4px;">JSTL Tag a usar:</label>
                                <select id="jstl-tag" style="width:100%;padding:8px;background:var(--bg);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:0.85rem;margin-bottom:8px;">
                                    <option value="forEach">&lt;c:forEach&gt;</option>
                                    <option value="if">&lt;c:if&gt;</option>
                                    <option value="choose">&lt;c:choose&gt;</option>
                                    <option value="out">&lt;c:out&gt;</option>
                                    <option value="set">&lt;c:set&gt;</option>
                                </select>
                                <div id="jstl-output" style="font-family:monospace;font-size:0.8rem;color:var(--text);min-height:100px;background:var(--bg);border:1px solid var(--border);border-radius:5px;padding:8px;white-space:pre-wrap;">&lt;c:forEach items="\${productos}" var="p"&gt;
    &lt;tr&gt;
        &lt;td&gt;\${p.nombre}&lt;/td&gt;
        &lt;td&gt;\${p.precio}&lt;/td&gt;
    &lt;/tr&gt;
&lt;/c:forEach&gt;</div>
                            </div>
                        </div>
                        <button class="btn" style="margin-top:12px;padding:8px 16px;background:var(--primary);color:white;border:none;border-radius:5px;cursor:pointer;font-weight:600;" onclick="SIMULADORES_JSP.checkJSTL()">Generar +50 XP</button>
                        <div id="jstl-feedback" style="margin-top:8px;font-weight:600;"></div>
                    </div>
                </div>
            `;
            const select = container.querySelector('#jstl-tag');
            const output = container.querySelector('#jstl-output');
            if (select && output) {
                select.addEventListener('change', () => {
                    const tags = {
                        'forEach': '<c:forEach items="${productos}" var="p">\n    <tr>\n        <td>${p.nombre}</td>\n        <td>${p.precio}</td>\n    </tr>\n</c:forEach>',
                        'if': '<c:if test="${total > 100}">\n    <p>Hay más de 100 productos</p>\n</c:if>',
                        'choose': '<c:choose>\n    <c:when test="${categoria == \'Electrónica\'}">\n        <p>Categoría: Electrónica</p>\n    </c:when>\n    <c:otherwise>\n        <p>Otra categoría</p>\n    </c:otherwise>\n</c:choose>',
                        'out': '<c:out value="${producto.nombre}" default="Sin nombre" />',
                        'set': '<c:set var="descuento" value="${precio * 0.1}" />'
                    };
                    output.textContent = tags[select.value] || tags['forEach'];
                });
            }
        });
    },

    checkJSTL() {
        const feedback = document.getElementById('jstl-feedback');
        feedback.innerHTML = '<span style="color:#16a34a;">✅ Expresión JSTL generada! +50 XP</span>';
        if (window.confetti) confetti({ particleCount: 50, spread: 50 });
    },

    // ── Simulador 4: Session Management Simulator ─────────────────────
    renderSessionSimulator() {
        const containers = document.querySelectorAll('.sim-session-container');
        containers.forEach(container => {
            this.sessionState = { autenticado: false, usuario: null, carrito: [], intentos: 0 };
            container.innerHTML = `
                <div class="simulator-card glass-panel" style="padding:20px;margin-bottom:20px;background:var(--bg-alt);border-radius:12px;border:1px solid var(--border);">
                    <div class="sim-header" style="display:flex;align-items:center;gap:12px;margin-bottom:16px;">
                        <span style="font-size:1.5rem;">🔐</span>
                        <h3 style="margin:0;">Session Management Simulator</h3>
                    </div>
                    <div class="sim-body">
                        <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;">
                            <div>
                                <label style="display:block;font-size:0.8rem;color:var(--text-muted);margin-bottom:4px;">Usuario:</label>
                                <input type="text" id="session-user" value="admin" style="width:100%;padding:8px;background:var(--bg);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:0.85rem;margin-bottom:8px;">
                                <input type="password" id="session-pass" value="admin123" style="width:100%;padding:8px;background:var(--bg);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:0.85rem;margin-bottom:8px;">
                                <button class="btn" style="padding:8px 16px;background:var(--primary);color:white;border:none;border-radius:5px;cursor:pointer;font-weight:600;margin-right:8px;" onclick="SIMULADORES_JSP.login()">Iniciar Sesión</button>
                                <button class="btn" style="padding:8px 16px;background:var(--text-muted);color:white;border:none;border-radius:5px;cursor:pointer;font-weight:600;" onclick="SIMULADORES_JSP.logout()">Cerrar Sesión</button>
                            </div>
                            <div>
                                <label style="display:block;font-size:0.8rem;color:var(--text-muted);margin-bottom:4px;">Estado de la Sesión:</label>
                                <div id="session-status" style="font-family:monospace;font-size:0.8rem;min-height:120px;background:var(--bg);border:1px solid var(--border);border-radius:5px;padding:8px;white-space:pre-wrap;">Sesión: No autenticado
ID: (null)
Usuario: invitado
Rol: ANONYMOUS</div>
                            </div>
                        </div>
                        <button class="btn" style="margin-top:12px;padding:8px 16px;background:var(--primary);color:white;border:none;border-radius:5px;cursor:pointer;font-weight:600;" onclick="SIMULADORES_JSP.checkSession()">Validar +50 XP</button>
                        <div id="session-feedback" style="margin-top:8px;font-weight:600;"></div>
                    </div>
                </div>
            `;
        });
    },

    login() {
        const user = document.getElementById('session-user').value;
        const pass = document.getElementById('session-pass').value;
        const status = document.getElementById('session-status');
        
        if (user && pass) {
            this.sessionState.autenticado = true;
            this.sessionState.usuario = user;
            this.sessionState.intentos = 0;
            status.innerHTML = `Sesión: Autenticado ✅
ID: SESSION-${Math.random().toString(36).substr(2, 8).toUpperCase()}
Usuario: ${user}
Rol: ${user === 'admin' ? 'ADMIN' : 'USER'}
Carrito: ${this.sessionState.carrito.length} items
Tiempo: ${new Date().toLocaleTimeString()}`;
        }
    },

    logout() {
        this.sessionState.autenticado = false;
        this.sessionState.usuario = null;
        const status = document.getElementById('session-status');
        status.innerHTML = `Sesión: Cerrada 🔒
ID: (invalidada)
Usuario: invitado
Rol: ANONYMOUS
Mensaje: Sesión destruida con session.invalidate()`;
    },

    checkSession() {
        const feedback = document.getElementById('session-feedback');
        feedback.innerHTML = '<span style="color:#16a34a;">✅ Gestión de sesión demostrada! +50 XP</span>';
        if (window.confetti) confetti({ particleCount: 50, spread: 50 });
    }
};

window.SIMULADORES_JSP = SIMULADORES_JSP;
document.addEventListener('DOMContentLoaded', () => SIMULADORES_JSP.init());
