# ~/.zshrc — gestionado por el repo dotfiles (no editar el symlink a ciegas: edita el repo)
#
# Orden de carga:
#   1. opciones de zsh (historial, completado, teclas)
#   2. módulos de ~/.config/zsh/*.zsh  (base.zsh siempre; sre.zsh / work.zsh según perfil)
#   3. ~/.zshrc.local                   (cosas de esta máquina, sin versionar)
#   4. plugins + prompt                 (syntax-highlighting siempre al final)

export PATH="$HOME/.local/bin:$PATH"

# --- Historial ----------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # historial compartido entre terminales abiertas
setopt HIST_IGNORE_ALL_DUPS   # sin duplicados
setopt HIST_IGNORE_SPACE      # un comando que empieza con espacio no se guarda (útil para secretos)
setopt HIST_REDUCE_BLANKS

# --- Comportamiento general -----------------------------------------------------
setopt AUTO_CD                # escribir el nombre de una carpeta = cd a esa carpeta
setopt INTERACTIVE_COMMENTS   # permite # comentarios en la terminal

# --- Completado -----------------------------------------------------------------
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select                          # menú navegable con flechas
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'      # sin distinguir mayúsculas
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# --- Teclas (modo emacs, Ctrl+flechas por palabra, Supr) --------------------------
bindkey -e
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[3~'   delete-char
bindkey '^[[H'    beginning-of-line
bindkey '^[[F'    end-of-line

# --- Módulos por perfil ---------------------------------------------------------
for module in "$HOME"/.config/zsh/*.zsh(N); do
  source "$module"
done
unset module

# --- Overrides de esta máquina ----------------------------------------------------
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# --- Plugins (instalados con pacman) --------------------------------------------
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Prompt
command -v starship >/dev/null && eval "$(starship init zsh)"

# syntax-highlighting tiene que ser lo último que se carga
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
