# zsh sin framework, con starship y módulos por perfil

El shell es zsh sin oh-my-zsh ni powerlevel10k: los plugins (autosuggestions, syntax-highlighting) se instalan con pacman y el prompt es starship. `.zshrc` es corto y carga todos los `~/.config/zsh/*.zsh`; cada perfil aporta su propio módulo (`base.zsh`, `sre.zsh`, y el privado `work.zsh`), así una máquina solo tiene los aliases de los perfiles que se le aplicaron.

## Considered Options

- **Mantener oh-my-zsh + p10k**: p10k está en soporte mínimo y oh-my-zsh cargaba mucho que no se usaba (ni siquiera los aliases del plugin `git`).
- **fish**: trae de serie lo que zsh consigue con plugins, pero no es compatible con bash. Rompe el copiar y pegar de snippets de instalación y casi nunca está en los servidores.

## Consequences

- Cada línea de un módulo se protege con `command -v` para que el shell arranque aunque falte una herramienta.
- syntax-highlighting se carga al final de `.zshrc`, después del prompt y de los módulos.
