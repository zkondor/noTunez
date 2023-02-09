#!/bin/sh

PAYLOAD='
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>uploadSymbols</key>
    <false/>
    <key>uploadBitcode</key>
    <false/>
    <key>method</key>
    <string>developer-id</string>
    <key>compileBitcode</key>
    <false/>
    <key>teamID</key>
    <string>%TEAM_ID%</string>
  </dict>
</plist>
'

TEAM_ID=$(security find-identity -v -p codesigning | awk '/Developer ID Application/{match($0, /\(([A-Z0-9]+)\)/, a); print a[1]}' | head -n1)

echo "${PAYLOAD}" | sed -e "s:%TEAM_ID%:${TEAM_ID}:g" | tee $1
