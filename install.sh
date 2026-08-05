#!/bin/bash

# Configurazione percorsi
PLIST_NAME="com.user.waterreminder.plist"
PLIST_PATH="$HOME/Library/LaunchAgents/$PLIST_NAME"
TXT_DEST="$HOME/frasi_acqua.txt"

echo "💧 Installazione Mac Water Reminder..."

# 1. Copia il file delle frasi solo se non esiste già nella Home (per non sovrascrivere personalizzazioni)
if [ ! -f "$TXT_DEST" ]; then
    cp frasi_acqua.txt "$TXT_DEST"
    echo "✅ File frasi creato in $TXT_DEST"
else
    echo "ℹ️ File $TXT_DEST già esistente, salto la sovrascrittura."
fi

# 2. Unload eventuale del plist precedente
launchctl unload "$PLIST_PATH" 2>/dev/null

# 3. Generazione dinamica del file .plist
cat << EOF > "$PLIST_PATH"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.plist">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.waterreminder</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>DAY=\$(date +%u); HOUR=\$(date +%H); if ([ \$DAY -ge 1 ] &amp;&amp; [ \$DAY -le 4 ] &amp;&amp; [ \$HOUR -ge 9 ] &amp;&amp; [ \$HOUR -lt 18 ]) || ([ \$DAY -eq 5 ] &amp;&amp; [ \$HOUR -ge 9 ] &amp;&amp; [ \$HOUR -lt 13 ]); then FILE="\$HOME/frasi_acqua.txt"; if [ -f "\$FILE" ]; then FRASE=\$(grep -v '^$' "\$FILE" | sort -R | head -n 1); osascript -e "say \\"\$FRASE\\""; fi; fi</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>StartInterval</key>
    <integer>900</integer>
</dict>
</plist>
EOF

# 4. Carica il servizio
launchctl load "$PLIST_PATH"

echo "🎉 Installato e avviato con successo! Ogni 15 minuti riceverai un reminder."
