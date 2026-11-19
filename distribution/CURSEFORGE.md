# Preparación de CurseForge

Estado: **publicación aplazada por el propietario**. No se ha creado ni enviado un proyecto. Este directorio prepara la documentación; no certifica que el issue #5 esté completo.

## Ficha preparada

Nombre propuesto para comprobar en la plataforma: **Tartaro Guild**. Mantener `Tartaro` como nombre de carpeta. No se ha comprobado disponibilidad del nombre.

Resumen en inglés:

Guild coordination for Tartaro in WoW: Forever: events, member locations, crafting requests and world PvP calls.

Descripción en inglés:

Tartaro is a Spanish-language guild coordination addon intended for WoW: Forever. Its features are restricted to characters in a guild named exactly **Tartaro**, regardless of realm. Characters outside that guild receive an informational message instead of access to its features.

The addon provides a guild calendar with signups, announcements and a daily message, member locations on the world map and minimap, member information, a profession recipe search and crafting orders, material donation requests, honor rankings, group searches and world PvP calls with configurable sound alerts.

Group searches support activity categories, locations and missing roles. Battleground searches support role slots. Quest searches use the character's own quest journal and announce a native quest link. Organizers can repost an active search without clearing its participants.

Material donation requests can be created from a recipe ingredient. The selected ingredient is displayed in a quantity form; there is no standalone item-entry form. Received requests remain visible while the requester is offline, can be closed by their owner and expire seven days after creation. Item tooltips can list guild members who have requested that material.

Members need compatible addon versions to exchange addon data. Communication uses the game's guild addon channel; no external account or server is required. Received records are stored locally in `TartaroDB`. A client cannot recover an unseen request from an offline author until they are online together. Creating a request queues a message; it does not confirm receipt by every member.

OpenMap integration is optional. OpenMap is not required or bundled. The interface is in Spanish. Support is limited to Forever; other WoW clients have not been validated. Game restrictions may require sending a prepared chat message manually. Alerts are hidden during combat by default.

Source: https://github.com/juanpablolujan86-a11y/Tartaro

Support: https://github.com/juanpablolujan86-a11y/Tartaro/issues

Descripción adicional en español:

Tártaro reúne calendario, avisos, ubicaciones de miembros, profesiones y pedidos, solicitudes de materiales, honor, búsquedas de grupo y llamados a las armas. Solo funciona con personajes de una hermandad llamada exactamente **Tartaro**, sin restricción de reino. Comparte datos dentro del juego entre miembros que tengan versiones compatibles y conserva los registros recibidos. Para recuperar solicitudes nunca recibidas debe coincidir conectado su autor. OpenMap es opcional y no se incluye.

## Decisiones y pendientes

| Elemento | Estado |
| --- | --- |
| Licencia del código | Todos los derechos reservados; LICENSE y Tartaro/LICENSE.txt |
| Cuenta propietaria y mantenedores | Falta confirmación del propietario |
| Derechos y créditos de recursos | Pendientes; ver Tartaro/CREDITS.md |
| Avatar de 400 × 400 | Pendiente de confirmar derechos del emblema y preparar el archivo |
| Categoría | Guild propuesta; confirmar al crear la ficha |
| Flavor y build | Solo Forever propuesto; registrar cliente real y selección disponible |
| Canal Release/Beta/Alpha | Pendiente de resultados reales y decisión del propietario |
| Distribución por terceros | Pendiente de decisión del propietario |
| Capturas | Usar capturas reales de la candidata probada |
| Dependencias | Sin dependencias obligatorias declaradas; OpenMap opcional |
| Publicación | Aplazada; sin ID ni URL de CurseForge |

## Antes de enviar

1. Terminar las pruebas manuales/E2E de #1–#4 y cerrar cada issue con evidencia y explicación.
2. Resolver cuenta, derechos de recursos, avatar, canal y distribución por terceros.
3. Seleccionar commit/tag final; registrar build de Forever, versión del TOC y escenarios probados, incluida actualización sin perder SavedVariables.
4. Ejecutar pruebas locales y verificar el ZIP con `python tools/package_addon.py --build`. El informe identifica expresamente una copia local modificada; no la atribuye al último commit.
5. Medir CPU, memoria y tráfico con varios personajes y una carga documentada. No hay resultados de rendimiento reales todavía.
6. Volver a comprobar las reglas y los campos de CurseForge. No usar el ZIP de fuentes automático de GitHub como instalador.
7. Solo tras una nueva autorización, crear/enviar el proyecto y comprobar moderación, descarga e instalación/actualización desde la app.
8. Cerrar #5 únicamente cuando sus criterios de distribución y verificación se hayan cumplido. Una release en GitHub no demuestra disponibilidad en CurseForge.

Fuentes oficiales revisadas: [normas de moderación](https://support.curseforge.com/support/solutions/articles/9000197279-moderation-policies), [tipos de archivo y campos](https://support.curseforge.com/support/solutions/articles/9000197242-file-types-and-additional-fields). La ficha incluye inglés antes del español y el avatar deberá ser de 400 × 400; el nombre y los campos definitivos se revisarán al publicar.
