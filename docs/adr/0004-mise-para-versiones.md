# mise maneja versiones de lenguajes y CLIs de infraestructura

> Cómo fija SIAT su Java 17: reemplazado por [ADR-0008](0008-java-del-build-separado-de-la-shell.md).

Java, Node, pnpm y las CLIs del perfil `sre` (kubectl, helm, terraform, aws-cli, etc.) se instalan con mise, no con pacman. Reemplaza a nvm y SDKMAN con una sola herramienta y permite que cada proyecto fije su versión con un `mise.toml` propio: SIAT usa Java 17 mientras el default global es Java 25 (lo piden las extensiones de Red Hat), y las CLIs de infraestructura tienen que coincidir con la versión del cluster o del proyecto.

## Consequences

- Una herramienta se instala por una sola vía: si está en mise no va en `packages/*.pacman`. Excepción documentada: `ansible`, que en mise depende del backend de Python y va por pacman.
- Las CLIs del perfil `sre` viven en `~/.config/mise/conf.d/sre.toml`, que solo existe si se aplicó el perfil.
- Los paquetes globales de npm instalados con el Node de nvm no se migran solos.
