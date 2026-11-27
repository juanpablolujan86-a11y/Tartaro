# Mejoras del menú: plan y bitácora de la rama

> Estado al 24/11/2026: pruebas y simulaciones externas eliminadas por instrucción del usuario. Las referencias siguientes a sus archivos y ejecuciones se conservan como historial; no representan programas disponibles ni validación real en Forever.

## Inicio de la sesión — 23/11/2026

- Usuario solicita una rama y aprobación individual antes de resolver cada hallazgo.
- Creada localmente `codex/mejoras-diseno-menu` desde 0.1.59, commit `6c1965ebf057832b784c4db757f4515a642f5ee3`. Sin push.
- Usuario aprueba el primer cambio: pulsar pedidos en Inicio para abrir/localizar el registro en Profesiones → Pedidos, conservar el acceso general e informar si dejó de estar disponible.
- Usuario añade filtro: ver pedidos propios, pedidos ajenos aceptados por el personaje y pedidos abiertos pendientes de asignación. Ocultar los ajenos tomados exclusivamente por otros.
- Usuario solicita registrar detalladamente los cambios de la rama desde esta sesión.

## Regla de filtro sustentada por el código

El modelo actual registra ofertas de fabricantes (`db.offers`), no una adjudicación exclusiva. El botón actual es «Puedo fabricarlo». Para el filtro solicitado:

1. Pedido propio activo: visible, independientemente de sus ofertas.
2. Pedido ajeno activo con oferta propia: visible, incluso si tiene otras ofertas.
3. Pedido ajeno activo sin ofertas de miembros actuales: visible.
4. Pedido ajeno activo con ofertas de otros miembros y sin oferta propia: oculto.

El filtro se aplica a la presentación. Los registros, recepción, retransmisión, autoría, caducidad y cierre no cambian. No constituye una reserva exclusiva ni garantiza conocer ofertas que todavía no llegaron al cliente. Los completados propios/aceptados conservan su presentación existente.

## Resultado esperado y comprobaciones

- Inicio conserva sus dos resúmenes (propios y aceptados); cada entrada abre el pedido identificado, no una coincidencia de nombre.
- Pedidos muestra solo las categorías autorizadas. Aceptar un pedido no lo oculta para el personaje que se ofreció.
- Al abrir desde Inicio, la tarjeta queda situada a la vista e identificada. Si el pedido cerró, venció o dejó de ser visible, se informa sin abrir otro registro.
- Ver pedidos conserva la apertura de la lista general filtrada.
- Comprobar cambios de orden de la lista, varios pedidos, itemID 0, copias compartidas, estados sin ofertas/con oferta propia/con ofertas ajenas, vencimiento y cierre.

## Pasos de implementación

1. Documentar alcance y estado de la rama antes de tocar código.
2. Añadir consulta de pedidos visibles sin modificar la consulta completa utilizada por sincronización/pruebas de protocolo.
3. Convertir resúmenes de Inicio en accesos y localizar la tarjeta por identidad al renderizar.
4. Añadir regresiones de filtro y navegación con módulos reales/APIs simuladas.
5. Verificar Lua 5.1, XML, regresiones y paquete; registrar resultados y archivos afectados.

## Registro de cambios

- Documentación inicial: creado este plan y `MAESTRO-DESARROLLO.md`, entrada que faltaba en el proyecto; enlazada desde AGENTS.md. LEEME sigue siendo el manual de uso y no se renombra.
- `Tartaro/Orders.lua`: añadida consulta `listVisibleOrders`, que filtra la presentación y conserva `listOrders` completa. Los mensajes y registros de pedidos/ofertas no se modifican ni se eliminan por el filtro.
- `Tartaro/UI.lua`: resúmenes de Inicio convertidos en botones con altura adaptada al texto. Los callbacks conservan ID y contexto de guild. Acceso común a Pedidos, selección de tarjeta, color distintivo y desplazamiento después de calcular el contenido; sin coincidencias por nombre. Aviso cuando el pedido ya no está disponible; Ver pedidos limpia la selección. La selección también se limpia al cambiar el contexto de guild.
- `tests/order_visibility.lua`: nueva regresión del filtro, estados mixtos de ofertas, copias, recarga, cierre y caducidad. `tests/run_local.py` incorpora el archivo a la ejecución habitual.
- `tests/ui.lua`: regresión de navegación y filtro; el montaje registra posición, color y scroll. Verifica selección de un pedido fuera del primer tramo visible y cierre entre dibujar Inicio y pulsar el acceso.
- `Tartaro/LEEME.md` y `tests/LEEME.md`: documentados el comportamiento local, la dependencia de ofertas recibidas, la cobertura y las limitaciones.
- No se cambió la versión del TOC (base 0.1.59), el protocolo, el historial de completados ni la copia instalada. No se aplicaron los otros hallazgos.

## Verificación del primer cambio — 23/11/2026

- `python -B tests/run_local.py`: pasó compilación Lua 5.1, XML, caracteres y todas las regresiones, incluidas las nuevas. También pasaron las pruebas existentes de pedidos/replicación, que siguen usando el listado completo.
- La primera ejecución del test de navegación esperaba alinear la tarjeta al borde superior incluso al final de la lista. Se corrigió esa expectativa para respetar el límite de desplazamiento; no se eliminó el límite del producto. La ejecución posterior pasó.
- `python -B tests/test_package.py`: 7 pruebas aprobadas.
- `python -B tools/package_addon.py --build`: genera y verifica el ZIP local y su informe, ignorados por Git. El informe indica expresamente cambios sin commit; no atribuye el contenido modificado al commit base.
- Paquete final de esta revisión: `Tartaro-0.1.59.zip`, SHA256 `b351651c5cbba0a23efa73f070072ea784e1c53bdce294f296df81213a4f0661`. Es una compilación local de la rama, no el asset publicado de 0.1.59.
- `git diff --check`: sin errores de espacios.
- Las comprobaciones usan APIs simuladas y no demuestran tamaño/legibilidad de botones ni render real. Falta revisión manual en Forever y aceptación del usuario. No se hizo push, commit ni copia al juego.
- Comparada la instalación con los archivos del commit base: no hay diferencias. Las modificaciones permanecen exclusivamente en la rama de trabajo.

## Actualización de main local — 23/11/2026

- Por instrucción del usuario se actualizó únicamente la referencia local `main`, por avance rápido de `6c1965e` a `262f9f3ed6df2e387f7559fc90ed4847bc6c2184` (TOC 0.1.60), coincidente con `origin/main`.
- Se mantuvo activa `codex/mejoras-diseno-menu`, con HEAD en `6c1965e`; todavía no integra 0.1.60. Comparados el diff de trabajo, el inventario de archivos no versionados y sus SHA256 antes/después de actualizar main: conservados íntegramente.
- La actualización no instala el addon, no ejecuta ni certifica 0.1.60, no genera commits y no publica la rama. Calendario sigue pendiente de aprobación. Este apunte documental se añadió después de comprobar la conservación del trabajo.

## Integración de 0.1.60 en la rama — 23/11/2026

- Usuario autoriza incorporar main 0.1.60 y comprobar si se conservan los cambios del primer hallazgo.
- Preservados temporalmente cambios versionados y archivos nuevos; avanzada la rama por fast-forward hasta `262f9f3ed6df2e387f7559fc90ed4847bc6c2184`; reaplicados los cambios locales. Git combinó automáticamente UI.lua, LEEME.md y tests/ui.lua, sin conflictos.
- Antes de actualizar esta bitácora se compararon las líneas añadidas/eliminadas de los siete archivos modificados con la copia anterior: coinciden. También coinciden por SHA256 los tres archivos nuevos. Audio.lua, Map.lua, Tartaro.toc y CHANGELOG.md coinciden exactamente con main.
- Se conservan: acceso por ID desde Inicio, tarjeta identificada y situada a la vista, aviso de indisponibilidad, acceso general, filtro personal y pruebas/documentación del primer cambio.
- Se incorporan los controles de 0.1.60 para ocultar/silenciar llamados dentro de instancias y detener/restaurar audio al cambiar de zona. Esto describe el código incorporado, no una prueba real del audio o de cambio de zona.
- Pasaron de nuevo `python -B tests/run_local.py` (incluidas pruebas de navegación/filtro y las pruebas de instancias incorporadas), `python -B tests/test_package.py` (7 casos) y `git diff --check`.
- Los cambios de Inicio permanecen sin commit sobre la nueva base. No se publicó la rama, no se instaló en WoW y no se empezó Calendario. Las pruebas reales siguen pendientes.
- Generado/verificado el paquete local integrado `Tartaro-0.1.60.zip`, SHA256 `39c67756ff3776db522d955291e6a5d300d136bcb1f087037f0a22c09c1c8e0f`; el informe lo identifica como contenido con cambios sin commit. Retirado el resguardo temporal de Git después de comprobar su reaplicación y pasar las pruebas.

## Revisión manual pendiente del primer cambio

1. Abrir Inicio con varios pedidos propios y aceptados; pulsar uno que quede al final de Pedidos y comprobar que su tarjeta queda identificada y visible.
2. Comprobar las tres categorías visibles. Tras recibir la oferta de otro fabricante, el pedido ajeno sin oferta propia se oculta; el propio y el aceptado personalmente continúan.
3. Comprobar mensajes cuando el pedido cierra/vence antes de abrirlo y que Ver pedidos funciona como lista general filtrada.
4. Comprobar nombres largos, varias ofertas, diferentes escalas y navegación entre secciones.
5. No tomar las pruebas anteriores de la versión publicada como aceptación de este cambio local.

## Pendientes

- Validación visual/manual en Forever del primer cambio y aceptación del usuario.
- Partes 2 y 3 autorizadas por el usuario; no implementar los hallazgos posteriores sin presentar solución y obtener aprobación.
- No publicar commits, rama, release ni copiar al juego durante esta tarea sin instrucción del usuario.

## Partes 2 y 3 — autorización y plan

El usuario indica «Adelante con la parte 2 y 3». Alcance tomado del análisis y de la solución presentada de Calendario:

- Calendario: lista de eventos a la izquierda y detalle/inscritos a la derecha con desplazamiento independiente. Conservar selección, permisos, edición e inscripciones.
- Buscar grupo: cabecera basada en cupos aún disponibles y acciones de invitación sobre inscritos para el organizador, reutilizando el menú existente del Calendario con validación específica de la búsqueda.

Pasos:

1. Separar el contenido desplazable del selector de eventos del detalle, manteniendo los botones visuales ya existentes y ocultando correctamente el panel al cambiar de área/guild.
2. Extraer el cálculo existente de necesidades restantes para compartirlo entre anuncio y lista de grupos, conservando las restricciones de republicación y sin modificar mensajes ni cupos.
3. Compartir la construcción del menú de invitación; validar vigencia, participante, organizador y conexión al abrir y ejecutar las acciones.
4. Probar dos desplazamientos independientes, selección y ausencia de filtraciones de controles a otras áreas; probar roles completos/liberados, invitaciones, banda y acciones obsoletas.
5. Ejecutar regresiones de la parte 1 y de la base 0.1.60, pruebas de paquete, documentar resultados y pendientes reales.

No se autoriza el resto del menú, publicación ni instalación en WoW. Los tests simulados no certificarán el resultado visual ni el envío real de invitaciones.

## Registro de implementación — partes 2 y 3

- `Tartaro/UI.lua`, Calendario: nuevo panel izquierdo desplazable con contenido y botones reutilizables propios; el panel derecho reutiliza el scroll y las filas existentes. Conserva los títulos, formato horario, selección, creación, detalles, inscripción y edición. El separador se ancla a la ventana para no desplazarse con los datos.
- La lista conserva su desplazamiento al cambiar de evento; el detalle empieza arriba. Al entrar desde el menú se restablece la lista. Se limita su desplazamiento si se acorta el contenido, se ocultan botones sobrantes y el panel no aparece en otras áreas o sin contexto de guild. Se verifica su recuperación cuando vuelve el contexto.
- `Tartaro/Activities.lua`: extraído `groupRemainingNeeds` del cálculo ya existente para reutilizarlo en vista y anuncio. `groupAnnouncementNeeds` conserva validaciones de organizador, permisos, vigencia y cupos completos. No se cambia el protocolo ni la capacidad/inscripción de grupos.
- `Tartaro/UI.lua`, Buscar grupo: cabecera de BG calculada con roles restantes; con cupos completos se conserva el estado ya existente sin afirmar que siguen faltando roles. Otras categorías conservan texto publicado, sin inventar inscritos.
- Menú de participantes: extraída la construcción existente de Calendario en `participantActions`, compartida por eventos y BG. Cada ruta conserva su validación particular; la búsqueda exige organizador, contexto vigente, permiso, registro activo e inscripción actual. Conexión y acciones se revalidan al ejecutarlas; conversión a banda sigue exigiendo liderazgo. Se conserva fallback al comando de invitación.
- `tests/ui.lua`: ampliado el montaje para registrar/GetVerticalScroll y SetScrollChild. La prueba previa de Inicio distingue ahora su scroll del nuevo scroll del Calendario; la funcionalidad de Inicio no se cambió. Nuevos escenarios: 12 eventos y 25 inscritos, cambios de selección y vista, recuperación de contexto, lista vacía, acciones de Calendario, roles de BG, invitaciones y acciones obsoletas.
- Ajustes del montaje durante pruebas: al añadir otro ScrollFrame, la prueba previa de Inicio seleccionaba el panel nuevo; se identificó el panel correcto. Una BG de prueba reutilizaba el instante de una BG anterior y conservaba sus inscripciones; se le asignó un instante nuevo para aislar el escenario. No se modificó el estado de producción para ocultar estos errores del montaje.
- `Tartaro/LEEME.md`, `tests/LEEME.md` y el maestro: documentados alcance, comportamiento, pruebas y limitaciones. Se conserva la base 0.1.60 sin incrementar versión ni publicar una release.

## Verificación — partes 2 y 3

- Paquete local final: `Tartaro-0.1.60.zip`, 37 archivos, SHA256 `9fb7e31c89c734be8b1413e28f8c78bdc5de1cdb7d80b6b0f15cbf8526435c4a`. El informe registra cambios sin commit; no es un asset publicado.
- `python -B tests/run_local.py`: pasaron compilación Lua 5.1, XML, caracteres y todas las regresiones. Incluye Inicio/filtro, pedidos y replicación de base, nuevas pruebas de Calendario e invitaciones, cupos completos/liberados, offline, liderazgo, permiso, organizador, guild, vencimiento, baja/cierre y fallback de chat.
- `python -B tests/test_package.py`: 7 pruebas aprobadas.
- `git diff --check`: sin errores.
- No se realizaron invitaciones reales ni pruebas visuales en Forever. Tampoco se instaló el código de la rama, se hizo commit/push ni se tocaron hallazgos posteriores.
- Comparada la instalación con el commit de la última instalación (0.1.59/6c1965e): continúa idéntica. No se copió esta candidata al juego.

## Revisión manual pendiente — partes 2 y 3

1. Abrir Calendario con suficientes eventos e inscritos para desplazar ambos paneles. Mover uno y comprobar que el otro no se mueve; cambiar selección y comprobar que el detalle vuelve arriba y la lista conserva posición.
2. Probar creación, edición, inscripción/baja, permisos y salida/retorno a Calendario; revisar resoluciones/escalas y límites de las barras de desplazamiento.
3. Con dos personajes, cubrir/liberar roles de BG y comprobar cabecera, contadores y republicación coincidentes, incluida la situación de cupos completos.
4. Como organizador, abrir el menú de un inscrito e invitar a grupo/banda; verificar conversión solo con liderazgo y comando alternativo si el cliente bloquea la invitación.
5. Comprobar rechazo de acciones si el inscrito se desconecta/se retira o la búsqueda cierra/vence mientras el menú está abierto.
6. Volver a probar Inicio y filtro en la misma candidata. Las simulaciones no sustituyen esta revisión ni la aceptación del usuario.

## Partes 4 y 5 — autorización y plan

El usuario autoriza «Continua con la parte 4 y 5» del análisis:

- Avisos: delimitar cada registro con el fondo de tarjeta ya utilizado en Pedidos, sin añadir edición/eliminación. Anticipar el exceso de longitud del mensaje en el editor, sin cortar ni perder texto y conservando la validación final.
- Profesiones: distinguir lectura/recepción/carga de objetos cuando existen operaciones pendientes reales; distinguir ausencia de catálogo de búsqueda sin coincidencias. No inventar una carga por tener una lista vacía.
- Pedidos y donaciones: reutilizar la presentación de objeto con icono/tooltip, preservando encantamientos sin objeto de salida. En donaciones vacías, explicar y enlazar la creación desde Buscar recetas, sin recuperar entrada manual.

