# Tártaro 0.2.0: interfaz, navegación y trazabilidad

Se propone integrar en `main` el trabajo de `codex/mejoras-diseno-menu`, partiendo de `262f9f3ed6df2e387f7559fc90ed4847bc6c2184` (0.1.60). La versión declarada pasa a **0.2.0**, según la denominación confirmada por el propietario. La propuesta mejora la navegación y la coherencia del menú, incorpora un calendario mensual y hace observable la carga y ejecución del addon.

**Se solicita revisión del PR. El merge requiere autorización explícita del propietario.** Esta entrega no incluye merge, auto-merge, tag, GitHub Release, ZIP ni publicación en CurseForge.

## Cambios funcionales y de interfaz

### 1. Inicio y pedidos de fabricación

- Los pedidos de Inicio abren directamente Profesiones → Pedidos por su ID. La tarjeta seleccionada se resalta y se desplaza a la vista; si dejó de estar disponible, se informa en lugar de abrir otro registro.
- Se conservan visibles los pedidos propios y aquellos para los que el personaje ya se ofreció. Los pedidos ajenos disponibles aparecen si no tienen ofertas de miembros actuales **y el personaje conoce la receta** según el perfil de profesiones del addon.
- Las ofertas de exmiembros no bloquean la disponibilidad. El filtro afecta únicamente a presentación: no elimina registros, no modifica su sincronización y no convierte ofertas en una adjudicación exclusiva.
- Inicio separa los pedidos propios pendientes de aquellos que el personaje se ofreció a fabricar. La lista general conserva su acceso y el historial personal de completados.
- Pedidos con objeto muestran cantidad, icono y tooltip compartidos. Los encantamientos con itemID 0 conservan su nombre sin inventar un objeto de salida.
- Ofrecerse no cierra un pedido; se conserva el cierre por su autor y la caducidad existente de siete días.

### 2. Calendario mensual

- El evento seleccionado se presenta en una tarjeta lateral con título destacado, fecha, hora local, tipo y descripción separados; los cupos e inscritos preceden a las acciones autorizadas. Reutiliza el componente de tarjetas y conserva la selección por clic y el tooltip al pasar el mouse.

- La agenda se presenta como una cuadrícula de siete columnas y seis semanas (42 días), con mes/año, anterior/siguiente, Hoy, selección de día y detalle lateral.
- Los resúmenes de hora/título permanecen dentro de su celda, con un máximo de dos líneas y tooltip de título completo. El exceso se indica con `+ N más`; el selector de eventos del día permite acceder a todos, ordenados por hora e ID.
- La cuadrícula permanece fija y el detalle largo se desplaza. La ventana conserva su ajuste de escala; el área de Calendario usa dimensiones ampliadas para alojar la cuadrícula.
- Abrir un evento desde Inicio, su aviso o después de guardarlo sitúa su mes y día por el mismo ID. Cambiar su fecha mueve la selección; eliminarlo actualiza el detalle.
- Los eventos vencidos conservados se muestran en modo de consulta con indicación de vencimiento e inscritos guardados, incluso nombres de quienes ya no están en el roster. No muestran edición, inscripción ni invitaciones.
- Los futuros conservan formulario, tipos de evento, cupos, roles, confirmados/suplentes, inscripción/baja, edición/eliminación y acciones autorizadas sobre participantes.
- Se conserva la mecánica temporal: el formulario interpreta fecha/hora local, almacena/transmite `when` numérico, cada cliente presenta y agrupa usando su hora local y los anuncios usan UTC. No se cambia el instante ni se añade configuración por país.
- No se amplía la retención: solo se muestran registros aún conservados por las reglas actuales de purga.

### 3. Buscar grupo

- Las búsquedas usan las mismas tarjetas de dos columnas que Pedidos y Donaciones, con altura adaptada al contenido y sus acciones particulares.
- Las BG muestran los roles que todavía faltan según sus inscripciones; al cubrirlos se indica que los cupos están completos. Otras actividades conservan las necesidades publicadas.
- Se comparte el cálculo de necesidades entre vista y anuncio para evitar discrepancias al volver a publicar.
- El organizador puede abrir las acciones de invitación de un inscrito. Se revalidan organizador, permiso, identidad, búsqueda vigente, inscripción, conexión y contexto al abrir y al ejecutar.
- Se reutilizan invitación a grupo/banda, conversión autorizada y alternativa mediante comando del menú de participantes. Se conserva la lógica existente de publicación, republicación y cierre.

### 4. Avisos y editor

