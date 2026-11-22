# Vocabulary

An offline trainer for 2,880 GRE vocabulary words, styled like a printed dictionary. It runs as a desktop app on Linux and as an app on Android. No account, no network, no tracking: your record stays on your device.

## What it does

- **Practice.** A word and four numbered senses; pick the right one. Also *sense to word* and *fill the blank* (the word is removed from an example sentence). Words you keep missing come up more often.
- **Cards.** Index-card flashcards. Turn the card, then mark *knew it* or *didn't know*; missed cards come back a few cards later.
- **Dictionary.** All 2,880 entries, A to Z, searchable by word or by meaning, each with part of speech, definition, example sentence, synonyms and antonyms.
- **Notebook.** Every word you have missed and not yet learned, hardest first, with a button to practice just those.
- **Record.** Lifetime percent correct, answers, daily streak, words seen and known, and the last 14 days.
- **Backup.** Copy your record as text and paste it into the app on another device. Reset asks before it clears anything.

Keyboard: `1` to `6` answer, `Enter` next word, `Space` turns a card, arrow keys mark it.

## Install

### Arch Linux

With the PKGBUILD in `linux/`:

```sh
cd linux && makepkg -si
```

Or from a clone, for your user only (no root):

```sh
make install PREFIX=$HOME/.local
```

System-wide: `sudo make install` (into `/usr/local`). Remove with `make uninstall` and the same `PREFIX`.

It needs the system Electron (`sudo pacman -S electron`) and Python 3 to build. Other distributions work the same way if `electron` is on your `PATH`; set `VOCABULARY_ELECTRON=/path/to/electron` otherwise.

### Android (7.0 and newer)

Download `Vocabulary.apk` from the Releases page and open it on your phone. Android asks you to allow installs from your browser or file manager the first time. The app has no internet permission.

## Build from source

```sh
make web      # dist/web/index.html, the page every platform uses
make apk      # dist/Vocabulary.apk
```

The APK build does not use Gradle. It needs JDK 17+, Python 3 and the Android SDK packages `platforms;android-34` and `build-tools;34.0.0` (`ANDROID_HOME` points at the SDK, default `~/Android/Sdk`). The first build creates a signing key in `android/`; keep it to publish updates that install over earlier versions, and never commit it.

## Layout

```
data/words.json     the word list: [word, part of speech, definition, synonyms, antonyms, example]
web/template.html   the app (HTML, CSS and JS in one file); web/build.py embeds the words
web/fonts/          Newsreader, the typeface (SIL Open Font License, see OFL.txt)
linux/              Electron shell, launcher, .desktop entry, icon, PKGBUILD
android/            WebView shell and the Gradle-free build script
```

To change the word list, edit `data/words.json` and rebuild.

## Credits and license

Code: MIT (see `LICENSE`). Typeface: Newsreader by Production Type, SIL Open Font License 1.1. The word list draws on common GRE study lists; the definitions, synonyms, antonyms and example sentences were written for this project.
