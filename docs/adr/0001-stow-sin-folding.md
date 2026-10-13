# GNU Stow con `--no-folding` para linkear configs

Las configs se linkean desde el repo a `$HOME` con GNU Stow, archivo por archivo (`--no-folding`), orquestado por un `install.sh` propio. Stow da symlinks reales, así que editar `~/.zshrc` es editar el repo, sin una herramienta extra que aprender y con un repo que se lee como el árbol de `$HOME`. `--no-folding` evita que Stow linkee carpetas enteras: herdr, Claude Code y VS Code escriben logs, cachés e historial en sus carpetas de config, y con carpetas linkeadas eso terminaría dentro del repo.

## Considered Options

- **chezmoi**: plantillas por máquina y archivos cifrados (podría haber reemplazado al repo privado). Descartado: copia en vez de linkear (se edita con `chezmoi edit`) y suma una herramienta que aprender para un problema que no tenemos todavía.
- **Script propio de symlinks** (como kr0nicas/dotfiles): control total, pero la lógica de links y backups la mantenemos nosotros.

## Consequences

- Las apps que escriben su config a través del symlink (VS Code, Zed, lazygit, Claude Code + herdr) generan diffs en el repo; hay que separar preferencia real de ruido antes de commitear.
- Una app que reemplaza el symlink por un archivo nuevo lo desconecta del repo; `install.sh --check` existe para detectarlo.
- Stow se niega a pisar archivos existentes: `install.sh` mueve lo previo a `~/.dotfiles-backup/<fecha>/` antes de linkear.
