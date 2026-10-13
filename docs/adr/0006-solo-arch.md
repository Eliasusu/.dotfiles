# Solo Arch/CachyOS por ahora

Todas las máquinas corren Arch o CachyOS, así que el instalador asume `pacman` y `yay`: las listas de paquetes son `packages/<perfil>.{pacman,aur}` y los pasos `post_*` usan `systemctl`. `install.sh` corta con un error si no encuentra `pacman`, salvo con `--links-only`, que solo necesita stow y sirve en cualquier sistema.

## Considered Options

- **Soportar también Debian/Ubuntu o macOS**: obliga a mantener listas por gestor de paquetes y a ramificar los pasos posteriores, sin ninguna máquina que lo use hoy.
- **Nix / home-manager**: reproducible en cualquier distro, pero es otra herramienta y otro lenguaje para algo que hoy resuelven pacman + stow + mise.

## Consequences

- En otro sistema se puede usar `--links-only` para tener las configs, e instalar las herramientas a mano.
- Lo que depende de la versión (lenguajes, CLIs de infra) ya va por mise y no por pacman (ver ADR 0004), así que portarlo a otra distro sería sobre todo traducir las listas de paquetes.
- Si aparece una máquina con otro sistema, se escribe un ADR nuevo que reemplace a este.