Pasos: compartir fondo de tarjetas; reutilizar constructores de mensajes para comprobar longitud antes de guardar; exponer estados de operaciones ya existentes y actualizar su presentación; reutilizar filas de objetos; cubrir límites UTF-8, ciclo de estados, tarjetas y accesos en pruebas. Regresar partes 1–3 y preparar paquete local.

No se autorizan cambios de permisos, protocolo, adjudicación, cierre o caducidad; tampoco publicación ni instalación en WoW.

## Registro de implementación — partes 4 y 5

- `Tartaro/UI.lua`: extraído `recordCard` del fondo existente de Pedidos y reutilizado en Avisos. Cada aviso conserva autor, fecha y texto con relleno y separación; se ocultan tarjetas al refrescar/cambiar contexto. Se mantiene el resaltado del pedido seleccionado de la parte 1.
- `Tartaro/Core.lua`: separados el cálculo no mutante de próxima revisión y la construcción del paquete de publicación. `editorMessageFits` utiliza los mismos formatos de aviso/mensaje diario/evento para comprobar 250 bytes. No cambia protocolo, permisos ni validación final del envío.
- Editor compartido: título, descripción, fecha/hora, tipo y cupos actualizan la comprobación anticipada. El exceso muestra explicación y deshabilita Guardar; al acortar se recupera sin perder texto. Guardar revalida. Los errores existentes de fecha/cupos siguen comprobándose al guardar.
- `Tartaro/Professions.lua`: `recipeSearchState` consulta escaneo programado, transferencia vigente de miembro actual, recetas recibidas y metadatos solicitados aún ausentes. Invalida la presentación al empezar/terminar escaneo/transferencia. Al vencer una transferencia programa invalidación limitada al mismo contexto y transferencia. No cambia transporte ni persistencia.
- Búsqueda sin resultados: distingue operaciones pendientes reales, catálogo vacío y falta de coincidencias. Con resultados conserva la lista existente. No supone carga solo porque falten resultados.
- Pedidos con objeto y donaciones reutilizan `recipeDetail`: nombre/cantidad, icono y tooltip. ItemID 0 conserva texto sin inventar objeto de salida. La fila libera ancho cuando no tiene botón ni subtítulo.
- Donaciones vacías: orientación y acceso a Buscar recetas; conserva creación solo desde ingredientes y cierre/cantidad/vencimiento existentes.
- `tests/notices_professions.lua`, `tests/notices_professions_ui.lua`, `tests/ui.lua`, `tests/run_local.py`: regresiones de mensajes, estados y UI real bajo APIs simuladas. El montaje registra estado enabled, textura e hyperlink.
- Ajustes del montaje: la búsqueda antigua por etiqueta pulsaba el filtro oculto homónimo de Profesiones; ahora selecciona el botón visible. Se diferencia el acceso de la guía del tab Buscar recetas por su contenedor. Se refresca tras el cierre diferido y se declara el callback de catálogo aportado por otro módulo en ejecución real. No se alteró producción para solventar estos errores de pruebas.
- Actualizados LEEME del addon, LEEME de pruebas y maestro. Se conserva versión base 0.1.60; cambios locales sin commit/publicación.

## Verificación — partes 4 y 5

- `python -B tests/run_local.py`: aprobados Lua 5.1, XML, caracteres y todas las regresiones, incluidas partes 1–3. Nuevos casos: límites 250/251 bytes, UTF-8, eventos nuevos/editados, cupos, reloj intacto al escribir, escaneo/recepción/vencimiento/catálogo/metadatos, tarjetas, acceso contextual, tooltip e itemID 0.
- `python -B tests/test_package.py`: 7 casos aprobados. `git diff --check`: sin errores.
- Paquete local verificado: `Tartaro-0.1.60.zip`, 37 archivos, SHA256 `81509bd2d2e0007fa227e553728818d34f0759ce22377e166fa2eff9ef7eb6e9`. El informe registra cambios sin commit; no es un asset publicado.
- APIs simuladas: no demuestra render, legibilidad, interacción con addons de tooltip ni sincronización dentro de Forever. No se instala/publica la candidata ni se cierran issues o inicia parte 6.

## Revisión manual pendiente — partes 4 y 5

1. Avisos cortos/largos, varias escalas y suficientes tarjetas para desplazar: revisar límites, separación y ausencia de solapamientos.
2. Texto con acentos hasta superar límite: comprobar explicación, botón bloqueado, texto intacto y recuperación al acortar. Repetir mensaje del día y evento nuevo/editado con título, descripción y cupos; conservar errores de fecha/cupos.
3. Buscar sin catálogo y sin coincidencias; observar lectura/recepción reales y metadatos pendientes.
4. Abrir pedido de objeto/encantamiento y donación: comprobar icono/tooltip real y nombres largos. Cambiar de área y comprobar que no quedan tarjetas ajenas.
5. Cerrar última donación, seguir guía, elegir receta/material y solicitar por el flujo existente. Revisar addons de tooltip instalados.
6. Revalidar partes 1–3 en la misma candidata y obtener aceptación del usuario. Sus comprobaciones reales previas siguen pendientes.

- Comprobación final de instalación: los 37 archivos comparados con 0.1.59/6c1965e coinciden por SHA256. No se copió la rama al juego.

## Partes 6 y 7 — autorización y plan

El usuario autoriza continuar con las partes 6 y 7 del análisis original: Honor y Miembros.

- Compartir un constructor pequeño de filas tabulares para celdas, anchos y alturas. Conservar colores, ordenaciones y cálculos específicos de cada área.
- Mostrar una explicación visible del orden activo en ambas áreas; conservar el botón de Honor y la cabecera interactiva de detección de Miembros.
- Añadir un menú sobre los miembros para preparar un susurro e invitar a grupo/banda, reutilizando las acciones de invitación existentes. Revalidar contexto y pertenencia; las nuevas acciones requieren conexión confirmada. Para invitar desde Miembros estando agrupado, exigir liderazgo; convertir a banda conserva su requisito de liderazgo. No usar permisos de edición de eventos.
- Conservar comportamiento de Calendario y Buscar grupo. No enviar susurros automáticamente: preparar el chat existente.

Pasos: extraer filas e invitaciones; incorporar indicación de orden y menú; probar cambios de orden, empates, datos faltantes, estilos y reutilización de filas; probar conexión/liderazgo/contexto cambiados con el menú abierto, susurro e invitación simulados; ejecutar regresiones y empaquetar.

No se autorizan partes 8–10, cambios en honor acumulado/semanal, permisos, protocolo ni instalación/publicación. Las revisiones reales pendientes de partes 1–5 permanecen pendientes.

## Registro de implementación — partes 6 y 7

- `Tartaro/UI.lua`: añadido `tableRow`, que reutiliza celdas por fila y configura anclajes, anchos, colores, altura y separación. Honor y Miembros lo consumen conservando sus columnas y estilos. La preparación de filas oculta celdas sobrantes, fondos y botones específicos al cambiar de área.
- Honor conserva cálculos de total/semanal, calendario, empates, posiciones, resaltado y botón de alternancia. Añadido texto visible del orden activo y desempate por nombre. El pequeño adaptador de filas de Honor vive dentro de su renderizador.
- Miembros conserva el comparador existente (conexión/nombre, precedido opcionalmente por detección), colores de clase/rol/conexión/detección y cabecera interactiva. Añadidos texto visible del orden y orientación para abrir las acciones.
- Extraído `invitationActions` del menú existente de participantes. Calendario y Buscar grupo reutilizan ese bloque sin cambiar sus validaciones particulares; Miembros aporta su propia condición de conexión confirmada y liderazgo cuando está agrupado. La conversión sigue requiriendo grupo, liderazgo y ausencia de banda; se revalida al ejecutar.
- Cada fila de otro miembro tiene un botón de menú que prepara Susurrar y reutiliza invitación/conversión. No se ofrecen acciones sobre uno mismo. Revalida base de datos, personaje actual y pertenencia del destinatario en apertura/ejecución. Conexión desconocida/desconectado deshabilita susurro e invitación. Cambiar conexión/liderazgo/hermandad invalida la acción ya abierta.
- Movidas sin cambiar su contenido `whisperTarget` y `openWhisperDraft` antes de los menús, para reutilizarlas también aquí. Susurrar prepara un borrador vacío; no envía texto. La invitación conserva pcall y comando alternativo de chat. No utiliza permisos de eventos ni modifica paquetes del addon.
- Lua 5.1 rechazó inicialmente el archivo por superar 200 variables locales activas. Acotados los auxiliares de Honor al renderizador, sin añadir globals; la compilación posterior pasa. No se cambiaron módulos ajenos para solventarlo.
- `tests/honor_members_ui.lua`: nuevos escenarios de tablas, clasificación y menús. `tests/ui.lua` carga Honor/Roles reales y registra color de texto. En el primer recorrido de Miembros faltaba cargar Roles en el montaje (roleLabel ausente); se incorporó ese módulo real, sin alterar producción para cubrir el fallo de la prueba.
- Actualizados maestro, LEEME del addon y de pruebas. Los cambios siguen en la rama local sobre 0.1.60, sin commit/push ni incremento de versión.

## Verificación — partes 6 y 7

- `python -B tests/run_local.py`: aprobados Lua 5.1, XML, caracteres y regresiones completas de partes 1–7. Honor: orden semanal/total, empates, periodo ausente, semana antigua, ceros, ausencia de registros y miembro retirado. Miembros: tres órdenes, datos desconocidos, estilos, controles propios y reciclado de filas. Menús: APIs de susurro modernas/alternativas, nombres con/sin reino, offline/desconocido, invitación y banda, pérdida de liderazgo/conexión/pertenencia/contexto/personaje, fallback de chat y cambio/vacío de área.
- `python -B tests/test_package.py`: 7 pruebas aprobadas. `git diff --check`: sin errores.
- Estas pruebas no ejecutan susurros ni invitaciones reales, no verifican render de fuentes, escalas ni interacción con otros addons. No certifican el cliente Forever ni sustituyen la aceptación del usuario.
- No se modificaron los módulos de datos de honor, roles, permisos o sincronización durante estas partes. No se implementaron partes 8–10 ni se cerraron issues.

## Revisión manual pendiente — partes 6 y 7

1. Alternar Honor semanal/total con empates y comparar puntuaciones y posiciones. Verificar texto del orden, columnas y nombres largos a distintas escalas.
2. Abrir Miembros, pulsar la cabecera Tártaro dos veces y comprobar orden mostrado, conexión, detección y colores. Volver desde Honor/Inicio y revisar que no queden columnas ni controles de otra área.
3. Con otro personaje conectado, abrir menú y Susurrar: comprobar destinatario y chat vacío sin envío automático; repetir con nombre de otro reino si se dispone de él.
4. Invitar sin grupo; ya agrupado, comprobar invitación como líder y bloqueo sin liderazgo. Convertir a banda como líder y comprobar invitación a banda. Verificar el comando alternativo si el cliente rechaza la API.
5. Dejar un menú abierto y desconectar/retirar al destinatario o perder liderazgo; comprobar que no ejecuta la acción. Verificar miembros desconectados o sin conexión confirmada y ausencia de menú sobre uno mismo.
6. Revalidar acciones previas en Calendario/Buscar grupo. Mantener pendientes las comprobaciones reales de partes 1–5 hasta realizarlas y obtener aceptación.

- Paquete local final de partes 6–7: `Tartaro-0.1.60.zip`, 37 archivos, SHA256 `712c2a5b260cb641f46644c195ead31b44b115f5d7e310efbb8d261d95320e2f`. Informe con cambios sin commit; no es una release publicada.
- Comprobación de instalación: los 37 archivos comparados con 0.1.59/6c1965e coinciden por SHA256; la instalación permanece sin cambios.

## Partes 8, 9 y 10 — autorización y plan

El usuario autoriza continuar con las partes 8 (Mapa), 9 (Permisos) y 10 (Opciones) del análisis original.

- Mapa: separar visualmente Ubicación, Estado y Llamados, conservando el mapa nativo y las funciones existentes. Reutilizar invitaciones para los solicitantes del llamado propio; revalidar autor, llamado vigente, petición, miembro, conexión, contexto y liderazgo aplicable.
- Permisos: sustituir «Crear y editar eventos» por «Crear eventos» y explicar la edición reservada a creador/líder/sublíder. No cambiar autorización ni grants.
- Opciones: identificar la prueba existente como prueba del archivo y explicar que no reproduce el modo completo de alerta. Conservar rutas de reproducción y restauración de audio; no añadir una prueba que modifique volúmenes.

Pasos: compartir las condiciones de invitación de Miembros con Mapa; organizar secciones, corregir etiquetas y explicación de prueba; comprobar menús y acciones obsoletas, permisos y audio simulado; ejecutar regresiones completas y empaquetar. No se instala/publica la rama ni se añaden las propuestas transversales del análisis. Persisten las validaciones reales pendientes de partes 1–7.

## Registro de implementación — partes 8, 9 y 10

- `Tartaro/UI.lua`, Mapa: conservados los controles de ubicación, diagnóstico y llamados, agrupados mediante encabezados Ubicación, Estado y Llamados. No se crea un mapa adicional.
- El autor del llamado ve solicitantes ordenados por nombre con el menú compartido de invitación. Se conservan ID y nombre por entrada, evitando perder identidad al presentar. La resolución al abrir/ejecutar exige base de datos y personaje originales, mismo llamado propio vigente, permiso de llamado actual, solicitud existente y pertenencia actual del destinatario.
- Extraída la condición de invitación de Miembros a `canInviteMember`: conexión confirmada y, estando agrupado, liderazgo. Compartida por Mapa y Miembros; `participantActions` acepta la condición opcional sin cambiar las comprobaciones propias de Calendario/BG. Conversión, invitación y comando alternativo siguen reutilizados. No se añade susurro a los solicitantes de Mapa.
- Permisos: etiqueta Crear eventos y explicación de edición por creador/líder/sublíder, visible también para quien no administra permisos. No se modifican Core, grants, permisos ni sincronización durante estas partes.
- Opciones: el botón pasa a Probar archivo, conservando A.playCallSound() sin modo de alerta. Dos textos explican SFX y el modo de alerta Master/silencio temporal, incluido fallback SFX sin control de volumen. No se modifica Audio.lua ni se introduce una prueba completa adicional.
- El panel de Opciones pasa a 320 de alto; los controles inferiores se anclan después de los textos para respetar su altura calculada. Queda pendiente comprobar fuentes/escalas reales.
- `tests/map_permissions_options_ui.lua` y `tests/ui.lua`: escenarios nuevos con UI/Activities/Core/Audio reales y APIs simuladas. Inicialmente la búsqueda por texto Bob encontraba una línea de tooltip del montaje sin padre, en lugar de la fila; la selección exige un control con padre. No se cambió producción para solventar esa colisión del montaje.
- Actualizados maestro, LEEME del addon y LEEME de pruebas. Se conserva base 0.1.60, rama local con cambios sin commit/push y sin instalación.

## Verificación — partes 8, 9 y 10

- `python -B tests/run_local.py`: aprobados compilación Lua 5.1 (incluido límite de locales), XML, caracteres y regresiones completas de partes 1–10.
- Nuevos casos: separación y recuentos de Mapa, dos destinatarios independientes, offline/desconocido, invitación/banda, pérdida de liderazgo, retirada de solicitud/miembro/permiso, vencimiento, reemplazo/cierre del llamado, autor, base de datos y personaje. Cierre real del módulo Activities con transporte simulado. Llamados ajenos sin menús de pedidos propios.
- Permisos: etiqueta/explicación y contraste con autorización real de creador, rango con grant y sublíder. Opciones: preview SFX sin cambios de volumen, elección/volumen/silencio, parada del preview anterior; alerta real del módulo por Master y restauración de cuatro valores simulados.
- `python -B tests/test_package.py`: 7 pruebas aprobadas. `git diff --check`: sin errores.
- Ninguna prueba envía invitaciones, reproduce audio ni verifica el mapa/render dentro de Forever. No se cierran issues ni se aceptan las partes por cuenta del usuario. Las propuestas transversales continúan sin implementar.

## Revisión manual pendiente — partes 8, 9 y 10

1. Mapa: revisar secciones, recuentos y desplazamiento a distintas escalas. Como autor con otro personaje solicitante, abrir menú, invitar fuera de grupo, como líder y en banda; comprobar bloqueo sin liderazgo.
2. Dejar menú abierto y cerrar/vencer/reemplazar llamado o retirar solicitud, conexión o permiso; comprobar que no ejecuta invitación. Verificar que un llamado ajeno no muestra solicitudes propias del autor.
3. Permisos: revisar etiqueta y explicación con líder/sublíder/otro rango. Crear no debe permitir editar evento ajeno; comprobar que la edición actual de creador/líder/sublíder permanece.
4. Opciones: revisar textos y controles inferiores en varias escalas. Probar archivo con los dos sonidos, distintos niveles y silencio; contrastar con alerta real y restauración de volúmenes, sin considerar la prueba de archivo una alerta completa.
5. Revalidar las partes 1–7 en la misma candidata y obtener aceptación del usuario. Ninguna comprobación real pendiente se considera realizada por estas simulaciones.

