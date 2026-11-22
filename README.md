# Vocabulary

A study app for 2,880 GRE vocabulary words, for Linux and Android. It works without an internet connection, and progress is saved on the device.

## Features

- **Practice**: multiple-choice questions. A question shows a word and asks for its meaning, shows a meaning and asks for the word, or asks which word completes a sentence. Words answered incorrectly come up more often.
- **Cards**: flashcards. Each card is marked as known or not known, and cards not known are shown again later in the same deck.
- **Dictionary**: all entries in alphabetical order, searchable by word or by definition. Each entry has a part of speech, a definition, an example sentence, synonyms and antonyms.
- **Notebook**: words answered incorrectly that have not yet been learned, with an option to practice only those.
- **Record**: overall accuracy, number of answers, daily streak, and results for the last 14 days.
- **Backup**: the record can be copied as text and restored on another device.

Keyboard shortcuts: `1` to `6` to answer, `Enter` for the next word, `Space` to turn a card, and the arrow keys to mark it.

## Installation

### Arch Linux

Using the PKGBUILD in `linux/`:

```sh
cd linux && makepkg -si
```

Or from a clone, for the current user only:

```sh
make install PREFIX=$HOME/.local
```

To install system-wide, run `sudo make install` (installs into `/usr/local`). `make uninstall` with the same `PREFIX` removes it.

The app runs on the system Electron (`sudo pacman -S electron`). Building requires Python 3. Other distributions work if `electron` is on the `PATH`, or if `VOCABULARY_ELECTRON` points to an Electron binary.

### Android

Requires Android 7.0 or later. Download `Vocabulary.apk` from the [Releases](https://github.com/lemoon01110/vocabulary/releases) page and open it on the device. Android may ask for permission to install apps from that source.

## Building from source

```sh
make web    # builds dist/web/index.html, used by both platforms
make apk    # builds dist/Vocabulary.apk
```

The Android build uses the SDK tools directly rather than Gradle. It requires JDK 17 or later, Python 3, and the Android SDK packages `platforms;android-34` and `build-tools;34.0.0`. Set `ANDROID_HOME` if the SDK is not in `~/Android/Sdk`. The first build creates a signing key in `android/`. Keep this key to release updates that install over earlier versions, and do not commit it.

## Project layout

```
data/words.json     word list: [word, part of speech, definition, synonyms, antonyms, example]
web/template.html   the app (HTML, CSS and JavaScript)
web/build.py        embeds the word list and writes dist/web/
web/fonts/          Newsreader typeface
linux/              Electron shell, launcher, desktop entry, icon, PKGBUILD
android/            WebView shell and build script
```

The word list can be changed by editing `data/words.json` and rebuilding.

## License

The code is released under the MIT License (see `LICENSE`). The Newsreader typeface by Production Type is released under the SIL Open Font License 1.1 (see `web/fonts/OFL.txt`). The word list is based on common GRE study lists. The definitions, synonyms, antonyms and example sentences were written for this project.
