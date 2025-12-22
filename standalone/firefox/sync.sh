#!/bin/bash
# Syncs Firefox fx-autoconfig files to profile and installation directories

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Auto-detect Windows username
WIN_USER=$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r')
if [ -z "$WIN_USER" ]; then
    echo "Error: Could not detect Windows username"
    exit 1
fi

# Paths
PROFILE_PATH="/mnt/c/Users/$WIN_USER/.config/firefox-profiles"
FIREFOX_PATH="/mnt/c/Program Files/Mozilla Firefox"

# Check for alternate Firefox locations if default doesn't exist
if [ ! -d "$FIREFOX_PATH" ]; then
    ALT_PATHS=(
        "/mnt/c/Program Files (x86)/Mozilla Firefox"
        "/mnt/c/Users/$WIN_USER/scoop/apps/firefox/current"
        "/mnt/c/Users/$WIN_USER/AppData/Local/Mozilla Firefox"
    )
    for alt in "${ALT_PATHS[@]}"; do
        if [ -d "$alt" ]; then
            FIREFOX_PATH="$alt"
            break
        fi
    done
fi

echo "Firefox fx-autoconfig Sync"
echo "=========================="
echo ""
echo "Source:  $SCRIPT_DIR"
echo "Profile: $PROFILE_PATH"
echo "Firefox: $FIREFOX_PATH"
echo ""

# Validate profile path
if [ ! -d "$PROFILE_PATH" ]; then
    echo "Error: Profile path not found: $PROFILE_PATH"
    exit 1
fi

# Find profile directories
PROFILES=()
if [ -d "$PROFILE_PATH/chrome" ] || [ -f "$PROFILE_PATH/prefs.js" ]; then
    # Single profile
    PROFILES+=("$PROFILE_PATH")
