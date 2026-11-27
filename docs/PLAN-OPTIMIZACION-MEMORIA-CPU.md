# Plan de análisis y optimización de memoria y CPU

Fecha inicial: 25/11/2026. Actualización: 26/11/2026. Estado: cambios de los hallazgos 1 a 10 en el alcance descrito abajo; 1, 3 y 8 mitigados parcialmente. Las entregas hasta 9/10 están instaladas para pruebas por autorización del usuario. Verificación dentro de Forever y mediciones pendientes; se conserva la observación manual de 2 MB sobre una entrega anterior. No se declara cerrado todo el plan.

## Objetivo y base verificada

Reducir trabajo repetido, asignaciones temporales y retención innecesaria sin perder funciones, datos, permisos, compatibilidad o trazabilidad.

- Fuente del análisis inicial: versión local declarada 0.2.1, rama `main`, HEAD `07155cdb3db3391753ccfca6a022db918e44d8ba`, con cambios locales sin commit. El commit por sí solo no representa todo el código analizado.
- Se revisaron 19 módulos Lua, con 6.793 líneas en total. En la revisión previa, los 40 archivos del addon instalado coincidían por SHA256 con la carpeta fuente `Tartaro/`.
- El usuario confirmó que su rango Dev permite ver Miembros y Permisos. Esto valida ese acceso observado, no el rendimiento ni los demás escenarios de permisos.
- Las líneas citadas pertenecen a esta copia local; pueden desplazarse al implementar. Se incluye el nombre de función para localizar cada evidencia.
- No se midieron MB, tiempo de CPU, pausas de recolección ni FPS. Los costes descritos son consecuencias del código; su magnitud y su orden real requieren medición.
- No se ejecutaron el addon, simuladores o pruebas dentro de WoW durante el análisis. No se inspeccionó ni controló la ventana del juego.

El usuario solicitó inicialmente documentar el plan y después autorizó trabajar en los hallazgos 1/2, 3/4, 5/6, 7/8 y 9/10. El 26/11/2026 autorizó consolidar los cambios en un nuevo commit local con documentación; no autorizó push. El alcance y la verificación se recogen en [Cambios locales 0.2.1](CAMBIOS-LOCALES-0.2.1.md). Las referencias históricas a «sin commit» conservan el estado de cada entrega previa. Las ampliaciones pendientes de los puntos parciales requieren selección antes de implementarse.

## Restricciones que deben conservarse

- Compatibilidad con Lua 5.1 y el cliente Forever declarado por el proyecto.
- Misma presentación, navegación, filtros y acciones, salvo aprobación expresa de un cambio visible.
- Acceso administrativo de rangos 0/1 y rango 8 con nombre exactamente `Dev`; el modo debug no concede acceso.
- Mismos permisos de eventos, llamados, avisos y grupos; no ampliar privilegios como efecto de optimizar.
- Hora local de eventos, consulta de vencidos e inscritos, tarjetas por horario y scroll reservado al contenido.
- Mensaje diario una vez por día o cambio de contenido; avisos de eventos y recordatorio de -30 a +30 minutos; bloqueo en combate, mazmorra, banda, BG y arena.
- Presencia y versión de Tartaro/Overlord con distinción entre confirmación actual e historia; mantener la renovación y caducidad existentes mientras no se apruebe otra política.
- Recuperación de sincronización ante entrada, reload, desconexión, recepción parcial y mensajes retrasados. Conservar compatibilidad con clientes anteriores.
- Logs apagados por defecto y trazabilidad utilizable al activarlos. No sustituirla por simulaciones ni añadir un sistema paralelo de pruebas.
- No eliminar SavedVariables, perfiles históricos ni archivos sin autorización. No generar ZIP, instalar o publicar como parte de este plan.

## Hallazgos y soluciones propuestas

### 1. Filas completas y controles conservados al máximo alcanzado

