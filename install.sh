#!/bin/bash

# ==============================================================================
# CONFIGURAZIONE ORARI PER GIORNO DELLA SETTIMANA (24h)
# 1 = Lunedì, 2 = Martedì, 3 = Mercoledì, 4 = Giovedì, 5 = Venerdì, 6 = Sabato, 7 = Domenica
# Per disattivare un giorno, imposta INIZIO e FINE a 0.
# ==============================================================================
INIZIO_1=9;  FINE_1=18   # Lunedì
INIZIO_2=9;  FINE_2=18   # Martedì
INIZIO_3=9;  FINE_3=18   # Mercoledì
INIZIO_4=9;  FINE_4=18   # Giovedì
INIZIO_5=9;  FINE_5=13   # Venerdì
INIZIO_6=0;  FINE_6=0    # Sabato (Disattivato)
INIZIO_7=0;  FINE_7=0    # Domenica (Disattivato)
# ==============================================================================

PLIST_NAME="com.user.waterreminder.plist"
PLIST_PATH="$HOME/Library/LaunchAgents/$PLIST_NAME"
TXT_DEST="$HOME/frasi_acqua.txt"

echo "💧 Installazione Mac Water Reminder..."

# 1. Copia il file delle frasi se non esiste
if [ ! -f "$TXT_DEST" ]; then
    cp frasi_acqua.txt "$TXT_DEST"
    echo "✅ File frasi creato in $TXT_DEST"
else
    echo "ℹ️ File $TXT_DEST già esistente, salto la sovrascrittura."
fi

# 2. Costruzione dinamica della condizione di orario (compatibile Bash 3.2)
CONDITIONS=()
for DAY in {1..7}; do
    eval "START=\$INIZIO_$DAY"
    eval "END=\$FINE_$DAY"
    if [ "$START" -ne 0 ] || [ "$END" -ne 0 ]; then
        CONDITIONS+=("([ \$DAY -eq $DAY ] &amp;&amp; [ \$HOUR -ge $START ] &amp;&amp; [ \$HOUR -lt $END ])")
    fi
done

# Unisce le condizioni con ||
TIME_CHECK=$(printf " || %s" "${CONDITIONS[@]}")
TIME_CHECK=${TIME_CHECK:4} # Rimuove il primo ' || '

# 3. Unload del plist precedente
launchctl unload "$PLIST_PATH" 2>/dev/null

# 4. Generazione della linea di comando con Logging e fix ottale (10#$HOUR)
EXEC_CMD="LOG=\"\$HOME/water_reminder.log\"; TIMESTAMP=\$(date '+%Y-%m-%d %H:%M:%S'); DAY=\$(date +%u); HOUR=\$((10#\$(date +%H))); if $TIME_CHECK; then FILE=\"\$HOME/frasi_acqua.txt\"; if [ -f \"\$FILE\" ]; then FRASE=\$(grep -v '^$' \"\$FILE\" | sort -R | head -n 1); echo \"[\$TIMESTAMP] OK: Pronuncio frase -> \$FRASE\" >> \"\$LOG\"; osascript -e \"say \\\"\$FRASE [[slnc 1000]]\\\"\"; else echo \"[\$TIMESTAMP] ERRORE: File frasi non trovato in \$FILE\" >> \"\$LOG\"; fi; else echo \"[\$TIMESTAMP] SKIP: Fuori orario lavorativo (Giorno: \$DAY, Ora: \$HOUR)\" >> \"\$LOG\"; fi"

# 5. Generazione del file .plist
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
        <string>$EXEC_CMD</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>StartInterval</key>
    <integer>900</integer>
</dict>
</plist>
EOF

# 6. Carica il servizio
launchctl load "$PLIST_PATH"

echo "🎉 Installato! Verifica l'esito subito con:"
echo "cat ~/water_reminder.log"
