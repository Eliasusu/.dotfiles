# Secretos y credenciales nunca se versionan, ni en el repo privado

Las claves SSH, los tokens (`gh`, `glab`, AWS) y los overrides locales no entran a ningún repo, tampoco al privado. Cada máquina genera su propia clave SSH (`ssh-keygen` + `gh auth login` desde el instalador), así perder una máquina se resuelve revocando solo su clave. Las skills de Claude de terceros tampoco se copian: se instalan desde su fuente (`claude-skills.txt` → `npx skills add`) para no quedarse con copias viejas.

## Consequences

- Una máquina nueva siempre pasa por un paso interactivo (passphrase de la clave y login en GitHub, y en `work` también GitLab).
- El repo privado puede tener datos laborales (hosts, emails), pero no credenciales.