**Evidencia:** [UIComponents.lua:17](../Tartaro/UIComponents.lua#L17), `view.Row`; [UIComponents.lua:56](../Tartaro/UIComponents.lua#L56), `view.TableRow`; [UIComponents.lua:106](../Tartaro/UIComponents.lua#L106), `view.Finish`; [UI.lua:1595](../Tartaro/UI.lua#L1595), `members`; [UI.lua:2711](../Tartaro/UI.lua#L2711), `honorRanking`.

Cada fila nueva crea marco, etiqueta, botón, checkbox y texto del checkbox aunque la fila solo muestre texto. Las tablas añaden celdas. Los renderizadores recorren sus listas completas, no únicamente la parte visible. `Finish` y `Hide` ocultan controles sobrantes conservando las referencias en el conjunto reutilizable.

**Consecuencia comprobable:** la cantidad de controles retenidos depende del máximo construido durante la sesión. Hay trabajo de configuración para filas fuera del área visible. La reutilización es positiva y no constituye por sí misma una fuga; el problema es el tamaño del conjunto y los componentes que cada fila crea sin necesitarlos.

**Propuesta:** primero crear botón y checkbox solo cuando la fila realmente los necesite, conservando la reutilización y limpiando callbacks/datos que ya no deban retenerse. Evaluar después filas visibles reutilizables para tablas uniformes de Miembros y Honor. Las tarjetas de altura variable requieren una evaluación separada; no introducir un framework de virtualización para todo el addon. La paginación es alternativa de diseño que requiere aprobación si cambia la navegación.

**Verificación:** contar controles antes/después de abrir listas de distinto tamaño y repetir la navegación. La primera mejora debe reducir los controles innecesarios sin cambiar filas o acciones; una eventual virtualización debe mantener un conjunto proporcional al área visible, conservar selección, cabeceras, scroll, tooltips y menús. Medir memoria retenida con el mismo conjunto de datos.

### 2. Reconstrucción completa del catálogo por metadatos de objetos

**Evidencia:** [Professions.lua:390](../Tartaro/Professions.lua#L390), evento `GET_ITEM_INFO_RECEIVED`; [RecipeCatalog.lua:13](../Tartaro/RecipeCatalog.lua#L13), `invalidateRecipeCatalog`; [RecipeCatalog.lua:21](../Tartaro/RecipeCatalog.lua#L21), `buildCatalog`; [UI.lua:2901](../Tartaro/UI.lua#L2901), `A.invalidate`.

La llegada de información de un objeto marcado en `itemRequests` elimina `entries` y `cached`, y solicita refrescos. La siguiente búsqueda reconstruye el catálogo recorriendo perfiles y recetas, consultando metadatos y creando tablas/textos normalizados. La agrupación existente de 0,08 segundos evita algunos refrescos duplicados, pero las respuestas separadas pueden reconstruir repetidamente el catálogo.

**Consecuencia comprobable:** repetición del recorrido global y asignaciones temporales durante una carga de metadatos. No implica que cada evento provoque una reconstrucción inmediata: depende de la vista activa, la agrupación y la siguiente búsqueda.

**Propuesta:** distinguir cambios estructurales de recetas de cambios de nombre, icono, rareza o vinculación de un objeto. Actualizar metadatos afectados y volver a evaluar resultados/filtros cuando corresponda. Si para ello hiciera falta una infraestructura desproporcionada, agrupar primero la reconstrucción pendiente usando el mecanismo existente. Revisar la vida de `itemRequests` para no tratar indefinidamente una consulta resuelta como una carga pendiente, conservando reintentos y respuestas fallidas.

**Verificación:** registrar reconstrucciones durante apertura con objetos sin caché y llegada escalonada de respuestas. Confirmar que aparecen nombres/iconos y se corrigen búsqueda, orden y filtros de rareza/BoP. Clics de detalle y cambios en bolsas no deben reconstruir el catálogo estructural sin necesidad.

### 3. Sincronización periódica de colecciones completas

**Evidencia:** [Core.lua:609](../Tartaro/Core.lua#L609), `request`; [Core.lua:396](../Tartaro/Core.lua#L396), recepción de `Q`; [Core.lua:309](../Tartaro/Core.lua#L309), `replay`; [Replication.lua:26](../Tartaro/Replication.lua#L26), `addSharedReplay`; [Donations.lua:120](../Tartaro/Donations.lua#L120), `syncDonations`; [Donations.lua:133](../Tartaro/Donations.lua#L133), temporizador de solicitud/envío.

Cada cliente solicita `Q` cada 60 segundos. Los receptores pueden preparar replay de registros propios y compartidos. Donaciones solicita `DQ` aproximadamente cada minuto y las respuestas preparan los registros aún vigentes. Existen espera mínima de diez segundos, colas activas y límites de envío, pero no un inventario que identifique los registros faltantes del receptor.

**Consecuencia comprobable:** serialización y procesamiento de registros sin cambios. El volumen depende de clientes, datos, distribución temporal de solicitudes y capacidad de vaciar colas; no se afirma una cifra ni una multiplicación exacta de tráfico en la instalación real. Las listas de envío conservan sus elementos ya recorridos hasta terminar la lista.

**Propuesta:** medir por separado presencia/versiones y recuperación de datos. Mantener renovación de presencia; evaluar desacoplarla de la recuperación completa. Primero aprovechar versiones, revisiones, esperas y deduplicación existentes. Liberar referencias de paquetes consumidos solo si se adapta el recorrido sin depender de longitud de tablas con huecos. Una negociación nueva, elección de un único retransmisor o cambio de protocolo requiere diseño y aprobación específicos; no suprimir retransmisiones a ciegas.

**Verificación:** comparar mensajes, bytes, paquetes preparados y CPU en reposo con varios clientes; repetir conexión tardía, reload, pérdida temporal del canal, datos existentes solo en un tercero y clientes anteriores. Pedidos, donaciones, eventos, inscripciones y cierres deben converger sin depender del autor conectado. Cero tráfico no es un criterio de éxito.

### 4. Recorridos y repintados del mapa por varias vías

**Evidencia:** [Core.lua:699](../Tartaro/Core.lua#L699), temporizadores; [Map.lua:27](../Tartaro/Map.lua#L27), `invalidateMap`; [Map.lua:298](../Tartaro/Map.lua#L298), `drawPositions`; [Map.lua:384](../Tartaro/Map.lua#L384), `drawMinimapPositions`.

El mapa mundial tiene actualización cada segundo y el minimapa cada 0,25 segundos. La recepción de posiciones agrupa repintados del mapa mundial con una espera de 0,12 segundos; también hay callbacks de OpenMap, cambio de mapa y escala. Los recorridos actualizan posiciones y propiedades de marcadores sin comparar todos los valores anteriores. La eliminación de posiciones caducadas se hace en el recorrido del mapa mundial después de comprobar que esté mostrado; el minimapa las ignora, pero no las elimina.

**Consecuencia comprobable:** recorridos y conversiones repetidos; posiciones caducadas pueden seguir almacenadas mientras el mapa mundial esté oculto. El minimapa necesita actualizarse cuando el jugador se mueve o gira aunque los demás no envíen cambios. El mapa mundial oculto sí tiene salida temprana.

**Propuesta:** coordinar invalidación y actualización periódica, conservar la respuesta a movimiento/giro/zoom y no repetir propiedades sin cambios. Separar limpieza de caducados de visibilidad del mapa, reutilizando una tarea existente. Evaluar caché de transformaciones únicamente si se conocen sus invalidaciones en mapa, OpenMap, escala y geometría. No reducir intervalos ni cambiar tamaños de iconos sin evidencia/aprobación.

**Verificación:** mapa abierto/cerrado, minimapa, movimiento, rotación, zoom de OpenMap, cambio de zona, entrada en instancia, entrada/salida de grupo y pérdida de posiciones. Medir recorridos, conversiones y CPU para el mismo número de personajes. Las posiciones deben caducar sin abrir el mapa mundial; no alterar marcadores ajenos.

### 5. Transferencias de profesiones vencidas que no se liberan

**Evidencia:** [Professions.lua:83](../Tartaro/Professions.lua#L83), `receiveProfessions`, especialmente el callback de la línea 96 y la eliminación al completar en la 104.

Se almacena una transferencia por autor con vencimiento de 240 segundos. El callback de vencimiento invalida el estado de recetas, pero no elimina `incoming[author]`. Una transferencia incompleta permanece hasta ser reemplazada, completarse o reiniciarse el estado de profesiones. Cada transferencia admite hasta 128 fragmentos de 190 bytes; ese límite corresponde a datos de fragmentos, no al tamaño total en RAM.

**Consecuencia comprobable:** los fragmentos vencidos permanecen referenciados. Además, el callback captura la transferencia hasta ejecutarse, incluso si antes fue reemplazada. No se afirma una fuga ilimitada.

**Propuesta:** en el vencimiento, eliminar únicamente la transferencia que siga coincidiendo con autor, contexto y objeto capturado. No borrar una recepción posterior. Si se observan reemplazos frecuentes, evaluar usar un único mecanismo de limpieza existente en lugar de un callback nuevo por reemplazo.

**Verificación:** recepción incompleta, completa antes del plazo, revisión nueva que reemplaza la anterior y cambio de hermandad. Tras caducar no debe quedar la transferencia abandonada; el vencimiento antiguo no debe cancelar datos nuevos. La interfaz debe dejar de informar recepción pendiente.

### 6. Ordenación de todos los eventos cada cinco segundos

**Evidencia:** [UI.lua:767](../Tartaro/UI.lua#L767), `checkEventReminders`; [UI.lua:813](../Tartaro/UI.lua#L813), temporizador.

Mientras no estén bloqueadas las notificaciones, se crean listas, se recorren todos los eventos y se ordenan tanto recordatorios pendientes como la lista completa. Después se calculan días y se comprueban mensajes. La ventana principal cerrada no detiene este trabajo, lo cual permite avisos fuera de ella.

**Consecuencia comprobable:** hasta doce comprobaciones por minuto según el intervalo configurado, con ordenación global y tablas temporales aunque los registros no cambien. La frecuencia efectiva puede variar por la ejecución del cliente. El bloqueo por combate/instancias ya evita el recorrido en esos contextos.

**Propuesta:** mantener una lista o índice reutilizable cuando cambien eventos y calcular el siguiente momento de interés. Reutilizar el temporizador y los recibos actuales; no añadir un planificador genérico. Invalidar al crear/editar/eliminar/recibir eventos y al cambiar contexto o día local; reevaluar al salir del bloqueo.

**Verificación:** día nuevo, cambio de hora del evento, recepción tardía, ventana cerrada, reload, combate e instancias. Conservar una aparición diaria, recordatorio único de -30/+30 y resumen local de eventos del día por carga, sin anuncios repetidos ni futuros fuera de la regla.

### 7. Perfiles históricos procesados aunque no sean miembros actuales

**Evidencia:** [Cleanup.lua:5](../Tartaro/Cleanup.lua#L5), `purgeExpired`; [RecipeCatalog.lua:23](../Tartaro/RecipeCatalog.lua#L23), construcción de catálogo; [RecipeCatalog.lua:54](../Tartaro/RecipeCatalog.lua#L54), filtrado posterior por `A.members`.

La limpieza periódica no establece una retención para perfiles de profesiones e informes históricos de miembros. El catálogo recorre perfiles guardados y prepara recetas antes de excluir a quienes no aparecen en el roster actual al construir resultados.

**Consecuencia comprobable:** datos históricos conservados y procesamiento de perfiles que no serán visibles. No se demostró cuánto ocupa la historia ni que conservarla sea un defecto funcional.

**Propuesta:** excluir de la construcción visible los perfiles de personajes ausentes en un roster válido y refrescar cuando entren/salgan miembros. Conservar datos originales hasta que el usuario defina una política de retención. No aplicar limpieza de perfiles por un roster todavía incompleto o pendiente.

**Verificación:** perfiles históricos, roster parcial durante login, llegada tardía de miembros, salida y reincorporación. No deben perderse recetas guardadas ni ocultarse permanentemente las de un miembro válido. La memoria de datos persistidos y la del índice de búsqueda deben evaluarse por separado.

### 8. Reconstrucción del roster antes de detectar cambios

**Evidencia:** [Core.lua:67](../Tartaro/Core.lua#L67), `roster`; [Core.lua:613](../Tartaro/Core.lua#L613), `refreshRoster`; [Core.lua:687](../Tartaro/Core.lua#L687), eventos.

`roster` crea tablas nuevas de miembros, rangos y alias y consulta la lista completa. `refreshRoster` compara después con los registros anteriores para decidir invalidaciones. Evitar un refresco de pantalla sin cambios no evita esta reconstrucción previa.

**Consecuencia comprobable:** consultas, recorridos y asignaciones aun cuando el resultado final sea el mismo. La frecuencia depende de los eventos reales del cliente; no hay medición de esa frecuencia.

**Propuesta:** agrupar notificaciones repetidas del roster y reutilizar registros sin cambios manteniendo coherencia de sus campos y alias. Revisar qué consumidores conservan referencias antes de cambiar identidades de tablas. No retrasar revocaciones de acceso ni conexión/desconexión con una espera amplia para ahorrar consultas.

**Verificación:** eventos repetidos sin cambios, conexión/desconexión, nombre/rango/nivel/clase, roster incompleto y cambio de hermandad. Deben mantenerse presencia, versiones, filtros, pérdida de acceso y retorno a Inicio cuando corresponda.

### 9. Refrescos completos de vistas estables

**Evidencia:** [UI.lua:2949](../Tartaro/UI.lua#L2949), temporizador de vistas; [UI.lua:2809](../Tartaro/UI.lua#L2809), `A.refresh`; [UI.lua:2788](../Tartaro/UI.lua#L2788), `RefreshNavigation`.

Cada cinco segundos se invalidan las vistas abiertas de Pedidos, Donaciones, Buscar grupo y Mapa. Los renderizadores recorren datos y preparan filas/callbacks de nuevo. `A.refresh` también recoloca y aplica estilos a las entradas del navegador aunque el conjunto visible no cambie. Miembros ya compara estados antes de solicitar refresco periódico; ese comportamiento debe conservarse.

**Consecuencia comprobable:** repetición de operaciones de interfaz y asignaciones temporales. La caducidad temporal sí exige comprobaciones aunque no llegue un mensaje de red.

**Propuesta:** separar comprobación temporal de reconstrucción visual. Renderizar por cambios de datos, acciones o caducidad efectiva; conservar comprobaciones necesarias. Actualizar anclajes/estilos del navegador al cambiar permisos, página o disposición, sin quitar su validación de acceso. Reutilizar cálculos dentro de un mismo render cuando se repitan resúmenes de ofertas o asistencia.

**Verificación:** dejar cada vista estable varios ciclos y contar renderizados; después modificar datos, vencer registros y cambiar permisos. Conservar scroll, selección, filtros, tarjetas y menús. No dejar contenido vencido en pantalla por eliminar el refresco periódico.

### 10. Preparación de argumentos de diagnóstico con debug apagado

**Evidencia:** [LoadTrace.lua:52](../Tartaro/LoadTrace.lua#L52), `write`; [LoadTrace.lua:79](../Tartaro/LoadTrace.lua#L79), `traceCallback`; [UI.lua:2894](../Tartaro/UI.lua#L2894), registro `render.end`.

El registrador sale inmediatamente si debug está apagado y los wrappers llaman directamente al callback. Sin embargo, el llamador ya habrá evaluado sus argumentos: algunas llamadas construyen tablas y consultan propiedades de marcos antes de entrar al registrador.

**Consecuencia comprobable:** trabajo de preparación que no produce un registro cuando debug está apagado. No equivale a que los logs sigan capturando ni demuestra un coste mayor que los recorridos anteriores.

**Propuesta:** evitar la preparación costosa cuando debug no esté activo mediante una comprobación simple del estado real del registrador. No duplicar la interpretación de preferencias ni añadir closures de evaluación diferida en todas las llamadas. Mantener registros de carga, errores y operaciones cuando se active; no retirar trazabilidad.

**Verificación:** debug apagado por defecto, activación/desactivación en sesión y persistencia. Comparar asignaciones/CPU de las mismas acciones en ambos modos. Verificar que sigan registrándose contexto, errores y operaciones al activarlo y se respeten los límites del historial.

## Protecciones existentes que deben conservarse

- Caché de catálogo y resultados en RecipeCatalog; cambiar un detalle no exige siempre reconstruirlos.
- Reutilización de filas, tarjetas y marcadores; mejorar sus límites no implica desecharla.
- Invalidaciones de UI agrupadas en 0,08 segundos y del mapa en 0,12 segundos.
- Cola principal de envío limitada a 160 mensajes; envío secundario condicionado por su ocupación.
- Límites de fragmentos y transferencias compartidas; no extrapolar crecimiento ilimitado ignorándolos.
- Limpieza periódica de registros temporales y caducidad de presencia/posiciones.
- Logs de ejecución limitados a 1.000 entradas y 30 errores, con debug apagado por defecto.
- El único `OnUpdate` encontrado se activa durante el arrastre del botón del minimapa y se retira al terminar u ocultarlo; no se encontró un bucle general permanente por frame.

## Secuencia propuesta para implementar

El orden siguiente es una propuesta por alcance y riesgo, no un ranking de consumo medido. Cada bloque requiere aprobación antes de tocar código; se reevalúa después de obtener evidencia.

1. **Fijar la base de comparación.** Conservar identificación de versión, cambios locales, datos y addons activos. Definir escenarios y medición manual autorizada antes de atribuir mejoras. No cambiar funcionalidad para obtener cifras.
2. **Cambios acotados de retención y trabajo inútil.** Hallazgo 5; exclusión del índice visible del 7 sin borrar historia; limpieza de posiciones del 4. Validarlos por separado.
3. **Catálogo e invalidaciones de interfaz.** Hallazgos 2 y 9, preservando filtros, navegación, caducidad y actualización de datos.
4. **Controles de listas.** Creación bajo demanda del hallazgo 1. Evaluar por separado cualquier virtualización o paginación antes de extenderla a tarjetas.
5. **Tareas periódicas.** Hallazgos 6 y 8 y coordinación de dibujado del 4. Mantener respuesta visual y permisos.
6. **Sincronización.** Hallazgo 3 solo después de medir varios clientes y definir compatibilidad/recuperación. No mezclarlo con cambios visuales.
7. **Coste del diagnóstico.** Hallazgo 10, con trazabilidad conservada y comprobación de ambos modos. Puede adelantarse si la medición demuestra que domina el coste.

No agrupar todos los cambios en una refactorización general. No añadir dependencias, módulos o abstracciones sin necesidad concreta demostrada.

## Medición y criterios comunes

### Escenarios pendientes de ejecución

| Escenario | Qué contrastar |
|---|---|
| Login/reload y reposo con ventana cerrada | Inicialización, solicitudes, temporizadores, memoria estable y tráfico sin cambios. |
| Miembros y Honor con la misma lista | Cantidad de controles, apertura, scroll, refrescos y memoria tras salir de la sección. |
| Buscar recetas con metadatos pendientes y ya disponibles | Reconstrucciones, búsqueda, carga de objetos y asignaciones temporales. |
| Pedidos, Donaciones y Buscar grupo | Refrescos sin cambios, caducidad, ofertas, inscripción y cierres. |
| Calendario y avisos | Ordenación, cambio de día, ventanas de aviso, bloqueo y reanudación. |
| Mapa mundial/OpenMap y minimapa | Oculto/visible, movimiento, rotación, zoom, cantidad de posiciones y caducidad. |
| Varios personajes/clientes | Bytes/mensajes, convergencia, desconexión, versión anterior y recepción parcial. |
| Debug apagado y activado | Coste del diagnóstico, límites y utilidad real de los logs. |

Las mediciones dentro de WoW quedan pendientes de un procedimiento aprobado y ejecutado por el usuario. Este plan no autoriza operar el cliente ni incorporar un panel de benchmarking, un simulador o pruebas externas ejecutables. No se prescriben APIs de profiling sin contrastar antes su disponibilidad en Forever.

### Evidencia mínima por cambio

- Misma población de datos, addons, configuración, contexto y acciones antes/después; indicar diferencias inevitables.
- Separar memoria retenida de asignaciones temporales y de memoria pendiente de recolección; el tamaño de un archivo o del paquete no mide la RAM de ejecución.
- Separar número de llamadas, tiempo total y tiempo por operación; menos llamadas no demuestra por sí solo menor coste total.
- Indicar método, duración y repeticiones. No fijar porcentajes de ahorro, límites de MB o metas de FPS sin línea base.
- No forzar recolección de basura dentro del producto como supuesta solución. Si se usara en una medición autorizada, declarar el procedimiento y mantenerlo igual en la comparación.
- Registrar comprobaciones estáticas pertinentes: Lua 5.1, XML, referencias del TOC/recursos, caracteres y diff. Estas no acreditan funcionamiento dentro de WoW.
- Ejecutar manualmente las verificaciones funcionales del hallazgo y sus dependencias antes de declararlo resuelto. Si faltan segundo cliente o escenarios, dejarlo pendiente.

## Estado de ejecución

### Revisión local de los hallazgos 1 y 2 — 25/11/2026

**Alcance implementado del hallazgo 1:** `UIComponents.Row(kind)` crea solo el marco base y, cuando se solicita, texto, botón o checkbox con su texto. `Line`, `Button` y `Check` declaran el uso; `TableRow` y las filas de detalle no crean esos componentes base innecesarios. Se conserva el conjunto reutilizable y el layout. `orderShortcut` solicita explícitamente el botón para no depender de una creación anticipada. Al reutilizar u ocultar filas sobrantes se limpian clicks de botón/checkbox; menús de participantes/miembros y acciones de detalle limpian sus callbacks con datos capturados al ocultarse. Los callbacks permanentes de estilo/hover se conservan donde no capturan datos del registro.

No se implementó virtualización o paginación: las listas aún se recorren completas y los controles creados permanecen al máximo alcanzado. La creación bajo demanda reduce componentes innecesarios, pero no cierra toda la retención identificada en el hallazgo 1. Miembros y Honor tienen alturas uniformes aprovechables para una siguiente etapa; adaptar el scroll y reciclaje requiere verificar cabecera, selección y menús. Las tarjetas variables requieren una solución separada. No se declara el hallazgo completamente resuelto.

**Alcance implementado del hallazgo 2:** el catálogo mantiene un índice por objeto con referencias a las entradas únicas de receta ya compartidas entre fabricantes. `refreshRecipeItem` actualiza únicamente esas entradas, reutilizando la misma función de metadatos del constructor. Solo invalida resultados de búsqueda si cambian nombre de receta/objeto, rareza, icono o vinculación; actualiza también los textos normalizados. La estructura completa se sigue invalidando ante cambios de profesiones o hermandad. No se alteran predicados de búsqueda, filtros, ordenación o agrupación de fabricantes.

`GET_ITEM_INFO_RECEIVED` ya no invalida el catálogo estructural. Acepta respuestas con datos verificables, elimina la solicitud resuelta y conserva refrescos de vista/detalle/pedidos. Si el cliente indica fallo o el nombre aún no está disponible, conserva estado pendiente sin reconstrucción; consultas posteriores pueden volver a solicitar el objeto tras 15 segundos. No añade un temporizador de reintentos. El índice adicional consume referencias en memoria a cambio de evitar recorridos globales; no se asegura ahorro neto de RAM sin medir.

**Trazabilidad:** el registrador existente recibe `ui.row.created`/`ui.part.created` con índice/tipo, `catalog.build` para construcción estructural y `catalog.item` para entradas afectadas/cambio detectado. Se conservan el modo debug y sus límites; no se crea panel, simulador o ejecutor de pruebas. Las llamadas quedan instrumentadas con etiquetas de línea actualizadas.

**Verificación ejecutada:** compilación sin ejecutar los 19 módulos mediante Lua 5.1; XML, caracteres, TOC/recursos y 40 archivos instalables correctos; 548 funciones instrumentadas y 21 llamadas protegidas; `git diff --check` correcto. Revisados los usos directos de `row`, botones, etiquetas y tablas, y el orden de carga: RecipeCatalog se define antes de los eventos de sesión que utilizan la actualización por objeto. Esto no valida visualmente controles ni respuestas reales de la API.

**Verificación manual pendiente:** navegar Inicio → Miembros/Honor → Calendario → Profesiones → Permisos y repetir; comprobar scroll, estilos, tooltips, acciones de pedidos, menús, checkboxes, ocultar/reabrir y combate. En recetas, observar llegada de nombres/iconos y cambios de búsqueda/filtros de rareza/BoP con objetos pendientes; varias recetas de un mismo objeto deben actualizarse y conservar fabricantes. Repetir respuesta resuelta, recepción fallida/reintento, materiales y cambio estructural de profesiones. Con debug activo, respuestas de objetos deben producir `catalog.item` sin otro `catalog.build` salvo invalidación estructural real. Si no hay objetos pendientes, ese escenario queda sin comprobar. Cuantificar creación de controles y CPU/RAM sigue pendiente.

Cambios del addon: `UIComponents.lua`, `UI.lua`, `RecipeCatalog.lua` y `Professions.lua`. Versión conservada 0.2.1 en `main` local. Instalación posterior autorizada por el usuario: copiados los 40 archivos a Forever y verificados por SHA256, sin archivos adicionales. Sin commit, push o interacción con el cliente; validación manual pendiente.

| Elemento | Estado |
|---|---|
| Hallazgos y propuesta | Documentados; magnitud del consumo pendiente de medición. |
| Hallazgo 1 | Creación bajo demanda y limpieza de callbacks implementadas localmente; virtualización y medición pendientes. |
| Hallazgo 2 | Actualización por objeto implementada localmente; pendiente verificación manual y medición. |
| Hallazgo 3 | Colas y liberación de paquetes optimizadas localmente; recuperación completa periódica conservada, pendiente medición multicliente. |
| Hallazgo 4 | Agrupación de repintados, propiedades sin cambios y limpieza con mapa cerrado implementadas localmente; pendiente validación manual y medición. |
| Hallazgo 5 | Eliminación de transferencias vencidas implementada localmente; pendiente comprobación con recepciones reales. |
| Hallazgo 6 | Índice ordenado reutilizable y próxima comprobación temporal implementados localmente; pendiente validación manual de avisos. |
| Hallazgo 7 | Índice construido solo desde perfiles presentes en el roster disponible; historia conservada. Implementado localmente, pendiente prueba manual. |
| Hallazgo 8 | Fichas sin cambios reutilizadas y mapas de miembros/rangos conservados si no hay cambios. Parcial: consultas y mapas candidatos siguen completos, sin agrupación diferida. |
| Hallazgo 9 | Refresco periódico condicionado a vencimientos/cambios visibles, navegador y cálculos reutilizados implementados localmente; pendiente prueba manual. |
| Hallazgo 10 | Consulta del estado real del registrador y guards de argumentos costosos implementados localmente; pendiente prueba manual de ambos modos. |
| Pruebas dentro de Forever de estas optimizaciones | No ejecutadas. |
| Eliminación de datos históricos | No autorizada ni realizada. |
| Instalación para pruebas de hallazgos 1 a 10 | Entregas autorizadas y realizadas; última copia de 9/10 con 40 archivos coincidentes por SHA256. |
| Commit local | Autorizado para consolidar la entrega del 26/11/2026; identificado por el commit que contiene el resumen consolidado. |
| Push o publicación por este plan | No realizados ni autorizados para esta entrega. |

La entrada de estado del proyecto es [MAESTRO-DESARROLLO.md](../MAESTRO-DESARROLLO.md). Este plan conserva el detalle propietario de optimización y su evidencia; el resumen consolidado identifica el alcance del nuevo commit local.

### Evidencia de instalación para pruebas — 25/11/2026

Destino: `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Tartaro`. Versión declarada 0.2.1. Los 40 archivos coinciden con la fuente por SHA256; sin archivos adicionales, borrados, ZIP o respaldos. HEAD conservado. No se ejecutó ni controló el cliente. Pendiente revisión manual del usuario.

| Archivo | SHA256 instalado |
|---|---|
| UIComponents.lua | 4EDA09BABA3312FAD3E4AA009BED561C7F9F440AEF7B6D4327CBD86211CF849E |
| RecipeCatalog.lua | B693E6639981D9D47A283031F30C4DDBBAB0A94B60ED509E5805F0FFF43426B2 |
| Professions.lua | C59A647EA373864337B2ADF8C22724BEDFE9B0E6EC92A707166F71625A6FB308 |
| UI.lua | F99E7B01B0F16C5218CEF5B58002BABB6A657269EBCB32F9F32AF51529F0EC68 |

### Observación manual del usuario — 25/11/2026

Tras instalar los cambios de filas/catálogo, el usuario comunica 2 MB menos de consumo de RAM. No se comunicó el procedimiento de medición; se conserva como observación del usuario y no sustituye una comparación controlada ni valida por sí sola todos los escenarios. El reporte posterior sobre posición de ventana se aborda por separado en la bitácora de UI.

### Revisión local de los hallazgos 3 y 4 — 25/11/2026

**Autorización y alcance:** el usuario solicita trabajar en los hallazgos 3/4. Se conservan protocolo, mensajes, autoridad y frecuencias de sincronización. No se desacopla todavía Q/DQ de la recuperación completa, no se elige un único retransmisor y no se incorpora negociación nueva sin la evaluación multicliente prevista. La mitigación del hallazgo 3 reduce trabajo y referencias retenidas al procesar la sincronización; no demuestra reducción del tráfico ni resuelve la retransmisión global periódica.

**Cola principal (Core.lua):** almacenamiento circular de capacidad 160, con cabecera y ocupación explícitas. Retirar un paquete ya enviado borra solo su casilla y avanza la cabecera; no desplaza los restantes mediante table.remove. Se conserva FIFO, deduplicación, límite de 250 bytes y ocupación secundaria menor que 8. Ubicación/X sigue fuera de la cola ordinaria con prioridad, heartbeat y reintento existentes. Un envío bloqueado o fallido no retira su paquete; el cambio de hermandad reinicia almacenamiento, cabecera, ocupación y deduplicación. El replay serializa cada intento de paquete una vez y usa la misma entrada interna de encolado.

Revisión lógica de la cola, sin ejecutarla: la inserción usa la siguiente casilla modular después de las ocupadas y solo ocurre con ocupación menor que 160; deduplicar no aumenta ocupación. La retirada solo sucede tras resultado de éxito del transporte, reduce ocupación una unidad y restablece la cabecera al vaciarse. Todas las lecturas/escrituras de la cola fueron revisadas para sustituir la longitud de tabla por la ocupación explícita, sin mezclarla con el paquete de ubicación.

**Listas de sincronización (Core/Donations/Orders/GroupAttendance):** al entregar un paquete a la cola se elimina su referencia de la lista de origen. También se liberan entradas descartadas por las condiciones previas de vigencia/duplicado o por tamaño. No se eliminan entradas por un intento de encolado fallido. Las listas se construyen completas antes de consumirse y el consumidor avanza con un cursor; los huecos quedan detrás del cursor y no se usa la longitud de la tabla durante ese recorrido. Esto libera objetos consumidos antes del fin de la lista, aunque la tabla puede conservar capacidad interna hasta liberarse. No se borran registros de negocio ni SavedVariables.

**Mapa (Map.lua y temporizador existente de Core):** los callbacks de cambio de mapa/escala y OpenMap_ViewChanged/OpenMap_StitchedChanged se agrupan mediante invalidateMap y sus 0,12 segundos existentes. Un repintado directo o periódico invalida la solicitud diferida anterior para que no dibuje de nuevo por ese mismo pendiente; una nueva solicitud posterior recibe otra secuencia. Apertura de mapa conserva repintado directo. Los callbacks agrupados pueden añadir hasta la espera programada de 0,12 segundos, sujeta a la ejecución de timers del cliente; fluidez pendiente de comprobar.

Se reutiliza la tabla de posición por personaje y se renueva siempre su vencimiento; repetir coordenadas/nombre no solicita otro repintado por ese mensaje. Continúa el recorrido periódico del mapa mundial a un segundo y el minimapa a 0,25 segundos. Se evitan SetPoint/ClearAllPoints, color, textura, tamaño, escala y nivel de los marcadores propios cuando los valores respectivos no cambian, según corresponda a cada tipo de marcador. Los pins nativos conservan SetPosition en cada dibujo para no asumir cómo actualiza el cliente su geometría. Al adquirir un pin nativo del pool se invalida la caché de aspecto. No se cambia tamaño ni apariencia ni se alteran iconos de otros addons.

El mismo ticker de un segundo llama a updateMap: cuando el mapa mundial está cerrado, limpia posiciones vencidas o ajenas al roster y llamados vencidos/sin permiso; después conserva la detección de mapa/OpenMap que realiza drawPositions. Con mapa abierto, la limpieza sigue en el recorrido de dibujo ya existente. El minimapa continúa recalculando movimiento, orientación y radio. No se guardan transformaciones geográficas entre vistas ni se elimina el recorrido periódico: quedan como candidatos sujetos a medición. Los campos de caché de cada marcador tienen coste en RAM; no se promete ahorro neto ni CPU medida.

**Dependencia contrastada:** lectura del OpenMap instalado en `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\OpenMap\API.lua`: major 1, version 4, callbacks de vista y modo stitched, agrupación propia de ViewChanged con VIEW_GAP de 0,15 segundos. Tartaro conserva detección opcional y su ruta sin OpenMap. No se modificó OpenMap.

**Verificación estática:** compilación sin ejecución de 19 módulos con Lua 5.1; XML, caracteres, TOC/recursos de 40 archivos y diff correctos. 556 funciones instrumentadas y 21 llamadas protegidas, con etiquetas de línea actualizadas. Se revisaron rutas de fallo, rotación/vaciado/reinicio de la cola, consumidores de listas, mutaciones de posiciones/llamados y orden de carga de updateMap antes de PLAYER_LOGIN. No se crearon pruebas ejecutables, simulaciones o herramientas de profiling; no se operó WoW.

**Pendiente manual:** con varios clientes, cola ocupada/vaciada repetidamente, mensajes intercalados con posiciones, bloqueo/reanudación del canal, recuperación tras login/reload, solicitudes simultáneas, cierres/tombstones e inscripciones. Para mapa: OpenMap presente/ausente, zoom, desplazamiento, cambio de escala/zona, posiciones quietas/móviles, entrar/salir de grupo, minimapa rotatorio, cambio entre llamado/personaje, cerrar/reabrir mapa y caducidad con el mapa cerrado. Comparar logs, tráfico, CPU, RAM y fluidez en condiciones equivalentes. Sin estas pruebas no se declara convergencia ni comportamiento visual comprobado.

Cinco módulos modificados para esta revisión: Core.lua, Map.lua, Donations.lua, Orders.lua y GroupAttendance.lua. Se conservan cambios previos de filas, catálogo, posición de ventana y permisos. Main local 0.2.1, sin instalación, commit o push; el addon instalado conserva la entrega anterior de posición de ventana.

### Instalación posterior de hallazgos 3/4 — 25/11/2026

Autorizada por el usuario y realizada en `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Tartaro`. Versión declarada 0.2.1: 40 archivos coinciden con la fuente por SHA256 y no hay archivos adicionales. Core.lua: F12871100E2ED5D92D2DAFFF8B51DE6970DB07D93CA1D554D0B0467F6B18F7B9. Map.lua: 578CAADDD7ED926D72FA78D0D5D54B4DE990FAF3D521457316775FE31525152B. HEAD conservado. Sin commit, push, ZIP, respaldos, borrados o interacción con el cliente. Pendiente revisión manual; la coincidencia de copia no acredita funcionamiento en WoW.

### Revisión local de los hallazgos 5 y 6 — 26/11/2026

**Hallazgo 5:** el callback de los 240 segundos de `receiveProfessions` elimina `incoming[author]` únicamente si la base de hermandad y la transferencia siguen siendo las capturadas. Después invalida el estado de recetas. Una transferencia completa ya tiene entrada nil; una revisión posterior u otro contexto no coinciden y no se borran. Se conserva el protocolo, la ventana de recepción y el temporizador existente. Los callbacks antiguos pueden seguir reteniendo sus capturas hasta ejecutarse a su plazo: no se implementó cancelación o sustitución de temporizadores porque no hay una medición de reemplazos que lo justifique.

**Hallazgo 6:** `eventNotices.events` conserva una lista de referencias de eventos ordenada por hora/ID. Solo se reconstruye cuando se invalida, no en cada ciclo de cinco segundos. Los recordatorios que vencen se extraen en ese mismo orden; no requieren una segunda ordenación y su lista temporal solo se crea si hay al menos uno.

`nextCheck` conserva la próxima entrada de un evento en la ventana de -30 minutos. Entre cambios o fronteras temporales se evita recorrer toda la colección. Si no hay una frontera futura, se usa un marcador infinito solo en memoria. El ticker de cinco segundos no cambia: antes de omitir el recorrido completo sigue comprobando bloqueos, mensaje del día, validez y texto del popup activo, día/contexto e historial del personaje. También procesa la cola de avisos pendientes; estos se validan contra el registro y la ventana -30/+30 al mostrarse. Al llegar al próximo plazo se vuelve a recorrer la lista existente sin ordenarla otra vez.

Se fuerza reevaluación si el reloj retrocede, cambia el día local, cambia la identidad del historial o el desfase local respecto a UTC (comparado mediante las horas/minutos locales y UTC del mismo instante). No se modifica el timestamp del evento ni la regla de hora local. El cálculo de desfase agrega dos tablas de fecha por comprobación; no se afirma coste cero o ahorro medido.

**Invalidaciones revisadas:** `A.invalidateEventNotices` limpia lista/plazo sin disparar un refresco adicional de pantalla. Core la llama al guardar/editar, borrar e inscribirse/desinscribirse localmente. Las recepciones de Core/Replication y la limpieza de Cleanup pasan por `A.invalidate("events")`, que ahora también limpia esta caché. `queuePendingEvents` y `resetGuildWindows` la reinician; el trim de entrada queda seguido de `queuePendingEvents`. Se preservan las reglas de autorización, los recibos persistentes, la prioridad de recordatorios, el resumen de chat de eventos del día por carga y el bloqueo en combate/mazmorra/banda/BG/arena. No se añade temporizador, planificador general, SavedVariable o mensaje de red.

**Trazabilidad:** `professions.transfer.expired` registra autor, revisión y cantidad de partes recibidas/esperadas solo cuando se elimina una transferencia vigente de ese contexto. `notifications.index` registra construcción de índice y `notifications.scan` el recorrido completo y próximo plazo. Se utiliza el registrador existente apagado por defecto, sin pruebas automáticas o datos simulados.

**Verificación ejecutada:** 19 módulos compilados con Lua 5.1 sin ejecutarlos; XML, caracteres, TOC/recursos de 40 archivos y diff correctos; 557 funciones instrumentadas y 21 llamadas protegidas con etiquetas de línea actualizadas. Revisado el orden de carga: el invalidante de UI está definido al ejecutarse los eventos de sesión de Core. Revisión lógica de transferencias completadas/reemplazadas y de todas las escrituras de eventos/inscripciones; esto no constituye prueba dentro de Forever ni medida de CPU/RAM.

**Pendiente manual:** transferencia incompleta que caduca, recepción completa antes del plazo, revisión que reemplaza una anterior y cambio de contexto. Para avisos: iniciar/reload con eventos de hoy/futuros/pasados; hora/ID de varios recordatorios; edición/borrado/recepción de eventos; inscripción/desinscripción; día nuevo; ventanas -30, inicio, +30 y fuera de ventana; bloqueo/reanudación en combate e instancias; cola con editor abierto; popup activo al expirar o cambiar el evento; cambio de hora/desfase si puede comprobarse sin alterar datos del juego. Con debug activo, índice y recorrido completo deben distinguirse de los ciclos sin cambios. Si un escenario no puede ejecutarse, queda pendiente. El usuario debe operar el cliente; el agente no tiene autorización para hacerlo.

Módulos afectados en esta revisión: Professions.lua, UI.lua y Core.lua. Main local 0.2.1; sin instalación, commit o push. Los 40 archivos instalados conservan la entrega anterior. Se mantienen las optimizaciones y correcciones previas, incluida la posición principal.

### Instalación posterior de hallazgos 5/6 — 26/11/2026

Autorizada por el usuario y realizada en `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Tartaro`. Versión declarada 0.2.1; 40 archivos coinciden por SHA256 con la fuente y no hay archivos adicionales. Core.lua: 978AFF767EFB28F6A3BF45C0D4CCAFE1B476B7B4DD7A13EC604ACE7E515FFB45. Professions.lua: 564C6A0B56EEA9FBEECFD8C601275438DA792326B6A57628A40EEA93D52E77F6. UI.lua: 66DDAE30C3FD3929FB5F2202F317C69BA02238C4E2799764634E320E9CBD9F50. HEAD conservado. Sin commit, push, ZIP, respaldos, borrados, modificación externa de SavedVariables o interacción con el cliente. Validación manual pendiente; la copia verificada no demuestra ejecución correcta dentro de WoW.

### Revisión local de los hallazgos 7 y 8 — 26/11/2026

**Hallazgo 7:** `buildCatalog` parte de los identificadores de `A.members` y consulta su perfil de profesiones, en lugar de recorrer todos los perfiles guardados y preparar sus recetas antes de filtrarlos. Tanto la estructura visible como el índice de objetos incorporan únicamente recetas de esos perfiles presentes. Se mantienen la deduplicación de metadatos y la actualización por objeto de la entrega anterior.

No se borra ningún perfil, informe histórico, material, catálogo de profesiones o SavedVariable. La ausencia en un roster parcial no se interpreta como expulsión: solo restringe la preparación del índice visible a la información disponible, igual que el filtrado de resultados anterior ya restringía su presentación. Cuando aparece o desaparece un identificador, `refreshRoster` invalida el catálogo estructural, no solo la búsqueda; así puede incorporar un perfil previamente omitido o liberar sus referencias del índice. La siguiente búsqueda usa el roster actualizado. Un cambio de conexión, rango, nombre, clase o nivel sin cambio de identificadores invalida resultados, conservando la estructura de recetas.

**Hallazgo 8:** Core compara los campos de la ficha antes de crear un reemplazo. `rosterMember` devuelve la ficha anterior solo cuando identificador, nombre, rango/nombre de rango, conexión, clase y nivel coinciden. Las fichas cambiadas se reemplazan; no se modifican las anteriores. Esto mantiene una instantánea previa válida para comparar desconexiones y limpiar confirmaciones de presencia/Overlord, y conserva referencias de fabricantes cuando no cambian sus datos.

El personaje propio se normaliza sin mutar la ficha anterior: mantiene prioridad del registro resuelto del roster, conexión local verdadera y nivel válido de UnitLevel según las reglas previas. Se actualiza también su referencia de alias si apuntaba a la ficha reemplazada; los alias ambiguos siguen siendo ambiguos. La reutilización se limita al mismo identificador de hermandad. Si no cambia ningún miembro o rango, se vuelven a usar los mapas anteriores de miembros/rangos. El mapa de alias se conserva recién reconstruido para mantener la resolución de la lectura actual.

**Límite explícito del punto 8:** se siguen consultando todas las filas del roster y construyendo mapas candidatos de miembros/rangos/alias. Se reduce la creación de fichas por personaje sin eliminar la reconstrucción global. No se añadió debounce, espera o temporizador; cada evento conserva su procesamiento inmediato. Agrupar consultas requiere medir la frecuencia y resolver cómo mantener igual de inmediatas revocaciones de permisos y conexión; queda pendiente, no se declara el hallazgo completamente resuelto. No se anuncia ahorro de MB, CPU o llamadas a la API medido.

**Trazabilidad y revisión:** `Core.rosterMember` queda instrumentada y `roster.refresh` distingue cambios generales de cambios de identificadores. Se revisaron referencias retenidas por RecipeCatalog/UI y las comprobaciones de sesión de Core/Version. Las mutaciones de las fichas propias se sustituyeron por comparación/reemplazo, conservando la comprobación de datos legibles y valores desconocidos. Las reglas administrativas y de negocio no cambian, y no se agrega ningún dato enviado por red.

**Verificación ejecutada:** compilación de 19 módulos con Lua 5.1 sin ejecutarlos; XML, caracteres, TOC/recursos de 40 archivos y diff correctos. 558 funciones instrumentadas y 21 llamadas protegidas; etiquetas actualizadas. Revisión lógica de fichas iguales/cambiadas, personaje propio, entradas/salidas y presencia previa; no equivale a prueba ejecutada con la API del cliente.

**Pendiente manual:** apertura de recetas con perfiles históricos, roster parcial y posterior llegada de miembros; salida/reincorporación y datos recibidos antes/después del roster; filtros de fabricante/conexión, nombres, nivel, clase y metadatos por objeto. Verificar permisos 0/1/Dev, pérdida de rango con pantallas abiertas, conexión/desconexión/reconexión y caducidad de informes de Tartaro/Overlord. Repetir eventos sin cambios y comparar creaciones de ficha, CPU y RAM con datos equivalentes. No borrar perfiles o alterar la guild para fabricar evidencia sin autorización; los escenarios que no se puedan producir quedan pendientes.

Cambios de esta revisión: Core.lua y RecipeCatalog.lua; documentación de estado/plan/contador de trazas. Main local 0.2.1, sin instalación, commit o push. Se conservan los cambios de entregas anteriores; los 40 archivos instalados permanecen en el estado de 5/6.

### Instalación posterior de hallazgos 7/8 — 26/11/2026

Autorizada por el usuario y realizada en `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Tartaro`. Versión declarada 0.2.1; los 40 archivos coinciden por SHA256 con la fuente y no hay archivos adicionales. Core.lua: 5BE6A100B5463ED56DD3763CC8F2294CE43804AEAAC13A12DE7A08842A0AAAA5. RecipeCatalog.lua: 9F8319315CF0726C1551F973C60230CB5E677A5311C96E3D297B780ABEA73925. HEAD conservado. Sin commit, push, ZIP, respaldos, borrados, modificación externa de SavedVariables o interacción con el cliente. Validación manual pendiente; la coincidencia de archivos no acredita funcionamiento dentro de WoW.

### Revisión local de los hallazgos 9 y 10 — 26/11/2026

**Hallazgo 9, listas:** Pedidos, Donaciones y Buscar grupo dejan de invalidarse incondicionalmente cada cinco segundos. Después de renderizar se calcula la próxima frontera temporal de sus registros: caducidad de siete días para pedidos/donaciones y 30 minutos para grupos. Pedidos/donaciones incluyen la frontera de admisión de fecha futura que usan sus reglas existentes (creación menos 120/60 segundos), para que una corrección del reloj no deje oculto permanentemente un registro. Se inspeccionan también registros no visibles como superconjunto de plazos; puede producirse un refresco en un plazo de un registro que no se mostraba, pero no se reconstruye toda la vista en cada ciclo estable.

Los plazos se comparan con el inicio del renderizado, para no perder un vencimiento que ocurra mientras se construye una lista. El ticker existente de cinco segundos comprueba si alcanzó el plazo, si cambió la vista o retrocedió el reloj. Un cambio del desfase horario local fuerza también refresco de textos de fecha. La lectura del desfase se comparte mediante `win.LocalTimeOffset` con los avisos del punto 6; no cambia sus reglas. Continúan las invalidaciones por datos/acciones/roster/permisos y los refrescos de Inicio/Calendario al llegar el próximo evento. Se conserva la comprobación de presencia/informes de Miembros; Honor sigue dependiendo de sus invalidaciones y cambio de semana.

**Mapa:** al renderizar Ajustes de mapa se conserva estado mostrado de ubicación, cantidad de posiciones vigentes, último estado del mapa mundial y llamados con sus textos de ubicación. Cada cinco segundos compara esos valores; solo pide reconstruir si cambian. La comparación sigue leyendo las APIs necesarias y recorriendo posiciones/llamados, pero evita preparar filas/callbacks y layout en reposo. Las solicitudes de grupo de un llamado conservan su invalidación de Activities. Las referencias del snapshot de llamados se liberan al ocultar la ventana, abandonar esa vista o reiniciar el contexto. No se modifican los intervalos de dibujo del mapa/minimapa ni el código de otros addons.

**Navegador:** el permiso se reevalúa en cada llamada y se conserva la redirección a Inicio al revocarlo. Cada botón recuerda disponibilidad, índice y selección aplicados; SetShown, anclajes y estilos solo se reaplican cuando cambia su valor. Las constantes de disposición del navegador no cambian. No se elimina la validación de los callbacks/renderizadores ni la administración 0/1/Dev.

**Cálculos del mismo render:** `listVisibleOrders` añade un tercer retorno de resúmenes de ofertas; Inicio y Pedidos reutilizan esos resúmenes en lugar de reconstruirlos. Los dos primeros retornos y los filtros son los mismos. `groupRemainingNeeds` acepta conteos opcionales; las tarjetas con cupos calculan asistencia una vez y la reutilizan para necesidades y detalle. Las llamadas sin conteos siguen calculándolos como antes.

Para conservar el estado visual al retirar el polling completo de grupos, GroupAttendance invalida la vista cuando llega FULL y se elimina una petición pendiente local, y cuando el ticker elimina una pendiente del contexto actual. No se cambian confirmaciones, reintentos, cupos o mensajes. Las otras rutas de éxito/datos ya invalidaban la sección.

**Hallazgo 10:** `A.isDebugEnabled()` devuelve el booleano interno `runtimeEnabled` del registrador. No vuelve a interpretar SavedVariables y no está instrumentada, al igual que el propio registrador. Se protegieron 17 llamadas de UI que construían tablas o consultaban controles/APIs solo para el log, incluyendo editor, notificaciones, selección, sonido, menú de miembro, recetas, pedidos, grupos y `render.end`. Los argumentos se preparan dentro de la condición, no en un callback de evaluación diferida. Permanece la trazabilidad de operaciones/errores, la captura de carga y los límites del registrador. El modo de desarrollo sigue false por defecto; no se cambian preferencias ni se activa debug. Las llamadas de argumentos ya disponibles y los wrappers conservan su coste mínimo; no se afirma coste total cero con debug apagado.

**Verificación ejecutada:** compilación de 19 módulos con Lua 5.1 sin ejecutarlos; XML, caracteres, TOC/recursos de 40 archivos y diff correctos. 563 funciones instrumentadas fuera del registrador y 21 llamadas protegidas; etiquetas de línea actualizadas. Revisadas rutas de invalidación, vencimiento, cambios de reloj, ocultamiento de snapshots, consumidores de los retornos y guards de log. No se ejecutaron APIs de cliente, pruebas simuladas o comparativas de consumo.

**Pendiente manual:** dejar Pedidos/Donaciones/Grupos/Mapa estables y contrastar ciclos de `UI.refresh`/`render.begin` en logs con los chequeos periódicos. Modificar datos y alcanzar vencimientos; comprobar orden, filtros, scroll, selección, botones y metadatos de objetos. Probar alta/baja de peticiones, FULL, reintentos, cupos, llamados que entran/caducan y ubicación activada/desactivada. Repetir revocación/recuperación de rango, ventanas durante combate, cambio de tamaños y posición persistida. Probar debug apagado/activado/apagado con las mismas acciones y confirmar que reaparecen contexto y errores al activarlo. Medir CPU/RAM en condiciones equivalentes, sin atribuir ahorro numérico previo. Si un escenario no puede comprobarse, queda pendiente.

**Límites:** siguen existiendo renderizados completos cuando una fuente de datos invalida la vista, incluida información de objetos y roster. Los controles no están virtualizados. Los chequeos periódicos, las APIs de estado y los snapshots/plazos tienen coste propio; el cambio reduce trabajo repetido identificado pero el rendimiento neto requiere medición. Los puntos parciales 1/3/8 no se cierran por esta entrega.

Módulos afectados en esta revisión: UI.lua, LoadTrace.lua, Orders.lua, Activities.lua y GroupAttendance.lua. Main local 0.2.1, sin instalación, commit o push. Se conservan cambios previos; los 40 archivos instalados siguen en el estado de 7/8.

### Instalación posterior de hallazgos 9/10 — 26/11/2026

Autorizada por el usuario y realizada en `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Tartaro`. Versión declarada 0.2.1; los 40 archivos coinciden por SHA256 con la fuente y no hay archivos adicionales. UI.lua: 8423694A2C3BDBF4EB23164402D29BBA3EEE3C1B53383AD27138164BEF566AF4. LoadTrace.lua: 8C380A41E967CD96B649BF315C9B9D32CFC184C68922094DB245AA601A5A50F6. HEAD conservado. Sin commit, push, ZIP, respaldos, borrados, modificación externa de SavedVariables o interacción con el cliente. Validación manual pendiente; la coincidencia de archivos no acredita funcionamiento dentro de WoW.
