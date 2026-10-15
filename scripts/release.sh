#!/bin/zsh
# Builds, notarizes and publishes a release: ./scripts/release.sh 1.2.0
# Runs locally because the Developer ID certificate is cloud-managed by Xcode.
# One-time setup: xcrun notarytool store-credentials notary ...; Sparkle key in the login keychain (generate_keys).
set -euo pipefail

VERSION=${1:?usage: release.sh <version>}
TEAM=Q738AAV584
SPARKLE_VERSION=2.10.0
REPO=fwilldev/Akkumulator
ROOT=${0:A:h:h}
WORK=$(mktemp -d)
DMG="$WORK/Akkumulator-$VERSION.dmg"
trap 'rm -rf "$WORK"' EXIT

cd "$ROOT"
[[ -z $(git status --porcelain) ]] || { echo "Working tree not clean."; exit 1; }

xcodebuild -project Akkumulator.xcodeproj -scheme Akkumulator -configuration Release \
  -archivePath "$WORK/Akkumulator.xcarchive" -allowProvisioningUpdates \
  MARKETING_VERSION="$VERSION" CURRENT_PROJECT_VERSION="$VERSION" archive

cat > "$WORK/export.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>method</key><string>developer-id</string>
<key>signingStyle</key><string>automatic</string>
<key>teamID</key><string>$TEAM</string>
</dict></plist>
EOF
xcodebuild -exportArchive -archivePath "$WORK/Akkumulator.xcarchive" -exportPath "$WORK/export" \
  -exportOptionsPlist "$WORK/export.plist" -allowProvisioningUpdates

mkdir "$WORK/dmg"
cp -R "$WORK/export/Akkumulator.app" "$WORK/dmg/"
ln -s /Applications "$WORK/dmg/Applications"
hdiutil create -volname Akkumulator -srcfolder "$WORK/dmg" -format UDZO -ov "$DMG"

xcrun notarytool submit "$DMG" --keychain-profile notary --wait
xcrun stapler staple "$DMG"

curl -sL "https://github.com/sparkle-project/Sparkle/releases/download/$SPARKLE_VERSION/Sparkle-$SPARKLE_VERSION.tar.xz" | tar xJ -C "$WORK"
SIGNATURE=$("$WORK/bin/sign_update" "$DMG")

cat > "$WORK/appcast.xml" <<EOF
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <title>Akkumulator</title>
    <item>
      <title>$VERSION</title>
      <pubDate>$(date -R)</pubDate>
      <sparkle:version>$VERSION</sparkle:version>
      <sparkle:shortVersionString>$VERSION</sparkle:shortVersionString>
      <sparkle:minimumSystemVersion>15.0</sparkle:minimumSystemVersion>
      <sparkle:releaseNotesLink>https://github.com/$REPO/releases/tag/v$VERSION</sparkle:releaseNotesLink>
      <enclosure url="https://github.com/$REPO/releases/download/v$VERSION/Akkumulator-$VERSION.dmg" type="application/octet-stream" $SIGNATURE />
    </item>
  </channel>
</rss>
EOF

gh release create "v$VERSION" "$DMG" "$WORK/appcast.xml" -R "$REPO" --target "$(git rev-parse HEAD)" \
  --title "Akkumulator $VERSION" --generate-notes