- Paquete local final partes 8–10: `Tartaro-0.1.60.zip`, 37 archivos, SHA256 `5be62316077e106aff4f35f9ae47da45191de7f0f209f4d6804a4ea7ac84d66b`. Informe con cambios sin commit; no es una release publicada.
- Instalación comparada por SHA256 con 0.1.59/6c1965e: 37 archivos sin diferencias. No se copió esta candidata al juego.

## Revisión de POO, DRY y SOLID — 23/11/2026

Solicitada por el usuario después de implementar las diez partes. Alcance: cambios locales sobre 262f9f3/0.1.60 y su integración en la arquitectura existente. No se realizan correcciones en esta revisión.

### Resultado y evidencia

- Cumplimiento parcial; no se certifica una arquitectura completamente orientada a objetos o SOLID por pasar regresiones. La implementación sigue siendo modular/procedural con closures y objetos Frame del cliente. No hay jerarquía propia cuya sustitución permita evaluar Liskov.
- DRY mejoró mediante recordCard, tableRow, invitationActions/canInviteMember, groupRemainingNeeds y los constructores compartidos de mensajes. Los callbacks de resolución/condición permiten compartir menús sin mezclar reglas de eventos, grupos, miembros y llamados.
- Importante — UI.lua:157,1068,2624,2878: el archivo conserva construcción, estado, navegación, validación y coordinación de vistas en un solo bloque principal. Compila actualmente. Prueba adicional solo en memoria: añadir al final una declaración local provoca el error Lua 5.1 «main function has more than 200 local variables». Este límite está comprobado, no es una hipótesis de rendimiento. Recomendación: separar componentes de UI con estado/ciclo de vida propios, comenzando por los reutilizados; no convertir locals a globals para evadir el límite. Verificación propuesta: compilar todos los módulos y conservar navegación, contexto y reutilización de controles en las diez vistas.
- DRY — UI.lua:411 y491: dos bucles leen los mismos cupos y normalizan vacíos antes de llamar eventCaps, uno para anticipar longitud y otro al guardar. Hoy las pruebas pasan; no se afirma divergencia funcional actual. Recomendación: una lectura compartida con resultado/campos de validación, consumida por ambas rutas. Verificación: mismos datos/cupos para prevalidación y guardado, incluyendo vacíos, límites y entradas inválidas.
- SRP — Professions.lua:358 y UI.lua:2322: el estado de profesiones incluye frases finales de UI para loading/metadata, mientras empty/no-match se redactan en UI. Recomendación: devolver códigos/datos del estado y centralizar su redacción en la vista. Verificación: distinguir escaneo, recepción, metadatos, catálogo vacío y sin coincidencias, conservando los textos observables.
- Encapsulación/OCP — UI.lua:157,204,1445: las filas comparten componentes, pero el reciclador conoce los campos internos de tabla, detalle y menús y debe modificarse al añadir otro tipo. Es una deuda del diseño base ampliada por los nuevos componentes. Recomendación: que cada componente controle su actualización/ocultación con una operación de ciclo de vida limitada, sin crear un framework general. Verificación: cambiar entre todas las vistas sin celdas, fondos o botones residuales y conservar los pools.
- DIP/segregación — UI.lua:931,1363,1445,2354: las nuevas vistas y callbacks todavía leen A.db/A.members/A.calls y APIs globales directamente. Es acoplamiento heredado que permanece, no un fallo funcional nuevo demostrado. Recomendación: consultas pequeñas en los módulos propietarios para la información consumida por más de una vista; mantener resolutores de acciones que revaliden al ejecutar. No duplicar la base de datos ni introducir contenedores de dependencias.

### Comprobaciones realizadas

- `python -B tests/run_local.py`: Lua 5.1, XML, caracteres y regresiones de las diez partes aprobadas.
- `python -B tests/test_package.py`: 7 casos aprobados. `git diff --check`: sin errores.
- Prueba del límite de locales realizada sin escribir el código de prueba a disco ni modificar UI.lua.
- No se modifica código, paquete ni instalación; no se hace commit/push. Esta revisión no demuestra E2E dentro de Forever ni resuelve los pendientes manuales.

## Instalación autorizada para pruebas — 24/11/2026

- El usuario solicita instalar esta versión para verla y realizar pruebas. Confirmadas rama codex/mejoras-diseno-menu y versión TOC 0.1.60: incluye las diez partes locales, sin correcciones adicionales de la revisión POO/DRY/SOLID.
- Copiados los 37 archivos de Tartaro/ a `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Tartaro`, sin backups, movimientos o eliminaciones. Comparados fuente/destino por SHA256: cero diferencias y ningún archivo adicional en destino.
- WoW estaba abierto durante la copia; el usuario debe usar /reload para cargar los cambios. La copia no prueba que el cliente los haya cargado ni valida funcionamiento dentro del juego. No se reinició/cerró el cliente ni se tocaron SavedVariables.
- Se actualiza el estado vigente de instalación: candidata local 0.1.60 instalada. Los apuntes previos sobre instalación intacta corresponden a sus respectivas comprobaciones históricas. No se hizo commit/push o publicación.

## Diagnóstico solicitado — 24/11/2026

El usuario solicita un botón de pruebas con log y elige comprobaciones locales con pasos guiados. Implementación, cambios y evidencia en [DIAGNOSTICO-LOCAL.md](DIAGNOSTICO-LOCAL.md). Módulo nuevo separado, conexión mínima con Opciones/contexto/combate, diez comprobaciones de solo consulta y doce pasos manuales. No implementa las refactorizaciones generales pendientes de POO/DRY/SOLID ni publica registros de prueba. La candidata conserva TOC 0.1.60 y distingue el diagnóstico con menu-local-diagnostico-1; no es una release nueva.

## Corrección del diagnóstico — revisión 2

El usuario aclara que el objetivo principal es evidencia técnica legible por el agente. Sustituida la guía basada en declaraciones por captura de acciones/estado/errores y condiciones instrumentadas; eliminados texto libre y aprobación manual. Evidencia, pruebas y limitaciones en DIAGNOSTICO-LOCAL.md. Implementación terminada localmente y pruebas aprobadas; el usuario ordena no actualizar el juego. Revisión 2 no instalada ni publicada, validación real pendiente.

## Donaciones con presentación de Pedidos — 24/11/2026

El usuario pide resolver la diferencia visual señalada: Donaciones debe reutilizar las tarjetas de Pedidos. Alcance: compartir distribución de dos columnas, fondo, márgenes, altura de fila y separación; conservar objeto/tooltip, cantidad, solicitante/conexión, fechas, copia compartida y cierre solo del propietario. No cambiar filtros, protocolo, creación ni caducidad. No actualizar el juego.

Plan: generalizar el grid existente con un renderizador y foco opcional; usarlo en ambas vistas sin añadir otra implementación; comprobar 1/3 registros, alineación, cierre/autoría, vacío, cambio de vista y regresión del foco de Inicio. Ejecutar Lua/XML/caracteres/regresiones/paquete y documentar evidencia; revisión real pendiente.

### Implementación y evidencia — tarjetas de Donaciones

- `Tartaro/UI.lua`: generalizado orderGrid como recordGrid(records, render, focus), sin otro grid ni nuevas variables locales principales. Comparte recordCard, dos columnas de 280 a ancho 570, gap 10, pad 9 y altura máxima por pareja. Pedidos conserva renderOrder, foco y desplazamiento; Donaciones pasa su renderizador sin foco para evitar resaltados por coincidencia de ID.
- Cada donación conserva cantidad, objeto, icono/tooltip, solicitante/conexión, fechas y copia compartida. Líneas compactas como en Pedidos y altura adaptativa del mismo constructor. Cerrar solicitud conserva la condición de propietario y el callback captura el request de esa tarjeta.
- tests/notices_professions_ui.lua: actualizada la expectativa anterior (antes se comprobaba cero tarjetas) y añadidos casos de una/tres donaciones, dos propias/una ajena, columnas/anchos/alturas/separación, fila impar, tooltip, cambio de vista, cierre de ambas propias sin afectar la ajena y retorno a vista vacía con guía. Se mantuvieron las regresiones de foco de Inicio y Pedidos.
- Pasaron python -B tests/run_local.py (Lua 5.1, XML, caracteres y todas las regresiones) y python -B tests/test_package.py (7 casos). git diff --check sin errores.
- Las medidas probadas son las configuradas en el montaje, no un render observado en Forever. Falta revisar escalas, nombres largos y copias compartidas reales.
- Implementación terminada localmente, sin commit/push ni copia al juego. Se respeta la instrucción vigente de no actualizar la instalación.

- Paquete local verificado tras el ajuste: Tartaro-0.1.60.zip, 38 archivos, SHA256 `23a324e28d71e3fc93bdda072e2e2dd0ccd52b558d92d01260975033b2084133`. Contenido con cambios sin commit, no release publicada.

## Buscar grupo con tarjetas compartidas — 24/11/2026

El usuario solicita revisar y resolver ahora la presentación de cada búsqueda de grupo. Confirmado: renderGroups dibujaba filas consecutivas sin recordCard. Alcance: usar recordGrid ya compartido por Pedidos/Donaciones, con dos columnas, fondo, márgenes y altura por pareja. Conservar datos, filtros, orden, roles, inscripción, invitaciones, edición/republicación/cierre y solicitud por susurro. No actualizar el juego.

Plan: sustituir el bucle de render por el grid con callback propio; probar una/tres búsquedas mezcladas, alturas y separación, estados vacíos/filtrados y acciones por propietario/destinatario; ejecutar regresiones y empaquetar. No añadir otro componente visual ni modificar protocolos.

### Implementación y evidencia — tarjetas de Buscar grupo

- UI.lua: reemplazado el bucle de renderGroups por recordGrid(active, callback). Conserva todo el contenido/callbacks de cada búsqueda y la ordenación/selección de activos existente. No crea otro grid ni añade variables locales principales.
- Dos columnas, fondo, relleno, separación y altura máxima por pareja exactamente del componente usado en Pedidos/Donaciones. Grupo pasa sin foco, conservando selección contextual exclusivamente donde se solicita.
- tests/group_cards.lua, integrado en tests/ui.lua: una/tres búsquedas mezcladas (BG, mazmorra y misión de fixture), columnas, anchos, alturas diferentes y tercera tarjeta; necesidades restantes, inscrito, cambio de vista, solicitud por susurro con destinatario correcto por tarjeta, cierre solo del propio, filtro offline y vencimiento/vacío. Envíos simulados; no se contactó a nadie en el juego.
- Pasaron Lua 5.1, XML, caracteres y todas las regresiones (incluidas invitaciones/roles anteriores, Pedidos, Donaciones y diagnóstico). Siete pruebas de paquete aprobadas y git diff --check sin errores.
- Implementación terminada localmente. Sin instalación, commit/push o publicación. Falta render real a distintas escalas, textos largos y muchos inscritos; las medidas probadas son las configuradas en el montaje.

- Paquete local verificado tras Buscar grupo: Tartaro-0.1.60.zip, 38 archivos, SHA256 `7ad7a4514b7833ace3a3401ad919e436895836f8bf3649184fd6e2a166d05cc1`. Contenido sin commit, no release publicada.

## Honor y Miembros: desplazar solo la tabla — 24/11/2026

El usuario solicita mantener legibles título/controles de Honor y Miembros mientras solo se desplazan las tablas. Confirmado: encabezados y tablas estaban en el mismo scrollChild.

Plan: mantener un encabezado fijo compartido fuera del scroll; reutilizar el scroll existente exclusivamente para filas de datos; conservar cabecera de columnas/ordenación de Miembros fija y reglas, colores, menús y ordenamientos. Calcular la altura fija desde las filas renderizadas, limitar desplazamiento al cambiar datos y restaurar el layout al salir. Probar listas largas/cortas, ordenación, cambio de área y contexto, regresiones y paquete. No actualizar el juego.

### Implementación y evidencia — scroll de Honor/Miembros

- UI.lua: un encabezado fijo compartido TartaroTableHeader, hijo de la ventana y fuera del ScrollFrame. row() reasigna el padre según región; conserva el pool y las celdas/componentes existentes.
- content:BeginTable fija la altura real del encabezado calculada por las filas, sitúa el scroll bajo ese encabezado y reinicia y para que solo el cuerpo compute altura desplazable. No se agrega otro scroll o variables locales principales.
- Honor conserva fijos título, regla semanal, orden activo, botón y columnas. Miembros conserva fijos título, orden, orientación, explicación de detección y columnas (incluida la cabecera interactiva Tártaro). La nota de detección se mueve desde el pie al encabezado para que solo se desplacen datos.
- A.refresh configura/oculta región fija, limita el scroll tras actualizar datos y restaura la región de contenido normal al cambiar de área/perder contexto. Se conservan reglas de orden, puntuaciones, colores, conexión y menús.
- Diagnóstico: snapshot incluye fixedHeader/fixedHeight y compara la región fija con la vista correspondiente. Esto evidencia estructura/configuración, no render real.
- tests/honor_members_ui.lua ajusta únicamente la ordenación de inspección del montaje para distinguir cabecera fija de filas del cuerpo. tests/ui.lua incorpora SetParent con estado realista del padre.
- tests/table_scroll.lua: listas de 30 registros, padres separados, títulos/botón/cabeceras estables, cuerpo desplazable, mantenimiento/limitación del offset tras refresco/reducción, reset al ordenar, vacío, salida de sección y pérdida/recuperación de contexto. El scroll existente se reutiliza y las columnas permanecen alineadas por sus anclajes configurados.
- Pasaron Lua 5.1/XML/caracteres y todas las regresiones, más 7 pruebas de paquete y git diff --check. Pruebas con APIs simuladas; no certifican recorte, fuentes o legibilidad a distintas escalas en Forever.
- Implementación terminada localmente; no se actualizó el juego ni se hizo commit/push. Pendientes pruebas visuales con listas largas y nombres extensos, escalas/resoluciones y aceptación del usuario.

- Paquete local verificado tras scroll de tablas: Tartaro-0.1.60.zip, 38 archivos, SHA256 `747a0f2622c8ba497a9019f98cdb06fd72baebcf9ed977265a228d9507514e38`. Cambios sin commit; no release publicada.

## Análisis solicitado: calendario mensual similar al nativo — 24/11/2026

Alcance de esta petición: analizar viabilidad y conservación de características, sin implementar ni instalar. Referencia visual: imagen del calendario nativo adjunta por el usuario. Código revisado: candidata de codex/mejoras-diseno-menu sobre 262f9f3/0.1.60.

### Hechos comprobados

- UI.lua:1086 construye una agenda de eventos futuros, ordenada por fecha/ID, y un detalle; no una cuadrícula de días. La lista tiene ancho 178 (UI.lua:123); sustituirla sin redistribuir la ventana dejaría siete columnas ilegibles.
- Core.lua:500/517/545 conserva creación/edición, eliminación e inscripción/baja por ID. canEditEvent en Core.lua:47 controla creador/líder/sublíder. Activities.lua:16 calcula inscritos, roles, confirmados/suplentes según cupos.
- Datos en A.db.events/signups/deletedEvents/eventReminders y replicación en Replication.lua son independientes de las posiciones de controles. No se encontró uso de C_Calendar/CalendarFrame en Tartaro o pruebas; tampoco un addon Calendar suelto en la carpeta instalada consultada. Esto no demuestra ausencia de API nativa dentro del cliente; su reutilización exacta sigue sin comprobar.
- Inicio y popup asignan selectedEvent por ID (UI.lua:924/868). Guardar también selecciona el ID (UI.lua:516). Una vista mensual debe mostrar el mes/día de ese evento.
- Interfaz de detalle usa hora local y anuncio usa UTC (UI.lua:1143/469); agrupar por día requiere mantener una referencia temporal coherente.
- UI filtra event.when > GetServerTime(); Core.signup también rechaza eventos vencidos. El historial conservado no se expone actualmente en Calendario. Mostrar eventos pasados sería una decisión adicional, no una consecuencia automática del cambio de diseño.

### Propuesta viable (no implementada)

Cuadrícula mensual de siete días por semana y hasta seis filas, navegación mes anterior/siguiente y Hoy, fecha seleccionada y resúmenes con hora/título. Los días con más eventos deben permitir consultar todos, manteniendo ID y orden. Panel lateral completo para detalle/inscripción/inscritos/acciones y botón Nuevo evento disponible según permiso. Cabecera/mes fijos; desplazamiento limitado al contenido largo del detalle o listado de un día.

