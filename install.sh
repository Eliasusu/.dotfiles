#!/usr/bin/env bash
# install.sh — instala paquetes y linkea configs con GNU Stow.
#
#   ./install.sh base desktop        # laptop / PC personal
#   ./install.sh base work           # PC del trabajo (necesita ~/.dotfiles-private)
#   ./install.sh sre                 # agrega las herramientas SRE/DevOps
#   ./install.sh mobile              # agrega Android SDK + emulador (React Native)
#   ./install.sh --dry-run base      # muestra qué haría, sin tocar nada
#   ./install.sh --links-only base   # solo symlinks, sin instalar paquetes
#   ./install.sh --check             # qué paquetes instalaste sin versionar / links pisados
#
# Perfiles: base, desktop, sre, mobile (repo público) · work (repo privado)

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRIVATE="${DOTFILES_PRIVATE:-$HOME/.dotfiles-private}"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# Qué paquetes de stow linkea cada perfil
declare -A STOW_PKGS=(
  [base]="zsh starship git ssh ghostty zed lazygit herdr vscode nvim claude mise bat"
  [desktop]=""
  [sre]="sre"
  [mobile]="mobile"
)
ALL_PROFILES=(base desktop sre mobile work)

DRY_RUN=0
LINKS_ONLY=0
CHECK=0
REQUESTED=()

# --- Salida -------------------------------------------------------------------
c_blue=$'\e[34m'; c_green=$'\e[32m'; c_yellow=$'\e[33m'; c_red=$'\e[31m'; c_dim=$'\e[2m'; c_off=$'\e[0m'
step() { printf '\n%s==> %s%s\n' "$c_blue" "$*" "$c_off"; }
ok()   { printf '%s  ✓ %s%s\n' "$c_green" "$*" "$c_off"; }
warn() { printf '%s  ! %s%s\n' "$c_yellow" "$*" "$c_off"; }
die()  { printf '%s✗ %s%s\n' "$c_red" "$*" "$c_off" >&2; exit 1; }

# Ejecuta un comando, o solo lo muestra en --dry-run
run() {
  if (( DRY_RUN )); then
    printf '%s  + %s%s\n' "$c_dim" "$*" "$c_off"
  else
    "$@"
  fi
}

usage() { sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

# Lee una lista de paquetes ignorando comentarios y líneas vacías
read_list() {
  [[ -f "$1" ]] || return 0
  sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e '/^[[:space:]]*$/d' "$1"
}

# --- Argumentos ---------------------------------------------------------------
for arg in "$@"; do
  case "$arg" in
    -n|--dry-run)  DRY_RUN=1 ;;
    --links-only)  LINKS_ONLY=1 ;;
    --check)       CHECK=1 ;;
    -h|--help)     usage 0 ;;
    base|desktop|sre|mobile|work) REQUESTED+=("$arg") ;;
    *) warn "Opción o perfil desconocido: $arg"; usage 1 ;;
  esac
done

# Perfiles en orden canónico (base siempre primero)
PROFILES=()
for p in "${ALL_PROFILES[@]}"; do
  for r in "${REQUESTED[@]}"; do [[ "$p" == "$r" ]] && PROFILES+=("$p") && break; done
done

# --- Symlinks -----------------------------------------------------------------
# Archivo "nuestro" = symlink que apunta al mismo archivo del repo
is_our_link() {
  [[ -L "$1" ]] && [[ "$(readlink -f "$1")" == "$(readlink -f "$2")" ]]
}

# Mueve a BACKUP_DIR cualquier archivo existente que stow no podría pisar
backup_conflicts() {
  local pkg="$1" src rel target
  while IFS= read -r -d '' src; do
    rel="${src#"$DOTFILES/$pkg/"}"
    target="$HOME/$rel"
    if [[ -e "$target" || -L "$target" ]] && ! is_our_link "$target" "$src"; then
      run mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
      run mv "$target" "$BACKUP_DIR/$rel"
      warn "backup: ~/$rel → ${BACKUP_DIR/#$HOME/\~}/$rel"
    fi
  done < <(find "$DOTFILES/$pkg" \( -type f -o -type l \) -print0)
}

link_pkg() {
  local pkg="$1"
  [[ -d "$DOTFILES/$pkg" ]] || die "No existe el paquete de stow: $pkg"
  backup_conflicts "$pkg"
  # --no-folding: linkea archivo por archivo, nunca carpetas enteras.
  # Así herdr, Claude, VS Code, etc. no escriben sus logs/cachés dentro del repo.
  if (( DRY_RUN )); then
    run stow --no-folding --dir "$DOTFILES" --target "$HOME" --restow "$pkg"
  else
    stow --no-folding --dir "$DOTFILES" --target "$HOME" --restow "$pkg"
  fi
  ok "$pkg"
}

# --- Paquetes -----------------------------------------------------------------
SUDO_KEEPALIVE_PID=""
start_sudo() {
  (( DRY_RUN )) && return 0
  [[ -n "$SUDO_KEEPALIVE_PID" ]] && return 0
  step "Pidiendo la contraseña de sudo (una sola vez)"
  sudo -v || die "Sin sudo no puedo instalar paquetes"
  # Mantiene sudo vivo mientras corre el script
  ( while kill -0 "$$" 2>/dev/null; do sudo -n true; sleep 50; done ) 2>/dev/null &
  SUDO_KEEPALIVE_PID=$!
  trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT
}

