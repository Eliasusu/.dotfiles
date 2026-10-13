# Repo público + repo privado como overlay

La configuración vive en dos repos: este, público (portfolio, sin datos del trabajo), y `dotfiles-private`, que agrega el perfil `work` encima. El privado se clona en `~/.dotfiles-private`; el público lo detecta y le delega `./install.sh work`. El público no conoce el contenido del privado: solo deja **ganchos** que cargan archivos opcionales (`~/.zshrc.local`, `~/.config/zsh/*.zsh`, `~/.gitconfig-work` vía `includeIf "gitdir:~/Workspace/muni/"`). Si el privado no está, los ganchos no cargan nada y todo funciona igual.

## Considered Options

- **Submódulo privado dentro del público**: más cómodo, pero expone la URL del repo privado y obliga a tenerlo para clonar sin errores.
- **Privado como copia completa del público**: todo duplicado en dos lugares.
- **Un solo repo con chezmoi y cifrado**: descartado junto con chezmoi (ADR-0001).

## Consequences

- Cualquier dato de la Municipalidad (hosts, IPs, emails, rutas, scripts de SIAT, config de glab) va al privado aunque sea una línea. En el público solo existe el gancho.
- Agregar algo laboral nuevo puede necesitar primero un gancho nuevo en el público.
