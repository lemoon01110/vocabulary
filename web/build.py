#!/usr/bin/env python3
"""Build the app page: dist/web/index.html (the whole word list embedded) plus the bundled font.

Used by every platform build (Linux, Android). No network access needed.
"""
import json, os, shutil

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "dist", "web")

def row(e):
    """data/words.json entry -> the compact array the page uses (see the comment at WORDS in template.html)."""
    senses = [[s["pos"], s["def"], s["ex"]] for s in e["senses"]]
    pos = " / ".join(dict.fromkeys(s[0] for s in senses))
    return [e["word"], pos, senses[0][1], e.get("syn", ""), e.get("ant", ""), senses[0][2],
            e.get("say", ""), e.get("ipa", ""), e.get("origin", ""), 1 if e.get("rare") else 0, senses]

def build(out=OUT):
    tpl = open(os.path.join(ROOT, "web", "template.html"), encoding="utf-8").read()
    words = [row(e) for e in json.load(open(os.path.join(ROOT, "data", "words.json"), encoding="utf-8"))]
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
