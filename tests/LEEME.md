# Estado de las pruebas externas

El 24/11/2026 el usuario ordenó eliminar las pruebas y simulaciones externas. Se eliminaron los 20 archivos Lua/Python de esta carpeta, incluido el ejecutor y las pruebas de empaquetado. No existe una suite ejecutable vigente en tests/.

ISSUE-6.md y REPLICATION.md se conservan como antecedentes documentales, no como pruebas disponibles ni resultados del cliente actual. Las referencias históricas a programas eliminados no son instrucciones para ejecutarlos.

Se conserva tools/package_addon.py, que comprueba archivos reales, metadatos, recursos y correspondencia del ZIP con la fuente; no simula WoW. Se conserva LoadTrace.lua dentro del addon. La ventana y el ejecutor del diagnóstico guiado también se retiran de la propuesta 0.2.0. Su alcance se explica en docs/DEPURACION-CARGA.md y docs/DIAGNOSTICO-LOCAL.md: no proporcionan trazabilidad completa de cada función ni acreditan ausencia total de errores.

La verificación del agente queda limitada a inspección de código, compilación de sintaxis Lua 5.1, XML, caracteres, paquete y lectura de registros. Las pruebas reales del cliente las realiza el usuario. Está prohibido controlar o inspeccionar la ventana de WoW.