- Los avisos se separan mediante tarjetas con autor, fecha, texto y espacio interior, reutilizando el fondo de Pedidos.
- El editor comprueba anticipadamente el límite real de **250 bytes** usando los constructores de paquetes existentes. Al excederlo informa y deshabilita Guardar; al acortar recupera la acción sin cortar ni perder el texto.
- Guardar mantiene su validación final. La lectura de cupos se comparte entre comprobación anticipada y guardado; no se cambian permisos ni formatos de mensajes.

### 5. Profesiones y donaciones

- Buscar recetas distingue escaneo programado, transferencia vigente, metadatos de objetos pendientes, catálogo vacío y búsqueda sin coincidencias. No se presenta una lista vacía como una carga supuesta.
- Se conservan los resultados disponibles durante estados parciales y se actualiza la vista cuando cambia la información recibida.
- Donaciones usa el grid compartido de Pedidos, con cantidad, ingrediente, solicitante, conexión, publicación/caducidad e indicación de copia cuando corresponde.
- Sin solicitudes se explica el flujo y se permite llegar a Buscar recetas. La creación sigue siendo desde los materiales de una receta; no se reintroduce entrada manual.
- Se conservan cantidades, cierre por solicitante, caducidad, tooltips y sincronización existentes.

### 6. Honor y Miembros

- Ambas vistas reutilizan filas/celdas tabulares y muestran su orden de forma visible.
- En Honor se distingue orden semanal/total. En Miembros se muestra el orden por detección de Tartaro y la cabecera permite alternarlo.
- Título, controles y cabeceras permanecen fijos; solo se desplaza el cuerpo de la tabla. Se calcula su altura, se limita el desplazamiento al reducir/vaciar listas y se reciclan las filas sin controles sobrantes.
- Miembros ofrece susurro e invitación mediante menú. Se valida conexión, pertenencia, contexto y liderazgo; las acciones se revalidan al ejecutarse. El susurro prepara el destinatario/borrador correspondiente y conserva el flujo de chat existente.

### 7. Mapa y permisos

- Mapa organiza el contenido en Ubicación, Estado y Llamados, conservando el mapa nativo y los controles existentes.
- El autor del llamado ve sus solicitantes con acciones compartidas de invitación. Se comprueban llamado propio vigente, solicitud, pertenencia/conexión y autorización al abrir y ejecutar.
- Se conserva la lógica de envío de ubicación y llamados, restricciones de instancia/fantasma y liderazgo aplicable. No se añade un mapa nuevo ni se envían invitaciones de prueba.
- Permisos pasa a describir **Crear eventos** y explica la edición reservada al creador, líder y sublíderes. No se modifica el modelo de grants ni la autorización de eventos por ese cambio de etiqueta.

### 8. Opciones y botón de llamado

- La prueba de sonido se identifica como **Probar archivo**. Se explica SFX frente al modo real de alerta Master/silencio temporal y su alternativa cuando no hay control de volumen. La política de audio existente se conserva.
- El launcher utiliza la plantilla nativa de botón de WoW y marco metálico dorado. Mantiene tipografía explícita con sombra y el texto exacto **Llamado a las Armas**, con espadas cruzadas a ambos lados y un espacio de separación. Se reutiliza CallSwords; no se añaden imágenes ni dependencias.
- Su base es 252×42, con etiqueta de 228 e iconos de 18 al 100%. Conserva visibilidad por permiso, confirmación previa, envío, arrastre y posición guardada.
- Opciones incorpora **Tamaño del botón**, del 50% al 150%, en pasos de 5%. `SetScale` sobre el padre escala texto, iconos, fondo y marco conjuntamente al mover el control.
- El tamaño se guarda, se restaura al login y reaplica el centro guardado con la escala efectiva. Restablecer configuración vuelve al 100% y recupera el anclaje predeterminado. El setter no fuerza la visibilidad del botón.

## Código compartido y corrección del arranque

- `UIComponents.lua` concentra filas, celdas, tarjetas, grid y ciclo de vida con estado/pools por instancia. Recibe factories y contenedores; sus componentes no acceden a `A.db`. `Attach` permite registrar partes que deben ocultarse sin modificar una lista de tipos en el reciclador.
- El grid devuelve la posición de foco y deja en el renderizador de Pedidos la decisión de selección/desplazamiento. Se mantienen renderizadores específicos por área.
- Se comparten consultas de ofertas y el límite de paquetes; Professions devuelve códigos de estado y UI resuelve sus textos. Se aplica composición sin añadir jerarquías de herencia o sustituir globalmente el namespace existente.
- Se corrige el fallo de carga confirmado en General.log: el estilo de un botón vacío accedía a una FontString inexistente al construir Calendario. La fábrica crea/asocia la etiqueta explícitamente antes de aplicar estilos. El aborto de UI dejaba sin definir accesos y callbacks usados por Version/Honor; se corrige el punto de interrupción, sin añadir guardas para ocultar sus consecuencias.

