# Trabajo en Tártaro

- Restricción expresa del usuario: no inspeccionar ni controlar la ventana de WoW; no capturas, teclas, clics, comandos ni automatización del cliente. Depurar mediante código, pruebas aisladas y lectura de archivos/registros. La autorización para copiar el addon no autoriza interactuar con el juego.

- Entrada de estado y desarrollo: [MAESTRO-DESARROLLO.md](MAESTRO-DESARROLLO.md). Cambios de la rama de diseño: [docs/MEJORAS-DISENO-MENU.md](docs/MEJORAS-DISENO-MENU.md).

- Mantener la carpeta `Tartaro/` lista para copiar en `Interface/AddOns/`. Por instrucción expresa posterior del usuario, no generar ZIP ni paquetes salvo petición explícita.
- Verificar sintaxis Lua 5.1, XML, caracteres de la UI y contenido del paquete antes de entregar. Por instrucción del usuario, las pruebas automatizadas y simulaciones externas fueron eliminadas; no recrearlas sin autorización. Esas comprobaciones estáticas no acreditan ejecución dentro de Forever.
- Para cambios originados en un issue, registrar qué se implementó, la versión y las pruebas realizadas.
- Cerrar cada issue únicamente cuando su implementación esté terminada y hayan pasado las pruebas E2E o manuales correspondientes. Antes del cierre, publicar una explicación de cambios, resultados y evidencia. Una simulación no cuenta como prueba dentro de Forever.
- Si falta acceso al juego, un segundo personaje o una comprobación, dejar el issue abierto e indicar qué falta. No inventar resultados, builds ni aprobaciones.
- Publicar los cambios en GitHub cuando el usuario lo autorice. Distinguir commit/push de una release y de una publicación en CurseForge.
- CurseForge está aplazado por decisión del usuario. No crear ni enviar el proyecto o sus archivos sin una nueva instrucción.
- Licencia elegida: Todos los derechos reservados. No asignar licencias a recursos de terceros cuya procedencia no esté confirmada.
