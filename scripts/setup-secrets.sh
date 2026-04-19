#!/usr/bin/env bash
# =============================================================
# scripts/setup-secrets.sh
# =============================================================
# Liest API-Keys aus ~/.bashrc (oder aktueller Shell-Umgebung)
# und erstellt ONE/Configuration/Secrets.local.xcconfig
# Diese Datei ist durch .gitignore ausgeschlossen.
#
# Verwendung:
#   chmod +x scripts/setup-secrets.sh
#   bash scripts/setup-secrets.sh
# =============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$PROJECT_DIR/ONE/Configuration"
OUTPUT_FILE="$CONFIG_DIR/Secrets.local.xcconfig"

echo "🔑  ONE – Secret-Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Versuche, Keys aus der aktuellen Umgebung zu lesen.
# Falls nicht gesetzt, aus ~/.bashrc extrahieren.
_extract_key() {
    local var_name="$1"
    local value="${!var_name:-}"

    if [ -z "$value" ] && [ -f "$HOME/.bashrc" ]; then
        value=$(grep -E "export ${var_name}=" "$HOME/.bashrc" \
            | tail -1 \
            | sed -E 's/.*=\"?([^\"]*)\"?.*/\1/')
    fi
    echo "$value"
}

GEMINI_KEY=$(_extract_key "GEMINI_API_KEY")
CLAUDE_KEY=$(_extract_key "CLAUDE_API_KEY")
MISTRAL_KEY=$(_extract_key "MISTRAL_API_KEY")
CHATGPT_KEY=$(_extract_key "CHATGPT_API_KEY")

# Validierung
errors=0
_check_key() {
    local name="$1" value="$2"
    if [ -z "$value" ]; then
        echo "  ❌  $name – nicht gefunden"
        errors=$((errors + 1))
    else
        echo "  ✅  $name – ${value:0:10}…"
    fi
}

_check_key "GEMINI_API_KEY"  "$GEMINI_KEY"
_check_key "CLAUDE_API_KEY"  "$CLAUDE_KEY"
_check_key "MISTRAL_API_KEY" "$MISTRAL_KEY"
_check_key "CHATGPT_API_KEY" "$CHATGPT_KEY"

if [ "$errors" -gt 0 ]; then
    echo ""
    echo "❌  $errors Key(s) fehlen. Trage sie in ~/.bashrc ein:"
    echo "   export GEMINI_API_KEY=\"dein-key\""
    echo "   export CLAUDE_API_KEY=\"dein-key\""
    echo "   export MISTRAL_API_KEY=\"dein-key\""
    echo "   export CHATGPT_API_KEY=\"dein-key\""
    exit 1
fi

mkdir -p "$CONFIG_DIR"

cat > "$OUTPUT_FILE" << EOF
// Secrets.local.xcconfig
// AUTOMATISCH GENERIERT – NICHT IN GIT COMMITTEN!
// Erstellt von: scripts/setup-secrets.sh am $(date +"%Y-%m-%d %H:%M")
//
// Zuweisung in Xcode:
//   Projekt-Einstellungen → Configurations → Debug → Secrets.local.xcconfig

GEMINI_API_KEY = ${GEMINI_KEY}
CLAUDE_API_KEY = ${CLAUDE_KEY}
MISTRAL_API_KEY = ${MISTRAL_KEY}
CHATGPT_API_KEY = ${CHATGPT_KEY}
EOF

echo ""
echo "✅  Datei erstellt: $OUTPUT_FILE"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "NÄCHSTE SCHRITTE IN XCODE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Option A (empfohlen) – xcconfig zuweisen:"
echo "  1. ONE.xcodeproj → Projekt-Settings → Info → Configurations"
echo "  2. Debug: 'Secrets.local' aus ONE/Configuration/ wählen"
echo "  3. Xcode fügt die Keys über Info.plist-Build-Settings ein"
echo ""
echo "Option B – Scheme Environment Variables:"
echo "  Product → Scheme → Edit Scheme → Run → Environment Variables"
echo "  GEMINI_API_KEY  = ${GEMINI_KEY:0:12}…"
echo "  CLAUDE_API_KEY  = ${CLAUDE_KEY:0:12}…"
echo "  MISTRAL_API_KEY = ${MISTRAL_KEY:0:12}…"
echo "  CHATGPT_API_KEY = ${CHATGPT_KEY:0:12}…"
echo ""
echo "  → DeveloperKeyInjector.injectIfNeeded() liest diese beim App-Start"
echo "    und schreibt sie einmalig in die Keychain."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
