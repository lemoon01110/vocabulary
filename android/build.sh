#!/bin/sh
# Builds dist/Vocabulary.apk without Gradle: aapt2 -> javac -> d8 -> zipalign -> apksigner.
# Needs: JDK 17+, Python 3, and the Android SDK with "platforms;android-34" and "build-tools;34.0.0".
# The SDK is found through ANDROID_HOME (default ~/Android/Sdk).
set -e
A=$(cd "$(dirname "$0")" && pwd); ROOT=$(dirname "$A")
SDK=${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}}
BT=$SDK/build-tools/34.0.0; JAR=$SDK/platforms/android-34/android.jar
[ -f "$JAR" ] && [ -x "$BT/aapt2" ] || { echo "Android SDK pieces missing. Run: sdkmanager \"platforms;android-34\" \"build-tools;34.0.0\"" >&2; exit 1; }

python3 "$ROOT/web/build.py" >/dev/null
B=$A/build; rm -rf "$B"; mkdir -p "$B/flat" "$B/gen" "$B/classes" "$B/dex" "$B/assets"
cp -r "$ROOT/dist/web/." "$B/assets/"
"$BT/aapt2" compile --dir "$A/res" -o "$B/flat/res.zip"
"$BT/aapt2" link -I "$JAR" -A "$B/assets" --manifest "$A/AndroidManifest.xml" -o "$B/base.apk" --java "$B/gen" "$B/flat/res.zip" \
  --min-sdk-version 24 --target-sdk-version 34
javac -source 8 -target 8 -bootclasspath "$JAR" -classpath "$JAR" -nowarn -Xlint:none -d "$B/classes" $(find "$A/src" "$B/gen" -name '*.java') 2>/dev/null
"$BT/d8" --min-api 24 --lib "$JAR" --output "$B/dex" $(find "$B/classes" -name '*.class')
cp "$B/base.apk" "$B/unsigned.apk"
(cd "$B/dex" && zip -q -j "$B/unsigned.apk" classes.dex)
"$BT/zipalign" -f -p 4 "$B/unsigned.apk" "$B/aligned.apk"

# Signing key: kept next to this script, never committed (see .gitignore). Keep it to ship updates.
KS=${VOCABULARY_KEYSTORE:-$A/vocabulary.keystore}; PASS=${VOCABULARY_KEYSTORE_PASS_FILE:-$A/keystore.pass}
if [ ! -f "$KS" ]; then
  echo "No signing key found, creating one at $KS"
  head -c 24 /dev/urandom | base64 | tr -d '/+=' > "$PASS"; chmod 600 "$PASS"
  keytool -genkeypair -keystore "$KS" -alias vocabulary -keyalg RSA -keysize 2048 -validity 10000 \
    -storepass:file "$PASS" -keypass:file "$PASS" -dname "CN=Vocabulary" >/dev/null 2>&1
  chmod 600 "$KS"
fi
mkdir -p "$ROOT/dist"
"$BT/apksigner" sign --ks "$KS" --ks-pass file:"$PASS" --out "$ROOT/dist/Vocabulary.apk" "$B/aligned.apk"
"$BT/apksigner" verify "$ROOT/dist/Vocabulary.apk"
echo "built $ROOT/dist/Vocabulary.apk"
