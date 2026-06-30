import os

styles_path = r"c:\Users\Miguel\Documents\Aplicaciones\_projects\guia-jsp\web\css\styles.css"

with open(styles_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Modify hero-visual max-width and flex
old_hero_visual = """    .hero-visual {
        display: block;
        flex: 1;
        max-width: 550px;
        animation: fadeInRight 0.8s ease-out;
    }"""

new_hero_visual = """    .hero-visual {
        display: block;
        flex: 1.25;
        max-width: 700px;
        animation: fadeInRight 0.8s ease-out;
    }"""

content = content.replace(old_hero_visual, new_hero_visual)

# 2. Modify window-body pre to include word wrapping styles
old_pre = """.window-body pre {
    margin: 0;
}"""

new_pre = """.window-body pre {
    margin: 0;
    white-space: pre-wrap !important;
    word-wrap: break-word !important;
    word-break: break-all;
}"""

content = content.replace(old_pre, new_pre)

# 3. Add global override for prism code elements to ensure no wrapping issues and standardization
override_styles = """
/* Standardized rule to force all code containers to show full width and wrap properly */
.code-window pre,
.code-window pre[class*="language-"],
.code-window code[class*="language-"],
.window-body pre,
.window-body code {
    white-space: pre-wrap !important;
    word-wrap: break-word !important;
    overflow-wrap: break-word !important;
}

/* Ensure code windows have adequate margins and display full content height dynamically */
.code-window {
    width: 100% !important;
    max-width: 100% !important;
    height: auto !important;
}
"""

content += override_styles

with open(styles_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Code container width fixed and wrapped rules standardized successfully!")
