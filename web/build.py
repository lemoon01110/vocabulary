#!/usr/bin/env python3
"""Build the app page: dist/web/index.html (all 2,880 words embedded) plus the bundled font.

Used by every platform build (Linux, Android). No network access needed.
"""
import json, os, shutil

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "dist", "web")

def build(out=OUT):
    tpl = open(os.path.join(ROOT, "web", "template.html"), encoding="utf-8").read()
    words = json.load(open(os.path.join(ROOT, "data", "words.json"), encoding="utf-8"))
    data = json.dumps(words, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\/")
    split = tpl.index('<div class="page">')
    head, body = tpl[:split], tpl[split:].replace("__DATA__", data, 1)
    page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n'
            '<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">\n'
            '<meta http-equiv="Content-Security-Policy" content="default-src \'self\'; script-src \'unsafe-inline\'; style-src \'self\' \'unsafe-inline\'; font-src \'self\'; img-src \'self\' data:">\n'
            '<style>:root{padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}body{margin:0}img{max-width:100%}</style>\n'
            + head + '</head>\n<body>\n' + body + '\n</body>\n</html>\n')
    if os.path.isdir(out): shutil.rmtree(out)
    shutil.copytree(os.path.join(ROOT, "web", "fonts"), os.path.join(out, "fonts"))
    with open(os.path.join(out, "index.html"), "w", encoding="utf-8") as f: f.write(page)
    return out

if __name__ == "__main__":
    print("built", os.path.join(build(), "index.html"))
