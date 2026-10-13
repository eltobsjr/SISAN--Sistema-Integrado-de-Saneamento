"""Monta os 8 slides do pitch numa página local (1920×1080 por slide) para virar PDF."""
import pathlib
import re

AQUI = pathlib.Path(__file__).parent
TELAS = AQUI.parent / 'pw' / 'shots'
PITCH = ['cover', 'oficial', 'fluxo', 'telas', 'prioridade', 'mapa', 'tecnologia', 'fim']

# /_blob/<id> → print local
blob = dict((v.split('/')[-1], k) for k, v in re.findall(r"'(\w+)': '(/_blob/\w+)'", (AQUI / 'gerar.py').read_text()))

ICONES = {
    'Users': '<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>',
    'Wrench': '<path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/>',
    'Chart': '<path d="M3 3v18h18"/><path d="M18 17V9"/><path d="M13 17V5"/><path d="M8 17v-3"/>',
    'CheckCircle': '<path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><path d="M22 4 12 14.01l-3-3"/>',
    'Lock': '<rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>',
    'Globe': '<circle cx="12" cy="12" r="10"/><path d="M2 12h20"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/>',
    'Lightning': '<path d="M13 2 3 14h9l-1 8 10-12h-9l1-8z"/>',
}


def icone(m):
    nome, estilo = m.group(1), m.group(2)
    cor = re.search(r'color:([^;]+)', estilo).group(1)
    w = re.search(r'width:(\d+)px', estilo).group(1)
    return (f'<svg width="{w}" height="{w}" viewBox="0 0 24 24" fill="none" stroke="{cor}" stroke-width="2" '
            f'stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0">{ICONES[nome]}</svg>')


def seta(m):
    cor = re.search(r'background:([^;"]+)', m.group(1)).group(1)
    return (f'<svg width="56" height="32" viewBox="0 0 56 32" style="flex-shrink:0">'
            f'<polygon points="0,9.6 33.6,9.6 33.6,0 56,16 33.6,32 33.6,22.4 0,22.4" fill="{cor}"/></svg>')


slides = []
for id_ in PITCH:
    s = (AQUI / 'project' / 'slides' / f'{id_}.html').read_text()
    s = re.sub(r'<aside>.*?</aside>', '', s, flags=re.S)
    s = re.sub(r'<x-icon name="(\w+)" style="([^"]*)"></x-icon>', icone, s)
    s = re.sub(r'<x-shape kind="arrow-right" style="([^"]*)"></x-shape>', seta, s)
    s = re.sub(r'/_blob/(\w+)', lambda m: f'file://{TELAS}/{blob[m.group(1)]}.jpg', s)
    slides.append(s)

html = f'''<!doctype html><html><head><meta charset="utf-8"><title>SISAN — Pitch</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700&family=Bricolage+Grotesque:opsz,wght@12..96,400..800&display=swap">
<style>
@page {{ size: 1920px 1080px; margin: 0 }}
* {{ box-sizing: border-box; margin: 0 }}
body {{ margin: 0 }}
section {{ width: 1920px; height: 1080px; position: relative; overflow: hidden; display: flex; flex-direction: column; break-after: page }}
div {{ display: flex; flex-direction: column }}
h1 {{ font-size: 96px; font-weight: 600; line-height: 1.1 }}
h2 {{ font-size: 64px; font-weight: 600; line-height: 1.15 }}
h3 {{ font-size: 44px; font-weight: 600; line-height: 1.2 }}
p {{ font-size: 32px; line-height: 1.4 }}
ul {{ padding-left: 1.2em }}
img {{ display: block; flex-shrink: 0 }}
</style></head><body>
{''.join(slides)}
</body></html>'''
(AQUI / 'pitch.html').write_text(html)
print('ok', len(slides))