La cuadrícula leería los mismos registros y reutilizaría operaciones de negocio/formulario actuales. No necesita migración de registros ni nuevos mensajes. Extraer el detalle reutilizable y un componente mensual separado permite limitar cambios a presentación; se mantiene pendiente la comprobación visual de dimensiones reales. La semejanza propuesta es estructural; no está verificada una reutilización literal de recursos o plantillas nativas de Forever.

Preservar: categorías BG/RAID/PVP/OTHER, creación/edición/eliminación con autorización, cupos/roles, confirmados/suplentes, baja/cambio de rol, participante sin cupos, menú de invitación autorizado, copias compartidas, cancelaciones, sincronización, recordatorios, acceso desde Inicio/popup y contexto/combate. No añadir historial, recurrencias, festividades, invitaciones masivas o nuevas reglas por aparecer en la referencia visual.

### Verificación necesaria antes de afirmar ausencia de regresiones

Pruebas de meses de 28/29/30/31 días, cambios de año, cuadrículas de seis semanas, varios eventos al mismo día/hora, overflow, días sin eventos, cambio de fecha al editar, cancelación mientras está seleccionado, entrada por ID desde Inicio/popup a otro mes, límites temporales y reloj local/UTC. Mantener pruebas de permisos, cupos, suplentes, inscripción/baja, replicación y tombstones; adaptar únicamente pruebas que dependen de la estructura anterior de dos scrolls y la captura del diagnóstico. Validación visual y de sincronización real en Forever seguirá siendo necesaria.

Conclusión: viable por la separación actual entre registros/operaciones y render. No equivale a una implementación comprobada ni permite garantizar cero regresiones antes de probarla. No se modifica código, paquete, instalación o datos en este análisis.

## Implementación autorizada: calendario mensual — 24/11/2026

El usuario aprueba implementar el layout mensual y aclara que cambia la presentación de los datos, no la lógica de eventos. Autoriza mostrar vencidos en modo consulta, con indicación de vencimiento y listado de inscritos, sin campos/acciones de edición, inscripción o invitación. El texto del evento debe permanecer contenido en su día.

Contrato: cuadrícula mensual de siete columnas y seis semanas, mes/año y navegación fija, día seleccionado y eventos identificados por el ID existente. Resúmenes de hora/título contenidos mediante ancho/alto y límite de líneas; exceso accesible desde el selector del día sin perder eventos. Detalle lateral independiente con las funciones existentes para futuros; vencidos solo lectura, incluidos los nombres conservados de inscritos aunque ya no estén en el roster. La consulta se limita a los registros aún guardados; no cambia el historial de 30 días, purgas, permisos, paquetes o inscripciones.

Verificación horaria del código: openEditor usa date local para mostrar fecha/hora; parseDate convierte mediante time(tabla) y valida round-trip date local. saveEvent almacena/transmite el número when sin convertirlo a texto local. Cada cliente vuelve a formatear when con date local; announceEvent usa date con ! para UTC. La cuadrícula agrupará con el mismo date local y el día puede variar entre zonas horarias para un mismo instante. No se cambia esa mecánica; la correspondencia con el reloj real de cada país depende del cliente/configuración y no se afirma probada en Forever.

Plan: componente Calendar.lua con calendario gregoriano y agrupación local; integrar la vista y reutilizar formulario/detalle/operaciones existentes; proteger callbacks de navegación por contexto y registro vigente; conservar enlaces desde Inicio/avisos y al guardar; adaptar pruebas de la antigua lista a cuadrícula/overflow; probar meses/bisiestos/año, varios eventos, pasado/solo lectura/inscritos, cambios/cancelaciones, relojes locales simulados y regresiones de protocolo. No actualizar el juego.

### Implementación y evidencia — calendario mensual

- Calendar.lua: componente propio de presentación con calendario gregoriano de 42 celdas, agrupación de los mismos eventos por date local, navegación/selección, consulta de día y guardas de contexto. Usa fábricas visuales existentes; sin imágenes, APIs o datos del calendario nativo.
- UI.lua: sustituida la antigua lista lateral de 178 por panel mensual de 650 y detalle de 320, ventana de 1202x704 con la escala existente. Mes/días permanecen fuera del scroll; solo el detalle utiliza el scroll general. Texto en botón interior con ancho/alto y máximo de dos líneas, word wrap y tooltip completo. Exceso indicado por + N más y selector de todos los eventos del día, ordenados por hora/ID.
- Se conservan IDs; cambio de selección reinicia detalle, enlaces desde Inicio/avisos o creación abren el mes correspondiente. Cambio de when mueve la selección. Cancelar el seleccionado actualiza el detalle desde datos vigentes; controles obsoletos verifican contexto/registro/permiso al ejecutarse.
- Vencidos: etiqueta de solo lectura y listado de joined guardados, incluidos nombres de quienes ya salieron del roster, sin controles de edición, inscripción o menú de invitación. No se reconstruyen ni inventan estados históricos. La retención sigue bajo Core/Cleanup; mostrar vencidos no amplía historial ni permite reinscribirse.
- No se modifica openEditor/parseDate/announceEvent: el formulario conserva sus valores iniciales y conversión local. La nueva vista usa el mismo date local para el día; UTC se mantiene en anuncio. El cliente/configuración determina la zona local, no una detección de país del addon.
- TOC añade Calendar.lua antes de UI.lua. Diagnóstico adapta el paso/calendar.select y snapshots a mes/año/día; día vacío no equivale a haber seleccionado un evento. No se añaden locals principales al archivo UI.
- tests/ui.lua adapta las aserciones del antiguo scroll de lista a cuadrícula fija/detalle independiente y conserva acciones de invitación/permisos. diagnostics_ui.lua usa selección por el ID en el componente; diagnostics_capture.lua adapta los datos de selección sin quitar su condición de evidencia.
- tests/calendar_month.lua: meses completos y alineación contra os.date para 1999/2000/2024/2026/2027/2100, febrero de 1900/2000/2024/2100, seis semanas, diciembre/enero, resúmenes interiores, exceso y selección de evento a misma hora, vencidos sin botones con exmiembro y baja excluida, guardas existentes, edición de fecha/cancelación, acceso desde Inicio, permiso retirado y contexto.
- Prueba de horario por el editor real: reloj local simulado UTC-5, Crear y anunciar, captura del paquete E con when original y texto UTC; luego reloj UTC+1 muestra el mismo instante a las 01:30 y en otro día local. No se probaron dos clientes Forever reales.
- Ajustes del montaje: os.time de Windows no genera fechas anteriores al epoch para contraste con os.date; comparación nativa se hace desde 1999 y el caso bisiesto 1900 se comprueba con días esperados del modelo. Tras restaurar un rango se refresca la vista de prueba antes de volver a pulsar Nuevo evento.
- Evidencia de preservación previa al nuevo paquete: validado SHA256 del ZIP anterior `747a0f2622c8ba497a9019f98cdb06fd72baebcf9ed977265a228d9507514e38`; comparados byte por byte Core, Activities, Replication, Cleanup, GroupAttendance, Orders, Donations y Honor: idénticos. También idéntico el bloque futuro de detalle/acciones desde signups hasta el cierre de calendar().
- Pasaron Lua 5.1, XML, caracteres, todas las regresiones de UI/datos/replicación y 7 pruebas de paquete, con diff --check sin errores. No se certifican render real, legibilidad, APIs del cliente o sincronización real por pruebas simuladas.
- Implementación terminada localmente y en revisión; no se actualiza el juego ni se hace commit/push/release.

### Verificación real pendiente del calendario

1. Revisar escala/resolución, títulos largos y hover sin texto fuera del día; exceso y selección de todos los eventos, incluidos misma hora/día.
2. Crear/editar un evento futuro usando el formulario actual, cambiar fecha a otro mes y abrirlo desde Inicio/aviso; verificar inscritos, roles/suplentes, edición y eliminación autorizadas.
3. Consultar vencidos conservados, incluidos inscritos que dejaron la guild, y confirmar ausencia de controles de acción.
4. Con dos clientes en zonas locales diferentes, contrastar el mismo when con sus horas/días locales y el anuncio UTC; verificar que no cambia el instante del evento.
5. Confirmar sincronización con autor desconectado, copias compartidas y cancelaciones; diagnóstico debe registrar selección del mes/día/ID y viewport de detalle.

- Paquete local final del calendario: Tartaro-0.1.60.zip, 39 archivos, SHA256 `50c243e7bc511dd0b4eaf2a4b14d808857d499a4be7c055a7790710cf97e5d57`. Cambios sin commit; no release publicada ni instalación.

## Refactorización autorizada POO/DRY/SOLID — 24/11/2026

El usuario prioriza calidad del código y conservación íntegra de características, y solicita continuar sin warnings/errores. Alcance de esta pasada: componentes visuales con estado por instancia y ciclo de vida extensible; separar ventana/ejecutor de diagnóstico; unificar lectura de cupos y tamaño de mensajes; separar códigos de estado de textos; centralizar consultas de ofertas compartidas. Se preservan layout, IDs, permisos, paquetes, caducidad, reloj local/UTC, flujos y esquema persistido. Sin instalación en el juego.

Base de comparación: paquete local previo 0.1.60, SHA256 50c243e7bc511dd0b4eaf2a4b14d808857d499a4be7c055a7790710cf97e5d57. Regresiones Lua/XML/caracteres y 7 pruebas de paquete aprobadas antes de editar. La revisión simplify se ejecuta directamente, sin delegación, en reutilización, claridad, eficiencia y alcance.

Plan: extraer componentes reutilizados con factories/contexto estrechos y registro de partes ocultables; mantener renderizadores específicos; separar DiagnosticsView mediante contrato de lectura/acciones; unificar las duplicaciones verificadas; probar aislamiento de instancias, ciclo de vida sin conocer tipos, foco, textos, estados, ofertas, límites y toda la suite; revisar warnings reales y empaquetar. No se introduce herencia ni un framework general. No se promete ausencia de errores del cliente sin ejecutarlo; cualquier pendiente real se registra.

### Cambios implementados y revisión de diseño

- **UIComponents.lua (nuevo), UI.lua:** el objeto de presentación conserva sus pools, contador, padre y layout por instancia; recibe factories y contenedores explícitos, sin acceder a A.db. Filas, texto, botones, checks, celdas, tarjetas y grid comparten ese ciclo de vida. Attach registra partes ocultables: agregar un menú o detalle no requiere modificar una lista de tipos en el reciclador. Las acciones siguen en sus renderizadores. Grid devuelve la posición de foco; el componente ya no conoce selectedOrder/pendingOrderScroll.
- **DiagnosticsView.lua (nuevo), Diagnostics.lua:** ventana y controles dependen únicamente de state/report/record/start y factories visuales. El ejecutor conserva captura, validación, persistencia y reglas; devuelve un estado de lectura sin exponer el informe mutable a la vista. Se mantienen nombres de frames, textos, controles, esquema 2 y build del diagnóstico.
- **UI.lua:** readEditorCaps comparte lectura y normalización entre validación anticipada y guardado. Conserva vacío, cero, error de cupos y valores existentes. No cambia la validación de negocio.
- **Core.lua:** una comprobación de bytes compartida por envío, replay y prevalidación del editor conserva exactamente el límite de 250 bytes. No cambian cola, fragmentos ni protocolo.
- **Orders.lua, UI.lua:** orderOfferSummary concentra consultas del filtro, Inicio y tarjeta. Devuelve miembros en una lista independiente para que ordenar la presentación no modifique ofertas guardadas. Conserva ofertas propias, exclusión de exmiembros y el comportamiento previo de valores falsos: una clave del roster seguía apareciendo en presentación, pero no contaba como oferta activa para el filtro. No se introduce una corrección silenciosa de esos datos.
- **Professions.lua, UI.lua:** la consulta devuelve estado y códigos scan/transfer/items; los mismos textos se resuelven en presentación. Conservados ready/empty, caducidad de transferencias y búsqueda con datos disponibles.
- **Tartaro.toc, tests/ui.lua:** orden de carga actualizado para ambas extracciones. Pruebas de componentes nuevas y contratos reforzados en order_visibility.lua/notices_professions.lua. Documentación propietaria actualizada.

POO se aplica mediante composición y estado privado por instancia; DRY en las duplicaciones verificadas. Responsabilidades de vista/ejecutor y datos/textos separadas; reciclador extensible sin conocer tipos; contratos estrechos y factories explícitos reducen dependencia de concreciones. No se añade jerarquía de herencia: Liskov no exige inventarla. No se certifica que cada módulo del addon cumpla íntegramente SOLID: el namespace A y acceso directo a A.db siguen existiendo en los módulos actuales; sustituir toda esa arquitectura excedería esta refactorización controlada.

Revisión simplify: se reutilizan componentes reales en varios renderizadores; se quita la dependencia del grid respecto a pedidos; se conservan pools y no se añaden timers/refrescos/envíos. No se afirma una mejora de rendimiento medida. El resumen de ofertas recorre sus datos y crea una lista: centraliza semántica, no constituye una optimización demostrada. No se añaden frameworks, funcionalidades, migraciones ni configuración.

### Verificación y entrega local

- Comparación contra ZIP anterior: cambios de Core/Orders/Professions limitados a las extracciones descritas; revisadas diferencias completas de UI y Diagnostics. Calendario, operaciones de eventos, permisos, replicación, donaciones y audio no se modifican en esta pasada. Textos y acciones de la vista de diagnóstico se conservan.
- `python -B tests/run_local.py`: compilación de todos los Lua con Lua 5.1, XML, caracteres y regresiones aprobadas. Incluye pedidos/ofertas/cierre/reload, retransmisión, calendario/horarios, profesiones, tarjetas, tablas, acciones, audio y captura de errores. Los errores inyectados deliberadamente en pruebas de diagnóstico son evidencia del manejo probado, no errores no resueltos de la ejecución.
- `python -B tests/test_package.py`: siete pruebas aprobadas. `git diff --check`: sin incidencias. Las comprobaciones terminaron sin errores ni advertencias emitidos. Luacheck/selene no disponibles en PATH; no se declara lint con herramientas ausentes ni ausencia absoluta de fallos en un cliente que no se ejecutó.
- `python -B tools/package_addon.py --build`: ZIP contrastado byte a byte con 41 archivos de la carpeta instalable y TOC validado. Paquete **Tartaro-0.1.60.zip**, SHA256 **049064f5ac8acc67e4d20acd45982ae8ececab0c51d817cfc1dacd1fd5483cba**.
- Código de esta pasada y pruebas locales terminados; pendiente aceptación y validación real de render, escalas, audio y sincronización entre clientes Forever. No se actualiza el juego, no se cambia versión declarada, no se hace commit/push ni publicación.

## Instalación autorizada para pruebas — 24/11/2026

El usuario solicita instalar la candidata actual en el juego. Copiados los 41 archivos desde Tartaro/ a C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Tartaro. Verificados conteo exacto, ausencia de archivos adicionales y coincidencia SHA256 de cada archivo con la fuente previamente contrastada contra el ZIP 049064f5ac8acc67e4d20acd45982ae8ececab0c51d817cfc1dacd1fd5483cba. Versión declarada 0.1.60; candidata local de codex/mejoras-diseno-menu, no nueva release. Sin backups, eliminación de archivos, cambios a SavedVariables, commit ni push. Pendiente reiniciar cliente y comprobación real del usuario; no se declara carga ni ejecución verificada dentro de Forever.


## Retirada autorizada de pruebas externas — 24/11/2026

El usuario ordena eliminar las pruebas/simuladores externos. Eliminados los 20 programas Lua/Python bajo tests/, incluidos run_local.py, startup/startup_wiring y test_package.py. Eliminado su informe Temporary/load-debug/latest.json. Rutas absolutas verificadas dentro de la carpeta del proyecto antes de eliminar; sin borrar versiones, backups, código del addon ni registros del cliente.

Conservados tres Markdown de tests como documentación, marcados según su carácter histórico. AGENTS y maestro ya no ordenan ejecutar archivos eliminados. DEPURACION-CARGA distingue el ejecutor externo retirado del registro pasivo dentro del addon. El diagnóstico y LoadTrace se conservan; su instrumentación no cubre todas las funciones ni implica ausencia de errores. No se implementó nueva arquitectura ni se añadieron simulaciones sustitutas.

Verificación posterior: compilación de sintaxis de 21 Lua con biblioteca Lua 5.1, XML, caracteres y ausencia de programas bajo tests. Sin ejecutar código del addon ni APIs simuladas. tools/package_addon.py verifica el ZIP existente contra los 42 archivos reales: SHA256 8b3a00520c892b33be41c31066c3b87b0cbbc9d34d686ff8c6b428d4e7b31c59. Fuente instalable sin cambios en esta retirada; no se copia de nuevo al juego, no se controla el cliente, no se modifican SavedVariables, no hay commit/push.


