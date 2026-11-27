# Estado de desarrollo de Tartaro

## Consolidación para revisión del PR #16 — 26/11/2026

- Autorizado un nuevo commit local sobre 2e89fa8, conservando 0.2.1: marco/banner Horda final con fondo completo, menú contenido, eliminación desde tarjetas de eventos, cancelación/recuperación de pedidos y resaltado de HOY. Incluye documentación, recursos referenciados, criterios y evidencias de instalación.
- PR #16 comprobado abierto, sin integrar y sin auto-merge antes de consolidar. Autorizado publicar el nuevo commit en codex/tartaro-0.2.1-mejoras-optimizacion y actualizar la descripción para revisión; no hacer merge, auto-merge, release, ZIP o nueva instalación.
- Verificación estática de 19 Lua con LuaJIT compatible Lua 5.1, XML/TOC/40 archivos, caracteres/etiquetas, cableado de acciones, formato OR/OC de la base 0.2.0, conteos 570/26 y diff. No equivale a ejecución real; siguen pendientes aceptación visual, pruebas de permisos/tiempos y sincronización entre clientes.
- Las secciones siguientes y la bitácora conservan el historial de implementación/instalaciones, incluidos los estados anteriores «sin commit» o «pendiente instalar». La referencia de esta consolidación es el commit que contiene esta sección. El PR conserva todo el historial anterior.

## Día actual del calendario — ajuste local, 26/11/2026

- Instalación posterior autorizada: 40 archivos coincidentes por SHA256 en `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Tartaro`, incluido resaltado de HOY y cambios locales previos. Sin extras, borrados, respaldos, ZIP, commit, push o interacción con el cliente. Pendiente revisión visual; las menciones siguientes a instalación pendiente son anteriores a esta copia.

- Calendar.lua resalta la celda de hoy con borde dorado, fondo ámbar y etiqueta HOY, además del número. Usa el todayKey local existente, sin cambiar selección, fechas, agrupación de eventos o hora local.
- Si hoy está seleccionado, conserva borde/etiqueta y usa fondo más claro; otros días seleccionados conservan estilo cobre. Al cambiar de mes/día se reaplica estilo y se oculta etiqueta donde no corresponde. Etiqueta creada bajo demanda, sin timers nuevos.
- Comprobaciones estáticas realizadas; revisión visual real pendiente. Versión 0.2.1 conservada; sin instalación, commit, push o modificación del PR por este ajuste.

## Cobertura interior del banner — ajuste local, 26/11/2026

- Instalación posterior autorizada y realizada: 40 archivos coincidentes por SHA256 en `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Tartaro`, con fondo completo y cambios de eventos/pedidos. Sin extras, borrados, respaldos, ZIP, commit, push o interacción con el cliente. Pendiente revisión visual y funcional. Las menciones siguientes a instalación pendiente describen el estado anterior a esta copia.

- El usuario aprueba marco y textos de la captura instalada, pero solicita que la tela roja y el escudo cubran todo el interior de la cabecera. UI.lua extiende el fondo a 128 px dentro de headerHeight=132, con 2 px de margen exterior; elimina el recuadro inferior independiente.
- Tela y emblema pasan a texturas BACKGROUND del mismo win, detrás de marco y calavera, evitando que un frame hijo oculte la calavera al cubrir su zona. El emblema conserva proporción; título/lema mantienen las mismas posiciones efectivas anteriores.
- No se cambian marco superior, calavera, menú, altura total ni lógica de eventos/pedidos. Sin instalación, commit, push o actualización del PR por este ajuste. Pendiente validación visual del usuario; la instalación anterior aún tiene la franja reportada.

## Eventos, pedidos y diseño — implementación local, 26/11/2026

- Instalación posterior autorizada y realizada: 40 archivos coincidentes por SHA256 en `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Tartaro`, incluyendo diseño corregido, eventos y pedidos. Sin extras, borrados, respaldos o ZIP; sin commit, push o interacción con el cliente. Pruebas visuales y multicliente pendientes. Las referencias siguientes a instalación pendiente describen el estado previo a esta copia.

