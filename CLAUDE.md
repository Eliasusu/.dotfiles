# dotfiles

Entorno de desarrollo de Elias para Arch/CachyOS: listas de paquetes + configs linkeadas con GNU Stow, orquestadas por `install.sh`. Repo público; lo del trabajo vive en el repo privado (`~/.dotfiles-private`), nunca acá.

- Vocabulario (perfil, paquete de stow, overlay, gancho…): `CONTEXT.md`. Usá esos términos tal cual.
- Por qué está armado así: `docs/adr/`. Leé el ADR que toque antes de cambiar la forma del repo (herramienta de links, perfiles, público/privado, mise, shell, alcance de plataforma, secretos). Si tu cambio contradice uno, proponé un ADR nuevo que lo reemplace en lugar de desviarte en silencio.
- Flags y perfiles: `./install.sh --help` y el bloque `STOW_PKGS` al principio de `install.sh` son la fuente de verdad.

## Recetas

**Agregar una herramienta sin config** → una línea en `packages/<perfil>.pacman` (o `.aur` si no está en los repos oficiales). Si la versión importa por proyecto (lenguajes, CLIs de infra), va en mise en vez de pacman: `mise/.config/mise/config.toml` (base) o `sre/.config/mise/conf.d/sre.toml` (sre). Una herramienta vive en una sola vía, nunca en pacman y mise a la vez.

**Agregar una herramienta con config** → además:
1. Crear el paquete de stow `<herramienta>/` replicando la ruta desde `$HOME` (ej. `foo/.config/foo/config.toml`).
2. Sumar el nombre al perfil correspondiente en `STOW_PKGS` de `install.sh`.
3. Tema Tokyo Night (variante *night*), fuente JetBrainsMono Nerd Font.
4. Actualizar la tabla de perfiles del `README.md`.

**Aliases o init de shell** → en el módulo del perfil: `zsh/.config/zsh/base.zsh` o `sre/.config/zsh/sre.zsh`. `.zshrc` solo orquesta; queda corto. Cada bloque se protege con `command -v <tool> >/dev/null &&` para que el shell arranque aunque la herramienta falte.

**Perfil nuevo** → `packages/<perfil>.{pacman,aur}`, entrada en `STOW_PKGS` y en `ALL_PROFILES`, un `post_<perfil>()` si necesita pasos posteriores, módulo `<perfil>/.config/zsh/<perfil>.zsh` si trae aliases. Leé `docs/adr/0002-perfiles.md` primero.

## Verificar un cambio

Una tarea en este repo está terminada cuando pasa todo esto:

1. `bash -n install.sh` y `shellcheck install.sh` sin errores (los avisos de estilo SC2001/SC2088 son aceptados).
2. `zsh -n` sobre cada archivo `.zsh` / `.zshrc` tocado.
3. Prueba de links en un HOME descartable, nunca sobre el `$HOME` real:
   ```bash
   T=$(mktemp -d); HOME=$T ./install.sh --links-only base sre
   HOME=$T ./install.sh --links-only base sre   # segunda corrida: cero backups
   ```
4. Si tocaste paquetes o pasos `post_*`: mostrale al usuario la salida de `./install.sh --dry-run <perfiles>` y dejá que él corra la instalación real (pide sudo).

## Archivos que las apps reescriben

Como las configs son symlinks, algunas apps escriben a través del link y el cambio aparece en `git diff`: `vscode/…/settings.json`, `zed/…/settings.json`, `lazygit/…/config.yml`, `claude/.claude/settings.json` (herdr agrega su hook). Ante un diff ahí, clasificalo: cambio de preferencia hecho por el usuario → se commitea; ruido generado por la app (claves reordenadas, defaults agregados, estado de UI) → se descarta con `git checkout -- <archivo>`. Si una app reemplazó el symlink por un archivo, `./install.sh --check` lo reporta.

## Límites

- Datos del trabajo (hosts, IPs, emails o rutas de la Muni, scripts de SIAT) van al repo privado. Acá solo existen los **ganchos** que el privado completa.
- Claves SSH, tokens (`gh`, `glab`, AWS) y `~/.zshrc.local` quedan fuera de cualquier repo.
- Rutas siempre relativas a `$HOME` o al directorio del script; el repo puede estar clonado en `~/.dotfiles` o en `~/dotfiles` según la máquina.