ensure_yay() {
  command -v yay >/dev/null && return 0
  step "Instalando yay (para paquetes de AUR)"
  if (( DRY_RUN )); then
    run git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    run makepkg -si --noconfirm
    return 0
  fi
  sudo pacman -S --needed --noconfirm base-devel git
  local tmp; tmp="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
  rm -rf "$tmp"
}

install_lists() {
  local profile="$1" dir="$2"
  local -a pac aur
  mapfile -t pac < <(read_list "$dir/packages/$profile.pacman")
  mapfile -t aur < <(read_list "$dir/packages/$profile.aur")
  if (( ${#pac[@]} )); then
    step "[$profile] pacman: ${#pac[@]} paquetes"
    run sudo pacman -S --needed --noconfirm "${pac[@]}"
  fi
  if (( ${#aur[@]} )); then
    ensure_yay
    step "[$profile] AUR: ${aur[*]}"
    run yay -S --needed --noconfirm "${aur[@]}"
  fi
}

# --- Pasos posteriores por perfil -----------------------------------------------
post_base() {
  step "[base] ajustes del sistema"

  # zsh como shell por defecto
  local zsh_path; zsh_path="$(command -v zsh || echo /usr/bin/zsh)"
  if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$zsh_path" ]]; then
    run sudo chsh -s "$zsh_path" "$USER" && ok "shell por defecto: zsh (vale desde el próximo login)"
  fi

  # docker sin sudo
  run sudo systemctl enable --now docker.service
  if ! id -nG "$USER" | grep -qw docker; then
    run sudo usermod -aG docker "$USER"
    warn "Te agregué al grupo docker: cerrá sesión y volvé a entrar para usarlo sin sudo"
  fi

  # Tema de bat/delta
  command -v bat >/dev/null && run bat cache --build && ok "tema de bat"

  # Java, Node, pnpm
  if command -v mise >/dev/null; then
    step "[base] mise: instalando Java/Node/pnpm (puede tardar)"
    run env MISE_YES=1 mise install
  fi

  # Instaladores oficiales (se actualizan solos)
  if ! command -v claude >/dev/null && [[ ! -x "$HOME/.local/bin/claude" ]]; then
    step "[base] Claude Code"
    run bash -c 'curl -fsSL https://claude.ai/install.sh | bash'
  fi
  if ! command -v herdr >/dev/null && [[ ! -x "$HOME/.local/bin/herdr" ]]; then
    step "[base] herdr"
    run sh -c 'curl -fsSL https://herdr.dev/install.sh | sh'
  fi

  # Skills globales de Claude
  local repo skill
  while read -r repo skill; do
    [[ -z "$repo" || -d "$HOME/.claude/skills/$skill" ]] && continue
    run mise exec node -- npx -y skills add "$repo" --skill "$skill" -g -a claude-code -y
  done < <(read_list "$DOTFILES/claude-skills.txt")

  # Extensiones de VS Code
  if command -v code >/dev/null; then
    local installed ext missing=0
    installed="$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')"
    while read -r ext; do
      grep -qx "${ext,,}" <<<"$installed" && continue
      run code --install-extension "$ext" --force
      missing=$((missing + 1))
    done < <(read_list "$DOTFILES/vscode-extensions.txt")
    ok "VS Code: $missing extensiones nuevas"
  fi

  setup_ssh_and_github
}

# Una clave SSH por máquina; gh la sube a GitHub
setup_ssh_and_github() {
  [[ -t 0 ]] || { warn "Sin terminal interactiva: salteo ssh-keygen y gh auth"; return 0; }
  if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
    step "Generando clave SSH para esta máquina"
    run ssh-keygen -t ed25519 -C "$USER@$(hostname)" -f "$HOME/.ssh/id_ed25519"
  fi
  if command -v gh >/dev/null && ! gh auth status >/dev/null 2>&1; then
    step "Login en GitHub (elegí SSH y subí la clave cuando pregunte)"
    run gh auth login --git-protocol ssh --web
  fi
}

post_desktop() {
  step "[desktop] servicios"
  run sudo systemctl enable --now tailscaled.service
}

post_sre() {
  step "[sre] mise: instalando kubectl, terraform, aws-cli… (puede tardar)"
  command -v mise >/dev/null && run env MISE_YES=1 mise install
}

# --- mobile: Android SDK (cmdline-tools, emulator, system image) --------------------
post_mobile() {
  command -v mise >/dev/null || die "[mobile] necesita mise (perfil base)"

  # El SDK usa el Java que mise pone en el PATH
  local sdk="$HOME/Android/sdk"
  local cmdline="$sdk/cmdline-tools/latest/bin"

  step "[mobile] Android cmdline-tools"
  if [[ ! -x "$cmdline/sdkmanager" ]]; then
    local url="https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip"
    local tmp; tmp="$(mktemp -d)"
    run curl -fsSL "$url" -o "$tmp/cmdline-tools.zip"
    run unzip -q "$tmp/cmdline-tools.zip" -d "$tmp"
    run mkdir -p "$sdk/cmdline-tools"
    run mv "$tmp/cmdline-tools" "$sdk/cmdline-tools/latest"
    run rm -rf "$tmp"
    ok "cmdline-tools instalados"
  else
    ok "cmdline-tools ya instalados"
  fi

  step "[mobile] componentes del SDK (platform-tools, emulator, platform, system image)"
  # Licencias: acepta todas sin prompt
  yes 2>/dev/null | run "$cmdline/sdkmanager" --licenses >/dev/null || true
  run "$cmdline/sdkmanager" --install \
    platform-tools \
    emulator \
    "platforms;android-35" \
    "build-tools;35.0.0" \
    "system-images;android-35;google_apis;x86_64"

  step "[mobile] AVD por defecto (Pixel_7_API_35)"
  if ! "$cmdline/avdmanager" list avd -c 2>/dev/null | grep -qx "Pixel_7_API_35"; then
    run "$cmdline/avdmanager" create avd \
      --name "Pixel_7_API_35" \
      --package "system-images;android-35;google_apis;x86_64" \
      --device "pixel_7" --force
    ok "AVD creado"
  else
    ok "AVD ya existe"
  fi

  # Emulador necesita KVM: avisar si no está disponible
  [[ -r /dev/kvm && -w /dev/kvm ]] ||
    warn "Sin permisos en /dev/kvm — el emulador va a ser muy lento (agregate al grupo kvm)"
}

run_work() {
  if [[ -x "$PRIVATE/install.sh" ]]; then
    step "[work] delegando en $PRIVATE/install.sh"
    local -a flags=()
    (( DRY_RUN )) && flags+=(--dry-run)
    (( LINKS_ONLY )) && flags+=(--links-only)
    run "$PRIVATE/install.sh" "${flags[@]}"
  else
    die "El perfil work vive en el repo privado. Clonalo primero:
    git clone git@github.com:Eliasusu/dotfiles-private.git ~/.dotfiles-private"
  fi
}

# --- --check --------------------------------------------------------------------
run_check() {
  command -v pacman >/dev/null || die "--check necesita pacman"
  step "Paquetes instalados a mano que no están en ninguna lista"
  local listed
  listed="$(for f in "$DOTFILES"/packages/* "$PRIVATE"/packages/*; do read_list "$f"; done 2>/dev/null | sort -u)"
  local extra
  extra="$(comm -23 <(pacman -Qqe | sort -u) <(echo "$listed"))"
  if [[ -n "$extra" ]]; then
    echo "$extra" | sed 's/^/    /'
    echo "  ${c_dim}(muchos son del sistema base de CachyOS; agregá a packages/ solo los que elegiste vos)${c_off}"
  else
    ok "todo versionado"
  fi

  step "Configs que dejaron de ser symlink (algún programa las reemplazó)"
  local pkg src rel target broken=0
  for pkg in "${STOW_PKGS[@]}"; do
    for p in $pkg; do
      while IFS= read -r -d '' src; do
        rel="${src#"$DOTFILES/$p/"}"; target="$HOME/$rel"
        if [[ -e "$target" ]] && ! is_our_link "$target" "$src"; then
          warn "~/$rel  (compará con: diff ~/$rel $src)"
          broken=1
        fi
      done < <(find "$DOTFILES/$p" \( -type f -o -type l \) -print0)
    done
  done
  (( broken )) || ok "todos los links en su lugar"
}

# --- Main -----------------------------------------------------------------------
main() {
  if (( CHECK )); then run_check; exit 0; fi
  (( ${#PROFILES[@]} )) || usage 1

  (( DRY_RUN )) && warn "DRY RUN: no se modifica nada, solo se muestran los comandos"

  if (( ! LINKS_ONLY )); then
    command -v pacman >/dev/null || die "Por ahora solo Arch/CachyOS (usá --links-only en otros sistemas)"
    start_sudo
    # stow hace falta antes de linkear
    command -v stow >/dev/null || run sudo pacman -S --needed --noconfirm stow
  fi
  command -v stow >/dev/null || (( DRY_RUN )) || die "Falta GNU stow (sudo pacman -S stow)"

  for profile in "${PROFILES[@]}"; do
    if [[ "$profile" == work ]]; then run_work; continue; fi

    (( LINKS_ONLY )) || install_lists "$profile" "$DOTFILES"

    if [[ -n "${STOW_PKGS[$profile]}" ]]; then
      step "[$profile] symlinks"
      for pkg in ${STOW_PKGS[$profile]}; do link_pkg "$pkg"; done
    fi

    if (( ! LINKS_ONLY )) && declare -F "post_$profile" >/dev/null; then
      "post_$profile"
    fi
  done

  if [[ -d "$BACKUP_DIR" ]]; then
    step "Tus archivos anteriores quedaron en ${BACKUP_DIR/#$HOME/\~}"
  fi
  step "Listo. Abrí una terminal nueva (o corré: exec zsh)"
}

main
