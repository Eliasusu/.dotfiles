# dotfiles

Cómo se describe y se reproduce el entorno de trabajo de Elias en cada una de sus máquinas, separando lo personal y público de lo laboral y privado.

## Máquinas y alcance

**Máquina**:
Una computadora de Elias que se configura con estos dotfiles: la laptop, la PC personal o la PC del trabajo.
_Avoid_: host, equipo, entorno

**Perfil**:
Un conjunto con nombre de herramientas y configs que una máquina elige tener (`base`, `desktop`, `sre`, `work`). Una máquina es la suma de los perfiles que se le aplicaron.
_Avoid_: rol, flavor, preset, modo

**Perfil base**:
Lo que toda máquina tiene: shell, git, editores, terminal, contenedores, lenguajes.
_Avoid_: core, mínimo, default

**Perfil desktop**:
Apps personales de uso diario que no son de desarrollo; solo en máquinas personales.
_Avoid_: personal, gui, apps

**Perfil sre**:
Herramientas de infraestructura (Kubernetes, IaC, nube, secretos) que se suman a demanda.
_Avoid_: devops, cloud, infra

**Perfil work**:
Todo lo específico de la Municipalidad; vive entero en el repo privado.
_Avoid_: muni, trabajo, laboral

## Repos

**Repo público**:
Este repositorio: configuraciones sin ningún dato del trabajo ni secreto, publicable como portfolio.
_Avoid_: dotfiles principal, repo base

**Repo privado**:
Repositorio aparte que agrega el perfil work encima del repo público, sin que el público sepa su contenido.
_Avoid_: dotfiles-work, submódulo

**Overlay**:
La relación entre ambos repos: el privado se aplica después del público y solo completa los ganchos que el público deja abiertos.
_Avoid_: herencia, fork, merge

**Gancho**:
Un punto del repo público que carga un archivo opcional que puede no existir, para que otro repo o la propia máquina lo complete.
_Avoid_: hook (reservado para hooks de git y de Claude), extension point, include

## Configs

**Paquete de stow**:
Una carpeta del repo que refleja, a partir de `$HOME`, los archivos de configuración de una herramienta.
_Avoid_: módulo, componente, package (a secas)

**Lista de paquetes**:
El registro de qué software instala un perfil, separado por origen (repos oficiales o AUR).
_Avoid_: Brewfile, dependencias, requirements

**Módulo de shell**:
El archivo de aliases e inicializaciones que aporta un perfil al shell; existe en una máquina solo si ese perfil se aplicó.
_Avoid_: plugin, snippet, rc

**Override local**:
Configuración de una sola máquina que nunca se versiona en ningún repo.
_Avoid_: config local, secretos

**Backup**:
La copia de un archivo previo de la máquina que se aparta antes de reemplazarlo por un link; nunca se pierde nada al aplicar un perfil.
_Avoid_: snapshot, respaldo automático

**Link pisado**:
Una config que debería ser un link al repo pero que una app reemplazó por un archivo propio, desconectándola del repo.
_Avoid_: link roto, drift

**Tema**:
Tokyo Night, variante night: la identidad visual común a todas las herramientas con interfaz.
_Avoid_: colorscheme, paleta