- Tarjetas de eventos de Calendario, futuros y vencidos: Eliminar evento con confirmación compartida con el editor. Permisos existentes (autor/rangos 0/1), contexto y revisión revalidados; borrado K y marcas de eliminación existentes conservados. Las inscripciones vencidas continúan en solo lectura.
- Tarjetas de pedidos propios: acciones verticales Recuperar pedido o Marcar como completado y Cancelar pedido, sin depender de un ancho restante estrecho. Copias propias recibidas de terceros se muestran sin republicar automáticamente; el propietario puede confirmar recuperación o cancelar.
- Orders.lua conserva ID/fecha y caducidad de 7 días al recuperar/cancelar. Un cierre retransmitido bloquea una copia no confirmada; no cierra un pedido propio autoritativo. OR sigue exigiendo remitente propietario. Candidatos propios no se retransmiten como autoritativos antes de confirmación.
- Solicitudes AQ repetidas cada 60 segundos usando ticker existente (y reintentos iniciales 3/18); sin nuevo timer o formato de paquete. Esto añade tráfico de consulta/respuesta y no garantiza entrega o latencia multicliente.
- Incluye corrección pendiente del diseño: marco Horda de ancho completo, calavera conservada, cabecera original 132 y mínimo de altura del menú según entradas visibles. Continúa sin instalar esta corrección.
- Verificación estática y compatibilidad de formato contra código 0.2.0 del commit 44aa65e; no constituye ejecución con el compañero. Criterios y límites en [bitácora](docs/MEJORAS-DISENO-MENU.md#eventos-pedidos-y-recuperación--26112026). Versión 0.2.1, cambios locales posteriores a 2e89fa8 sin commit, push o modificación del PR #16. Prueba real entre dos clientes pendiente.

## Banner de la Horda — implementación local, 26/11/2026

- Instalación posterior autorizada para pruebas: 40 archivos coincidentes por SHA256 en `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Tartaro`, sin extras. Pendiente revisión visual; sin commit, push o interacción con el cliente.

- Autorizado conservar la calavera y añadir debajo un banner rojo con «Tartaro», «For The Horde!» y emblema de la Horda a la izquierda. Tras el fallo visual reportado por el usuario, marco superior de ancho completo con el lado Horda de perks-theme-hordevsalliance-tp-topbig: extremos/centro proporcionados y tramos planos extensibles. Calavera delante, posición/tamaño y referencia de persistencia conservados.
- Se restaura la cabecera original de 132 px y el banner ocupa 56 px debajo de la calavera. La altura mínima de ventana incluye el número real de entradas visibles del menú y se reevalúa cuando cambia. Estandarte con recursos del cliente identificados en Overlord instalado, consultados directamente sin dependencia, copia de archivos o llamadas a Overlord.
- Recursos consultados al construir la UI, sin timers/animaciones; alternativa roja y emblema nativo si no está disponible el atlas. Sin cambios de lógica, protocolo o versión (0.2.1).
- Detalle: [bitácora](docs/MEJORAS-DISENO-MENU.md#banner-de-la-horda--26112026). Corrección posterior a captura: pendiente inspección visual e instalación de la corrección. La instalación registrada arriba corresponde al primer diseño rechazado. Commit y actualización del PR interrumpidos por el usuario antes de ejecutarlos; siguen pendientes.

## Llamado desde el cadáver — implementación local, 26/11/2026

- Instalación posterior autorizada y realizada para pruebas: 40 archivos coincidentes por SHA256 en `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Tartaro`, sin extras ni interacción con el cliente. Sin commit/push; verificación funcional pendiente del usuario.

- Autorizado permitir llamado en modo fantasma desde el cadáver; Map.lua consulta C_DeathInfo y UI.lua identifica el destino en la confirmación. Revalida estado, permiso y coordenadas al aceptar; sin cambios de protocolo CTA, cooldown o duración.
- PLAYER_DEAD conserva contexto de mundo/instancia y mapa en memoria; el cadáver de instancia se rechaza aunque el fantasma esté fuera. PLAYER_UNGHOST limpia el contexto. Si se inicia o recarga ya fantasma sin contexto de muerte, no se envía. Sin SavedVariables nuevas, coordenadas de reserva ni temporizadores.
- Se consultan el mapa registrado al morir y hasta tres mapas superiores, sin recorrer todos los mapas ni convertir coordenadas manualmente. Coordenadas ausentes/invalidas bloquean el envío.
- Detalle y criterios manuales: [bitácora](docs/MEJORAS-DISENO-MENU.md#llamado-desde-el-cadáver--26112026). Pendiente validación dentro de Forever; no se afirma funcionamiento E2E.
- Versión conservada 0.2.1. Autorizado consolidar los cambios posteriores a 84baf3c en un nuevo commit local, con instalación para pruebas ya realizada, y publicarlo en la rama del PR #16 mientras siga abierto. Comprobado abierto y sin integrar antes de esta operación; actualizar su descripción sin merge ni auto-merge. Las referencias a «sin commit» en la bitácora describen las entregas previas.

## Entrega adicional en commit local — 26/11/2026

- Autorizado un nuevo commit local en main, conservando 0.2.1 y tomando 07155cd como padre. [Resumen consolidado](docs/CAMBIOS-LOCALES-0.2.1.md): ventana/persistencia, Overlord/versiones, acceso 0/1/Dev y optimizaciones 1 a 10 con sus límites.
- Validación de cableado estática sin conexiones obligatorias ausentes detectadas; 19 módulos compilados con LuaJIT compatible Lua 5.1, XML/TOC/recursos y 40 archivos. 563 funciones instrumentadas y 21 llamadas protegidas. No equivale a ejecución dentro de Forever.
- Pruebas manuales y medición pendientes; puntos 1/3/8 parciales. Acceso Dev confirmado por el usuario y 2 MB menos reportados en una entrega previa, sin medición independiente.
- Sin push, merge, release, ZIP o instalación en esta operación. Las secciones siguientes y la bitácora conservan el estado de cada entrega anterior, incluidas sus referencias a cambios aún sin commit en aquel momento. El commit de esta entrega se identifica mediante git log -1.

## Optimización local de refrescos y diagnóstico — 26/11/2026

- Autorizados hallazgos 9/10 del [plan](docs/PLAN-OPTIMIZACION-MEMORIA-CPU.md): listas refrescan por datos o próximo plazo, Mapa compara estado visible y Miembros conserva comparación de presencia. Navegador reaplica disponibilidad/anclajes/estilos solo al cambiar, con autorización siempre revalidada. Se reutilizan ofertas/asistencia en el mismo render.
- GroupAttendance invalida al limpiar peticiones pendientes o recibir FULL, conservando actualización visual sin reconstrucción periódica general. Se preservan reglas temporales, reloj/hora local, acciones e invalidaciones de negocio.
- LoadTrace expone su estado real mediante isDebugEnabled; 17 logs costosos de UI preparan argumentos solo con debug activo. Captura de carga, errores, operaciones, límites y apagado por defecto conservados.
- Verificación estática: 19 Lua 5.1, XML, caracteres, TOC/recursos y 40 archivos; 563 funciones instrumentadas y 21 llamadas protegidas. Pendientes validación manual de vistas/caducidad/ambos modos de debug y medición neta de CPU/RAM. Los puntos parciales 1/3/8 siguen abiertos.
- Main local 0.2.1, cambios previos conservados. Refrescos/diagnóstico instalados posteriormente por autorización del usuario: 40 archivos coincidentes por SHA256, sin extras. Sin commit, push o interacción con WoW; pendiente validación manual.

## Optimización local de perfiles y roster — 26/11/2026

- Autorizados hallazgos 7/8 del [plan](docs/PLAN-OPTIMIZACION-MEMORIA-CPU.md): RecipeCatalog prepara recetas solo para identificadores del roster disponible, conservando toda la historia. Entradas/salidas invalidan catálogo estructural para incorporar perfiles omitidos o retirar referencias visibles.
- Core reutiliza fichas sin cambios, reemplaza las cambiadas sin mutar la instantánea previa y conserva mapas de miembros/rangos cuando son iguales. El personaje propio y los alias mantienen su normalización. El punto 8 queda parcial: siguen consultas completas y mapas candidatos; no se añade demora a eventos de permisos/conexión.
- Verificación estática: 19 Lua 5.1, XML, caracteres, TOC/recursos y 40 archivos; 558 funciones instrumentadas y 21 llamadas protegidas. Pendiente validación manual de roster parcial/cambios, recetas, permisos y presencia/Overlord, y medición de consumo.
- Main local 0.2.1, cambios previos conservados. Perfiles/roster instalados posteriormente por autorización del usuario: 40 archivos coincidentes por SHA256, sin extras. Sin commit, push o interacción con WoW; pendiente validación manual.

## Optimización local de transferencias y avisos — 26/11/2026

- Autorizados hallazgos 5/6 del [plan](docs/PLAN-OPTIMIZACION-MEMORIA-CPU.md): Professions elimina la transferencia vencida solo si sigue siendo la misma en el mismo contexto. Mantiene plazo y temporizador existentes; no cancela capturas antiguas antes de su plazo.
- UI reutiliza lista de eventos ordenada por hora/ID y calcula la próxima entrada en ventana de recordatorio. El ticker de cinco segundos conserva comprobaciones de bloqueo, día, mensaje diario, popups/cola e historial. Core/UI invalidan al cambiar eventos, inscripciones o contexto; se reevalúa ante retroceso de reloj/cambio de desfase local. Sin otro temporizador o cambios de protocolo/recibos.
- Verificación estática: 19 Lua 5.1, XML, caracteres, TOC/recursos y 40 archivos; 557 funciones instrumentadas y 21 llamadas protegidas. Pendientes pruebas reales de recepción/caducidad y reglas de avisos, así como medición de consumo. No se ejecutan simuladores ni se controla WoW.
- Main local 0.2.1, cambios previos conservados. Transferencias/avisos instalados posteriormente por autorización del usuario: 40 archivos coincidentes por SHA256 y sin extras. Sin commit, push o interacción con WoW; pendiente validación manual.

## Optimización local de sincronización y mapa — 25/11/2026

- Autorizados hallazgos 3/4 del [plan](docs/PLAN-OPTIMIZACION-MEMORIA-CPU.md): cola circular de 160 mensajes, serialización única por intento de replay y liberación de paquetes consumidos en Core/Donations/Orders/GroupAttendance. Se conservan protocolo, solicitudes completas, frecuencias, límites, deduplicación y reintentos; el hallazgo 3 queda parcialmente mitigado, sin reducción de tráfico comprobada.
- Map agrupa callbacks de vista con la espera existente de 0,12 segundos, cancela repintados diferidos ya cubiertos, reutiliza registros de posición y evita propiedades de marcadores sin cambios. Continúan ticker mundial de 1 segundo, minimapa de 0,25 y SetPosition nativo. El ticker mundial también limpia caducados con mapa cerrado. Sin cachear transformaciones ni tocar iconos ajenos.
- Verificación estática: 19 Lua 5.1, XML, caracteres, TOC/recursos y 40 archivos correctos; 556 funciones instrumentadas y 21 llamadas protegidas. Pendientes pruebas manuales de colas/sincronización multicliente y mapa/OpenMap, y medición comparativa de CPU/RAM.
- Main local 0.2.1; cambios de sincronización/mapa instalados posteriormente por autorización del usuario: 40 archivos coincidentes por SHA256, sin extras. Sin commit, push o interacción con WoW. Cambios anteriores conservados; pendiente validación manual.

## Persistencia de posición principal — 25/11/2026

- Corrección local en UI.lua: posición principal explícita en TartaroDB.windowPosition, con anclaje/coordenadas normalizadas y referencia del emblema para el modo centrado. Restauración en login y reintento desde refresh si la geometría inicial aún no está disponible; guardado al arrastrar, ocultar, salir y cambiar la preferencia.
- Antes del apilado se conserva la posición independiente; durante el apilado no se sustituyen sus coordenadas por las temporales. El modo centrado conserva la referencia estable salvo movimiento deliberado. Restablecer configuración incluye la nueva posición. Datos anteriores sin registro propio mantienen el posicionamiento disponible; no se recupera una ubicación perdida que no quedó guardada.
- Instalada posteriormente por autorización del usuario: versión 0.2.1, 40 archivos coincidentes por SHA256 y sin archivos adicionales. Pendiente validación manual. Sin commit, push ni interacción con WoW. Detalle y criterios en [bitácora](docs/MEJORAS-DISENO-MENU.md).
- El usuario reporta 2 MB menos de RAM tras la optimización anterior; se registra como observación manual sin método de medición comunicado, no como cuantificación independiente ni prueba de todos los escenarios.

## Plan de memoria y CPU — 25/11/2026

- [Hallazgos, propuestas y criterios de verificación](docs/PLAN-OPTIMIZACION-MEMORIA-CPU.md): diez puntos contrastados en el código local 0.2.1; costes lógicos separados de consumo real todavía no medido. Incluye secuencia propuesta y restricciones de funcionalidad, compatibilidad y trazabilidad.
- Autorización posterior para hallazgos 1 y 2: controles de fila bajo demanda y limpieza de callbacks; actualización de metadatos por objeto sin invalidar toda la estructura de recetas. Cambios locales en UIComponents/UI/RecipeCatalog/Professions, versión 0.2.1; instalados posteriormente para pruebas por autorización del usuario (40 archivos coincidentes por SHA256). Sin commit ni push. Se conservan cambios anteriores.
- Hallazgo 1 mitigado parcialmente: aún se construyen listas completas y el conjunto de filas conserva su máximo; virtualización pendiente. Hallazgo 2 implementado localmente. Detalle, límites y criterios manuales en el plan; no se atribuye ahorro en MB o CPU medidos.
- Verificación estática correcta: 19 Lua 5.1, XML, caracteres, TOC/recursos, 40 archivos; 548 funciones instrumentadas y 21 llamadas protegidas. No se ejecutaron addon ni simulaciones. Validación manual de estos cambios dentro de Forever pendiente.
- El usuario confirmó que con rango Dev puede ver Miembros y Permisos tras la instalación anterior; otros escenarios de permisos siguen pendientes de validación.

## Ampliación local instalada para pruebas: rango Dev — 25/11/2026

- Comprobado mediante lectura de SavedVariables: Tartaro-pty guarda grants[8].name = "Dev"; Tartaro-camwowus2realm8pvp guarda "Addon" en ese índice. Son datos persistidos, no una consulta en vivo del roster.
- canManagePermissions conserva rangos 0/1 y añade únicamente rango 8 con rankName exactamente "Dev". El número sin el nombre no concede acceso. El rango/nombre actual se obtiene del roster mediante las APIs existentes al ejecutar el addon.
- La política compartida cubre navegación/renderizadores/acciones de Miembros y Permisos, escritura local y recepción/reenvío de grants. No cambia canEditEvent ni A.can: no concede otros permisos automáticamente. Los clientes antiguos siguen con su política anterior hasta actualizarse.
- Verificación: 19 módulos compilados con Lua 5.1 sin ejecutarlos; XML, caracteres, TOC/recursos y 40 archivos correctos; git diff --check correcto. Pendiente comprobación manual del acceso Dev y sincronización entre clientes actualizados. Instalación posterior autorizada y realizada: 40 archivos coincidentes por SHA256, sin archivos adicionales, sin interacción con WoW. Sin commit ni push. Core.lua instalado: 469530C8909BE59407129C2F272D75A883FE46788DAC6EC7DAC98A93243BAF52.

## Corrección local en revisión: menú administrativo — 25/11/2026

- Miembros y Permisos solo aparecen para rangos 0 y 1, reutilizando canManagePermissions. El navegador compacta las entradas visibles, bloquea clics no autorizados y revalida al refrescar. Los renderizadores y las acciones pendientes de filas de Miembros también comprueban acceso.
- Cambio de rango/roster o permisos actualiza el menú incluso desde Opciones. Perder acceso con una sección administrativa abierta oculta inmediatamente sus filas y tooltip, pasa a Inicio y solicita refresco agrupado. No se crean permisos nuevos ni un bypass por debug; la identidad de desarrollador sigue sin estar definida.
- Esta corrección no elimina el roster ni los grants utilizados por otras funciones y no modifica la retención o el transporte de informes. No se atribuye ahorro en MB sin medición. Cambios en main local 0.2.1, sin commit ni push; se conserva el trabajo previo. Por autorización posterior se instaló este filtro en Forever el 25/11/2026: 40 archivos coincidentes por SHA256, sin archivos adicionales y sin interacción con el cliente. Validación dentro de WoW pendiente.
- Verificación estática y criterios manuales en la bitácora; pendiente revisión en Forever con rangos permitidos/no permitidos y cambio de rango en vivo.

## Trabajo local posterior: anclaje y datos de addons — 25/11/2026

- Base local main/07155cd, 0.2.1 instalada previamente para pruebas. El anclaje opcional ya fue instalado para pruebas sin commit ni push. El usuario autoriza ahora reinstalar todos los archivos desde la carpeta ausente, incluyendo la detección de Overlord y versiones. Los cambios siguen sin commit ni push; la copia y sus hashes se registran en el resumen de sesión del workspace. Se conserva la versión 0.2.1.
- Opciones incorpora «Mantener centro horizontal y crecer hacia abajo», desmarcada por defecto y persistida como centerWindowOnResize. Activada, conserva el centro del emblema en coordenadas de pantalla antes de redimensionar; crece horizontalmente en ambas direcciones y verticalmente hacia abajo. Respeta ajuste de escala, límites de pantalla y apilado de avisos. Al arrastrar se actualiza el origen sin bloquear el movimiento; al desactivar recupera el tipo de anclaje previo en la posición visible; Restablecer elimina la preferencia.
- Verificación estática correcta: 19 Lua 5.1, XML/caracteres/TOC/recursos, 40 archivos instalables y 542 funciones instrumentadas. Pendiente comprobación visual en Forever de secciones, arrastre, escalas, avisos, bordes, persistencia de la casilla y desactivación. Sin ejecución del addon ni simulaciones.
- Miembros incorpora columna Overlord y tooltip con versiones de ambos addons y fecha del informe. Distingue cargado, desactivado, instalado sin cargar, no instalado, sin datos e histórico. Los demás jugadores deben comunicar el dato mediante Tártaro compatible; sin informe no se afirma ausencia de Overlord. Miembros amplía su contenido a 690 y ventana a 892 para conservar columnas legibles; otras áreas mantienen sus tamaños.
- El mensaje V conserva su primer campo de versión y añade estado/versión de Overlord; se valida formato y longitud. Se registra únicamente el informe del remitente validado contra la hermandad. Historial persistente en memberAddons; confirmación monotónica de esta sesión, caducidad de 150 segundos compartida con presencia y borrado de confirmación al observar desconexión/cambio de hermandad. UI detecta caducidad sin tráfico nuevo de consulta.
- Anuncio silencioso automático al reconocer hermandad y al iniciar sesión/reload, repetición a los 5 segundos y renovación con request cada 60 segundos, además de replay existente. Sin temporizadores nuevos, sin entrada del jugador, sin mensaje visible en chat y sin depender del protocolo propio de Overlord. Nombres/clase/nivel/conexión siguen viniendo del roster y rol del intercambio existente. La entrega de mensajes no se garantiza si WoW bloquea el canal o la cola no puede enviarlos.
- Verificación manual pendiente específica: dos personajes con cliente nuevo/anterior, Overlord cargado/desactivado/ausente, versiones y fechas, reload, reconexión, caducidad del informe aun recibiendo otros mensajes, orden, scroll y acciones. Sintaxis y comprobaciones estáticas correctas; no se ha ejecutado el addon ni el cliente.
- Detalle y criterios: [bitácora](docs/MEJORAS-DISENO-MENU.md). La sección siguiente describe el commit e instalación anteriores.

## Entrega local para pruebas: 0.2.1 — 25/11/2026

- Base actual: main/44aa65e (0.2.0), PR #15 integrado por el propietario remoto. Versión local de desarrollo 0.2.1 confirmada por el usuario el 25/11/2026. La rama anterior de mejoras fue eliminada por autorización expresa. Antes de esta entrega, la instalación contenía los 40 archivos de la base 0.2.0.
- Autorizada la mejora de detección sin alterar conexión, funcionalidades ni permisos. Tras mantener los cambios sin commit durante el desarrollo, el usuario autoriza ahora commit local e instalación en Forever para sus pruebas. No autoriza push ni publicación.
- Miembros separa conexión informada por WoW de actividad de Tártaro: Activo, Sin confirmar, Histórico y Sin detectar. La fecha del último mensaje se consulta en el tooltip; el personaje local muestra un registro local, no una recepción remota ficticia. Se conserva el orden por detección histórica y las acciones autorizadas existentes.
- Se conserva addonSeen en SavedVariables y se usa una marca monotónica solo en memoria para confirmar actividad de esta sesión. Confirmación vigente durante 150 segundos, renovada con cualquier mensaje reconocido del remitente. El registro se invalida al observar desconexión, salida o cambio de hermandad; no se borra la detección histórica ni se transmite un censo de terceros.
- Se reutilizan la solicitud de sincronización de 60 segundos y el temporizador de UI de 5 segundos. No se añade tráfico, evento de red, módulo, dependencia o temporizador. La UI solo se invalida al cambiar el estado mostrado; el silencio se representa como falta de confirmación, nunca como desinstalación. Umbral provisional de implementación, no garantía de entrega ni medición en Forever.
- Verificación estática: 19 Lua compilados mediante Lua 5.1, XML/caracteres/TOC/recursos y 40 archivos instalables; 535 funciones instrumentadas. No se ejecutó el addon ni se recrearon tests o simulaciones. Pendiente verificación manual: entrada/salida/reconexión, apertura de vista tras caducidad, silencio con personaje conectado, recepción tardía, persistencia histórica, tooltip/orden/susurro/invitación y cliente anterior compatible.
- Añadidos avisos persistentes por personaje/hermandad: mensaje del día una vez al día local o al cambiar texto; eventos pendientes solo en el día de inicio y recordatorio único de -30 a +30 minutos (ventana posterior de 30 minutos confirmada por el usuario). No se añade duración al modelo de eventos. Resumen en chat local de cada evento de hoy una vez por carga; sin envío a GUILD. Popups y este resumen bloqueados en combate, mazmorra, banda, BG y arena; se reevalúan pendientes al salir.
- Calendario muestra todas las tarjetas del día por horario/ID, sin selector. Reutiliza cabecera fija y scroll de contenido: solo las tarjetas se desplazan; selección externa o clic llevan su tarjeta a la vista. Se conservan acciones por evento, permisos y consulta de vencidos.
- Durante compilación se detectó el límite de 200 variables locales de Lua 5.1 en UI.lua; corregido agrupando estado de avisos y utilizando el marco de calendario existente, sin módulos nuevos. Compilación final de 19 Lua, XML/caracteres/TOC/recursos y 40 archivos correcta; 535 funciones instrumentadas. Pendiente revisión manual de avisos, bloqueo, cambio de día y render/foco de tarjetas en Forever. No se ejecutan simulaciones ni cliente.
- Entrega en main local, versión 0.2.1, con commit e instalación autorizados el 25/11/2026. Evidencia posterior del commit y copia por SHA256 en el resumen de sesión 2026-11-25-tartaro-021-commit-instalacion del workspace. No se publica ni se controla el juego; pendiente validación manual por el usuario.
- Detalle y criterios manuales: [bitácora](docs/MEJORAS-DISENO-MENU.md). Las secciones siguientes describen la entrega anterior y su historial; no sustituyen este estado local.

## Entrega para revisión: 0.2.0 — 24/11/2026

- El propietario da por concluido el desarrollo de la sesión y autoriza commit local detallado, publicación de codex/mejoras-diseno-menu y apertura de PR hacia main. Prohibido hacer merge o activar auto-merge sin una autorización posterior explícita.
- Versión de la propuesta confirmada por el propietario: 0.2.0; base 0.1.60/262f9f3. Detalle final por área, cambios técnicos y límites: [CAMBIOS-0.2.0.md](docs/CAMBIOS-0.2.0.md). Historial completo: [bitácora](docs/MEJORAS-DISENO-MENU.md).
- Retirados de la propuesta la ventana, botones y ejecutor del diagnóstico guiado. Solo permanecen logs de carga/ejecución controlados por /tartarodebug, apagados por defecto. También se mantiene la retirada de programas externos de tests, que conserva únicamente tres Markdown históricos.
- La propuesta contiene 19 Lua y 40 archivos instalables, con 531 funciones instrumentadas y 21 puntos de pcall registrados. La verificación de cierre es estática; no se declara validación real completa.
- La copia instalada antes de este cierre sigue identificada como 0.1.60 y conserva el diagnóstico guiado anterior. No se actualiza automáticamente con el PR. No se genera ZIP, release o tag; CurseForge sigue aplazado.

## Ajuste de tarjeta de Calendario — 24/11/2026

- Por autorización del propietario se presenta el detalle del evento en una tarjeta compartida: título destacado, fecha/hora local, tipo, descripción, cupos e inscritos y acciones al final. Se conservan selección por clic, tooltip, autorización y vencidos de solo lectura. No cambia almacenamiento, sincronización ni conversión horaria.
- Se sustituye el commit de la propuesta conservando exactamente su mensaje original; la actualización remota queda limitada a codex/mejoras-diseno-menu mediante lease explícito. El PR #15 conserva su título y descripción; no se autoriza merge ni auto-merge.
- Verificación estática de Lua 5.1, XML, caracteres, TOC y recursos; presentación y funcionamiento dentro de Forever pendientes de comprobación manual. No se instala en el juego ni se generan pruebas o ZIP.

## Historial de implementación de la sesión

Las secciones siguientes registran estados intermedios. El estado de la entrega vigente es el apartado anterior; una instalación o diagnóstico descritos abajo no implica que formen parte de la propuesta final.

## Tamaño del launcher y texto con espadas — 24/11/2026

- Añadido control «Tamaño del botón» en Opciones: 50%-150%, pasos de 5%, actualiza SetScale del padre para incluir texto, iconos, fondo y marco. Guarda callLauncherSize; restaura en login, reaplica el centro guardado y vuelve a 100% al restablecer opciones. No fuerza visibilidad ni cambia permisos, confirmación o envío.
- Texto exacto «Llamado a las Armas» con CallSwords a ambos lados y un espacio; base 252x42, etiqueta 228 e iconos de 18 a escala 100%. Sin recursos nuevos. El diagnóstico comprueba el valor guardado y la trazabilidad incluye el cambio de escala.
- Lua 5.1 de 21 archivos, XML, caracteres, TOC/recursos y diff --check correctos; sin ejecución del cliente ni simulaciones. Instalado por petición del usuario el 24/11/2026: 42 archivos coincidentes por SHA256 con la fuente, sin ZIP ni interacción con el cliente. Pendiente comprobar render y escala reales en Forever.

## Diseño del botón Llamado a las armas — 24/11/2026

- Usuario solicita apariencia acorde a WoW, conservando texto y descartando un icono plano como sustituto. UI.lua cambia únicamente la presentación del launcher: UIPanelButtonTemplate de 208x42, tipografía GameFontNormalLarge centrada con sombra y borde nativo metálico tintado en oro envejecido. Sin iconos nuevos, animaciones ni recursos externos.
- Conservados permisos/visibilidad, confirmación, envío, arrastre y posición guardada. Sintaxis Lua 5.1, caracteres, TOC/recursos y diff --check verificados; sin simulaciones ni ejecución del cliente. Pendiente apariencia/legibilidad y dimensiones reales en Forever.
- Instalado por orden del usuario el 24/11/2026 junto al filtro adicional de receta conocida: 42 archivos coincidentes por SHA256 con la fuente. Sin ZIP ni control del cliente. Pendiente revisión visual real.

## Filtro adicional: receta conocida — 24/11/2026

- Por instrucción del usuario, se añade conocer la receta a la rama de pedidos ajenos disponibles sin ofertas, conservando los filtros de pedidos propios y aquellos para los que el personaje ya se ofreció. Se reutiliza knowsRecipe sobre los datos de profesiones existentes.
- Actualizados Orders.lua, la comprobación/guía real del diagnóstico y el LEEME. Sintaxis Lua 5.1, caracteres, TOC/recursos y diff --check verificados sin simulaciones. No cambia sincronización, almacenamiento, cierre, caducidad ni historial de completados.
- Instalado por orden del usuario el 24/11/2026 junto al nuevo diseño del botón. Sin ZIP, publicación ni interacción con el cliente. Pendiente comprobación real.

## Trazabilidad de ejecución autorizada — 24/11/2026

- Ampliado el registrador existente: 577 funciones propias instrumentadas tras añadir los tres callbacks/operaciones de tamaño, 25 puntos de llamadas protegidas existentes, hitos de UI, transporte y resultados de diagnóstico. Se conservan argumentos, self y retornos; la instrumentación no atrapa errores de negocio para ocultarlos.
- Modo controlado por /tartarodebug on, off o consulta sin parámetros. On/off guardan las preferencias de ejecución y carga; off también suspende el diagnóstico activo. developmentBuild=false por instrucción expresa del usuario: apagado por defecto. Se conservan logs anteriores al apagar.
- TartaroDB.debugTrace contiene 1.000 entradas recientes, contadores/última entrada y salida por operación y 30 errores aparte, con secuencias, horas y reemplazos indicados. TartaroDB.loadTrace conserva el arranque. [Contrato y límites](docs/DEPURACION-CARGA.md).
- Ampliación instalada por orden expresa del usuario el 24/11/2026: 42 archivos contrastados por SHA256 con la fuente, versión declarada 0.1.60 y debug apagado por defecto. Verificados sintaxis, XML, caracteres, TOC y recursos sin ejecutar simulaciones. No se genera ZIP, no se controla el cliente ni se modifican SavedVariables. Pendiente confirmar carga y funcionamiento real dentro de Forever. No publicada.

## Instrucción vigente: retirar pruebas externas — 24/11/2026

- Eliminados por orden del usuario los 20 programas Lua/Python de tests/, incluido run_local.py y test_package.py, y el informe generado Temporary/load-debug/latest.json. No se recrearán simulaciones ni ejecutores sin autorización.
- Los tres Markdown de tests/ se conservan como documentación; ISSUE-6 y REPLICATION son antecedentes. Las referencias previas de esta entrada y de la bitácora a suites aprobadas son evidencia histórica, no programas disponibles ni aceptación real.
- Se conservan código del addon, LoadTrace.lua, diagnóstico instrumentado, datos del jugador y registros reales. La cobertura del debug se amplía posteriormente conforme al apartado anterior. El ejecutor externo --debug-load fue eliminado.
- La validación restante del agente comprende inspección, sintaxis Lua 5.1, XML, caracteres y verificación del paquete real con tools/package_addon.py. No se modifica la instalación ni se interactúa con el cliente en esta retirada.

## Base y alcance actual

- Rama local: `codex/mejoras-diseno-menu`, creada desde `6c1965ebf057832b784c4db757f4515a642f5ee3` (0.1.59).
- Base actual integrada: `262f9f3ed6df2e387f7559fc90ed4847bc6c2184` (0.1.60). Se conservaron los cambios locales de Inicio y filtro, todavía sin commit.
- `Tartaro/LEEME.md` conserva las instrucciones de uso. `distribution/ISSUES.md` conserva la aceptación de los issues existentes; este documento no la reemplaza ni declara pruebas reales adicionales.
- Trabajo autorizado: acceso directo a pedidos desde Inicio y filtro de pedidos propios, aceptados por el personaje y abiertos sin ofertas.
- Usuario autoriza continuar con las partes 2 (Calendario: lista y detalle con desplazamiento separado) y 3 (Buscar grupo: roles restantes y acciones de invitación para el organizador).
- Usuario autoriza partes 4 (Avisos: separación visual y validación anticipada de longitud) y 5 (Profesiones: estados verificables de datos, presentación de objetos y orientación para donaciones).
- Usuario autoriza partes 6 (Honor: filas tabulares compartidas y orden visible) y 7 (Miembros: orden visible y menú de susurro/invitación con revalidación).
- Usuario autoriza partes 8 (Mapa: secciones e invitaciones a solicitantes), 9 (Permisos: creación y edición descritas correctamente) y 10 (Opciones: distinguir la prueba de archivo del modo de alerta).
- Cada hallazgo posterior requiere presentar su solución y obtener aprobación del usuario antes de implementarlo.
- Cambios de esta rama, alcance, evidencia y pendientes: [plan y bitácora](docs/MEJORAS-DISENO-MENU.md).
- El 24/11/2026 el usuario autorizó instalar la candidata local para probarla. Instalación para pruebas actualizada posteriormente con el diagnóstico: 38 archivos en Forever verificados por SHA256. No se ha autorizado publicar la rama; CurseForge sigue aplazado.

## Diagnóstico local autorizado — 24/11/2026

- El usuario solicita un botón de pruebas con log y selecciona comprobaciones locales con pasos guiados.
- Implementado localmente y en revisión: diez consultas automáticas y doce pasos instrumentados, último informe técnico persistente (esquema 2), sin publicaciones/invitaciones/audio automáticos. [Plan y evidencia](docs/DIAGNOSTICO-LOCAL.md).
- Candidata con diagnóstico instalada para pruebas: 38 archivos coincidentes por SHA256. Pendiente reiniciar cliente y probar el botón; no hay ejecución real certificada.
- Revisión 2 terminada en código y verificada localmente; NO instalada por instrucción expresa del usuario. La copia del juego conserva el diagnóstico anterior. Pendiente revisión/validación real.
- La revisión 2 elimina texto libre/aprobación manual, captura acciones/estado/errores Lua con origen y stack cuando está disponible, y exige evidencia para avanzar. Evidencia local no significa revisión visual o E2E.
- La guía no convierte pasos no ejecutados en aprobación; quedan pendientes render y validación real. La separación de su vista se realiza en la refactorización autorizada posterior, descrita más abajo.

## Ajuste de Donaciones — 24/11/2026

- Resuelta localmente la diferencia con Pedidos: ambas usan el mismo grid de tarjetas con renderizadores propios y foco opcional solo para Pedidos.
- Conservados datos, permisos y acciones de donación. Regresiones locales y empaquetado aprobados; pendiente render real y aceptación. No se actualiza el juego, conforme a la instrucción vigente.

## Ajuste de Buscar grupo — 24/11/2026

- Cada búsqueda reutiliza el grid compartido con Pedidos/Donaciones, conservando funciones y filtros. Implementación terminada localmente y regresiones aprobadas.
- No se actualiza el juego. Pendientes render/escalas y aceptación del usuario; evidencia en la bitácora.

## Honor y Miembros: tabla desplazable — 24/11/2026

- Separados título/controles/cabeceras fijos del cuerpo de tabla en el scroll existente, con cálculo de altura y reutilización de filas. Implementación terminada localmente y regresiones aprobadas.
- No se actualiza el juego. Falta validación visual en Forever y aceptación; evidencia en bitácora.

## Calendario mensual — 24/11/2026

- Implementación local terminada: cuadrícula mensual, navegación, resúmenes contenidos, selector de exceso y detalle lateral. Vencidos en solo lectura con inscritos conservados, sin cambiar retención ni operaciones.
- Verificada la mecánica existente de entrada local → when numérico → anuncio UTC/presentación local con relojes simulados. Módulos de negocio y bloque de acciones futuras idénticos al paquete anterior comprobado.
- Regresiones locales y paquete aprobados. No se actualiza el juego; pendiente render/escalas y comprobación real en Forever. Detalle en la bitácora.

## Refactorización POO/DRY/SOLID — 24/11/2026

- Autorizada por el usuario, conservando características y sin actualizar el juego. Componentes visuales por instancia en UIComponents.lua; vista de diagnóstico separada en DiagnosticsView.lua; UI y ejecutor usan contratos pequeños con dependencias explícitas.
- Unificadas lectura de cupos, comprobación del límite de 250 bytes y consulta de ofertas; estados de profesiones separados de sus textos. No cambia el protocolo, esquema persistido, permisos, hora local/UTC ni reglas de negocio.
- Implementación local verificada mediante Lua 5.1, XML, caracteres, regresiones y siete pruebas de empaquetado. Sin errores ni advertencias emitidos por esas comprobaciones. Luacheck/selene no están disponibles; no se declara una revisión con esos analizadores. Pendientes render y ejecución reales en Forever, y aceptación del usuario.
- Detalle de archivos, decisiones de diseño, límites y paquete en la bitácora. No hay commit/push ni nueva release. La versión declarada continúa en 0.1.60.

## Referencias

- Incidencia de carga reportada por el usuario: [DEPURACION-CARGA.md](docs/DEPURACION-CARGA.md). General.log confirma UI.lua:66 → Calendar.lua:98, etiqueta ausente al aplicar estilo a un botón vacío; errores posteriores de Version/Honor al quedar UI incompleta. Corregida la fábrica de botones; trazabilidad temprana y ejecutor --debug-load implementados. Instalada la copia corregida de 42 archivos, verificados por SHA256 contra paquete 8b3a00520c892b33be41c31066c3b87b0cbbc9d34d686ff8c6b428d4e7b31c59. Falta confirmar su carga real. Prohibido inspeccionar o controlar el cliente; solo archivos y pruebas aisladas.

- Contrato del proyecto: [AGENTS.md](AGENTS.md).
- Funcionamiento: [LEEME.md](Tartaro/LEEME.md).
- Retirada de pruebas externas y límites de validación: [tests/LEEME.md](tests/LEEME.md).
- Distribución y sus pendientes: [distribution/CURSEFORGE.md](distribution/CURSEFORGE.md).

## Estado

Partes 1 a 10 y ajustes posteriores implementados localmente y en revisión. El usuario autorizó la refactorización POO/DRY/SOLID documentada arriba. Otras propuestas fuera de ese alcance requieren autorización. La aprobación funcional dentro de WoW sigue pendiente.


La bitácora registra los paquetes sucesivos y sus hashes. La instalación anterior de 41 archivos falló al arrancar según General.log. La instalación vigente contiene 42 archivos con la corrección y el registro de carga, contrastados por SHA256. Sin respaldos ni modificaciones a SavedVariables. La última lectura del archivo SavedVariables no contiene aún loadTrace; no acredita carga de la nueva copia. Pendiente comprobación real del usuario; no declarar resuelto el arranque solo por las pruebas locales.