else
    # Multiple profiles - find directories with prefs.js or chrome folder
    while IFS= read -r -d '' dir; do
        if [ -f "$dir/prefs.js" ] || [ -d "$dir/chrome" ]; then
            PROFILES+=("$dir")
        fi
    done < <(find "$PROFILE_PATH" -maxdepth 1 -mindepth 1 -type d -print0)
    
    # If no profiles found, use the path directly
    if [ ${#PROFILES[@]} -eq 0 ]; then
        PROFILES+=("$PROFILE_PATH")
    fi
fi

echo "Found ${#PROFILES[@]} profile(s)"
echo ""

# === SYNC TO PROFILE(S) ===
echo "=== Syncing Profile Files ==="

for profile in "${PROFILES[@]}"; do
    profile_name=$(basename "$profile")
    echo ""
    echo "Profile: $profile_name"
    
    chrome_dir="$profile/chrome"
    mkdir -p "$chrome_dir"
    
    # Copy utils folder
    if [ -d "$SCRIPT_DIR/utils" ]; then
        mkdir -p "$chrome_dir/utils"
        cp -r "$SCRIPT_DIR/utils/"* "$chrome_dir/utils/"
        echo "  - utils/ (loader modules)"
    fi
    
    # Copy JS folder
    if [ -d "$SCRIPT_DIR/JS" ]; then
        mkdir -p "$chrome_dir/JS"
        cp -r "$SCRIPT_DIR/JS/"* "$chrome_dir/JS/"
        echo "  - JS/ (user scripts)"
    fi
    
    # Copy resources folder (create empty if doesn't exist)
    mkdir -p "$chrome_dir/resources"
    if [ -d "$SCRIPT_DIR/resources" ] && [ "$(ls -A "$SCRIPT_DIR/resources" 2>/dev/null)" ]; then
        cp -r "$SCRIPT_DIR/resources/"* "$chrome_dir/resources/"
    fi
    echo "  - resources/"
    
    # Copy CSS folder if exists
    if [ -d "$SCRIPT_DIR/CSS" ]; then
        mkdir -p "$chrome_dir/CSS"
        cp -r "$SCRIPT_DIR/CSS/"* "$chrome_dir/CSS/"
        echo "  - CSS/ (user styles)"
    fi
    
    # Copy userChrome.css if exists
    if [ -f "$SCRIPT_DIR/userChrome.css" ]; then
        cp "$SCRIPT_DIR/userChrome.css" "$chrome_dir/userChrome.css"
        echo "  - userChrome.css"
    fi
    
    # Copy userContent.css if exists
    if [ -f "$SCRIPT_DIR/userContent.css" ]; then
        cp "$SCRIPT_DIR/userContent.css" "$chrome_dir/userContent.css"
        echo "  - userContent.css"
    fi
done

# === SYNC TO FIREFOX INSTALLATION ===
# These files MUST be in Firefox's installation directory for autoconfig to work
echo ""
echo "=== Syncing Firefox Installation Files ==="
echo "(Requires admin permissions for Program Files)"

if [ -d "$FIREFOX_PATH" ]; then
    # Check if files already exist and match
    CONFIG_EXISTS=false
    PREFS_EXISTS=false
    
    if [ -f "$FIREFOX_PATH/config.js" ]; then
        if cmp -s "$SCRIPT_DIR/program/config.js" "$FIREFOX_PATH/config.js"; then
            CONFIG_EXISTS=true
            echo "  - config.js (already up to date)"
        fi
    fi
    
    if [ -f "$FIREFOX_PATH/defaults/pref/config-prefs.js" ]; then
        if cmp -s "$SCRIPT_DIR/program/defaults/pref/config-prefs.js" "$FIREFOX_PATH/defaults/pref/config-prefs.js"; then
            PREFS_EXISTS=true
            echo "  - config-prefs.js (already up to date)"
        fi
    fi
    
    # Only try to copy if files need updating
    if [ "$CONFIG_EXISTS" = false ] || [ "$PREFS_EXISTS" = false ]; then
        # Try copying (may fail without admin)
        if [ "$CONFIG_EXISTS" = false ]; then
            if cp "$SCRIPT_DIR/program/config.js" "$FIREFOX_PATH/config.js" 2>/dev/null; then
                echo "  - config.js -> $FIREFOX_PATH/"
            else
                echo "  ! config.js (permission denied)"
            fi
        fi
        
        if [ "$PREFS_EXISTS" = false ]; then
            mkdir -p "$FIREFOX_PATH/defaults/pref" 2>/dev/null
            if cp "$SCRIPT_DIR/program/defaults/pref/config-prefs.js" "$FIREFOX_PATH/defaults/pref/config-prefs.js" 2>/dev/null; then
                echo "  - defaults/pref/config-prefs.js"
            else
                echo "  ! config-prefs.js (permission denied)"
            fi
        fi
        
        # Check if we need to show manual instructions
        if [ ! -f "$FIREFOX_PATH/config.js" ] || [ ! -f "$FIREFOX_PATH/defaults/pref/config-prefs.js" ]; then
            echo ""
            echo "Note: Program files need admin permissions. Run manually in PowerShell (Admin):"
            echo ""
            echo "  Copy-Item '$SCRIPT_DIR/program/config.js' '$FIREFOX_PATH/config.js'"
            echo "  Copy-Item '$SCRIPT_DIR/program/defaults/pref/config-prefs.js' '$FIREFOX_PATH/defaults/pref/config-prefs.js'"
        fi
    fi
else
    echo "Warning: Firefox installation not found at $FIREFOX_PATH"
    echo "Locate your Firefox installation and copy manually:"
    echo "  - program/config.js -> <Firefox>/config.js"
    echo "  - program/defaults/pref/config-prefs.js -> <Firefox>/defaults/pref/"
fi

echo ""
echo "Done!"
echo ""
echo "Next steps:"
echo "1. Open Firefox"
echo "2. Go to about:support"
echo "3. Click 'Clear startup cache...' and restart"
echo "4. Verify in Browser Console (Ctrl+Shift+J):"
echo "   'Browser is executing custom scripts via autoconfig'"
