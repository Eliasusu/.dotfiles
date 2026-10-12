# base.zsh — herramientas y aliases que van en todas las máquinas

export EDITOR=nvim
export VISUAL=nvim

# --- mise: versiones de Java, Node, pnpm (reemplaza a nvm y sdkman) ---------------
command -v mise >/dev/null && eval "$(mise activate zsh)"

# --- zoxide: `z proyecto` salta a la carpeta más usada que coincida -----------------
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# --- fzf: Ctrl+R busca en el historial, Ctrl+T busca archivos, Alt+C busca carpetas --
if command -v fzf >/dev/null; then
  source <(fzf --zsh)
  command -v fd >/dev/null && export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  # Tokyo Night
  export FZF_DEFAULT_OPTS="--highlight-line --info=inline-right --ansi --layout=reverse --border=none \
    --color=bg+:#283457,bg:#16161e,border:#27a1b9,fg:#c0caf5,gutter:#16161e,header:#ff9e64 \
    --color=hl+:#2ac3de,hl:#2ac3de,info:#545c7e,marker:#ff007c,pointer:#ff007c,prompt:#2ac3de \
    --color=query:#c0caf5:regular,scrollbar:#27a1b9,separator:#ff9e64,spinner:#ff007c"
fi

# --- bat (cat con colores) ---------------------------------------------------------
export BAT_THEME="tokyonight_night"

# --- Aliases -----------------------------------------------------------------------
if command -v eza >/dev/null; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -l --icons --group-directories-first --git'
  alias la='eza -la --icons --group-directories-first --git'
  alias tree='eza --tree --icons'
fi
command -v bat >/dev/null && alias cat='bat --paging=never'
alias lg='lazygit'
alias dc='docker compose'
alias reload='exec zsh'
alias dotfiles='cd ~/.dotfiles'
