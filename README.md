# dotfiles

Mi entorno de desarrollo en Arch/CachyOS: un solo comando deja una máquina nueva igual que las otras.

- **Configs**: linkeadas con [GNU Stow](https://www.gnu.org/software/stow/) — editar `~/.zshrc` es editar este repo.
- **Paquetes**: listas en `packages/`, instaladas con `pacman` / `yay`.
- **Versiones de lenguajes**: [mise](https://mise.jdx.dev) (Java, Node, pnpm, herramientas SRE).
- **Tema**: Tokyo Night en todo (Ghostty, Zed, VS Code, lazygit, bat, delta, fzf, starship).

## Máquina nueva

```bash
sudo pacman -S --needed git stow
git clone https://github.com/Eliasusu/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh --dry-run base desktop   # mirá qué va a hacer
./install.sh base desktop
```

El script pide `sudo` una vez. Al final genera una clave SSH para la máquina y corre `gh auth login`
(elegí SSH y subí la clave). Nunca lo corras con `sudo ./install.sh`.

PC del trabajo: después de lo anterior,

```bash
git clone git@github.com:Eliasusu/dotfiles-private.git ~/.dotfiles-private
./install.sh work
```

## Perfiles

| Perfil    | Qué trae |
|-----------|----------|
| `base`    | zsh + starship, git + gh + delta + lazygit, mise (Java 25, Node LTS, pnpm), fzf, zoxide, ripgrep, fd, bat, eza, btop, neovim + LazyVim, Ghostty, Zed, VS Code, Docker, Claude Code, herdr |
| `desktop` | Spotify, Obsidian, OnlyOffice, RustDesk, Tailscale, waypipe |
| `sre`     | kubectl, k9s, helm, kubectx, kind, terraform, aws-cli, trivy, sops, age (mise) + ansible |
| `work`    | vive en el repo privado |

## Opciones

```bash
./install.sh --dry-run <perfiles>     # solo muestra los comandos
./install.sh --links-only <perfiles>  # solo symlinks, sin instalar nada
./install.sh --check                  # paquetes instalados sin versionar + configs pisadas
```

Si un archivo ya existe (ej. tu `.zshrc` viejo), se mueve a `~/.dotfiles-backup/<fecha>/` antes de linkear.

## Estructura

```
install.sh               orquesta todo
packages/<perfil>.pacman lista de paquetes de repos oficiales
packages/<perfil>.aur    lista de paquetes de AUR
vscode-extensions.txt    extensiones de VS Code
claude-skills.txt        skills globales de Claude Code
<paquete>/               un paquete de stow = la estructura tal cual va en ~
  zsh/.zshrc                       → ~/.zshrc
  zsh/.config/zsh/base.zsh         → ~/.config/zsh/base.zsh
  ghostty/.config/ghostty/config   → ~/.config/ghostty/config
  ...
```

### Cómo se arma el shell

`~/.zshrc` es corto: carga todos los `~/.config/zsh/*.zsh` y después `~/.zshrc.local`.
Cada perfil deja su archivo ahí (`base.zsh`, `sre.zsh`, y el privado pone `work.zsh`),
así cada máquina tiene solo los aliases que le corresponden.

## Día a día

- **Cambié una config**: ya está en el repo (es un symlink). `git commit` y `git push`.
- **Instalé un paquete nuevo**: agregalo a `packages/<perfil>.pacman`. `./install.sh --check` te avisa si te olvidaste.
- **Otra máquina**: `git pull` y `./install.sh <perfiles>` (es idempotente: lo podés correr cuantas veces quieras).
- **Algo solo para esta máquina**: `~/.zshrc.local` (no se versiona).

## Notas

- **Ghostty + ssh**: `shell-integration-features = ssh-env` hace que al conectarte por ssh la terminal
  se presente como `xterm-256color`. Sin eso, en servidores que no conocen Ghostty el backspace no anda.
- **Claude Code**: el hook de `settings.json` lo usa herdr (el script del hook lo crea herdr al instalarse).
  Si algún programa reescribe `settings.json` y rompe el symlink, `./install.sh --check` lo detecta.
- **Secretos**: nada de claves, tokens ni datos del trabajo en este repo. Eso va en el privado o en `~/.zshrc.local`.