## Ampliación autorizada: trazabilidad de ejecución y apagado — 24/11/2026

El usuario exige implementar trazabilidad dentro del addon y pregunta expresamente si puede apagarse fuera de desarrollo. Se amplía LoadTrace.lua, sin recuperar simulaciones ni controlar el cliente. Candidata base 0.1.60 de codex/mejoras-diseno-menu; cambios sin commit.

- A.traceCallback instrumenta 574 funciones propias de los 20 módulos posteriores al registrador, incluidas funciones privadas, validadores, métodos y callbacks. Se conservan cuerpos, argumentos, self y retornos múltiples/nil; los errores de negocio no se capturan en este adaptador. Se añaden dos adaptadores para las referencias nativas de arrastre.
- A.debugPcall conserva las 25 llamadas protegidas existentes y registra sus errores atrapados con origen. No crea validaciones ficticias ni transforma fallos en éxito. Los errores normales se capturan durante la sesión debug, no solo antes de login, y se reenvían intactos al manejador previo. Un fallo del capturador se cuenta en captureFailures y no impide ese reenvío.
- Registros explícitos adicionales: ventanas mostradas/ocultas, vistas solicitadas/bloqueadas, observaciones de UI aunque la guía manual no esté activa, recepción de paquetes, canal bloqueado, resultado del transporte y resultado de las comprobaciones manuales existentes. No hay envíos, invitaciones o acciones de prueba automáticas.
- /tartarodebug on activa y guarda debugMode/debugLoad=true; off registra la desactivación, guarda ambos false y suspende un diagnóstico activo; sin parámetros informa estado. No borra logs previos. Un diagnóstico manual posterior requiere una acción explícita del usuario y conserva su funcionamiento. La candidata usa developmentBuild=true; publicación deberá usar false como valor predeterminado, respetando la elección guardada.
- Debug apagado: delegación a cuerpos originales sin resumir argumentos ni escribir entradas nuevas; captura de debug inactiva y errores normales reenviados. La instrumentación permanece, por lo que no se afirma coste cero. Hay buffer transitorio de arranque antes de conocer SavedVariables; no se adjunta si la preferencia guardada está apagada.
- debugTrace: anillo de 1.000 entradas recientes con secuencia/tiempos, pares entrada/retorno, contadores y últimos registros por operación, 30 errores aparte y contadores de reemplazos. Los argumentos/tablas son resúmenes acotados y no un volcado integral. Persistencia normal de SavedVariables, sin escritura arbitraria ni transmisión de logs. Contrato detallado: DEPURACION-CARGA.md.

Verificación sin simulaciones: auditoría léxica de cobertura, compilación de los 21 Lua mediante Lua 5.1, XML y caracteres, diff --check y comparación del ZIP con los 42 archivos reales. La comparación inversa de la instrumentación inicial verificó cuerpos originales en 18 módulos y mostró únicamente los registros manuales de transporte/diagnóstico en Core/Diagnostics; después se agregaron explícitamente visibilidad y observaciones de UI. El registrador se excluye de instrumentarse a sí mismo. No se ejecutó el addon ni se certifica funcionamiento real del comando o coste en Forever.

Paquete preparado: Tartaro-0.1.60.zip, 42 archivos, SHA256 0f8eda873f2f93442070fe2105e0eb8e18efb7b7a239af4b418f98e8268b48a4. Ampliación no instalada ni publicada; la copia del juego conserva 8b3a0052. Pendiente ejecución manual real por el usuario. No hay commit/push ni interacción con el cliente.


## Instalación solicitada y debug apagado por defecto — 24/11/2026

El usuario solicita instalar el addon y previamente exige debug apagado por defecto y no preparar ZIP. LoadTrace.lua usa developmentBuild=false; sin elección explícita guardada no activa el registro de ejecución. Las opciones on/off explícitas conservan su precedencia. No se editan SavedVariables del usuario.

Copiados 42 archivos desde Tartaro/ a C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Tartaro. Coincidencia SHA256 verificada para cada archivo y conteo exacto sin archivos adicionales. Lua 5.1 (21 archivos), XML, caracteres, TOC, recursos y diff --check correctos. Solo se compila sintaxis y valida archivos reales; no se ejecuta el addon ni APIs simuladas. No se genera ni actualiza ZIP; los paquetes anteriores son históricos y no representan esta fuente. Actualizados contrato y documentación del valor predeterminado. Sin backups, control del cliente, cambios a SavedVariables, commit o push. Pendiente comprobación real de carga y uso.


## Filtro adicional autorizado: receta conocida — 24/11/2026

El usuario aclara que deben conservarse los filtros actuales y agregar la condición faltante de conocer la receta. Orders.listVisibleOrders mantiene owner==self y oferta propia como ramas independientes. A la rama sin ofertas de miembros actuales se añade knowsRecipe(self, order.spell). No se incorpora un filtro global que oculte pedidos propios o compromisos existentes. Se usa la consulta de conocimiento ya implementada, que admite recetas con itemID 0 y depende del perfil de profesiones guardado por el addon.

Diagnostics actualiza su cálculo esperado y la guía de Pedidos a la misma condición para evitar informar una inconsistencia ficticia. LEEME actualizado. Se verificó que refreshProfessions sin detail invalida Pedidos, por lo que la llegada/lectura de datos de profesiones vuelve a evaluar la visibilidad. Los registros y la lista completa usada para sincronización permanecen intactos; cierre, caducidad, ofertas e historial no cambian.

Verificación estática: ambos Lua modificados compilan con Lua 5.1 y pasan caracteres; TOC y recursos reales válidos; diff --check sin incidencias. Sin pruebas/simulaciones, ejecución del cliente, ZIP ni instalación. Criterios manuales pendientes: disponible con receta conocida aparece; disponible sin receta conocida se oculta; propio y oferta propia permanecen visibles; oferta ajena sigue ocultando; una actualización de profesiones refresca la lista. El cambio está solo en el proyecto y requiere copiarlo cuando el usuario lo solicite.


## Diseño autorizado: botón Llamado a las armas — 24/11/2026

El usuario aporta la imagen del launcher claro actual y solicita una estética acorde al juego, conservando texto, sin sustituirlo por un icono plano tipo toon. Se descarta la propuesta inicial de usar las espadas como protagonista. Aplicada skill frontend-design al criterio visual; no se controla el cliente ni se genera una imagen de supuesto render real.

UI.lua reemplaza solo la construcción visual del launcher: copperButton de 148x25 con estilo primario plano pasa a UIPanelButtonTemplate de 208x42. Etiqueta explícita GameFontNormalLarge, centrada, ancho 184 y una línea, con sombra negra. Marco decorativo no interactivo con BackdropTemplate y UI-DialogBox-Border, edgeSize 16 y tinte 0.85/0.66/0.34. Se usan recursos nativos ya referenciados por addons asociados (AceGUI y Aegis), sin añadir TGA ni dependencias. Los estados normales/pulsado/hover proceden de la plantilla nativa. El marco no intercepta el mouse.

Conservados literalmente texto, ResetPosition, parent Minimap, visibilidad por A.can(call), arrastre/guardado de centro normalizado, clic/confirmación y envío. Se elimina únicamente la aplicación del estilo plano de copperButton a este launcher. No se alteran otros botones, permisos, sonido ni comportamiento del llamado. Ajustadas etiquetas de origen de la trazabilidad a las líneas actuales.

Comprobación estática: UI.lua compila en Lua 5.1 y pasa caracteres; TOC y recursos propios válidos; diff --check correcto. No se recrean simulaciones ni se ejecuta/inspecciona el juego. El recurso nativo no puede validarse visualmente con el verificador de archivos propios. Pendientes render real, legibilidad y espacio alrededor de la posición guardada con el mayor tamaño. Implementación local en revisión; sin instalación, ZIP, commit/push ni publicación.


## Instalación solicitada: filtro adicional y botón nativo — 24/11/2026

Copiados los 42 archivos de la fuente a C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Tartaro, versión declarada 0.1.60. Verificados todos por SHA256, conteo exacto y ausencia de archivos adicionales. Incluye filtro de receta conocida, diagnóstico ajustado y diseño nativo del botón Llamado a las armas. Debug permanece apagado por defecto; no se modifican preferencias guardadas.

Antes de copiar: sintaxis de 21 Lua mediante Lua 5.1, XML, caracteres, TOC y recursos propios correctos. Sin ejecutar el addon ni simulaciones; no se valida aquí el render nativo del cliente. SHA256 de UI.lua: 5bc2afd7e5a353d03283d3cfb2703ddb70e02edd587c11e40ed8f34cb7ffd96b; Orders.lua: a739773f358604bb8fb45505ac42ee6f6e26532f10738a840450e0486ddd6f82. Sin ZIP, backups, cambios a SavedVariables, control del juego, commit/push ni publicación. Pendiente prueba real del usuario.


## Control de tamaño en vivo y texto con espadas — 24/11/2026

El usuario solicita controlar en Opciones el tamaño del botón y todo su contenido en tiempo real; añade el texto exacto Llamado a las Armas y un icono de espadas cruzadas al inicio y al final, separados del texto por un espacio.

UI.lua añade un slider en la zona superior derecha libre de Opciones (x=334/336), rango 50-150, paso 5 y lectura porcentual. A.callLauncherSize normaliza la preferencia con valor predeterminado 100; A.setCallLauncherSize guarda el porcentaje, usa SetScale en TartaroCallLauncher y reaplica el centro normalizado existente cuando hay posición guardada. El control solo modifica ese launcher, sin alterar escala de ventana/minimapa u otros controles. Texto, marco, fondo e iconos heredan la escala del padre. La sincronización de Opciones actualiza lectura/slider; el evento de login reutiliza el setter; Restablecer configuración elimina la preferencia y aplica 100 antes de restaurar la posición predeterminada.

El tamaño base pasa de 208x42 a 252x42 y el ancho de etiqueta de 184 a 228 para alojar los dos iconos de 18 mediante textura inline CallSwords existente. Texto visible exacto Llamado a las Armas y un espacio entre cada icono y el texto. No se añade imagen ni dependencia. Las funciones/callbacks nuevos usan la trazabilidad existente (577 cuerpos propios tras esta ampliación), con evento appearance.scale que registra porcentaje y GetScale real. El diagnóstico comprueba rango/paso del valor guardado sin modificarlo.

Cableado revisado: getter definido al construir Opciones; setter definido antes de callbacks de login/apertura de opciones; OnValueChanged invoca setter sin volver a modificar el slider, evitando recursión; callbacks de arrastre y permisos se conservan. El setter no muestra el botón ni altera su autorización. Las coordenadas guardadas se reaplican con la escala efectiva actual; sin posición guardada conserva el anclaje al minimapa.

Verificado sintácticamente en Lua 5.1 (21 archivos), XML, caracteres, TOC, recurso real CallSwords y diff --check. No se ejecuta el cliente ni se recrean simulaciones; no se certifica el render nativo. Pendientes comprobación manual al 50/100/150%, ajuste en vivo de todo el contenido, persistencia entre sesiones, centro al redimensionar y arrastrar, restablecimiento y legibilidad/espaciado. Cambio solo local; sin instalación, ZIP, commit/push o publicación.


## Instalación solicitada: escala e iconos del launcher — 24/11/2026

Instalada la fuente local 0.1.60 en C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Tartaro. Los 42 archivos coinciden por SHA256; incluye control de tamaño en Opciones, persistencia/restablecimiento y texto Llamado a las Armas con espadas a ambos lados. Debug permanece apagado por defecto (preferencias explícitas guardadas sin modificar).

Verificados antes de copiar: sintaxis de 21 Lua con Lua 5.1, XML, caracteres, TOC y recursos propios. Sin simulaciones ni ejecución del addon. UI.lua SHA256 fa199d2a5a52bfe21b2339037e2b5f625550ada575b4fcac215060ee3706a5bd; Diagnostics.lua 15f304591f1f821926948b0f24af0f1261602486363506942294904996453bec. LEEME sincronizado tras quitar la indicación obsoleta de instalación pendiente. Sin ZIP, backups, control del cliente, cambios a SavedVariables, commit/push ni publicación. Pendiente comprobación visual y funcional manual del usuario.


## Cierre de desarrollo y propuesta 0.2.0 — 24/11/2026

El usuario concluye el desarrollo de la sesión, solicita commit local con detalle completo, publicación de codex/mejoras-diseno-menu y PR hacia main, y prohíbe expresamente el merge sin nueva autorización. Confirma 0.2.0 como identificador de la propuesta; se actualizan TOC, LEEME y CHANGELOG. CAMBIOS-0.2.0.md reúne el estado final por área, código compartido, trazabilidad, evidencia y límites.

Tras mostrar la ventana de pruebas de la copia instalada, el usuario confirma retirar también la ventana, sus botones y el ejecutor interno, manteniendo únicamente los logs. Se eliminan Diagnostics.lua y DiagnosticsView.lua de la fuente y TOC, y su entrada del manifiesto de carga. UI envía sus observaciones directamente a debugLog; desaparecen llamadas a A.diagnostics, pasos guiados, consultas automáticas e informes de prueba. Se conserva registro de vistas, filas, tooltips, orden y operaciones con datos reales, sin simular acciones. Los informes viejos en SavedVariables no se borran; el código nuevo no los usa. La instalación anterior 0.1.60 no se altera durante esta preparación.

Estado final: 19 Lua, 40 archivos instalables, 530 funciones instrumentadas y 21 llamadas protegidas registradas. Tres documentos Markdown permanecen en tests y no quedan programas en esa carpeta. El historial de Git conserva código eliminado previamente versionado; eliminarlo del árbol actual no reescribe el historial. No hay ZIP, tag, release, CurseForge ni autorización de merge.

Verificación final de la propuesta: 19 Lua compilados con Lua 5.1, XML/caracteres/TOC/recursos correctos, 40 archivos instalables, cobertura estructural de 530 funciones y 21 llamadas protegidas, tests con solo tres Markdown y ausencia de dependencias ejecutables de Diagnostics. diff --check correcto. No se ejecutó el addon, simulaciones ni cliente. Se revisaron los archivos a publicar para excluir temporales, ZIP, informes locales y patrones de credenciales examinados.


## Tarjeta del evento y sustitución autorizada del commit — 24/11/2026

El propietario confirma que la diferencia de hora observada correspondía a otro evento seleccionado y solicita corregir el diseño del detalle. Se reutiliza UIComponents.Card, con espacio interior y título ampliado. Fecha, hora local y tipo quedan separados; descripción, cupos e inscritos se agrupan antes de las acciones. UIComponents.Line admite fuente opcional y restablece la fuente normal en cada fila reutilizada para no arrastrar el tamaño del título a otras vistas.

Se conservan las condiciones de inscripción, cambio de rol, baja, edición y acciones sobre participantes; los vencidos siguen sin controles. No cambian fechas almacenadas, anuncios UTC, agrupación local ni selección por clic. No se instala ni se interactúa con el juego. Verificación estática: compilación Lua 5.1, XML, caracteres, TOC y recursos; pendiente revisión visual y funcional en Forever, sin simulaciones ni afirmación de E2E.

Autorizada la sustitución del commit local y remoto de la propuesta 0.2.0 manteniendo el mensaje original byte por byte. El push usa force-with-lease contra el SHA previamente observado de la rama de mejoras. El título y cuerpo originales del PR #15 se conservan; no se modifica main ni se ejecuta merge o auto-merge.

## Presencia de Tártaro en Miembros — 25/11/2026

Base main/44aa65e (0.2.0). El propietario autoriza mejorar la detección y ordena expresamente no realizar commit al terminar porque continuará con otros cambios. Posteriormente confirma 0.2.1 para esta revisión local; se actualizan TOC, LEEME y CHANGELOG. Implementación local sin commit, publicación ni instalación.

Core.addonPresence devuelve un estado único para consumo de UI: Activo si el personaje está conectado y hay mensaje reconocido recibido hace menos de 150 segundos en esta sesión; Sin confirmar si está conectado y tiene detección histórica sin confirmación reciente; Histórico si tiene detección guardada sin conexión confirmada; Sin detectar si no existe registro. El personaje local conectado está activo por ejecución del propio addon. La conexión sigue dependiendo del roster de WoW y no se deduce del silencio de red.

addonSeen conserva la fecha recibida mediante GetServerTime. sessionSeen guarda GetTime solo en memoria, sin migración ni cambio de SavedVariables o protocolo. No hereda actividad de la ejecución anterior. Los cambios de hermandad y las desconexiones observadas invalidan confirmaciones; el histórico no se borra. La recepción directa de cualquier acción reconocida renueva la confirmación, con registro presence.changed al cambiar el estado. No se replican detecciones de terceros ni se afirma poder certificar una instalación actual.

