# Vocabulary: offline GRE vocabulary trainer.
#   make install                     system-wide into /usr/local (use sudo)
#   make install PREFIX=$HOME/.local  just for you, no sudo
#   make uninstall [PREFIX=...]
#   make apk                         Android app (needs the Android SDK, see README)
PREFIX ?= /usr/local
DESTDIR ?=
BINDIR = $(PREFIX)/bin
APPDIR = $(PREFIX)/share/vocabulary
SHARE = $(PREFIX)/share

.PHONY: all web install uninstall apk clean
all: web

web:
	python3 web/build.py

install: web
	install -d "$(DESTDIR)$(APPDIR)/app" "$(DESTDIR)$(BINDIR)" "$(DESTDIR)$(SHARE)/applications" \
	  "$(DESTDIR)$(SHARE)/icons/hicolor/scalable/apps" "$(DESTDIR)$(SHARE)/icons/hicolor/256x256/apps"
	cp -r dist/web/. "$(DESTDIR)$(APPDIR)/app/"
	install -m644 linux/main.js linux/package.json linux/vocabulary.png "$(DESTDIR)$(APPDIR)/"
	sed 's|@APPDIR@|$(APPDIR)|' linux/vocabulary.in > "$(DESTDIR)$(BINDIR)/vocabulary"
	chmod 755 "$(DESTDIR)$(BINDIR)/vocabulary"
	sed 's|@BINDIR@|$(BINDIR)|' linux/vocabulary.desktop.in > "$(DESTDIR)$(SHARE)/applications/vocabulary.desktop"
	install -m644 linux/vocabulary.svg "$(DESTDIR)$(SHARE)/icons/hicolor/scalable/apps/vocabulary.svg"
	install -m644 linux/vocabulary.png "$(DESTDIR)$(SHARE)/icons/hicolor/256x256/apps/vocabulary.png"
	-[ -z "$(DESTDIR)" ] && update-desktop-database "$(SHARE)/applications" 2>/dev/null; true
	-[ -z "$(DESTDIR)" ] && gtk-update-icon-cache -q -t "$(SHARE)/icons/hicolor" 2>/dev/null; true

uninstall:
	rm -rf "$(DESTDIR)$(APPDIR)"
	rm -f "$(DESTDIR)$(BINDIR)/vocabulary" "$(DESTDIR)$(SHARE)/applications/vocabulary.desktop" \
	  "$(DESTDIR)$(SHARE)/icons/hicolor/scalable/apps/vocabulary.svg" "$(DESTDIR)$(SHARE)/icons/hicolor/256x256/apps/vocabulary.png"

apk: web
	sh android/build.sh

clean:
	rm -rf dist android/build
