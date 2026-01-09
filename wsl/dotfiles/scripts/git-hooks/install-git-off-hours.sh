#!/bin/bash
#
# Off-hours timestamp hook
#
# Automatically masks commit timestamps to appear outside working hours (Mon-Fri 9am-6pm France timezone).
#
# Only affects commits made during working hours; includes opt-out mechanism via SKIP_OFF_HOURS env var.
# ---

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

HOOK_MARKER="# GIT-OFF-HOURS-HOOK"

# The actual hook content
read -r -d '' HOOK_CONTENT << 'HOOK_EOF' || true
#!/bin/bash
# GIT-OFF-HOURS-HOOK
# Auto-generated post-commit hook that moves commits outside working hours
# To skip: SKIP_OFF_HOURS=1 git commit OR git commit --no-verify

# Skip if SKIP_OFF_HOURS is set
if [[ -n "$SKIP_OFF_HOURS" ]]; then
    exit 0
fi

# Prevent infinite loop when we amend
if [[ -n "$GIT_OFF_HOURS_AMENDING" ]]; then
    exit 0
fi

# Configuration
TIMEZONE="Europe/Paris"
WORK_START_HOUR=9
WORK_END_HOUR=18

# Get current time info in France timezone
current_timestamp=$(date +%s)
current_hour=$(TZ=$TIMEZONE date +%-H)
current_day_of_week=$(TZ=$TIMEZONE date +%u)

# Check if current time is during working hours
is_working_hours() {
    # Weekend is not working hours (6 = Saturday, 7 = Sunday)
    if [[ $current_day_of_week -ge 6 ]]; then
        return 1
    fi
    
    # Check if hour is within 9-18
    if [[ $current_hour -ge $WORK_START_HOUR && $current_hour -lt $WORK_END_HOUR ]]; then
        return 0
    fi
    
    return 1
}

# Generate a random off-hours timestamp (returns unix timestamp)
# Avoids 2am-5am and future times
generate_off_hours_timestamp() {
    local date_str=$(TZ=$TIMEZONE date +%Y-%m-%d)
    
    # Available time slots (avoiding 2am-5am):
    # - Late night: 0:00 - 1:59 (2 hours)
    # - Early morning: 5:00 - 8:59 (4 hours)
    # - Evening: 18:00 - 23:59 (6 hours) - only if current hour >= 18
    
    local available_slots=("late_night" "early_morning")
    
    if [[ $current_hour -ge 18 ]]; then
        available_slots+=("evening")
    fi
    
    # Pick a random available slot
    local slot_count=${#available_slots[@]}
    local slot_index=$((RANDOM % slot_count))
    local chosen_slot=${available_slots[$slot_index]}
    
    local hour minute second
    
    case $chosen_slot in
        "late_night")
            hour=$((RANDOM % 2))
            ;;
        "early_morning")
            hour=$((5 + RANDOM % 4))
            ;;
        "evening")
            local max_hour=$current_hour
            if [[ $max_hour -gt 23 ]]; then
                max_hour=23
            fi
            local hour_range=$((max_hour - 18 + 1))
            hour=$((18 + RANDOM % hour_range))
            ;;
    esac
    
    minute=$((RANDOM % 60))
    second=$((RANDOM % 60))
    
    # Construct the new datetime
    local new_datetime=$(printf "%s %02d:%02d:%02d" "$date_str" "$hour" "$minute" "$second")
    
    # Return unix timestamp
    TZ=$TIMEZONE date -d "$new_datetime" "+%s"
}

# Get parent commit's author timestamp (returns 0 if no parent)
get_parent_timestamp() {
    local parent_ts=$(git log -1 --format="%at" HEAD^ 2>/dev/null || echo "0")
    echo "$parent_ts"
}