Se reutiliza Q cada 60 segundos como mensaje periódico ya existente. El umbral de 150 segundos permite dos intervalos más 30 segundos de margen, sin garantía sobre entrega o cola. No se agregan mensajes, temporizadores, dependencias ni consultas adicionales al servidor. El ticker existente de UI comprueba cada 5 segundos solo con Miembros visible y solicita refresco únicamente al detectar cambio de estado frente al último render; abrir la vista calcula el estado actual. Caducidad lógica a los 150 segundos, presentación en el siguiente ciclo de UI y su agrupación de 0,08 segundos, sujeta a ejecución del cliente.

La tabla conserva anchos, scroll, orden por conexión/nombre y opción de ordenar por detección histórica; verde queda reservado a Activo. Tooltip por fila con significado del estado y fecha/hora local del último mensaje; en la fila propia se identifica como registro local. El propio personaje no abre menú de acciones. Susurro/invitación mantienen las revalidaciones existentes. Se oculta el tooltip al salir, ocultar/reutilizar la fila o abrir su menú.

Verificación: compilación sintáctica de 19 Lua con Lua 5.1 sin ejecución del addon; XML, caracteres, TOC y recursos correctos; 40 archivos instalables, 535 funciones instrumentadas y 21 llamadas protegidas. Revisado el diff conservando condiciones de permisos y transporte. No hay tests ni simuladores recreados. La comprobación manual en Forever no se ejecutó por la prohibición de controlar el cliente.

Criterios manuales pendientes:

- Con dos miembros conectados, recibir un mensaje del segundo debe mostrar Activo y una fecha real de recepción; no requiere compartir ubicación. El otro cliente mantiene su propia observación independiente.
- Con el segundo conectado pero su addon sin emitir, dejar pasar 150 segundos: la tabla abierta debe pasar a Sin confirmar en el siguiente ciclo, sin cambiar Conectado ni borrar el último registro. Volver a recibir debe recuperar Activo.
- Cerrar/reabrir la vista tras la caducidad debe calcular el estado actual, sin conservar el texto anterior por caché.
- Tras observar desconexión: Desconectado e Histórico. Tras reconexión: no confirmar actividad hasta recibir un nuevo mensaje. Al reiniciar este cliente, los históricos remotos no pasan a Activo solo por cargar SavedVariables.
- Personaje nunca detectado: Sin detectar; ausencia de datos de conexión: Sin datos. Ningún caso debe afirmar desinstalación por silencio.
- Verificar legibilidad de las cuatro etiquetas, tooltip de fecha local, orden histórico en ambos sentidos y acciones de susurro/invitación. Cliente previo que emite Q/V/H debe seguir siendo detectado sin protocolo nuevo.

Los plazos son decisiones de implementación aún pendientes de medición en Forever; no son resultados de una prueba E2E.

## Avisos persistentes y tarjetas del día — 25/11/2026

El usuario ordena mantener este trabajo en main local, como parte de 0.2.1, sin commit ni push. Solicita mensaje del día una vez por día o cambio de contenido, eventos solo en su fecha y un recordatorio adicional. Confirma explícitamente que el recordatorio puede aparecer hasta 30 minutos después del inicio. No hay duración en el modelo y no se añade: esa cifra define solo la ventana de aviso. Reitera que los mensajes no deben aparecer en combate, mazmorra ni banda.

UI.lua mantiene notificationHistory por personaje dentro de la base de hermandad, con día local, último texto diario presentado y recibos de eventos del día. La visualización efectiva marca el recibo; no depende de cerrar la ventana y no se reinicia por /reload. El texto se compara por contenido, sin depender de la revisión del mensaje. Cambios A → B → A permiten volver a mostrarlo; vaciarlo no muestra popup y permite que un texto posterior vuelva a considerarse cambiado. La tabla diaria de eventos se renueva al cambiar de día, sin acumular días ilimitadamente.

El aviso diario conserva el público anterior de eventos pendientes de inscripción, pero se limita a eventos de hoy que todavía no comenzaron. La ventana de recordatorio incluye desde 30 minutos antes hasta 30 después para todos, inscritos o no. Si el primer acceso es dentro de esa ventana, el recordatorio consume también el aviso diario para evitar dos popups consecutivos del mismo evento. Se conserva eventReminders por horario, compatible con los registros previos y sin repetición del mismo recordatorio al cruzar medianoche. Si cambian el horario se revalida la cola; no se repite el recordatorio de ese evento dentro del mismo día si ya se mostró.

Se reutiliza el ticker de avisos de 5 segundos para detectar ventana de recordatorio y cambio de día. La cola descarta avisos cuyo evento desapareció, cambió de horario o salió de la ventana. Al empezar, el texto cambia de Empieza en a Comenzó hace; no afirma que el evento siga en curso. El historial de eventos vencidos y las reglas para inscribirse siguen sin cambios.

Popups diarios y de eventos y resumen de chat bloqueados por combate real y tipos de instancia party/raid, independientemente de hideWindowsInCombat para el resto de ventanas. Se añaden PLAYER_ENTERING_WORLD y ZONE_CHANGED_NEW_AREA al observador existente de UI, sin reemplazar los eventos de combate. Se ocultan los avisos al entrar; los ya presentados siguen consumidos y no se reabren al salir. Lo no mostrado queda pendiente y no se consume dentro del bloqueo. Al salir se reevalúa; un evento que ya pasó la ventana no se anuncia tarde. El mensaje diario que ya había sido mostrado no se repite solo por salir de combate. Las reglas específicas de llamados y la visibilidad de otras ventanas se conservan.

El resumen de chat usa print, no SendChatMessage: una línea por ID de evento de hoy y carga, en orden de hora, con hora local y título; incorpora registros que lleguen después por sincronización. No lista fechas futuras ni repite cada tick. Si la carga es dentro de un bloqueo, queda sin consumir hasta salir. Un día nuevo permite listar los eventos de ese día. No reinicia los recibos de popups ni modifica los anuncios manuales al crear eventos, que conservan UTC.

Calendario reutiliza Calendar.group, ya ordenado por hora/ID, y renderiza todas las tarjetas del día, eliminando el selector. Día/conteo permanecen en la cabecera fija del componente existente, con el scroll aplicado solo al contenido de tarjetas y la cuadrícula inmóvil. Selección en la cuadrícula y navegación desde Inicio/aviso/guardado llevan la tarjeta correspondiente a la vista. UI guarda ese estado en el marco calendarPanel. RenderEvent mantiene literalmente el cuerpo de la tarjeta previa, salvo índice, resaltado y registro de posición: comparación estática de texto normalizado correcta para contenido, acciones, callbacks y permisos. Cada cierre usa el parámetro de su propio evento, sin reutilizar el seleccionado global como destinatario.

La compilación detectó el límite de 200 variables locales de Lua 5.1 en UI.lua. Resuelto agrupando estado de notificaciones y almacenando el estado de presentación en el marco existente. No se añade módulo ni dependencia. La compilación posterior fue correcta. Las etiquetas de trazabilidad se ajustan a sus líneas actuales; notification.shown registra día, ID/horario y tipo al presentar un aviso. Debug sigue apagado por defecto.

Verificación estática: 19 Lua compilados con Lua 5.1, XML/caracteres/TOC/recursos, versión 0.2.1 y 40 archivos instalables. Se conservan 535 funciones instrumentadas y 21 llamadas protegidas. Diff sin problemas de espacios. No se ejecuta el addon, simulaciones o pruebas de APIs inventadas; tests conserva únicamente los tres documentos previos. No se instala, publica ni crea commit o ZIP.

Criterios de comprobación manual pendientes en Forever:

- Cerrar mensaje diario y usar /reload: no repetirlo; cambiar contenido y día local: permitir un nuevo aviso. Repetir con dos personajes para comprobar registros independientes.
- Evento para hoy a más de 30 minutos: aviso diario una vez si no está inscrito. Evento de otro día: sin popup diario. Inscrito: conserva ausencia del aviso de inscripción pendiente, pero recibe recordatorio.
- En -30 minutos: un recordatorio adicional; cerrar y recargar sin repetir. Entrar por primera vez en -15, +0 o +20 minutos: solo recordatorio. Más de +30: ninguno. Revisar medianoche, cambio de horario y eliminación con avisos en cola.
- Combate con la preferencia general en ambos estados, mazmorra y banda: no mostrar popups ni resumen de chat. Salir durante una ventana vigente permite pendientes; salir después no ofrece recordatorios caducados. Un aviso ya mostrado no vuelve a abrirse al salir.
- Chat: una línea por evento de hoy por carga, también eventos ya comenzados o inscritos; nunca envío a la guild ni repetición por tick. Registros recibidos después se listan una vez. Entrada bloqueada difiere las líneas hasta salir.
- Día con cero, uno y varios eventos: todas las tarjetas ordenadas; solo el cuerpo lateral se desplaza, fecha y cuadrícula fijas. Pulsar segundo evento y abrirlo desde Inicio o aviso enfoca su tarjeta. Comprobar inscripción/cambio/baja/edición en su evento correcto, permisos y vencidos de solo lectura con inscritos.

Ningún criterio manual anterior se declara ejecutado. Implementación en revisión pendiente de uso real; se mantienen los cambios locales previos de presencia.


## Extensión del bloqueo de avisos a BG y arenas — 25/11/2026

Por autorización expresa, daily.NotificationsBlocked incluye IsInInstance con tipos pvp y arena, además de party/raid y combate. El cambio se aplica mediante el guard compartido a los popups diarios y de eventos, resumen local de chat y ocultación al cambiar de zona. Se conservan las ventanas temporales, los recibos persistentes y las reglas de avisos pendientes. No cambia los llamados ni las demás ventanas. Main local 0.2.1, sin commit, push o instalación.

Verificación de sintaxis Lua 5.1 y recursos; pendiente comprobación manual dentro y fuera de BG/arenas, también sin combate. Debe impedir mostrar/consumir avisos pendientes dentro y reevaluarlos al salir si siguen vigentes. No se ejecutó el cliente ni simulaciones.


## Commit local e instalación autorizados — 25/11/2026

El usuario autoriza commit local en main de los cambios acumulados 0.2.1 y posterior copia a Forever para sus pruebas. Esta instrucción reemplaza la restricción temporal de no hacer commit; no autoriza push, merge remoto o publicación. Se conserva el historial de desarrollo anterior. Antes de copiar se comprueban sintaxis Lua 5.1, XML, caracteres, TOC/recursos y diff. La copia se verifica archivo por archivo con SHA256 y conteo exacto, sin interacción con el juego ni cambios a SavedVariables. No se crean backups o ZIP. El SHA del commit y resultado real de la instalación se registran después en el resumen de sesión del workspace; las pruebas dentro del cliente siguen pendientes del usuario.


## Anclaje opcional con emblema fijo — 25/11/2026

El usuario pide una casilla en Opciones, desmarcada por defecto, sin modificar el comportamiento predeterminado. Al activarla, la ventana debe conservar el centro horizontal y crecer hacia abajo manteniendo el emblema en su sitio; no se interpreta como mantener el centro geométrico de toda la ventana. Trabajo sobre main local/07155cd, versión 0.2.1 conservada, sin commit, push o instalación de esta revisión.

UI.lua añade centerWindowOnResize en SavedVariables solo al interactuar con el control; nil y false mantienen la ruta anterior de anclaje, escalado y posición de avisos. El control aparece debajo de la opción de combate y desplaza Restablecer configuración dentro del panel existente. sync restaura su estado visual; Restablecer elimina la preferencia y el estado transitorio.

CaptureResizeOrigin y ApplyResizeOrigin son métodos del marco principal, sin nuevas variables locales de nivel superior. Capturan el centro real de skullArt y lo convierten a unidades de UIParent mediante la escala efectiva. Al redimensionar se conserva ese punto, ajustando el anclaje TOP al desplazamiento del centro de la textura. El ajuste posterior de escala sigue respetando esa referencia. Se guarda el tipo de anclaje anterior para recuperarlo al desactivar, sin volver a coordenadas antiguas que provocarían un salto deliberado de posición.

El arrastre marca estado transitorio para que las actualizaciones de avisos no vuelvan a fijar el punto anterior mientras se mueve. Al terminar se captura la ubicación nueva y se normaliza TOP solo si está activa la preferencia. El arrastre del grupo de avisos actualiza la misma referencia. Con avisos visibles, el origen superior del grupo se calcula a partir del emblema para que el cambio de tamaño no lo desplace, conservando orden y ajuste de escala. Se mantienen las restricciones de pantalla: cerca de un borde, el clamp puede desplazar la ventana o el grupo para permitir su visualización. No se promete invariancia física cuando el conjunto no cabe.

Verificación estática: compilación de 19 Lua con Lua 5.1, XML, caracteres, TOC y recursos; 40 archivos instalables; 538 funciones instrumentadas, 21 llamadas protegidas; sin errores de diff. Se revisó la ruta por defecto para conservar las expresiones originales de colocación y para retornar de los métodos nuevos antes de alterar el marco cuando la preferencia no es true. No se ejecutó WoW, código del addon o simulaciones. No se recrearon tests.

Pendiente revisión manual: casilla inicial desmarcada; navegación Inicio/Buscar recetas/Calendario en ambos estados; crecimiento horizontal simétrico y hacia abajo con emblema fijo; arrastre libre y con avisos; comprobación tras cambios de escala efectiva/resolución; límites de pantalla; desactivar sin salto atribuible a restaurar coordenadas antiguas; persistencia de casilla por reload y Restablecer. Validar que el nuevo control y el botón de restablecimiento caben en Opciones y que los avisos conservan sus reglas de frecuencia y bloqueo.


## Instalación autorizada del anclaje opcional — 25/11/2026

El usuario solicita instalar la copia local con la casilla Mantener centro horizontal y crecer hacia abajo, expresamente sin commit ni push. Versión declarada conservada en 0.2.1 y base local 07155cd; cambios posteriores permanecen sin commit. Verificación previa de sintaxis Lua 5.1, XML, caracteres y TOC/recursos. La copia se comprueba por SHA256 archivo por archivo y conteo exacto; resultado real en el resumen de sesión del workspace. Sin controlar el juego, cambiar SavedVariables, generar ZIP o backups. La casilla queda desmarcada por defecto; activación y validación visual corresponden a las pruebas del usuario.


## Overlord y versiones por personaje en Miembros — 25/11/2026

El usuario solicita detectar Overlord, añadirlo como columna de Miembros y mostrar las versiones instaladas en el tooltip de Tártaro/Overlord. También solicita comprobar y aprovechar un mensaje automático al iniciar sesión o hacer /reload. Trabajo local sobre main/07155cd, conservando la opción de anclaje y versión 0.2.1. No se autoriza commit, push o instalación de esta revisión.

Evidencia previa: Core.refreshRoster ya llama shareVersion al reconocer hermandad; replay también la llama ante Q; PLAYER_LOGIN solicita datos y programa request a los 5 segundos y cada 60 segundos. Se amplía request para anunciar versión/estado de forma autónoma, sin depender de recibir una Q ajena ni de una acción manual. La cola existente deduplica paquetes idénticos; no se añade ticker ni mensaje visible de chat. Comunicación interna GUILD con prefijo TARTARO01, sujeta a validación de guild y bloqueos/reintentos de transporte existentes. Datos del personaje siguen obteniéndose del roster y del rol H ya implementado, sin duplicarlos en el paquete.

Version.lua consulta únicamente el addon local llamado Overlord: DoesAddOnExist, alternativa GetAddOnInfo, GetAddOnMetadata y IsAddOnLoaded, más GetAddOnEnableState si no está cargado. Se conserva compatibilidad con funciones globales antiguas y el orden de argumentos distinto de GetAddOnEnableState. Se distingue loadedOrLoading/loaded cuando IsAddOnLoaded devuelve dos valores; el primer valor se acepta solo si no existe el segundo. No se carga, habilita, modifica ni inspecciona la base privada de Overlord.

Firmas contrastadas con el código de documentación de Blizzard publicado en https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/AddOnsDocumentation.lua y usos instalados de C_AddOns.GetAddOnEnableState en AtlasLootClassic y BugGrabber. Esto no constituye validación ejecutada de las APIs dentro de Forever.

Formato ampliado V, separado por tabulaciones: acción, versión Tártaro, estado Overlord, versión Overlord. Estado enum L=cargado, D=desactivado, E=habilitado sin cargar, I=instalado con activación desconocida, N=no reconocido como instalado, U=sin consulta concluyente. El campo Overlord admite hasta 32 caracteres alfanuméricos/punto/guion/guion bajo; Tártaro mantiene el parser numérico existente. El paquete máximo con versión Tártaro de 11 caracteres ocupa 48 bytes, bajo el límite de 250. Los lectores anteriores usan solo el primer campo de versión; los emisores anteriores permiten guardar su versión Tártaro pero no generan un estado negativo ficticio de Overlord.

