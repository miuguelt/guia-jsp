import os
import re
import sys
import json

ROOT = os.path.dirname(os.path.abspath(__file__))
SRC_DIR = os.path.join(ROOT, 'src')
DEFAULT_PAGE = 'index'


def resolve_include_path(template_dir, filepath):
    """Resolve an include path relative to the template directory."""
    path = os.path.normpath(os.path.join(template_dir, filepath))
    if not os.path.exists(path):
        # Try from SRC_DIR as fallback
        fallback = os.path.normpath(os.path.join(SRC_DIR, filepath))
        if os.path.exists(fallback):
            return fallback
        # Try from shared/
        shared = os.path.normpath(os.path.join(SRC_DIR, 'shared', filepath))
        if os.path.exists(shared):
            return shared
    return path


def build_page(page_name):
    """Build a single page from its template."""
    page_dir = os.path.join(SRC_DIR, 'pages', page_name)
    template_path = os.path.join(page_dir, 'template.src.html')

    if not os.path.exists(template_path):
        print(f'ERROR: Template not found for page "{page_name}"')
        print(f'  Expected: {template_path}')
        return False

    with open(template_path, 'r', encoding='utf-8') as f:
        template = f.read()

    template_dir = os.path.dirname(template_path)

    def include_replacer(m):
        filepath = m.group(1).strip()
        fullpath = resolve_include_path(template_dir, filepath)
        if not os.path.exists(fullpath):
            print(f'  [WARN] Include not found: {filepath}')
            print(f'    Searched: {fullpath}')
            return f'<!-- MISSING: {filepath} -->'
        with open(fullpath, 'r', encoding='utf-8') as f:
            content = f.read()
        print(f'  Include: {os.path.relpath(fullpath, SRC_DIR)} ({len(content)} chars)')
        return content

    result = re.sub(r'<!--#include\s+file="([^"]+)"\s*-->', include_replacer, template)

    # Variable substitution from page.json
    config_path = os.path.join(page_dir, 'page.json')
    if os.path.exists(config_path):
        with open(config_path, 'r', encoding='utf-8') as f:
            config = json.load(f)
        for key, value in config.items():
            placeholder = '{{' + key.upper() + '}}'
            result = result.replace(placeholder, str(value))

    # Determine output filename
    if page_name == 'index':
        output_name = 'index.html'
    else:
        output_name = f'{page_name}.html'

    output_path = os.path.join(ROOT, output_name)

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(result)

    print(f'\n  -> {output_name} ({len(result)} chars, {result.count(chr(10)) + 1} lines)')
    return True


def build_all():
    """Build all pages found in src/pages/."""
    pages_dir = os.path.join(SRC_DIR, 'pages')
    if not os.path.exists(pages_dir):
        print('ERROR: src/pages/ directory not found')
        return

    pages = sorted(os.listdir(pages_dir))
    if not pages:
        print('No pages found')
        return

    for page in pages:
        page_dir = os.path.join(pages_dir, page)
        if not os.path.isdir(page_dir):
            continue
        template = os.path.join(page_dir, 'template.src.html')
        if not os.path.exists(template):
            continue

        print(f'\n=== Building page: {page} ===')
        build_page(page)


if __name__ == '__main__':
    # Usage: python build.py [page_name]
    #   python build.py           -> builds all pages
    #   python build.py index     -> builds only index page
    #   python build.py flutter-guide -> builds only flutter-guide

    page_args = [a for a in sys.argv[1:] if not a.startswith('--')]

    if page_args:
        for page in page_args:
            print(f'\n=== Building page: {page} ===')
            build_page(page)
    else:
        build_all()
