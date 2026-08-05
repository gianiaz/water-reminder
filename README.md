# 💧 Mac Water Reminder

Un'automazione nativa e ultraleggera per **macOS** che sostituisce le classiche app di idratazione con un reminder audio personalizzato. Ogni 15 minuti, il sistema sceglie una frase casuale da un file di testo e la pronuncia ad alta voce utilizzando la voce di sistema di macOS (`osascript`).

Zero app aperte in background, zero consumo inutile di RAM.

---

## 🛠️ Come funziona

1. **`frasi_acqua.txt`**: Un file di testo (modificabile a piacimento) contenente una lista di frasi, una per riga.
2. **LaunchAgent (`com.user.waterreminder.plist`)**: Un servizio gestito direttamente da `launchd` che si attiva ogni 15 minuti.
3. **Filtro Orari**: Il reminder gira esclusivamente nei giorni e orari lavorativi:
   - **Lunedì – Giovedì**: 09:00 – 18:00
   - **Venerdì**: 09:00 – 13:00
   - **Sabato e Domenica**: Disattivato

---

## 🚀 Installazione Rapida

Clona il repository ed esegui lo script di installazione:

```bash
git clone [https://github.com/](https://github.com/gianiaz/water-reminder.git
cd mac-water-reminder
chmod +x install.sh && ./install.sh
