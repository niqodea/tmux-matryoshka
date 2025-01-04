#!/usr/bin/env sh

set -eu

# >>> Configuration options and default values
down_keybind="$(tmux show-option -gqv @matryoshka_down_keybind)"
if [ -z "$down_keybind" ]; then down_keybind='F1'; fi

up_keybind="$(tmux show-option -gqv @matryoshka_up_keybind)"
if [ -z "$up_keybind" ]; then up_keybind='F2'; fi

up_recursive_keybind="$(tmux show-option -gqv @matryoshka_up_recursive_keybind)"
if [ -z "$up_recursive_keybind" ]; then up_recursive_keybind='F3'; fi

inactive_status_style_strategy="$(tmux show-option -gqv @matryoshka_inactive_status_style_strategy)"
if [ -z "$inactive_status_style_strategy" ]; then inactive_status_style_strategy='assignment'; fi

inactive_status_style="$(tmux show-option -gqv @matryoshka_inactive_status_style)"
if [ -z "$inactive_status_style" ]; then inactive_status_style='bg=colour238,fg=colour245'; fi

status_style_option="$(tmux show-option -gqv @matryoshka_status_style_option)"
if [ -z "$status_style_option" ]; then status_style_option='status-style'; fi
# <<< Configuration options and default values

MATRYOSHKA_COUNTER_ENV_NAME='MATRYOSHKA_COUNTER'
MATRYOSHKA_INACTIVE_TABLE_NAME='matryoshka-inactive'

# Down: disable the outer-most active tmux
if [ "$inactive_status_style_strategy" = 'assignment' ]; then
    status_style_update="set-option \"$status_style_option\" \"$inactive_status_style\""
elif [ "$inactive_status_style_strategy" = 'sed' ]; then
    status_style_update="run-shell 'tmux set-option \"$status_style_option\" \"\$(tmux show-option -gqv \"$status_style_option\" | sed \"$inactive_status_style\")\"'"
else
    >&2 echo "Error: unknown inactive status style strategy '$inactive_status_style_strategy'"
    exit 1
fi
tmux bind -n "$down_keybind" \
"set-environment \"$MATRYOSHKA_COUNTER_ENV_NAME\" 1 ; "\
"set key-table \"$MATRYOSHKA_INACTIVE_TABLE_NAME\" ; "\
'set prefix None ; '\
'set prefix2 None ; '\
"$status_style_update"
tmux bind -T "$MATRYOSHKA_INACTIVE_TABLE_NAME" "$down_keybind" \
"run-shell 'tmux set-environment \"$MATRYOSHKA_COUNTER_ENV_NAME\" \$(( \$(tmux show-environment \"$MATRYOSHKA_COUNTER_ENV_NAME\" | cut -d = -f 2) + 1 ))' ; "\
"send-keys \"$down_keybind\""

# Up: enable the inner-most inactive tmux
tmux bind -n "$up_keybind" \
'display-message "Error: no inactive tmux to enable"'
tmux bind -T "$MATRYOSHKA_INACTIVE_TABLE_NAME" "$up_keybind" \
"run-shell 'tmux set-environment \"$MATRYOSHKA_COUNTER_ENV_NAME\" \$(( \$(tmux show-environment \"$MATRYOSHKA_COUNTER_ENV_NAME\" | cut -d = -f 2) - 1 ))' ; "\
"if-shell '[ \"\$(tmux show-environment \"$MATRYOSHKA_COUNTER_ENV_NAME\" | cut -d = -f 2)\" -eq 0 ]' "\
"'set-environment -u \"$MATRYOSHKA_COUNTER_ENV_NAME\" ; set -u prefix ; set -u prefix2 ; set -u key-table ; set -u \"$status_style_option\"' "\
"'send-keys \"$up_keybind\"'"

# Up recursive: enable all tmux instances recursively
# Useful to go back to top-level tmux or reset broken counters
tmux bind -n "$up_recursive_keybind" \
'send-keys ""'  # No op
tmux bind -T "$MATRYOSHKA_INACTIVE_TABLE_NAME" "$up_recursive_keybind" \
"send-keys \"$up_recursive_keybind\" ; "\
"set-environment -u \"$MATRYOSHKA_COUNTER_ENV_NAME\" ; "\
'set -u key-table ; '\
'set -u prefix ; '\
'set -u prefix2 ; '\
"set -u \"$status_style_option\""

# Note: `$(tmux show-environment MATRYOSHKA_COUNTER | cut -d = -f 2)` is the simplest way to retrieve the
# value of MATRYOSHKA_COUNTER, for some reason