## Trazabilidad dentro del addon, sin interfaz de pruebas

- Se retiran la ventana «Pruebas locales y guía», los botones «Ejecutar pruebas»/«Ver informe» y los módulos Diagnostics.lua/DiagnosticsView.lua desarrollados durante la sesión. No forman parte de esta propuesta; no quedan dependencias de ese ejecutor en UI o en el TOC.
- Las observaciones útiles de vistas, editor, pedidos, recetas, tooltips y ordenación se registran directamente en el logger, sin ejecutar comprobaciones automáticas ni pasos guiados.
- `LoadTrace.lua` se carga primero y registra módulos iniciados/finalizados, faltantes y los hitos de login/disponibilidad de UI.
- Se instrumentan **530 funciones propias** de los módulos y los **21 puntos de llamadas protegidas existentes**. Se registran entrada, salida, argumentos/resultados resumidos, secuencia, hora, origen y relación entre llamada y retorno. Se conservan `self`, retornos múltiples/nil y propagación de errores de negocio.
- Se conservan observaciones de ventanas/vistas, recepción de paquetes, bloqueo del canal y resultados reales del transporte. Los errores atrapados por compatibilidad se distinguen de errores no atrapados y se conserva el reenvío al manejador previo.
- La trazabilidad está **apagada por defecto**. `/tartarodebug on`, `/tartarodebug off` y consulta sin parámetros controlan el modo; las preferencias se guardan. Off conserva la evidencia anterior y no escribe nuevas entradas de ejecución.
- `debugTrace` conserva un anillo de 1.000 entradas recientes, contadores y último estado de entrada/salida por operación, con 30 errores aparte y contadores de reemplazo/fallos de captura. `loadTrace` conserva el arranque. Los buffers son acotados y no constituyen un historial infinito ni un volcado completo de tablas.
- WoW guarda los datos al recargar/salir normalmente. No hay escritura arbitraria a archivos, envío de logs ni automatización del cliente. Un manejador ajeno que no mantenga la cadena puede limitar la captura.
- El modo activo añade trabajo de diagnóstico; no se afirma una mejora de rendimiento ni coste cero cuando está apagado.

## Pruebas externas y documentación

- Se retira la suite ejecutable Lua/Python de `tests` por instrucción expresa del propietario, incluido su ejecutor y las pruebas de empaquetado. Permanecen tres Markdown como antecedentes, marcados como históricos.
- Las simulaciones realizadas durante el desarrollo se documentan como antecedentes; no se presentan como validación real ni como programas todavía disponibles. No se recrean en esta entrega.
- Se conserva el verificador de archivos reales de `tools/package_addon.py`; en esta preparación se utiliza únicamente su validación de fuente, sin construir ZIP.
- `AGENTS.md`, `MAESTRO-DESARROLLO.md`, el LEEME, la bitácora y los documentos de diagnóstico describen el alcance, las instrucciones vigentes y las limitaciones. `Temporary` se ignora y no se publica con los datos de trabajo.

## Verificación de esta entrega y límites

- Compilación de sintaxis de los 19 Lua con Lua 5.1, análisis XML y comprobación de caracteres.
- Validación de TOC, versión numérica, archivos referenciados y recursos propios; revisión de diff y `git diff --check`.
- Auditoría estructural de la instrumentación y revisión del cableado del control de tamaño, inicio/restablecimiento y nuevo filtro de receta conocida.
- Las candidatas de la sesión se copiaron a Forever por solicitud del propietario y se contrastaron archivo a archivo por SHA256. Esa copia verificada no acredita ejecución. La instalación al cierre conserva el identificador 0.1.60 y el diagnóstico interno anterior. La propuesta 0.2.0 es la que retira esa interfaz y no actualiza la copia instalada por sí misma.
- No se controla ni inspecciona la ventana del juego. No se ejecuta una nueva suite simulada ni se certifican E2E, render, fuentes, escalas, audio audible, sincronización entre clientes o coste real del debug.
- Deben revisarse manualmente el calendario con varios eventos/inscritos, tablas largas, menús ante cambios de contexto/permisos, filtros con datos de profesiones recibidos, botón/iconos/escala y su persistencia, y sincronización real con dos clientes.
- Los formatos de red, pertenencia a la guild, retenciones y reglas de negocio no se rediseñan. Este PR requiere revisión e integración explícitas antes de considerar una publicación; no cierra automáticamente issues.

El detalle fechado de implementación y evidencia se conserva en [MEJORAS-DISENO-MENU.md](MEJORAS-DISENO-MENU.md). El contrato del registro está en [DEPURACION-CARGA.md](DEPURACION-CARGA.md).
