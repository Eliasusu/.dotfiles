# Perfiles componibles elegidos por flag

Lo que tiene cada máquina se arma con perfiles que se eligen al correr el instalador (`./install.sh base desktop`, `./install.sh base work`, `./install.sh sre`) en vez de detectar la máquina por hostname o tener una config por máquina. Las tres máquinas de Elias comparten casi todo; lo que varía es por *rol* (apps personales, trabajo, infraestructura), no por equipo, y un rol nuevo no obliga a tocar las máquinas existentes.

- `base`: lo que toda máquina tiene.
- `desktop`: apps personales; laptop y PC personal.
- `sre`: herramientas de infraestructura, opcionales, para cuando se necesiten (no se instalan "por las dudas").
- `work`: vive entero en el repo privado (ver ADR-0003).

## Consequences

- Los perfiles se aplican siempre en orden canónico (`base` primero) sin importar el orden de los flags, porque los demás asumen lo que instala `base` (mise, zsh).
- Un perfil puede tener paquetes, paquetes de stow, un módulo de shell y pasos posteriores; ninguno de los cuatro es obligatorio.
- Aplicar un perfil es idempotente: se puede volver a correr en una máquina a medio configurar.
