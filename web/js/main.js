document.addEventListener('DOMContentLoaded', () => {
    // Elementos del DOM
    const mainSidebar = document.getElementById('mainSidebar');
    const sidebarToggle = document.getElementById('sidebarToggle');
    const sidebarShowBtn = document.getElementById('sidebarShowBtn');
    const sidebarSearch = document.getElementById('sidebarSearch');
    const sidebarLinks = document.querySelectorAll('.sidebar-link');
    const sidebarCheckboxes = document.querySelectorAll('.sidebar-link-check');
    const sections = document.querySelectorAll('section[id]');
    const progressBar = document.getElementById('progressBar');
    const progressText = document.getElementById('progressText');
    const scrollTopBtn = document.getElementById('scrollTopBtn');
    const tabBtns = document.querySelectorAll('.tab-btn');
    const tabPanels = document.querySelectorAll('.tab-panel');
    const copyBtns = document.querySelectorAll('.copy-btn');
    
    // Elementos de búsqueda y tema
    const searchToggle = document.getElementById('searchToggle');
    const searchToggleSidebar = document.getElementById('searchToggleSidebar');
    const searchModal = document.getElementById('searchModal');
    const searchInput = document.getElementById('searchInput');
    const searchResults = document.getElementById('searchResults');
    const searchClose = document.getElementById('searchClose');
    const themeToggle = document.getElementById('themeToggle');
    const headerThemeToggle = document.getElementById('headerThemeToggle');
    const resetProgress = document.getElementById('resetProgress');
    
    // Estado
    let highlightedIndex = -1;
    let searchData = [];

    // ============================================
    // DATOS DE BÚSQUEDA
    // ============================================
    function buildSearchData() {
        searchData = [];
        const items = document.querySelectorAll('section[id]');
        items.forEach(section => {
            const title = section.querySelector('.section-title, .hero-title');
            const subtitle = section.querySelector('.section-subtitle, .hero-description');
            const text = section.textContent.toLowerCase();
            
            if (title) {
                const id = section.getAttribute('id');
                const icon = section.querySelector('.section-number')?.textContent || '';
                searchData.push({
                    id: id,
                    title: title.textContent.trim(),
                    section: 'Sección ' + icon,
                    icon: section.querySelector('.section-header i')?.className || 'fas fa-file',
                    content: text.substring(0, 200)
                });
            }
        });
    }
    buildSearchData();

    // ============================================
    // SIDEBAR
    // ============================================
    function toggleSidebar() {
        document.body.classList.toggle('sidebar-collapsed');
    }

    if (sidebarToggle) {
        sidebarToggle.addEventListener('click', toggleSidebar);
    }
    if (sidebarShowBtn) {
        sidebarShowBtn.addEventListener('click', toggleSidebar);
    }

    // Búsqueda en sidebar
    if (sidebarSearch) {
        sidebarSearch.addEventListener('input', (e) => {
            const query = e.target.value.toLowerCase();
            sidebarLinks.forEach(link => {
                const text = link.textContent.toLowerCase();
                if (text.includes(query)) {
                    link.style.display = 'flex';
                } else {
                    link.style.display = 'none';
                }
            });
            
            // Ocultar secciones sin resultados
            document.querySelectorAll('.sidebar-section').forEach(section => {
                const visibleLinks = section.querySelectorAll('.sidebar-link[style*="flex"]');
                if (visibleLinks.length === 0 && query) {
                    section.style.display = 'none';
                } else {
                    section.style.display = 'block';
                }
            });
        });
    }

    // ============================================
    // BÚSQUEDA GLOBAL (Ctrl+K)
    // ============================================
    function openSearch() {
        searchModal.classList.add('active');
        setTimeout(() => searchInput.focus(), 100);
    }

    function closeSearch() {
        searchModal.classList.remove('active');
        searchInput.value = '';
        highlightedIndex = -1;
    }

    function performSearch(query) {
        if (!query) {
            searchResults.innerHTML = `
                <div class="no-results">
                    <i class="fas fa-search"></i>
                    <p>Escribe para buscar en la guía</p>
                </div>
            `;
            return;
        }

        const results = searchData.filter(item => 
            item.title.toLowerCase().includes(query.toLowerCase()) ||
            item.section.toLowerCase().includes(query.toLowerCase()) ||
            item.content.toLowerCase().includes(query.toLowerCase())
        );

        if (results.length === 0) {
            searchResults.innerHTML = `
                <div class="no-results">
                    <i class="fas fa-search"></i>
                    <p>No se encontraron resultados para "${query}"</p>
                </div>
            `;
            return;
        }

        searchResults.innerHTML = results.map((item, index) => `
            <a href="#${item.id}" class="search-result-item" data-index="${index}">
                <div class="search-result-icon">
                    <i class="${item.icon}"></i>
                </div>
                <div class="search-result-content">
                    <div class="search-result-title">${item.title}</div>
                    <div class="search-result-section">${item.section}</div>
                </div>
                <i class="fas fa-arrow-right search-result-arrow"></i>
            </a>
        `).join('');

        // Navegación con teclado
        const items = searchResults.querySelectorAll('.search-result-item');
        items.forEach(item => {
            item.addEventListener('click', (e) => {
                e.preventDefault();
                const targetId = item.getAttribute('href');
                closeSearch();
                setTimeout(() => {
                    const target = document.querySelector(targetId);
                    if (target) {
                        const offset = target.offsetTop - 80;
                        window.scrollTo({ top: offset, behavior: 'smooth' });
                    }
                }, 200);
            });
        });
    }

    if (searchToggle) {
        searchToggle.addEventListener('click', openSearch);
    }
    if (searchToggleSidebar) {
        searchToggleSidebar.addEventListener('click', openSearch);
    }
    if (searchClose) {
        searchClose.addEventListener('click', closeSearch);
    }
    if (searchModal) {
        searchModal.addEventListener('click', (e) => {
            if (e.target === searchModal) closeSearch();
        });
    }
    if (searchInput) {
        searchInput.addEventListener('input', (e) => {
            performSearch(e.target.value);
        });
    }

    // Atajos de teclado
    document.addEventListener('keydown', (e) => {
        if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
            e.preventDefault();
            openSearch();
        }
        if (e.key === 'Escape' && searchModal.classList.contains('active')) {
            closeSearch();
        }
        if (searchModal.classList.contains('active')) {
            const items = searchResults.querySelectorAll('.search-result-item');
            if (e.key === 'ArrowDown') {
                e.preventDefault();
                highlightedIndex = Math.min(highlightedIndex + 1, items.length - 1);
                items.forEach((item, i) => {
                    item.classList.toggle('highlighted', i === highlightedIndex);
                });
            }
            if (e.key === 'ArrowUp') {
                e.preventDefault();
                highlightedIndex = Math.max(highlightedIndex - 1, 0);
                items.forEach((item, i) => {
                    item.classList.toggle('highlighted', i === highlightedIndex);
                });
            }
            if (e.key === 'Enter' && highlightedIndex >= 0) {
                e.preventDefault();
                items[highlightedIndex].click();
            }
        }
    });

    // ============================================
    // MODO OSCURO
    // ============================================
    function toggleTheme() {
        const current = document.documentElement.getAttribute('data-theme');
        const newTheme = current === 'dark' ? 'light' : 'dark';
        document.documentElement.setAttribute('data-theme', newTheme);
        localStorage.setItem('theme', newTheme);
    }

    function loadTheme() {
        const saved = localStorage.getItem('theme');
        if (saved) {
            document.documentElement.setAttribute('data-theme', saved);
        } else if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
            document.documentElement.setAttribute('data-theme', 'dark');
        }
    }

    loadTheme();
    if (themeToggle) themeToggle.addEventListener('click', toggleTheme);
    if (headerThemeToggle) headerThemeToggle.addEventListener('click', toggleTheme);

    // ============================================
    // MODO LECTURA
    // ============================================
    const readingModeToggle = document.getElementById('readingModeToggle');
    function toggleReadingMode() {
        document.body.classList.toggle('reading-mode');
        const isActive = document.body.classList.contains('reading-mode');
        localStorage.setItem('guide-reading-mode', isActive);
        if (readingModeToggle) {
            readingModeToggle.classList.toggle('active', isActive);
            readingModeToggle.title = isActive ? 'Salir del modo lectura' : 'Modo lectura';
        }
    }
    if (readingModeToggle) {
        if (localStorage.getItem('guide-reading-mode') === 'true') {
            document.body.classList.add('reading-mode');
            readingModeToggle.classList.add('active');
            readingModeToggle.title = 'Salir del modo lectura';
        }
        readingModeToggle.addEventListener('click', toggleReadingMode);
    }

    // ============================================
    // SISTEMA DE PROGRESO
    // ============================================
    function loadProgress() {
        try {
            const saved = localStorage.getItem('guide-progress');
            if (saved) {
                const data = JSON.parse(saved);
                if (Array.isArray(data)) {
                    data.forEach(id => {
                        const check = document.querySelector(`[data-check="${id}"]`);
                        if (check) {
                            check.classList.add('completed');
                            check.innerHTML = '<i class="fas fa-check"></i>';
                        }
                    });
                }
            }
        } catch (e) {
            console.error('Error al cargar progreso:', e);
        }
    }

    function saveProgress(completed) {
        const checks = document.querySelectorAll('.sidebar-link-check.completed');
        const data = Array.from(checks).map(c => c.getAttribute('data-check'));
        localStorage.setItem('guide-progress', JSON.stringify(data));
    }

    function updateProgressBar() {
        const scrollTop = window.scrollY;
        const docHeight = document.documentElement.scrollHeight - window.innerHeight;
        const progress = Math.min((scrollTop / docHeight) * 100, 100);
        
        if (progressBar) progressBar.style.width = progress + '%';
        if (progressText) progressText.textContent = Math.round(progress) + '%';
    }

    // Checkboxes de progreso
    sidebarCheckboxes.forEach(check => {
        check.addEventListener('click', (e) => {
            e.preventDefault();
            e.stopPropagation();
            check.classList.toggle('completed');
            if (check.classList.contains('completed')) {
                check.innerHTML = '<i class="fas fa-check"></i>';
            } else {
                check.innerHTML = '';
            }
            saveProgress();
        });
    });

    // Reset progreso
    if (resetProgress) {
        resetProgress.addEventListener('click', () => {
            if (confirm('¿Reiniciar todo el progreso?')) {
                localStorage.removeItem('guide-progress');
                sidebarCheckboxes.forEach(check => {
                    check.classList.remove('completed');
                    check.innerHTML = '';
                });
            }
        });
    }

    loadProgress();

    // ============================================
    // NAVEGACIÓN
    // ============================================
    function updateActiveNav() {
        const scrollPos = window.scrollY + 150;
        
        sections.forEach(section => {
            const top = section.offsetTop;
            const height = section.offsetHeight;
            const id = section.getAttribute('id');
            
            if (scrollPos >= top && scrollPos < top + height) {
                sidebarLinks.forEach(link => {
                    link.classList.remove('active');
                    if (link.getAttribute('data-section') === id) {
                        link.classList.add('active');
                    }
                });
            }
        });
    }

    // Scroll suave para enlaces del sidebar
    sidebarLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            const href = link.getAttribute('href');
            if (href && href.startsWith('#')) {
                e.preventDefault();
                const target = document.querySelector(href);
                if (target) {
                    const offset = target.offsetTop - 80;
                    window.scrollTo({ top: offset, behavior: 'smooth' });
                }
            }
        });
    });

    // ============================================
    // TABS
    // ============================================
    tabBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            const tabId = btn.getAttribute('data-tab');
            tabBtns.forEach(b => b.classList.remove('active'));
            tabPanels.forEach(p => p.classList.remove('active'));
            btn.classList.add('active');
            const panel = document.getElementById('tab-' + tabId);
            if (panel) {
                panel.classList.add('active');
                if (typeof Prism !== 'undefined') {
                    Prism.highlightAllUnder(panel);
                }
            }
        });
    });

    // ============================================
    // QUIZ INTERACTIVO
    // ============================================
    document.querySelectorAll('.quiz-container').forEach(quiz => {
        const options = quiz.querySelectorAll('.quiz-option');
        const feedback = quiz.querySelectorAll('.quiz-feedback');
        const prevBtn = quiz.querySelector('.quiz-btn-prev');
        const nextBtn = quiz.querySelector('.quiz-btn-next');
        const currentSpan = quiz.querySelector('.quiz-current');
        const scoreSpan = quiz.querySelector('.quiz-score');
        const progressBar = quiz.querySelector('.quiz-progress-bar');
        const timerEl = quiz.querySelector('.quiz-timer');
        const questions = quiz.querySelectorAll('.quiz-question');
        let currentQuestion = 0;
        let score = 0;
        let answered = new Set();
        let timerSeconds = 0;
        let timerInterval = null;

        function startTimer() {
            if (timerInterval) return;
            timerInterval = setInterval(() => {
                timerSeconds++;
                if (timerEl) {
                    const m = String(Math.floor(timerSeconds / 60)).padStart(2, '0');
                    const s = String(timerSeconds % 60).padStart(2, '0');
                    timerEl.textContent = `${m}:${s}`;
                }
            }, 1000);
        }

        function stopTimer() {
            clearInterval(timerInterval);
            timerInterval = null;
        }

        function showQuestion(index) {
            questions.forEach((q, i) => {
                q.style.display = i === index ? 'block' : 'none';
            });
            if (currentSpan) currentSpan.textContent = index + 1;
            
            const total = questions.length;
            if (progressBar && total > 0) progressBar.style.width = ((index) / total * 100) + '%';
            
            // Clear feedback for new question
            if (questions[index]) {
                const currentFeedback = questions[index].querySelector('.quiz-feedback');
                if (currentFeedback) {
                    currentFeedback.classList.remove('show', 'correct', 'incorrect');
                    currentFeedback.innerHTML = '';
                    currentFeedback.style.display = 'none';
                }
            }

            if (prevBtn) prevBtn.style.display = index > 0 ? 'inline-flex' : 'none';
            if (nextBtn) {
                if (index === questions.length - 1) {
                    nextBtn.innerHTML = 'Ver Resultado <i class="fas fa-check"></i>';
                } else {
                    nextBtn.innerHTML = 'Siguiente <i class="fas fa-arrow-right"></i>';
                }
                // Disable next until question is answered
                nextBtn.disabled = !answered.has(index);
                nextBtn.style.opacity = answered.has(index) ? '1' : '0.5';
            }
            
            startTimer();
        }

        // Re-enable options when navigating
        function resetOptionsForQuestion(qIndex) {
            const q = questions[qIndex];
            if (!q) return;
            const opts = q.querySelectorAll('.quiz-option');
            opts.forEach(opt => {
                opt.disabled = false;
                opt.classList.remove('correct', 'incorrect');
            });
            // If already answered, show the state
            if (answered.has(qIndex)) {
                opts.forEach(opt => opt.disabled = true);
                const selected = q.querySelector('.quiz-option.selected');
                if (selected) {
                    const isCorrect = selected.getAttribute('data-correct') === 'true';
                    if (isCorrect) selected.classList.add('correct');
                    else selected.classList.add('incorrect');
                }
                opts.forEach(opt => {
                    if (opt.getAttribute('data-correct') === 'true') opt.classList.add('correct');
                });
            }
        }

        options.forEach(option => {
            option.addEventListener('click', () => {
                const questionEl = option.closest('.quiz-question');
                if (!questionEl) return;
                const qIndex = Array.from(questions).indexOf(questionEl);
                
                if (answered.has(qIndex)) return;
                answered.add(qIndex);
                
                const qOptions = questionEl.querySelectorAll('.quiz-option');
                const qFeedback = questionEl.querySelector('.quiz-feedback');
                const isCorrect = option.getAttribute('data-correct') === 'true';
                const correctText = qOptions[['A','B','C','D'].findIndex(l => option.querySelector('.quiz-option-letter')?.textContent === l)]?.querySelector('span:last-child')?.textContent || '';
                
                option.classList.add('selected');
                qOptions.forEach(opt => opt.disabled = true);
                
                qOptions.forEach(opt => {
                    if (opt.getAttribute('data-correct') === 'true') {
                        opt.classList.add('correct');
                    }
                });

                if (isCorrect) {
                    option.classList.add('correct');
                    score++;
                    if (scoreSpan) scoreSpan.textContent = score;
                    if (qFeedback) {
                        qFeedback.classList.add('show', 'correct');
                        qFeedback.style.display = 'block';
                        qFeedback.innerHTML = '<i class="fas fa-check-circle"></i> ¡Correcto! ' + correctText;
                    }
                } else {
                    option.classList.add('incorrect');
                    if (qFeedback) {
                        qFeedback.classList.add('show', 'incorrect');
                        qFeedback.style.display = 'block';
                        const correctOpt = Array.from(qOptions).find(o => o.getAttribute('data-correct') === 'true');
                        const correctAnswer = correctOpt ? correctOpt.querySelector('span:last-child')?.textContent || '' : '';
                        qFeedback.innerHTML = '<i class="fas fa-times-circle"></i> Incorrecto. La respuesta correcta es: <strong>' + correctAnswer + '</strong>';
                    }
                }
                
                if (nextBtn) {
                    nextBtn.disabled = false;
                    nextBtn.style.opacity = '1';
                }
                
                // Save progress to localStorage
                const quizData = JSON.parse(localStorage.getItem('quiz-progress') || '{}');
                quizData[qIndex] = { answered: true, correct: isCorrect };
                localStorage.setItem('quiz-progress', JSON.stringify(quizData));
            });
        });

        if (nextBtn) {
            nextBtn.addEventListener('click', () => {
                if (currentQuestion < questions.length - 1) {
                    currentQuestion++;
                    showQuestion(currentQuestion);
                    resetOptionsForQuestion(currentQuestion);
                } else {
                    // Show final result
                    stopTimer();
                    const totalScore = score;
                    const totalQ = questions.length;
                    const pct = Math.round(totalScore / totalQ * 100);
                    
                    let icon = '', msg = '', grade = '';
                    if (pct === 100) { icon = '🏆'; msg = '¡Excelente! Dominas completamente el tema.'; grade = 'A+'; }
                    else if (pct >= 80) { icon = '🌟'; msg = '¡Muy bien! Tienes un sólido entendimiento.'; grade = 'A'; }
                    else if (pct >= 60) { icon = '👍'; msg = 'Bien, pero repasa los puntos donde fallaste.'; grade = 'B'; }
                    else if (pct >= 40) { icon = '📖'; msg = 'Necesitas repasar más. Vuelve a leer las secciones.'; grade = 'C'; }
                    else { icon = '🔄'; msg = 'Te recomendamos estudiar la guía nuevamente.'; grade = 'D'; }

                    const resultEl = quiz.querySelector('.quiz-result');
                    if (resultEl) {
                        resultEl.style.display = 'block';
                        resultEl.innerHTML = `
                            <div class="quiz-feedback show ${pct >= 60 ? 'correct' : 'incorrect'}" style="display:block;text-align:center;padding:16px;">
                                <div style="font-size:3rem;margin-bottom:8px;">${icon}</div>
                                <h4 style="font-size:1.2rem;margin-bottom:4px;">¡Quiz Completado!</h4>
                                <div style="font-size:2rem;font-weight:800;color:var(--primary);">${totalScore}/${totalQ}</div>
                                <div style="font-size:0.9rem;color:var(--text-muted);margin:4px 0;">Calificación: <strong>${grade}</strong> (${pct}%)</div>
                                <p style="margin-top:8px;">${msg}</p>
                                <div style="margin-top:12px;font-size:0.8rem;color:var(--text-muted);">⏱️ Tiempo total: ${timerEl ? timerEl.textContent : '00:00'}</div>
                                <button class="quiz-btn quiz-btn-primary" onclick="location.reload()" style="margin-top:12px;">
                                    <i class="fas fa-redo"></i> Reintentar Quiz
                                </button>
                            </div>
                        `;
                    }
                    prevBtn.style.display = 'none';
                    nextBtn.style.display = 'none';
                    if (progressBar) progressBar.style.width = '100%';
                    
                    // Save best score
                    const best = JSON.parse(localStorage.getItem('quiz-best') || '{}');
                    const quizName = quiz.getAttribute('data-quiz') || 'default';
                    if (!best[quizName] || best[quizName] < totalScore) {
                        best[quizName] = totalScore;
                        localStorage.setItem('quiz-best', JSON.stringify(best));
                    }
                }
            });
        }

        if (prevBtn) {
            prevBtn.addEventListener('click', () => {
                if (currentQuestion > 0) {
                    currentQuestion--;
                    showQuestion(currentQuestion);
                    resetOptionsForQuestion(currentQuestion);
                }
            });
        }

        // Load saved progress
        try {
            const saved = JSON.parse(localStorage.getItem('quiz-progress') || '{}');
            if (saved && typeof saved === 'object') {
                Object.keys(saved).forEach(idx => {
                    const data = saved[idx];
                    if (data && data.answered && data.correct) score++;
                });
            }
        } catch (e) {
            console.error('Error al cargar progreso del quiz:', e);
        }
        if (scoreSpan) scoreSpan.textContent = score;

        try {
            showQuestion(0);
            resetOptionsForQuestion(0);
        } catch (e) {
            console.error('Error al inicializar preguntas del quiz:', e);
        }
    });

    // ============================================
    // SCROLL Y OBSERVERS
    // ============================================
    function handleScroll() {
        if (window.scrollY > 50) {
            document.getElementById('header')?.classList.add('scrolled');
        } else {
            document.getElementById('header')?.classList.remove('scrolled');
        }
        
        if (window.scrollY > 300) {
            scrollTopBtn?.classList.add('visible');
        } else {
            scrollTopBtn?.classList.remove('visible');
        }
        
        updateProgressBar();
        updateActiveNav();
    }

    window.addEventListener('scroll', handleScroll, { passive: true });

    if (scrollTopBtn) {
        scrollTopBtn.addEventListener('click', () => {
            window.scrollTo({ top: 0, behavior: 'smooth' });
        });
    }

    // Animaciones de entrada
    try {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }
            });
        }, { threshold: 0.1 });

        document.querySelectorAll('.step-card, .exercise-card, .evidence-card, .content-card, .tech-card, .problem-card, .objective-item, .timeline-item, .config-step, .simulator-card, .orm-side, .diagram-container, .quiz-container').forEach(el => {
            el.style.opacity = '0';
            el.style.transform = 'translateY(20px)';
            el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
            observer.observe(el);
        });
    } catch (e) {
        console.warn('IntersectionObserver no soportado o falló, mostrando elementos directamente:', e);
        document.querySelectorAll('.step-card, .exercise-card, .evidence-card, .content-card, .tech-card, .problem-card, .objective-item, .timeline-item, .config-step, .simulator-card, .orm-side, .diagram-container, .quiz-container').forEach(el => {
            el.style.opacity = '1';
            el.style.transform = 'none';
        });
    }

    // Inicializar de forma segura
    try { updateProgressBar(); } catch (e) { console.error('Error al actualizar barra de progreso:', e); }
    try { updateActiveNav(); } catch (e) { console.error('Error al actualizar navegación activa:', e); }

    try {
        if (typeof Prism !== 'undefined') {
            Prism.highlightAll();
        }
    } catch (e) {
        console.error('Error al ejecutar Prism highlightAll:', e);
    }

    // ============================================
    // MÓDULOS DE TECNOLOGÍA (EXPANDIR/COLAPSAR)
    // ============================================
    const techModules = document.querySelectorAll('.tech-module');

    // Función unificada para alternar el estado de un módulo
    function toggleModule(module) {
        if (!module) return;
        const isActive = module.classList.contains('active');
        
        // Cerrar todos los módulos
        techModules.forEach(m => m.classList.remove('active'));
        
        // Si no estaba activo, abrirlo
        if (!isActive) {
            module.classList.add('active');
            
            // Scroll suave al módulo
            setTimeout(() => {
                const offset = module.offsetTop - 100;
                window.scrollTo({ top: offset, behavior: 'smooth' });
            }, 100);
            
            // Re-highlight del código si Prism está disponible
            if (typeof Prism !== 'undefined') {
                setTimeout(() => {
                    try {
                        Prism.highlightAllUnder(module);
                    } catch (err) {
                        console.warn('Error al resaltar código en el módulo:', err);
                    }
                }, 300);
            }
        }
    }
    
    techModules.forEach(module => {
        const header = module.querySelector('.module-header');
        if (header) {
            header.addEventListener('click', (e) => {
                toggleModule(module);
            });
        }

        // Registrar click en el botón toggle si existe, para asegurar que funcione y no haga submit
        const toggleBtn = module.querySelector('.module-toggle');
        if (toggleBtn) {
            toggleBtn.addEventListener('click', (e) => {
                e.preventDefault();
                e.stopPropagation();
                toggleModule(module);
            });
        }
    });
    
    // Click en tech-cards para abrir el módulo correspondiente
    try {
        const techCards = document.querySelectorAll('.tech-card[data-tech]');
        
        techCards.forEach(card => {
            card.addEventListener('click', () => {
                const tech = card.getAttribute('data-tech');
                const module = document.getElementById('module-' + tech);
                if (module) {
                    toggleModule(module);
                }
            });
            card.style.cursor = 'pointer';
        });
    } catch (e) {
        console.error('Error al inicializar techCards:', e);
    }

    // ============================================
    // UI/UX ENHANCEMENTS v2.0
    // ============================================

    // --- TOAST SYSTEM ---
    function ensureToastContainer() {
        let container = document.querySelector('.toast-container');
        if (!container) {
            container = document.createElement('div');
            container.className = 'toast-container';
            document.body.appendChild(container);
        }
        return container;
    }

    function showToast(message, type, duration) {
        type = type || 'success';
        duration = duration || 4000;
        const container = ensureToastContainer();
        const icons = { success: 'check-circle', info: 'info-circle', warning: 'exclamation-triangle', error: 'times-circle', celebration: 'star' };
        const toast = document.createElement('div');
        toast.className = 'toast';
        toast.innerHTML = `
            <div class="toast-icon ${type}"><i class="fas fa-${icons[type] || 'info-circle'}"></i></div>
            <span class="toast-text">${message}</span>
            <button class="toast-close"><i class="fas fa-times"></i></button>
            <div class="toast-progress ${type}"></div>
        `;
        container.appendChild(toast);
        toast.querySelector('.toast-close').addEventListener('click', () => removeToast(toast));
        setTimeout(() => removeToast(toast), duration);
    }

    function removeToast(toast) {
        if (toast.classList.contains('toast-out')) return;
        toast.classList.add('toast-out');
        setTimeout(() => { if (toast.parentNode) toast.parentNode.removeChild(toast); }, 300);
    }

    // --- ENHANCED COPY WITH TOAST ---
    copyBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            const codeBlock = this.closest('.code-block');
            if (!codeBlock) return;
            const code = codeBlock.querySelector('code')?.textContent || '';
            navigator.clipboard.writeText(code).then(() => {
                const original = this.innerHTML;
                this.innerHTML = '<i class="fas fa-check"></i> Copiado';
                this.classList.add('copied');
                showToast('Código copiado al portapapeles', 'success', 2000);
                setTimeout(() => { this.innerHTML = original; this.classList.remove('copied'); }, 2000);
            });
        });
    });

    // --- AUTO-READ TRACKING ---
    const READ_STORAGE_KEY = 'guide-sections-read';
    const SECTION_TIME_KEY = 'guide-section-time';

    function getReadSections() {
        try { return JSON.parse(localStorage.getItem(READ_STORAGE_KEY)) || {}; }
        catch(e) { return {}; }
    }

    function markSectionRead(sectionId) {
        const data = getReadSections();
        if (!data[sectionId]) {
            data[sectionId] = { completed: true, timestamp: Date.now(), count: (data[sectionId]?.count || 0) + 1 };
            localStorage.setItem(READ_STORAGE_KEY, JSON.stringify(data));
            updateSectionVisualState(sectionId, 'completed');
            updateSidebarDot(sectionId, 'completed');
            updateQuickNavDot(sectionId, 'completed');
            updateReadingBadge(sectionId, 'completed');
            updateOverallProgress();
            if (!document.querySelector(`[data-check="${sectionId}"]`)?.classList.contains('completed')) {
                const check = document.querySelector(`[data-check="${sectionId}"]`);
                if (check) {
                    check.classList.add('completed');
                    check.innerHTML = '<i class="fas fa-check"></i>';
                    saveProgress();
                }
            }
            const totalRead = Object.keys(getReadSections()).length;
            if (totalRead > 0 && totalRead % 3 === 0) {
                triggerCelebration();
                showToast(`¡${totalRead} secciones completadas! Sigue así 🎉`, 'celebration', 5000);
            } else {
                showToast('Sección marcada como leída ✓', 'success', 2000);
            }
        }
    }

    function markSectionReading(sectionId) {
        updateSectionVisualState(sectionId, 'reading');
        updateSidebarDot(sectionId, 'reading');
        updateQuickNavDot(sectionId, 'reading');
        updateReadingBadge(sectionId, 'reading');
    }

    function updateSectionVisualState(sectionId, state) {
        const section = document.getElementById(sectionId);
        if (!section) return;
        section.classList.remove('section-state-unread', 'section-state-reading', 'section-state-completed');
        section.classList.add('section-state-' + state);
        const badge = section.querySelector('.section-read-state');
        if (badge) {
            badge.className = 'section-read-state ' + state;
            if (state === 'unread') { badge.innerHTML = '<i class="fas fa-circle read-state-icon" style="font-size:0.4rem;opacity:0.5"></i> No leído'; }
            else if (state === 'reading') { badge.innerHTML = '<i class="fas fa-spinner fa-pulse read-state-icon"></i> Leyendo'; }
            else { badge.innerHTML = ''; }
        }
    }

    function updateSidebarDot(sectionId, state) {
        const link = document.querySelector(`.sidebar-link[data-section="${sectionId}"]`);
        if (!link) return;
        let dot = link.querySelector('.section-progress-dot');
        if (!dot) {
            dot = document.createElement('span');
            dot.className = 'section-progress-dot';
            link.appendChild(dot);
        }
        dot.className = 'section-progress-dot ' + state;
    }

    function updateReadingBadge(sectionId, state) {
        const section = document.getElementById(sectionId);
        if (!section) return;
        const badge = section.querySelector('.section-read-state');
        if (badge) {
            badge.className = 'section-read-state ' + state;
            if (state === 'unread') badge.innerHTML = '<i class="fas fa-circle read-state-icon" style="font-size:0.4rem;opacity:0.5"></i> No leído';
            else if (state === 'reading') badge.innerHTML = '<i class="fas fa-spinner fa-pulse read-state-icon"></i> Leyendo';
            else badge.innerHTML = '';
        }
    }

    // --- READING TIME ESTIMATOR ---
    function estimateReadingTime(section) {
        const text = section.textContent || '';
        const wordsPerMinute = 200;
        const textLength = text.trim().split(/\s+/).length;
        return Math.max(1, Math.ceil(textLength / wordsPerMinute));
    }

    function addReadingTimeBadges() {
        document.querySelectorAll('section[id]').forEach(section => {
            if (section.querySelector('.reading-time-badge')) return;
            const minutes = estimateReadingTime(section);
            const header = section.querySelector('.section-header-wrap, .section-header');
            if (header) {
                const badge = document.createElement('span');
                badge.className = 'reading-time-badge';
                badge.innerHTML = `<i class="far fa-clock"></i> ${minutes} min`;
                header.appendChild(badge);
            }
        });
    }

    // --- INTERSECTION OBSERVER FOR AUTO-READ ---
    function setupReadTracking() {
        const readData = getReadSections();
        const sectionEls = document.querySelectorAll('section[id]');
        
        // Initialize visual state for all sections
        sectionEls.forEach(section => {
            const id = section.getAttribute('id');
            // Add state overlay
            if (!section.querySelector('.section-state-overlay')) {
                const overlay = document.createElement('div');
                overlay.className = 'section-state-overlay';
                section.appendChild(overlay);
            }
            // Add reading time badges
            if (!section.querySelector('.reading-time-badge') && section.querySelector('.section-header-wrap, .section-header')) {
                const minutes = estimateReadingTime(section);
                const header = section.querySelector('.section-header-wrap, .section-header');
                if (header) {
                    const badge = document.createElement('span');
                    badge.className = 'reading-time-badge';
                    badge.innerHTML = `<i class="far fa-clock"></i> ${minutes} min`;
                    header.appendChild(badge);
                }
            }
            const initialState = readData[id]?.completed ? 'completed' : 'unread';
            updateSectionVisualState(id, initialState);
            updateSidebarDot(id, initialState);
        });

        // Section enter/exit tracking
        const sectionObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                const id = entry.target.getAttribute('id');
                if (!id) return;
                const readData = getReadSections();
                
                if (entry.isIntersecting) {
                    if (!readData[id]?.completed) {
                        markSectionReading(id);
                    }
                    // Update quick nav active
                    document.querySelectorAll('.quick-nav-dot').forEach(d => d.classList.remove('active-section'));
                    const dot = document.querySelector(`.quick-nav-dot[data-section="${id}"]`);
                    if (dot) dot.classList.add('active-section');
                }
            });
        }, { threshold: 0.15 });

        sectionEls.forEach(s => sectionObserver.observe(s));

        // Auto-mark as read after time threshold (30 seconds of being visible)
        const timeTracker = {};
        const timeObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                const id = entry.target.getAttribute('id');
                if (!id) return;
                const readData = getReadSections();
                if (readData[id]?.completed) return;

                if (entry.isIntersecting) {
                    if (!timeTracker[id]) timeTracker[id] = { start: Date.now(), timer: null };
                    if (!timeTracker[id].timer) {
                        timeTracker[id].timer = setTimeout(() => {
                            const stillVisible = document.getElementById(id);
                            if (stillVisible) {
                                const rect = stillVisible.getBoundingClientRect();
                                if (rect.top < window.innerHeight && rect.bottom > 0) {
                                    const readData = getReadSections();
                                    if (!readData[id]?.completed) {
                                        markSectionRead(id);
                                    }
                                }
                            }
                            delete timeTracker[id];
                        }, 30000);
                    }
                } else {
                    if (timeTracker[id]) {
                        clearTimeout(timeTracker[id].timer);
                        delete timeTracker[id];
                    }
                }
            });
        }, { threshold: 0.3 });

        sectionEls.forEach(s => timeObserver.observe(s));
    }

    // --- QUICK NAV PANEL ---
    function buildQuickNav() {
        if (document.querySelector('.quick-nav-panel')) return;
        
        const sections = document.querySelectorAll('section[id]');
        if (sections.length < 3) return;
        
        const panel = document.createElement('nav');
        panel.className = 'quick-nav-panel';
        panel.setAttribute('aria-label', 'Navegación rápida');
        
        const readData = getReadSections();
        
        sections.forEach(section => {
            const id = section.getAttribute('id');
            if (!id) return;
            const title = section.querySelector('.section-title, .hero-title')?.textContent?.trim() || id;
            const state = readData[id]?.completed ? 'completed' : 'unread';
            
            const dot = document.createElement('button');
            dot.className = `quick-nav-dot ${state}`;
            dot.setAttribute('data-section', id);
            dot.setAttribute('aria-label', `Ir a: ${title}`);
            dot.innerHTML = `<span class="quick-nav-tooltip">${title}</span>`;
            
            dot.addEventListener('click', () => {
                const target = document.getElementById(id);
                if (target) {
                    const offset = target.offsetTop - 80;
                    window.scrollTo({ top: offset, behavior: 'smooth' });
                }
            });
            
            panel.appendChild(dot);
        });
        
        document.body.appendChild(panel);
        
        // Show panel after scrolling a bit
        let navTimeout;
        window.addEventListener('scroll', () => {
            if (window.scrollY > 400) {
                panel.classList.add('visible');
                clearTimeout(navTimeout);
            } else {
                navTimeout = setTimeout(() => panel.classList.remove('visible'), 200);
            }
        }, { passive: true });
    }

    function updateQuickNavDot(sectionId, state) {
        const dot = document.querySelector(`.quick-nav-dot[data-section="${sectionId}"]`);
        if (dot) {
            dot.className = 'quick-nav-dot ' + state;
        }
    }

    // --- OVERALL PROGRESS ---
    function updateOverallProgress() {
        const total = document.querySelectorAll('section[id]').length;
        const readData = getReadSections();
        const completed = Object.keys(readData).filter(k => readData[k]?.completed).length;
        const pct = total > 0 ? Math.round((completed / total) * 100) : 0;
        
        // Update sidebar progress ring
        const ring = document.querySelector('.progress-ring-fill');
        if (ring) {
            const circumference = 2 * Math.PI * 14;
            const offset = circumference - (pct / 100) * circumference;
            ring.style.strokeDasharray = circumference;
            ring.style.strokeDashoffset = offset;
        }
        const ringText = document.querySelector('.progress-ring-text');
        if (ringText) ringText.textContent = pct + '%';
        
        // Update sidebar progress label
        const label = document.querySelector('.progress-ring-label');
        if (label) label.innerHTML = `<strong>${completed}</strong>/${total} secciones`;
        
        // Update header stats
        const headerStat = document.querySelector('#headerProgressStat');
        if (headerStat) headerStat.textContent = completed + '/' + total;
        const headerPct = document.querySelector('#headerPctStat');
        if (headerPct) headerPct.textContent = pct + '%';
        
        // Update section group status
        document.querySelectorAll('.sidebar-section').forEach(group => {
            const links = group.querySelectorAll('.sidebar-link[data-section]');
            const totalLinks = links.length;
            const completedLinks = Array.from(links).filter(l => {
                const id = l.getAttribute('data-section');
                return readData[id]?.completed;
            }).length;
            const statusEl = group.querySelector('.sidebar-section-status');
            if (statusEl) {
                const pct = totalLinks > 0 ? Math.round((completedLinks / totalLinks) * 100) : 0;
                statusEl.innerHTML = `<span class="status-bar"><span class="status-bar-fill" style="width:${pct}%"></span></span> ${completedLinks}/${totalLinks}`;
                statusEl.className = 'sidebar-section-status' + (pct === 100 ? ' complete' : '');
            }
        });

        if (progressText) progressText.textContent = pct + '%';
    }

    function buildSidebarProgressRing() {
        const footer = document.querySelector('.sidebar-footer');
        if (!footer || footer.querySelector('.progress-ring-container')) return;
        
        const container = document.createElement('div');
        container.className = 'progress-ring-container';
        container.innerHTML = `
            <div class="progress-ring">
                <svg width="36" height="36" viewBox="0 0 36 36">
                    <circle class="progress-ring-bg" cx="18" cy="18" r="14"/>
                    <circle class="progress-ring-fill" cx="18" cy="18" r="14"/>
                </svg>
                <span class="progress-ring-text">0%</span>
            </div>
            <span class="progress-ring-label"><strong>0</strong>/0 secciones</span>
        `;
        
        footer.insertBefore(container, footer.firstChild);
    }

    // --- CELEBRATION EFFECT ---
    function triggerCelebration() {
        let overlay = document.querySelector('.celebration-overlay');
        if (!overlay) {
            overlay = document.createElement('div');
            overlay.className = 'celebration-overlay';
            document.body.appendChild(overlay);
        }
        
        const colors = ['#00664a', '#f9a825', '#16a34a', '#0284c7', '#7c3aed', '#dc2626', '#f59e0b', '#00b386'];
        
        for (let i = 0; i < 50; i++) {
            const particle = document.createElement('div');
            particle.className = 'celebration-particle';
            const color = colors[Math.floor(Math.random() * colors.length)];
            const left = Math.random() * 100;
            const size = 4 + Math.random() * 8;
            const duration = 2 + Math.random() * 3;
            const delay = Math.random() * 1.5;
            particle.style.cssText = `
                left: ${left}%;
                width: ${size}px;
                height: ${size}px;
                background: ${color};
                border-radius: ${Math.random() > 0.5 ? '50%' : '2px'};
                --duration: ${duration}s;
                animation-delay: ${delay}s;
            `;
            overlay.appendChild(particle);
        }
        
        setTimeout(() => { if (overlay.parentNode) overlay.parentNode.removeChild(overlay); }, 5000);
    }

    // --- FOCUS MODE FOR CODE BLOCKS ---
    function addFocusModeToCodeBlocks() {
        document.querySelectorAll('.code-block').forEach(block => {
            if (block.querySelector('.focus-toggle-btn')) return;
            const header = block.querySelector('.code-header, .window-header');
            if (header) {
                const btn = document.createElement('button');
                btn.className = 'focus-toggle-btn';
                btn.innerHTML = '<i class="fas fa-expand"></i>';
                btn.title = 'Modo enfoque';
                btn.addEventListener('click', (e) => {
                    e.stopPropagation();
                    toggleFocusMode(block);
                });
                header.appendChild(btn);
            }
        });
    }

    function toggleFocusMode(block) {
        const isActive = block.classList.contains('focus-mode');
        let overlay = document.querySelector('.code-overlay');
        
        if (isActive) {
            block.classList.remove('focus-mode');
            block.querySelector('.focus-toggle-btn').innerHTML = '<i class="fas fa-expand"></i>';
            if (overlay) {
                overlay.classList.remove('active');
                setTimeout(() => { if (overlay.parentNode) overlay.parentNode.removeChild(overlay); }, 300);
            }
            document.body.style.overflow = '';
        } else {
            if (!overlay) {
                overlay = document.createElement('div');
                overlay.className = 'code-overlay';
                document.body.appendChild(overlay);
            }
            block.classList.add('focus-mode');
            block.querySelector('.focus-toggle-btn').innerHTML = '<i class="fas fa-compress"></i>';
            overlay.classList.add('active');
            document.body.style.overflow = 'hidden';
            
            overlay.addEventListener('click', () => toggleFocusMode(block), { once: true });
            
            // Scroll the focused block into view
            setTimeout(() => block.scrollIntoView({ behavior: 'smooth', block: 'center' }), 100);
        }
    }

    // --- KEYBOARD SHORTCUTS ---
    function buildShortcutsModal() {
        if (document.querySelector('.shortcuts-modal')) return;
        
        const modal = document.createElement('div');
        modal.className = 'shortcuts-modal';
        modal.id = 'shortcutsModal';
        modal.innerHTML = `
            <div class="shortcuts-content">
                <h3><i class="fas fa-keyboard"></i> Atajos de Teclado</h3>
                <div class="shortcuts-grid">
                    <div class="shortcut-row">
                        <span>Buscar en la guía</span>
                        <div class="shortcut-keys"><span class="shortcut-key">Ctrl</span><span class="shortcut-key">K</span></div>
                    </div>
                    <div class="shortcut-row">
                        <span>Alternar modo oscuro</span>
                        <div class="shortcut-keys"><span class="shortcut-key">Ctrl</span><span class="shortcut-key">D</span></div>
                    </div>
                    <div class="shortcut-row">
                        <span>Marcar sección como leída</span>
                        <div class="shortcut-keys"><span class="shortcut-key">Ctrl</span><span class="shortcut-key">Enter</span></div>
                    </div>
                    <div class="shortcut-row">
                        <span>Ir al inicio</span>
                        <div class="shortcut-keys"><span class="shortcut-key">Ctrl</span><span class="shortcut-key">Home</span></div>
                    </div>
                    <div class="shortcut-row">
                        <span>Mostrar/ocultar sidebar</span>
                        <div class="shortcut-keys"><span class="shortcut-key">Ctrl</span><span class="shortcut-key">B</span></div>
                    </div>
                    <div class="shortcut-row">
                        <span>Mostrar este panel</span>
                        <div class="shortcut-keys"><span class="shortcut-key">?</span></div>
                    </div>
                </div>
                <p style="text-align:center;margin-top:16px;font-size:0.75rem;color:var(--text-muted)">Presiona <kbd style="padding:2px 6px;background:var(--bg-tertiary);border-radius:3px;font-family:var(--font-mono);font-size:0.7rem">ESC</kbd> para cerrar</p>
            </div>
        `;
        
        modal.addEventListener('click', (e) => {
            if (e.target === modal) modal.classList.remove('active');
        });
        
        document.body.appendChild(modal);
    }

    function showShortcuts() {
        const modal = document.getElementById('shortcutsModal');
        if (modal) modal.classList.add('active');
    }

    // --- KEYBOARD SHORTCUTS HANDLER ---
    document.addEventListener('keydown', (e) => {
        // Ctrl+D for theme toggle
        if ((e.ctrlKey || e.metaKey) && e.key === 'd') {
            e.preventDefault();
            toggleTheme();
            showToast('Modo ' + (document.documentElement.getAttribute('data-theme') === 'dark' ? 'oscuro' : 'claro') + ' activado', 'info', 2000);
        }
        // ? for shortcuts
        if (e.key === '?' && !e.ctrlKey && !e.metaKey && !e.altKey) {
            const target = e.target;
            if (target.tagName === 'INPUT' || target.tagName === 'TEXTAREA' || target.isContentEditable) return;
            e.preventDefault();
            showShortcuts();
        }
        // Escape for shortcuts modal
        if (e.key === 'Escape') {
            const modal = document.getElementById('shortcutsModal');
            if (modal?.classList.contains('active')) modal.classList.remove('active');
        }
        // Ctrl+Enter for mark section read
        if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
            e.preventDefault();
            const activeLink = document.querySelector('.sidebar-link.active');
            if (activeLink) {
                const sectionId = activeLink.getAttribute('data-section');
                if (sectionId) {
                    const readData = getReadSections();
                    if (!readData[sectionId]?.completed) {
                        markSectionRead(sectionId);
                    } else {
                        showToast('Sección ya marcada como leída', 'info', 2000);
                    }
                }
            }
        }
        // Ctrl+B for sidebar toggle
        if ((e.ctrlKey || e.metaKey) && e.key === 'b') {
            e.preventDefault();
            toggleSidebar();
        }
    });

    // --- MARK READ BUTTONS IN SECTIONS ---
    function addMarkReadButtons() {
        document.querySelectorAll('section[id]').forEach(section => {
            if (section.querySelector('.mark-read-btn')) return;
            const id = section.getAttribute('id');
            const readData = getReadSections();
            if (readData[id]?.completed) return;
            
            const header = section.querySelector('.section-header-wrap, .section-header');
            if (header && !section.closest('.tech-module')) {
                const btn = document.createElement('button');
                btn.className = 'mark-read-btn';
                btn.innerHTML = '<i class="far fa-circle"></i> Marcar como leído';
                btn.addEventListener('click', (e) => {
                    e.preventDefault();
                    e.stopPropagation();
                    markSectionRead(id);
                    btn.innerHTML = '<i class="fas fa-check-circle"></i> Completado';
                    btn.classList.add('completed');
                });
                // Add to section-header-wrap or after section-header
                const wrap = section.querySelector('.section-header-wrap');
                if (wrap) wrap.appendChild(btn);
                else header.appendChild(btn);
            }
        });
    }

    // --- HEADER PROGRESS STATS ---
    function addHeaderProgressStats() {
        const headerMeta = document.querySelector('.header-meta, .header-right');
        if (!headerMeta || headerMeta.querySelector('.header-progress-stats')) return;
        
        const stats = document.createElement('div');
        stats.className = 'header-progress-stats';
        stats.innerHTML = `
            <span class="stat">📖 <strong id="headerProgressStat">0/0</strong></span>
            <span class="stat-divider"></span>
            <span class="stat">🎯 <strong id="headerPctStat">0%</strong></span>
        `;
        
        headerMeta.insertBefore(stats, headerMeta.firstChild);
    }

    // --- BUILD SECTION STATE BADGES ---
    function addSectionStateBadges() {
        document.querySelectorAll('section[id]').forEach(section => {
            if (section.querySelector('.section-read-state') || section.closest('.tech-module')) return;
            const id = section.getAttribute('id');
            const readData = getReadSections();
            
            const headerWrap = section.querySelector('.section-header-wrap');
            if (!headerWrap) {
                const header = section.querySelector('.section-header');
                if (header) {
                    const wrap = document.createElement('div');
                    wrap.className = 'section-header-wrap';
                    wrap.innerHTML = header.innerHTML;
                    header.innerHTML = '';
                    header.appendChild(wrap);
                }
            }
            
            const targetWrap = section.querySelector('.section-header-wrap');
            if (targetWrap) {
                const badge = document.createElement('span');
                badge.className = 'section-read-state ' + (readData[id]?.completed ? 'completed' : 'unread');
                badge.innerHTML = readData[id]?.completed ? '' : '<i class="fas fa-circle read-state-icon" style="font-size:0.4rem;opacity:0.5"></i> No leído';
                targetWrap.appendChild(badge);
            }
        });
    }

    // --- BUILD SIDEBAR SECTION STATUS BARS ---
    function addSidebarSectionStatus() {
        document.querySelectorAll('.sidebar-section').forEach(group => {
            if (group.querySelector('.sidebar-section-status')) return;
            const title = group.querySelector('.sidebar-section-title');
            if (title) {
                const status = document.createElement('span');
                status.className = 'sidebar-section-status';
                status.innerHTML = '<span class="status-bar"><span class="status-bar-fill" style="width:0%"></span></span> 0/0';
                title.appendChild(status);
            }
        });
    }

    // --- FLOATING CODE PREVIEW ON SIDEBAR HOVER ---
    function addSidebarPreviews() {
        document.querySelectorAll('.sidebar-link[data-section]').forEach(link => {
            if (link.querySelector('.sidebar-link-preview')) return;
            const preview = document.createElement('span');
            preview.className = 'sidebar-link-preview';
            preview.textContent = 'Ir a sección';
            link.appendChild(preview);
        });
    }

    // --- SESSION TIMER ---
    function initSessionTimer() {
        const startKey = 'guide-session-start';
        let startTime = localStorage.getItem(startKey);
        if (!startTime) {
            startTime = Date.now().toString();
            localStorage.setItem(startKey, startTime);
        }
        const elapsed = Math.floor((Date.now() - parseInt(startTime)) / 1000);
        const minutes = Math.floor(elapsed / 60);
        
        if (minutes > 1) {
            setTimeout(() => {
                showToast(`Llevas ${minutes} min estudiando. ¡Sigue así! 💪`, 'info', 4000);
            }, 2000);
        }
    }

    // ============================================
    // SCROLL TO TOP ON PAGE LOAD
    // ============================================
    if (!window.location.hash) {
        window.scrollTo(0, 0);
    }

    // ============================================
    // PREV/NEXT SECTION NAVIGATION
    // ============================================
    function buildSectionNav() {
        const navSections = Array.from(document.querySelectorAll('section[id]'));
        if (navSections.length < 2) return;

        const sectionData = navSections.map((section, idx) => {
            const title = section.querySelector('.section-title, .hero-title')?.textContent?.trim() || '';
            return { id: section.getAttribute('id'), title: title, index: idx };
        });

        navSections.forEach((section, idx) => {
            if (section.classList.contains('hero-section') || section.querySelector('.section-nav')) return;
            const prev = idx > 0 ? sectionData[idx - 1] : null;
            const next = idx < sectionData.length - 1 ? sectionData[idx + 1] : null;

            const nav = document.createElement('nav');
            nav.className = 'section-nav';
            nav.setAttribute('aria-label', 'Navegación de sección');

            if (prev) {
                nav.innerHTML += `
                    <a href="#${prev.id}" class="section-nav-link prev">
                        <div class="nav-arrow"><i class="fas fa-arrow-left"></i></div>
                        <div>
                            <div class="nav-label">Anterior</div>
                            <div class="nav-title">${prev.title}</div>
                        </div>
                    </a>
                `;
            } else {
                nav.innerHTML += '<div></div>';
            }

            if (next) {
                nav.innerHTML += `
                    <a href="#${next.id}" class="section-nav-link next">
                        <div>
                            <div class="nav-label">Siguiente</div>
                            <div class="nav-title">${next.title}</div>
                        </div>
                        <div class="nav-arrow"><i class="fas fa-arrow-right"></i></div>
                    </a>
                `;
            } else {
                nav.innerHTML += '<div></div>';
            }

            section.appendChild(nav);
        });

        document.querySelectorAll('.section-nav-link').forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const href = link.getAttribute('href');
                const target = document.querySelector(href);
                if (target) {
                    const offset = target.offsetTop - 80;
                    window.scrollTo({ top: offset, behavior: 'smooth' });
                    history.pushState(null, '', href);
                }
            });
        });
    }

    // ============================================
    // BREADCRUMBS
    // ============================================
    function buildBreadcrumbs() {
        const mainContent = document.querySelector('.main-content, main');
        if (!mainContent || mainContent.querySelector('.breadcrumbs')) return;

        const pageName = document.title.split('|')[0].trim().substring(0, 40);
        const currentPage = window.location.pathname.split('/').pop() || 'index.html';

        const pageMap = {
            'index.html': { name: 'Guía JSP + MVC', icon: 'fa-java' },
            'flutter-guide.html': { name: 'Guía Flutter', icon: 'fa-flutter' },
            'simuladores.html': { name: 'Simuladores', icon: 'fa-flask' }
        };

        const current = pageMap[currentPage] || { name: pageName, icon: 'fa-book' };

        const crumbs = document.createElement('div');
        crumbs.className = 'breadcrumbs';
        crumbs.innerHTML = `
            <a href="index.html"><i class="fas fa-home"></i> Inicio</a>
            <span class="breadcrumb-sep"><i class="fas fa-chevron-right"></i></span>
            <span class="breadcrumb-current"><i class="fas ${current.icon}"></i> ${current.name}</span>
        `;

        const firstSection = mainContent.querySelector('section[id]');
        if (firstSection) {
            firstSection.parentNode.insertBefore(crumbs, firstSection);
        }
    }

    // ============================================
    // PAGE SWITCHER IN HEADER
    // ============================================
    function buildPageSwitcher() {
        const headerLeft = document.querySelector('.header-left, .header-inner > div:first-child');
        if (!headerLeft || headerLeft.querySelector('.page-switcher')) return;
        if (document.querySelector('.page-switcher')) return;

        const currentPage = window.location.pathname.split('/').pop() || 'index.html';

        const switcher = document.createElement('nav');
        switcher.className = 'page-switcher';
        switcher.innerHTML = `
            <a href="index.html" class="page-switcher-link ${currentPage === 'index.html' ? 'active' : ''}">
                <i class="fab fa-java"></i> JSP
            </a>
            <a href="flutter-guide.html" class="page-switcher-link ${currentPage === 'flutter-guide.html' ? 'active' : ''}">
                <i class="fab fa-flutter"></i> Flutter
            </a>
            <a href="simuladores.html" class="page-switcher-link ${currentPage === 'simuladores.html' ? 'active' : ''}">
                <i class="fas fa-flask"></i> Labs
            </a>
        `;

        headerLeft.appendChild(switcher);
    }

    // ============================================
    // MOBILE BOTTOM NAV
    // ============================================
    function buildMobileNav() {
        if (document.querySelector('.mobile-page-nav')) return;

        const currentPage = window.location.pathname.split('/').pop() || 'index.html';

        const nav = document.createElement('nav');
        nav.className = 'mobile-page-nav';
        nav.innerHTML = `
            <a href="index.html" class="mobile-page-nav-link ${currentPage === 'index.html' ? 'active' : ''}">
                <i class="fab fa-java"></i>
                <span>JSP</span>
            </a>
            <a href="flutter-guide.html" class="mobile-page-nav-link ${currentPage === 'flutter-guide.html' ? 'active' : ''}">
                <i class="fab fa-flutter"></i>
                <span>Flutter</span>
            </a>
            <a href="simuladores.html" class="mobile-page-nav-link ${currentPage === 'simuladores.html' ? 'active' : ''}">
                <i class="fas fa-flask"></i>
                <span>Labs</span>
            </a>
        `;

        document.body.appendChild(nav);
    }

    // ============================================
    // KEYBOARD NAVIGATION (Arrow keys for prev/next)
    // ============================================
    document.addEventListener('keydown', (e) => {
        if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA' || e.target.isContentEditable) return;
        if (e.ctrlKey || e.metaKey || e.altKey) return;

        if (e.key === 'ArrowLeft' || e.key === 'ArrowRight') {
            const activeLink = document.querySelector('.sidebar-link.active');
            if (!activeLink) return;

            const allLinks = Array.from(document.querySelectorAll('.sidebar-link[data-section]'));
            const currentIdx = allLinks.indexOf(activeLink);
            if (currentIdx === -1) return;

            let targetIdx = -1;
            if (e.key === 'ArrowLeft' && currentIdx > 0) targetIdx = currentIdx - 1;
            if (e.key === 'ArrowRight' && currentIdx < allLinks.length - 1) targetIdx = currentIdx + 1;

            if (targetIdx >= 0) {
                e.preventDefault();
                const targetLink = allLinks[targetIdx];
                const href = targetLink.getAttribute('href');
                const target = document.querySelector(href);
                if (target) {
                    const offset = target.offsetTop - 80;
                    window.scrollTo({ top: offset, behavior: 'smooth' });
                    history.pushState(null, '', href);
                }
            }
        }
    });

    // --- INITIALIZE ALL UI/UX ENHANCEMENTS ---
    try {
        buildShortcutsModal();
        addHeaderProgressStats();
        buildSidebarProgressRing();
        addSidebarSectionStatus();
        addSectionStateBadges();
        addReadingTimeBadges();
        buildQuickNav();
        addFocusModeToCodeBlocks();
        addMarkReadButtons();
        addSidebarPreviews();
        setupReadTracking();
        updateOverallProgress();
        initSessionTimer();
        buildSectionNav();
        buildBreadcrumbs();
        buildPageSwitcher();
        buildMobileNav();
    } catch (e) {
        console.warn('Error al inicialar mejoras UI/UX:', e);
    }

    console.log('%c🎓 Guía JSP + MVC | SENA ADSO v2.0', 'font-size: 20px; font-weight: bold; color: #00664a;');
    console.log('%cDesarrollado con ❤️ para aprendices del SENA', 'font-size: 12px; color: #666;');
    console.log('%cPresiona Ctrl+K para búsqueda global | ? para atajos', 'font-size: 11px; color: #999;');
});