Core entrega el remitente validado a receiveVersion. memberAddons conserva por personaje versión Tártaro, estado/versión Overlord y fecha real de comprobación o recepción. No se aceptan identidades declaradas por terceros ni se retransmite un censo histórico. La confirmación por informe usa GetTime en memoria y el mismo límite de presencia de 150 segundos mediante addonPresence con instante opcional. Otros mensajes pueden renovar Tártaro pero no el informe de Overlord. El cambio de sesión/hermandad o una desconexión observada invalida la confirmación. El histórico persiste y no acredita estado actual.

Miembros incorpora una sexta columna de 110 unidades con estados legibles. Conserva las primeras cuatro columnas, amplía Tártaro y fija extremos 10/164/207/367/470/580/690; ancho de contenido 690 y ventana 892, sin cambiar el tamaño de otras áreas. Cabecera y controles siguen fijos y solo se desplazan filas. El orden histórico por detección Tártaro y los menús autorizados se conservan. El tooltip separa actividad Tártaro de carga Overlord, muestra ambas versiones y fechas y aclara lo local, lo comunicado y lo histórico. No instalado solo se muestra ante N vigente; falta de informe se presenta como Sin datos. Cargado no garantiza funcionamiento completo de Overlord.

El ticker de Miembros ya existente compara presencia y vigencia del informe para actualizar caducidad sin redibujar cada cinco segundos cuando no cambia el estado. La recepción registra addons.report e invalida la vista solo al cambiar campos o recuperar vigencia. Debug permanece apagado por defecto. La advertencia existente de versión nueva de Tártaro se conserva.

Verificación estática: compilación de 19 Lua con Lua 5.1, XML, caracteres, TOC/recursos y 40 archivos instalables. 542 funciones instrumentadas y 21 llamadas protegidas. Revisado el orden de carga Version antes de UI y antes de PLAYER_LOGIN; métodos definidos antes de su ejecución por eventos, y máximo de locales aceptado por el compilador. No se ejecutó el addon ni simulaciones, no se recrean tests y no se controla WoW.

Pendiente comprobación manual con dos miembros: anuncio sin interacción tras login/reload, arranque con roster pendiente, V periódico y recepción diferida; Overlord presente/cargado, desactivado, habilitado sin cargar y ausente; versión y fechas en ambas filas; cliente antiguo con Sin datos y versión Tártaro disponible; desconexión/reconexión, reload del observador y caducidad del informe mientras llegan otros mensajes. Comprobar columna, tooltip, orden, cabecera/scroll y susurro/invitación, así como anclaje opcional al ampliarse Miembros. Usuarios sin Tártaro compatible no pueden declarar sus addons mediante esta característica. No se promete un tiempo máximo de entrega de red.


## Reinstalación de archivos desde carpeta ausente — 25/11/2026

El usuario elimina la carpeta de Tártaro instalada y autoriza instalar desde cero los archivos actuales, incluida la columna Overlord y versiones. Se confirma que el destino Tartaro no existe antes de crearlo. Fuente 0.2.1 sobre main/07155cd con cambios posteriores sin commit; sin commit ni push de esta instalación. Comprobación previa correcta de 19 Lua con Lua 5.1, XML, caracteres, TOC y recursos. La copia se verifica por SHA256 y conteo exacto; resultados y hashes en el resumen de sesión del workspace. No se elimina ni modifica SavedVariables: instalación limpia de archivos, sin reiniciar datos guardados. Sin interacción con el cliente, ZIP o backups; validación en Forever pendiente del usuario.


## Acceso administrativo en el navegador — 25/11/2026

El usuario solicita que Miembros y Permisos no aparezcan en el menú sin autorización. Se utiliza la regla administrativa existente canManagePermissions: base de hermandad disponible y miembro de rango 0 o 1. No se define por cuenta propia una identidad de desarrollador ni se acepta debug como autorización. La optimización de retención/transporte no forma parte de esta corrección y no se asegura ningún ahorro de memoria cuantificado.

La tabla de pestañas declara el predicado existente para ambas áreas. Sus botones nacen ocultos cuando no hay autorización y el callback revalida antes de seleccionar la página. RefreshNavigation usa esa misma declaración para mostrarlas o excluirlas y recolocar solo las visibles a intervalos de 32, sin huecos. Al revocar acceso con una de esas páginas activa, pone Inicio, oculta filas y cabecera anteriores, cierra tooltip y restablece el scroll. A.refresh vuelve a filtrar antes de renderizar; ambos renderizadores administrativos retornan antes de construir contenido si no están autorizados.

A.invalidate actualiza navegación al recibir roster/permisos y conserva una marca navigation en el lote pendiente. Así el menú también se actualiza cuando Opciones está visible y la redirección fuerza el refresco de Inicio aunque no fuera una sección dependiente de permisos. Se utiliza el temporizador agrupado existente de 0,08 segundos, sin otro ticker ni cambios de red. Las acciones/tooltip de filas de Miembros comprueban administración nuevamente a través de currentMember; los cambios de grants conservan además la validación existente de Core.setGrant.

No se elimina A.members, A.ranks, db.grants ni informes históricos y no se altera su sincronización. Las otras pestañas mantienen orden y disponibilidad. La memoria no fue medida dentro de Forever; excluir entradas evita abrir esas vistas, pero no descarga el módulo UI ni garantiza ahorro de varios MB.

Verificación estática: Lua 5.1, XML/caracteres/TOC/recursos y diff. No se ejecutó el addon, simuladores ni cliente. Pendiente prueba manual: rangos 0/1 ven y utilizan ambas áreas; rangos restantes no ven entradas y el menú no tiene huecos; ganancia/pérdida de rango con Inicio, Opciones, Miembros o Permisos abiertos; revocación con tooltip o menú de miembro abierto; datos de guild pendientes/salida de guild; demás páginas sin cambios. Debug activado no debe conceder acceso. Main local 0.2.1 sin commit, push o instalación de esta revisión.

Instalación autorizada posterior — 25/11/2026: copiados los 40 archivos de Tartaro/ a C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Tartaro; versión declarada 0.2.1. Todos coinciden con la fuente por SHA256 y no hay archivos adicionales. UI.lua SHA256 B42E065F93EA29605438EC7DBD42BB2EAD32E42213BBC251079A04C378FAF03B. Sin borrar archivos, respaldos, ZIP, commit, push o interacción con WoW. Pendiente comprobación manual del usuario.

## Autorización administrativa de Dev — 25/11/2026

El usuario solicita identificar el número del rango Dev y añadirlo. Lectura sin ejecución de WTF/Account/ARCANISGK/SavedVariables/Tartaro.lua: Tartaro-pty contiene Dev como octava entrada implícita de grants (índice 8); otra guild guardada contiene Addon en ese índice. Core escribe grants por índice de rango y el roster establece rank/rankName. Se añade a canManagePermissions la conjunción rank == 8 y rankName == "Dev", conservando 0/1. No se usa nombre de personaje ni modo debug. La misma regla protege menú, contenido y acciones administrativas, setGrant, recepción de R y replay de grants. No se modifican otros permisos ni eventos. Datos persistidos no equivalen a consulta en vivo del roster. Clientes anteriores no aceptan al nuevo administrador hasta incorporar la política.

19 Lua compilados sin ejecución con Lua 5.1, XML, caracteres, TOC/recursos de 40 archivos y diff correctos. Pendiente prueba manual con Dev 8, otros rangos, cambio de rango/nombre y sincronización de permisos entre clientes actualizados. Sin commit, push ni instalación de esta ampliación; versión local 0.2.1.

Instalación posterior de acceso Dev autorizada el 25/11/2026: versión 0.2.1 copiada a C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Tartaro. 40 archivos coinciden por SHA256, sin extras; Core.lua SHA256 469530C8909BE59407129C2F272D75A883FE46788DAC6EC7DAC98A93243BAF52. HEAD conservado. Sin commit, push ni interacción con el cliente; pendiente prueba manual del usuario.

## Persistencia de la ventana principal — 25/11/2026

El usuario reporta pérdida de posición tras actualizar y autoriza corregirla. El código anterior conservaba resizeOrigin solo en memoria y aplicaba SetUserPlaced(false) en el modo centrado; no existía una posición propia de la ventana principal en TartaroDB. Lectura de archivos: centerWindowOnResize estaba activado y layout-local.txt de Arcanisgk-Pty no contenía TartaroWindow. No se reconstruye una ubicación anterior desconocida ni se atribuye borrado de configuración a la instalación: la copia anterior se limitó a los archivos del addon.

UI.lua incorpora SavePosition/RestorePosition sobre TartaroDB.windowPosition. Guarda el punto de anclaje, coordenadas normalizadas según escala/dimensiones de UIParent y coordenadas del centro del emblema. El modo predeterminado restaura el anclaje existente; el centrado restaura el emblema y mantiene el crecimiento horizontal simétrico/hacia abajo. Mantiene SetClampedToScreen y sus límites, que pueden desplazar una ventana para conservarla visible.

La restauración ocurre en PLAYER_LOGIN y se comprueba desde A.refresh; valida tipo de tabla, anclaje y números finitos. Si aún no hay dimensiones utilizables, permite reintento. Sin registro válido deja el posicionamiento disponible (predeterminado o del cliente), sin inventar una migración desde noticePosition. Guarda después de arrastre, OnHide, PLAYER_LOGOUT y cambio deliberado de la preferencia. Antes de apilar se guarda la ubicación independiente; durante el apilado no se sobreescriben sus coordenadas con las del conjunto temporal. Para el modo centrado se conserva la referencia de emblema estable; arrastrar el conjunto actualiza esa referencia. CaptureResizeOrigin evita recapturar una posición temporal apilada salvo movimiento explícito. Restablecer configuración limpia windowPosition junto con las opciones anteriores. No se añaden temporizadores, módulos o mensajes de red.

La autorización se limita al desarrollo local; no se instala, hace commit ni push. Versión conservada 0.2.1. Se mantienen las optimizaciones previas de filas y catálogo. No se modifican archivos WTF/SavedVariables desde fuera del cliente.

Verificación: compilación estática de los 19 Lua con Lua 5.1, XML, caracteres, TOC/recursos y 40 archivos; etiquetas numéricas de traza actualizadas, 552 funciones instrumentadas y 21 llamadas protegidas; diff revisado. Sin ejecución del addon, simuladores ni interacción con WoW. Pendiente revisión manual: mover y cerrar/reabrir; reload y cierre completo/reapertura; ambos modos, navegación entre tamaños, alternar preferencia con avisos presentes/ausentes, arrastrar el conjunto, ocultamiento/restauración por combate, reset y límites de pantalla. Sin posición propia previa, colocar la ventana una vez; no se puede restaurar una ubicación histórica no guardada.

Instalación posterior autorizada de la corrección de posición — 25/11/2026: versión 0.2.1 copiada a C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Tartaro. Los 40 archivos coinciden por SHA256 con la fuente y no hay archivos adicionales. UI.lua: 94BD12C47A5D0AA8C03E3F18A28DDC016552ABB116EA251536D910E1FB923F72. HEAD conservado; sin commit, push, ZIP, respaldos, borrados, modificación externa de SavedVariables o interacción con el cliente. Pendiente comprobación manual del usuario.


## Llamado desde el cadáver — 26/11/2026

Implementación local autorizada posterior a 84baf3c. Se retira únicamente el rechazo incondicional de fantasma; el origen pasa a la posición real del cadáver obtenida por C_DeathInfo.GetCorpseMapPosition. Vivo y muerto sin liberar conservan el flujo previo de posición del personaje.

Map.lua registra en memoria el contexto de PLAYER_DEAD (A.db, IsInInstance y mapa), lo limpia al resucitar o entrar vivo y exige el mismo contexto de hermandad. No persiste datos ni conserva coordenadas aproximadas al morir. La consulta intenta el mapa registrado y hasta tres padres, con detección de ciclos y validación numérica/no secreta; acepta el vector de la API y el retorno de dos números contemplado por ForeverDungeonJournal instalado. Errores de consultas se capturan mediante debugPcall; no hay sustitución por fantasma/cementerio. No se añade dependencia de esos addons.

La confirmación muestra «la ubicación de tu cadáver» seguida de zona/coordenadas. Al aceptar se revalidan permisos e instancia y se rechaza un cambio entre vivo/fantasma. Para cadáver se vuelve a consultar y se compara mapa/coordenadas con la precisión existente de transmisión (cinco decimales): un destino diferente exige abrir otra confirmación. CTA, recepción, sonido, chat, marcador, cooldown de 30 segundos y duración de 300 segundos conservados. La procedencia del cadáver es una distinción local de confirmación; no se añade un campo remoto.

Limitación deliberada: si el addon no observó la muerte en esta sesión (incluido reload/login estando fantasma), no hay prueba del contexto original y el llamado se rechaza con explicación. IsInInstance del fantasma por sí solo no permite concluir dónde está el cuerpo. Un cadáver conocido dentro de una instancia siempre se rechaza. Si la API no proporciona el cadáver en los mapas consultados, no se envía. No se promete cobertura de todos los mapas.

Criterios pendientes de verificación manual, a ejecutar por el usuario:

1. Mundo abierto, con permiso: morir y liberar sin reload; confirmar que zona/coordenadas y marcador recibido corresponden al cuerpo y no al cementerio/fantasma. Cancelar no debe emitir CTA.
2. Sin permiso, en instancia o cuerpo de instancia con fantasma fuera: rechazo sin envío. Conservar cooldown y cierre del llamado existente.
3. API sin posición válida o entrada/reload ya fantasma: mensaje explicativo, sin llamado ni ubicación alternativa.
4. Abrir confirmación como vivo y liberar, o abrirla como fantasma y resucitar: rechazo al aceptar. Si cambia la ubicación del cuerpo, exigir nueva confirmación.
5. Llamado vivo y muerto sin liberar: conservar posición confirmada y comportamiento previo. Clientes anteriores deben recibir CTA sin cambio de formato.
6. Con debug activo, revisar consultas/capturas y errores reales; con debug apagado no activar registros. Sin certificación hasta comprobarlo en Forever.

Verificación local: compilación estática de 19 módulos con LuaJIT compatible Lua 5.1, XML/TOC/40 archivos, caracteres, etiquetas de línea y diff. Cobertura estructural actual: 565 funciones propias instrumentadas y 24 llamadas protegidas. No se ejecutaron addon, simulaciones ni APIs de WoW. Sin commit, push, actualización de PR, ZIP o instalación por esta implementación.


Instalación posterior autorizada — 26/11/2026: la implementación local de llamado desde el cadáver (0.2.1, posterior a 84baf3c y sin commit) se copió en `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Tartaro`. Los 40 archivos coinciden con la fuente por SHA256; sin extras, borrados, respaldos o ZIP. HEAD conservado; sin push, modificación del PR ni interacción con el cliente. Pendiente prueba funcional por el usuario; coincidencia de archivos no certifica ejecución.


Consolidación posterior autorizada — 26/11/2026: nuevo commit local sobre 84baf3c, conservando 0.2.1 e incluyendo implementación, límites, verificación estática y evidencia de instalación anteriores. El usuario autorizó posteriormente publicarlo en la rama del PR #16 si continúa abierto, con actualización descriptiva y sin merge ni auto-merge. Se comprobó abierto y sin integrar antes de operar. Sin nueva instalación. El commit que contiene esta anotación identifica la entrega. Las pruebas dentro de Forever siguen pendientes.


## Banner de la Horda — 26/11/2026

**Historial del primer intento:** el usuario rechazó el marco reducido y reportó «Opciones» fuera de la ventana en la captura posterior. La corrección vigente se describe al final de esta sección; las dimensiones y atlas del primer intento siguientes no describen el diseño corregido.

El usuario aportó referencias de un estandarte rojo con emblema lateral y marco superior de la Horda y confirmó expresamente conservar la calavera. Implementación independiente en UI.lua sobre 2e89fa8: calavera intacta (142 x 145, anclada al mismo punto), ornamento superior nativo debajo de ella y banner rojo con «Tartaro»/«For The Horde!» centrados. Los recursos se identificaron leyendo Overlord/UIShared.lua y GroupFinderUI.lua instalados; no se copian funciones, archivos ni se añade dependencia de Overlord.

Diseño: marco metálico de facción sobre tela roja, emblema lateral proporcionado y dos líneas en fuentes nativas GameFontNormalHuge/GameFontNormalLarge. Paleta de alternativa: rojo profundo #3D0405, sombra #1F0203, borde dorado #A87530, título #FFD147 y lema #FFDEA6. La calavera sigue siendo el elemento principal y la referencia de posición/crecimiento de la ventana.