# Generate off-hours time that preserves commit order
# Ensures new timestamp is after parent commit's timestamp
generate_off_hours_time() {
    local parent_ts=$(get_parent_timestamp)
    local new_ts=$(generate_off_hours_timestamp)
    
    # If new timestamp is before or equal to parent, set it after parent
    if [[ $new_ts -le $parent_ts ]]; then
        # Add random offset between 1-120 seconds after parent
        new_ts=$((parent_ts + 1 + RANDOM % 120))
    fi
    
    # Convert to git date format
    TZ=$TIMEZONE date -d "@$new_ts" "+%Y-%m-%d %H:%M:%S %z"
}

# Only proceed if we're in working hours
if ! is_working_hours; then
    exit 0
fi

# Generate new off-hours date
NEW_DATE=$(generate_off_hours_time)

# Amend the commit with the new date (both author and committer date)
export GIT_OFF_HOURS_AMENDING=1
export GIT_COMMITTER_DATE="$NEW_DATE"
git commit --amend --no-edit --date="$NEW_DATE" --no-verify >/dev/null 2>&1

echo "Commit moved to off-hours: $NEW_DATE"
HOOK_EOF

install_hook() {
    # Check if we're in a git repository
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo -e "${RED}Error: Not a git repository${NC}"
        exit 1
    fi
    
    local git_dir=$(git rev-parse --git-dir)
    local hook_path="$git_dir/hooks/post-commit"
    
    # Check if hook already exists
    if [[ -f "$hook_path" ]]; then
        if grep -q "$HOOK_MARKER" "$hook_path"; then
            echo -e "${YELLOW}Off-hours timestamp hook is already installed${NC}"
        else
            echo -e "${YELLOW}Warning: A post-commit hook already exists${NC}"
        fi
        
        read -p "Do you want to overwrite it? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Installation cancelled${NC}"
            exit 0
        fi
    fi
    
    # Create hooks directory if it doesn't exist
    mkdir -p "$git_dir/hooks"
    
    # Write the hook
    echo "$HOOK_CONTENT" > "$hook_path"
    chmod +x "$hook_path"
    
    echo -e "${GREEN}Hook installed successfully!${NC}"
    echo -e "${BLUE}Commits made during working hours (Mon-Fri 9am-6pm France time) will be automatically moved to off-hours.${NC}"
    echo ""
    echo -e "Opt-out options:"
    echo -e "  ${YELLOW}SKIP_OFF_HOURS=1${NC} git commit -m \"message\"   # Skip for one commit"
    echo -e "  git commit ${YELLOW}--no-verify${NC} -m \"message\"         # Skip using git flag"
}

uninstall_hook() {
    # Check if we're in a git repository
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo -e "${RED}Error: Not a git repository${NC}"
        exit 1
    fi
    
    local git_dir=$(git rev-parse --git-dir)
    local hook_path="$git_dir/hooks/post-commit"
    
    if [[ ! -f "$hook_path" ]]; then
        echo -e "${YELLOW}No post-commit hook found${NC}"
        exit 0
    fi
    
    if ! grep -q "$HOOK_MARKER" "$hook_path"; then
        echo -e "${RED}Error: The existing post-commit hook was not installed by this script${NC}"
        exit 1
    fi
    
    rm "$hook_path"
    echo -e "${GREEN}Hook uninstalled successfully!${NC}"
}

show_usage() {
    echo "Usage: $0 [install|uninstall]"
    echo ""
    echo "Commands:"
    echo "  install     Install the post-commit hook in the current repository"
    echo "  uninstall   Remove the post-commit hook from the current repository"
    echo ""
    echo "Opt-out mechanisms (after installation):"
    echo "  SKIP_OFF_HOURS=1 git commit -m \"message\"   # Environment variable"
    echo "  git commit --no-verify -m \"message\"        # Git flag"
}

# Main
case "${1:-}" in
    install|"")
        install_hook
        ;;
    uninstall)
        uninstall_hook
        ;;
    *)
        show_usage
        exit 1
        ;;
esac
