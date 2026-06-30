import os

styles_path = r"c:\Users\Miguel\Documents\Aplicaciones\_projects\guia-jsp\web\css\styles.css"

with open(styles_path, 'r', encoding='utf-8') as f:
    content = f.read()

# We want to find the last clean selector before '#fundamentos .concept-card' or '#fundamentos #tab-'
target = '#fundamentos #tab-jakarta.active'
idx = content.find(target)
if idx == -1:
    # Let's search for '#fundamentos .concept-card'
    target = '#fundamentos .concept-card'
    idx = content.find(target)

if idx != -1:
    print(f"Found target at index {idx}")
    # Truncate content at the target block
    new_content = content[:idx]
else:
    print("Target not found, appending to end")
    new_content = content

# Now append all rules cleanly
new_rules = """#fundamentos #tab-jakarta.active {
    border-left-color: var(--accent);
}
#fundamentos #tab-jdbc.active {
    border-left-color: var(--info);
}
#fundamentos #tab-records.active {
    border-left-color: #0d9488;
}

/* Enhanced Concept Cards */
#fundamentos .concept-card {
    position: relative;
    border-left: 4px solid var(--border-light);
    transition: transform 0.3s ease, box-shadow 0.3s ease;
}

#fundamentos .concept-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 12px 24px rgba(0, 0, 0, 0.1);
}

#fundamentos .concept-card:has(.concept-icon.model) {
    border-left-color: var(--info);
}
#fundamentos .concept-card:has(.concept-icon.view) {
    border-left-color: var(--success);
}
#fundamentos .concept-card:has(.concept-icon.controller) {
    border-left-color: var(--accent);
}

/* Colorful flow diagram */
#fundamentos .flow-diagram {
    background: linear-gradient(135deg, var(--bg-secondary), var(--bg-tertiary));
    border: 1px solid var(--border);
    gap: 8px;
}

#fundamentos .flow-step {
    border-left: 3px solid var(--primary);
    transition: transform 0.2s ease, box-shadow 0.2s ease;
}

#fundamentos .flow-step:hover {
    transform: scale(1.02);
    box-shadow: var(--shadow-md);
}

#fundamentos .flow-step:nth-child(3) { border-left-color: var(--primary); }
#fundamentos .flow-step:nth-child(5) { border-left-color: var(--accent); }
#fundamentos .flow-step:nth-child(7) { border-left-color: var(--info); }
#fundamentos .flow-step:nth-child(9) { border-left-color: var(--success); }
#fundamentos .flow-step:nth-child(11) { border-left-color: #d97706; }
#fundamentos .flow-step:nth-child(13) { border-left-color: #0d9488; }

#fundamentos .step-number {
    background: linear-gradient(135deg, var(--primary), var(--primary-light));
    box-shadow: 0 2px 6px rgba(0, 102, 74, 0.3);
}

#fundamentos .flow-arrow {
    color: var(--primary);
    font-size: 1.2rem;
    opacity: 0.6;
}

/* Feature items with gradient icons */
#fundamentos .feature-item i {
    background: linear-gradient(135deg, var(--primary), var(--primary-light));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    font-size: 1.3rem;
}

/* Colorful comparison items */
#fundamentos .comparison-table {
    border: 2px solid var(--border-light);
    border-radius: var(--radius-md);
    overflow: hidden;
}

#fundamentos .comparison-item.old {
    border-left: 4px solid var(--danger);
}

#fundamentos .comparison-item.new {
    border-left: 4px solid var(--success);
}

/* Advantage grid colorful items */
#fundamentos .advantage-item i {
    background: linear-gradient(135deg, var(--success), var(--primary-light));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    font-size: 1.1rem;
}

/* Warning box enhancement */
#fundamentos .warning-box {
    border-left: 4px solid var(--danger);
    background: linear-gradient(135deg, rgba(220, 38, 38, 0.04), rgba(220, 38, 38, 0.01));
}

/* Pros/Cons colorful styling */
#fundamentos .pros h5 {
    color: var(--success);
}
#fundamentos .pros h5 i {
    color: var(--success);
}
#fundamentos .cons h5 {
    color: var(--danger);
}
#fundamentos .cons h5 i {
    color: var(--danger);
}

/* ORM vs badge */
#fundamentos .orm-vs span {
    background: linear-gradient(135deg, var(--primary), var(--accent));
    color: white;
    width: 48px;
    height: 48px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 800;
    font-size: 0.9rem;
    box-shadow: 0 4px 12px rgba(0, 102, 74, 0.25);
}

/* Recommendation box enhancement */
#fundamentos .recommendation-box {
    border-left: 4px solid var(--primary);
    border-radius: var(--radius-md);
}

#fundamentos .recommendation-box i {
    background: linear-gradient(135deg, var(--warning), #f59e0b);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    font-size: 1.4rem;
}

/* ==========================================================================
   COLORES PREMIUM PARA CÓDIGO (PRISM HIGHLIGHTS OVERRIDES & BACKUPS)
   ========================================================================== */
.code-window pre[class*="language-"],
.code-window code[class*="language-"] {
    background: #121820 !important;
    text-shadow: none !important;
}

.code-window .token.keyword {
    color: #ff79c6 !important;
    font-weight: 600 !important;
}

.code-window .token.class-name,
.code-window .token.type {
    color: #8be9fd !important;
    font-weight: 600 !important;
}

.code-window .token.function,
.code-window .token.method {
    color: #50fa7b !important;
}

.code-window .token.string {
    color: #f1fa8c !important;
}

.code-window .token.comment {
    color: #6272a4 !important;
    font-style: italic !important;
}

.code-window .token.annotation {
    color: #ffb86c !important;
    font-weight: 500 !important;
}

.code-window .token.punctuation {
    color: #f8f8f2 !important;
}

.code-window .token.operator {
    color: #ff79c6 !important;
}

.code-window .token.number {
    color: #bd93f9 !important;
}

.code-window .token.boolean {
    color: #bd93f9 !important;
}

.code-window .token.property,
.code-window .token.attr-name {
    color: #ffb86c !important;
}

.code-window .token.tag {
    color: #ff79c6 !important;
}
"""

with open(styles_path, 'w', encoding='utf-8') as f:
    f.write(new_content + new_rules)

print("Styles file fixed and premium highlights appended successfully!")