Recursos del cliente: C_Texture.GetAtlasInfo para HordeScenario-TitleBG (parte superior con proporción conservada, ancho máximo 300 y alto máximo 52) y archivo compartido referenciado por AllianceScenario-TitleBG (contiene también la tela roja de Horda). La tela se separa en emblema y tramo plano: el tramo se estira con el ancho de la ventana y el emblema mantiene su proporción. Si no hay atlas, se mantiene fondo rojo y emblema nativo Interface/Timer/Horde-Logo; no se inventa una ruta de textura propia ni se aborta la carga por atlas ausente. Las dos consultas usan debugPcall.

El banner ocupa 64 px, con margen lateral de 16 px, debajo del ornamento y separado del contenido. La reserva de cabecera aumenta de 132 a 194; anclajes del menú, tablas, opciones, calendario, recetas y tamaño total siguen usando la variable compartida headerHeight. El código se construye una vez, sin eventos adicionales, callbacks, animaciones o timers. No cambia drag, persistencia, llamados, permisos o datos de negocio. No hay nuevos archivos gráficos distribuidos.

Verificación estática: 19 módulos compilados con LuaJIT compatible Lua 5.1, XML, TOC/40 archivos, caracteres, etiquetas de línea, trazabilidad y diff --check. 565 funciones instrumentadas y 26 llamadas protegidas. Sin ejecutar el addon, simulaciones o interacción con WoW. Pendiente validar visualmente la disponibilidad/recorte de los atlas en Forever y la composición: sin colisión de calavera, marco, títulos o botón de cierre; ancho mínimo, calendario, opciones, cambio de tamaño y límites de pantalla. No se presenta como un resultado visual comprobado.

Cambios locales sin commit, push, modificación del PR #16 o instalación; versión conservada 0.2.1.


Instalación posterior autorizada del banner — 26/11/2026: Tartaro 0.2.1 con cambios locales posteriores a 2e89fa8 copiado en `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Tartaro`. Verificados 40 archivos coincidentes por SHA256, sin extras, borrados, respaldos o ZIP. UI.lua: `8D302592FCBC498CA74B63332F8CBC813990E8518D5AD681DFF5726D6FE0E97B`. Sin commit, push, cambio al PR o interacción con el cliente. Pendiente revisión visual y funcional por el usuario.


### Corrección del marco y del menú — 26/11/2026

Captura aportada por el usuario: el recorte de HordeScenario-TitleBG quedó como adorno pequeño bajo la calavera; no correspondía al marco superior solicitado. La cabecera ampliada de 194 desplazó el navegador sin aumentar la altura fija de Inicio (497), dejando Opciones fuera. No se hizo commit o actualización del PR antes de la interrupción; HEAD sigue en 2e89fa8.

Corrección local: sustituir el adorno por el atlas perks-theme-hordevsalliance-tp-topbig identificado en el código instalado de Overlord. Se utiliza solo el lado Horda y su reflejo: seis texturas para dos extremos, dos mitades centrales y dos tramos planos. Los extremos y el centro mantienen proporción; solo los tramos planos se anclan por ambos bordes para ajustarse al ancho. Calavera en capa superior sin cambio de posición, tamaño, límites o referencia de persistencia. El marco se coloca sobre el borde superior de la ventana, sin un segundo adorno pequeño debajo de la calavera.

Restaurar headerHeight a 132, banner a 56 px con top en -70 y emblema proporcionado; título y lema centrados en dos líneas. La altura mínima del navegador se calcula como headerHeight + 16 + entradasVisibles*32 + 14. El redimensionado de las vistas incluye ese mínimo, y cambios de ese valor invalidan el layout. Esto cubre tanto la disposición actual como cambios de disponibilidad del menú. Sin nuevos eventos, timers o dependencias.

Verificación estática: compilación de los 19 Lua con LuaJIT compatible Lua 5.1, XML/TOC/40 archivos, caracteres, etiquetas, 565 funciones/26 llamadas protegidas y diff --check. Cálculo de márgenes de navegación para 8 y 10 entradas; no equivale a render dentro del cliente. Pendiente comprobar marco, calavera, textos, mínimos/máximos de ancho, navegación completa y escalas dentro de Forever. Corrección aún sin instalar, commit, push o modificación del PR.


## Eventos, pedidos y recuperación — 26/11/2026

Autorización del usuario para resolver eliminación de eventos, vencimiento/cancelación de pedidos y recuperación desde otro miembro, incluyendo la corrección de diseño pendiente. Código modificado: UI.lua y Orders.lua; correcciones de banner/menú previas conservadas. Sin nueva instalación, commit, push o modificación del PR.

### Eventos de Calendario

Las tarjetas futuras y vencidas incluyen Eliminar evento para quien cumple A.canEditEvent (autor o rangos 0/1). Se comparte la confirmación con el editor mediante win.ConfirmDeleteEvent, sin abrir el editor para borrar desde tarjeta. La aceptación comprueba la misma A.db y revisión del evento; si cambió o desapareció exige nueva confirmación. A.deleteEvent conserva validación de permiso y emisión K con registro de eliminación, borrado de inscripciones/recordatorios y recuperación de cierres existente. Se cierra el editor solo si correspondía al evento eliminado. Los eventos vencidos mantienen participantes e inscripciones en solo lectura; el borrado autorizado es la única acción nueva.

### Pedidos y caducidad

La caducidad existente es siete días desde la fecha codificada en el ID, sin renovarse al recibir, recuperar o cerrar. orderOwner se usa en recepción, listados y acciones; ahora también en canCraftOrder para no dar por fabricable un pedido vencido al consultar esa capacidad. La limpieza existente purga pedidos, copias, cierres y ofertas; el refresco por vencimientos existente sigue retirando tarjetas. No se crea una segunda regla temporal. El vencimiento visual puede esperar al siguiente refresco existente y la limpieza física a su ticker de 60 segundos.

Las tarjetas propias muestran las acciones una debajo de otra: Recuperar pedido para copia no confirmada o Marcar como completado para pedido autoritativo, y Cancelar pedido en ambos casos. Solo su propietario puede efectuar estas operaciones; se comprueban identidad del objeto en el estado vigente, ID válido y vigencia. Una copia no confirmada no puede completarse sin recuperarla antes. Cancelar una copia propia emite el cierre OR con el mismo ID desde el verdadero propietario y guarda el cierre; recuperar emite OR abierto y conserva ID, fecha, contenido y ofertas disponibles. Un fallo al encolar no promueve ni cancela el candidato local.

### Recuperación y sincronización

Antes OC rechazaba owner==A.self, impidiendo recibir copias de un pedido propio perdido. Ahora esas copias se conservan en orderPreviews con unverified/sharedBy y se muestran al propietario como pendientes de recuperar o cancelar. No se convierten automáticamente en pedidos activos autoritativos, no se retransmiten desde el autor como OC y no se amplía la facultad de terceros de publicar OR: su remitente sigue debiendo coincidir con el propietario del ID.

OX de terceros puede retirar un candidato propio no confirmado y conservar marca orderCopyClosed para impedir que una OC abierta vieja lo haga reaparecer. Si existe un pedido propio autoritativo, OX ajeno no lo modifica. La marca de tercero no se transforma automáticamente en OR de cierre emitido por el propietario. Otros flujos de copias/cierres se conservan. La recuperación se rechaza si existe cierre conocido, registro autoritativo o vencimiento; no se generan un ID nuevo o una semana nueva.

Se mantiene el arranque AQ a 3/18 segundos y se agrega solicitud cada 60 segundos desde el ticker de pedidos ya existente. requestedAt se reinicia con el contexto y solo avanza al encolar AQ, salvo el establecimiento inicial de espera. Respuestas conservan jitter, cola y ritmo existentes. No hay nuevo protocolo, SavedVariables o timer; sí mayor tráfico de consulta/respuestas, cuyo costo con varios clientes no se ha medido. No se garantiza recibir una copia en 60 segundos: depende de disponibilidad del compañero, estado conservado, colas y entrega real. Pedidos vencidos o no conservados por ningún cliente no se pueden recuperar con este mecanismo.

Se contrastaron las funciones orderPacket/previewPacket con la base 0.2.0 del commit 44aa65e: campos OR/OC conservados. Esto verifica compatibilidad de formato de ese código, no la versión real o entrega del cliente del compañero. No se atribuye la pérdida de datos al borrado de Interface/AddOns: no se inspeccionó ni modificó su historial de SavedVariables.

### Diseño incluido y verificación

Se conserva la corrección de marco/banner y mínimo de altura del menú descrita en la sección anterior. Los botones de pedidos dejan de compartir una fila con ancho residual: se apilan usando el mismo constructor de botones y tarjetas existentes.

Comprobaciones estáticas: 19 Lua compilados con LuaJIT compatible Lua 5.1, XML, TOC/40 archivos, caracteres, etiquetas de línea, llamadas y diff --check. Cobertura estructural: 570 funciones instrumentadas y 26 llamadas protegidas. Se revisaron las rutas de OC propio, confirmación/cancelación OR, OX previo/posterior y vencimiento; no se ejecutaron simulaciones, APIs de WoW o el cliente. No se declara validación E2E ni ausencia universal de errores.

Criterios manuales pendientes:

1. Evento futuro y vencido: autor y rangos 0/1 ven Eliminar evento; otro miembro no. Cancelar confirmación conserva el evento; aceptar retira evento e inscritos localmente y en otro cliente. Cambiar rango/contexto/revisión antes de aceptar debe impedir la acción anterior. Unirse/modificar inscripción de vencido sigue bloqueado.
2. Pedido propio normal: Cancelar pedido visible dentro de tarjeta estrecha y desaparece al cerrar; otro cliente recibe el cierre. No cancelar pedidos ajenos. Conservación de completados y filtros existentes.
3. Copia propia vigente guardada por el segundo cliente: recibirla como pendiente, sin republicación automática; Recuperar conserva ID/fecha y Cancelar emite cierre del mismo ID. No borrar datos para fabricar el caso sin autorización.
4. Cierre conocido seguido de copia abierta atrasada: no reaparece el candidato; OX ajeno no cierra un pedido propio autoritativo. Replay/reload no reabre un cancelado conservado.
5. Pedido con más de siete días: rechazo en recepción, ausencia en lista, acción impedida y limpieza posterior. No cambiar reloj del cliente ni alterar fechas de SavedVariables para la prueba sin autorización.
6. Cliente que entra después de las consultas iniciales y mensajes perdidos: comprobar recuperación en consultas posteriores; comparar mismo ID/estado en ambos extremos y revisar logs con debug activado. Sin medición o garantía de latencia aún.
7. Marco, calavera, banner y menú: ancho mínimo/calendario/opciones, rangos con 8 y 10 entradas, escalas y límites de pantalla. Revisión visual real pendiente.


Instalación posterior autorizada de diseño, eventos y pedidos — 26/11/2026: Tartaro 0.2.1 con cambios locales posteriores a 2e89fa8 copiado en `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Tartaro`. Los 40 archivos coinciden por SHA256; sin extras, borrados, respaldos o ZIP. UI.lua: `59AEBDA138DB2A7C1B612BB642103D08DE683938E7FE9077819A6E5BFBAE057E`. Orders.lua: `97536A8B6C5DD4E5A7904F45CBD41C95843FFA9E70630E62ED248126C9D87459`. Sin commit, push, modificación del PR o interacción con WoW. Pendiente validación visual y de sincronización por el usuario.


## Cobertura interior del banner — 26/11/2026

El usuario aprobó el marco y los textos de la captura instalada, y señaló la franja vacía entre marco y estandarte. Ajuste limitado a la presentación: el rojo ocupa todo el interior de la cabecera (132 px con 2 px de margen en cada borde, 128 px de altura), sin un recuadro inferior separado. El emblema lateral crece con esa altura y conserva la proporción 90/69 de la tela nativa; el tramo plano ocupa el resto del ancho.

Banner, tela y emblema son texturas BACKGROUND de win (subniveles 2/3/4), detrás del marco ARTWORK -1 y de la calavera ARTWORK. Se elimina el frame hijo del banner para que el fondo ampliado no tape la parte inferior de la calavera. No cambia el marco segmentado, su ancho, proporción ni posición. Título: posición efectiva izquierda 96 y top -77; lema: izquierda 96 y bottom -120 respecto del borde superior. Son las mismas coordenadas del diseño aprobado por el usuario. No cambia headerHeight=132, menú ni lógica de negocio.

Verificación estática: compilación de 19 módulos con LuaJIT compatible Lua 5.1, XML/TOC/40 archivos, caracteres, etiquetas, conteos 570/26 y diff. Comprobación aritmética de anclajes para conservar textos, y revisión de capas sin ejecutar el cliente. Pendiente confirmar visualmente el resultado en Forever. Sin instalar, commit, push o actualizar PR por este ajuste.


Instalación posterior autorizada del fondo completo — 26/11/2026: Tartaro 0.2.1 local posterior a 2e89fa8 copiado en `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Tartaro`, incluyendo eventos/pedidos. Los 40 archivos coinciden por SHA256, sin extras, borrados, respaldos o ZIP. UI.lua: `2D5976616CF009222D1BDC2A4FA2855DED5B9D7614394B9F998FAFBF966D0EEF`. Sin commit, push, actualización del PR o interacción con WoW. Pendiente revisión visual y funcional por el usuario.


## Día actual del calendario — 26/11/2026

El usuario solicita distinguir hoy más allá del color del número. Calendar.Display conserva todayKey mediante Calendar.dayKey(GetServerTime()), selección y eventos existentes. Tras aplicar SetStyle, para hoy establece borde dorado y fondo ámbar, con etiqueta HOY en la esquina superior derecha; número permanece a la izquierda y los eventos comienzan más abajo. El fondo es más claro cuando hoy también está seleccionado. El resto de días conserva el estilo anterior, incluido el seleccionado en cobre.

La etiqueta se crea bajo demanda en la celda que la necesita; al reutilizar celdas se oculta si no corresponde a hoy. SetStyle reaplicado elimina borde/fondo anteriores cuando cambia la fecha o el mes. No se añaden callbacks, eventos, timers, animaciones o dependencias, ni se altera fecha local o selección. El calendario continúa usando sus refrescos existentes.

Verificación estática: 19 Lua compilados con LuaJIT compatible Lua 5.1, XML/TOC/40 archivos, caracteres, etiquetas de línea, conteos 570/26 y diff --check. Pendiente comprobar visualmente hoy seleccionado y sin seleccionar, otro día seleccionado, cambio de mes y cambio de día local. No se ejecutó el addon. Versión 0.2.1; sin instalación, commit, push o actualización del PR por este ajuste.


Instalación posterior autorizada de resaltado de HOY — 26/11/2026: Tartaro 0.2.1 local posterior a 2e89fa8 copiado en `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Tartaro`, con todos los cambios locales previos. Los 40 archivos coinciden por SHA256; sin extras, borrados, respaldos o ZIP. Calendar.lua: `1E8914C484C02F5ACE505FA2C1D91DCE17CBEBD4754A2801A57C22B9D648F4B9`. Sin commit, push, cambio del PR o interacción con WoW. Pendiente revisión visual y funcional del usuario.


## Consolidación de banner, calendario, eventos y pedidos — 26/11/2026

Autorizado un nuevo commit local sobre 2e89fa8, versión 0.2.1. Reúne el marco Horda definitivo de ancho completo, calavera conservada, fondo rojo/emblema cubriendo la cabecera y textos aprobados; mínimo de altura del navegador; botón de eliminar desde tarjetas de eventos futuros/vencidos; cancelación y recuperación explícita de pedidos propios, vigencia original y AQ periódico; borde/fondo/etiqueta HOY del calendario. Los apartados anteriores preservan evidencia y límites de cada cambio, incluidos intentos visuales rechazados y sus correcciones.

Instalación final previa autorizada y verificada con 40 SHA256 coincidentes, sin operar el cliente. Esta consolidación actualiza documentación y no reinstala. Compilación estática de 19 Lua con LuaJIT compatible Lua 5.1, XML/TOC/40 archivos, caracteres, etiquetas, conteos 570/26 y diff. Pruebas visuales finales, permisos, cancelación/eliminación recibidas y sincronización real entre dos clientes siguen pendientes; no se declaran cerradas.

PR #16 comprobado abierto y sin integrar; el usuario autoriza publicar este nuevo commit en su rama y actualizar la descripción. Sin reescritura del historial, merge, auto-merge, release o ZIP. Los estados anteriores «sin commit/push/instalación» son históricos de las entregas, no restricciones posteriores a esta autorización. El commit que contiene esta anotación identifica la consolidación.
