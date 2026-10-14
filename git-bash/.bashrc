export PATH="/usr/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"
export BAT_THEME="Dracula"

# 与 PowerShell / Nushell 共用提示符主题。
if command -v oh-my-posh >/dev/null 2>&1; then
    eval "$(oh-my-posh init bash --config "$HOME/.config/oh-my-posh/dracula-dev.omp.json" --strict)"
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi

if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --bash 2>/dev/null)"
fi

if command -v eza >/dev/null 2>&1; then
    alias ll='eza -lah --icons --group-directories-first --git'
    alias la='eza -a --icons --group-directories-first'
    alias l='eza --icons --group-directories-first'
    alias lt='eza --tree --level=2 --icons'
fi

if command -v bat >/dev/null 2>&1; then
    alias bb='bat --style=plain'
fi
