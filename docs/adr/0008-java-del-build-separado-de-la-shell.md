# El Java del build se separa del Java de la shell

Un proyecto que compila con un Java viejo (SIAT, Java 17) no lo fija para la shell: sus versiones de build van en un `mise.build.toml`, que mise solo carga con `MISE_ENV=build`, y es el comando de build el que lo activa (`MISE_ENV=build mise -C <proyecto> exec -- ant`). La shell y los IDEs ven siempre el Java global (25), porque jdtls (nvim, Zed) y la extensión de Red Hat (VS Code) necesitan 21 o más para arrancar, y un `JAVA_HOME=17` heredado del directorio los rompe. Para el IDE el proyecto sigue siendo de Java 17: jdtls lee el nivel de Java del proyecto y compila con `--release 17` sobre el JDK 25, que valida contra la API exacta de 17.

## Considered Options

- **Fijar Java 17 en el `mise.toml` del proyecto** (lo que decía ADR-0004): cada terminal o IDE abierto en esa carpeta hereda `JAVA_HOME=17` y el servidor de lenguaje no arranca. Además no alcanza a los worktrees que viven fuera de la carpeta del proyecto.
- **Configurar en cada IDE un runtime `JavaSE-17`**: Zed y VS Code piden una ruta absoluta en su JSON (`~` no se expande), lo que rompe la regla de rutas relativas a `$HOME`. Queda como salida si aparece una diferencia real entre `--release 17` y un JDK 17.

## Consequences

- El IDE muestra un aviso del tipo "no hay un JRE compatible con JavaSE-17, uso el 25". Es esperado.
- Compilar a mano con `ant` en una terminal usa Java 25; el build se corre siempre por el comando del proyecto.
- No puede haber un `mise.toml` con `java = "temurin-17"` en la carpeta del proyecto ni en sus padres: volvería a fijarlo para la shell.
