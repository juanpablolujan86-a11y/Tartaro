# Tártaro 0.2.2 para WoW: Forever

## Consolidación para revisión — 26/11/2026

Este commit adicional sobre 2e89fa8 conserva 0.2.1 y reúne los ajustes locales de banner completo, menú, eliminación de eventos desde tarjeta, recuperación/cancelación de pedidos y resaltado de HOY. Autorizado actualizar PR #16 mientras siga abierto, sin merge ni auto-merge. Las secciones siguientes conservan el estado de entregas anteriores; sus referencias a falta de commit/publicación o instalación son históricas. La instalación previa final fue verificada por SHA256; la actualización documental de esta consolidación no se reinstala. Pruebas visuales finales y sincronización real siguen pendientes.

## Cambios locales de eventos, pedidos y diseño — 26/11/2026

Las tarjetas de eventos de Calendario permiten eliminar con confirmación al autor o rangos 0/1, incluidos los vencidos; sus inscripciones siguen en solo lectura. Las tarjetas de pedidos propios muestran Cancelar pedido y, para copias recuperadas de otro miembro, Recuperar pedido antes de poder completarlo. Las acciones se apilan para evitar recortes. Las copias no se republican automáticamente, conservan ID/fecha y desaparecen al cumplir siete días; una copia vencida no puede recuperarse. Se consulta AQ cada 60 segundos sobre el temporizador existente, sin garantía de entrega inmediata.

También se corrige el primer banner rechazado: marco Horda de ancho completo, calavera conservada, cabecera de 132 px y altura mínima según entradas del menú. Estas correcciones están locales, pendientes de instalación y pruebas reales. La instalación previa del primer diseño no valida este resultado. Detalle y criterios: [bitácora](../docs/MEJORAS-DISENO-MENU.md#eventos-pedidos-y-recuperación--26112026). Sin commit, push o actualización del PR por estos cambios.

## Estado de esta entrega local — 26/11/2026

La versión se mantiene en 0.2.1. El nuevo commit local consolida posición persistente de ventana, informes de Overlord/versiones, acceso administrativo y optimizaciones de memoria/CPU. El detalle técnico, los límites y los criterios pendientes están en [Cambios locales 0.2.1](../docs/CAMBIOS-LOCALES-0.2.1.md) y en el [plan de optimización](../docs/PLAN-OPTIMIZACION-MEMORIA-CPU.md). Los puntos 1, 3 y 8 siguen parciales; no hay publicación remota por esta entrega.

La validación actual es estática: compilación de 19 módulos con LuaJIT compatible con Lua 5.1, XML, TOC/recursos y revisión de cableado. No acredita ejecución completa dentro de Forever. Las referencias siguientes a pruebas simuladas o instalaciones describen antecedentes de cada cambio, no pruebas nuevas de este commit; las baterías externas fueron retiradas y no se recrearon. Las pruebas manuales y mediciones pendientes se detallan en el resumen consolidado.

## Debug de la candidata local

El modo debug registra carga, operaciones y errores de Tártaro sin tener que abrir la ventana del addon. Usá /tartarodebug off para apagarlo, /tartarodebug on para activarlo y /tartarodebug para consultar su estado. La preferencia se guarda entre sesiones. Apagarlo no borra logs anteriores.

Los datos están en TartaroDB.loadTrace (carga) y TartaroDB.debugTrace (ejecución). Conservan 1.000 entradas recientes de ejecución, contadores y últimos datos por operación, y hasta 30 errores aparte. WoW los guarda en SavedVariables al recargar o salir normalmente; no se escriben inmediatamente a un archivo externo. Los registros no ocultan los errores normales ni ejecutan acciones por el personaje. La trazabilidad está apagada por defecto y solo se activa mediante una elección explícita guardada. La existencia del registro no certifica ausencia de errores.

## Refactorización local en revisión

Opciones incluye «Mantener centro horizontal y crecer hacia abajo», desmarcada por defecto. Si se activa, el cambio de tamaño conserva el centro del emblema: el ancho crece a ambos lados y la ventana crece hacia abajo. Se compensa la escala efectiva y se coordina con el apilado de avisos. Arrastrar sigue permitido y actualiza el punto de referencia. Al desactivar se recupera el tipo de anclaje anterior en la posición visible; Restablecer configuración desmarca la casilla. La preferencia y la posición principal se guardan entre sesiones en TartaroDB; se conserva el anclaje y la referencia del emblema, sin sustituir la posición independiente por el apilado temporal. Restablecer configuración incluye ambos datos. Los límites de pantalla pueden recolocar la ventana o el conjunto de avisos cuando no cabe. Este ajuste es posterior al commit e instalación 07155cd; su instalación ha sido autorizada para pruebas y sigue pendiente de validación visual.

El botón muestra «Llamado a las Armas», con espadas cruzadas a ambos lados y un espacio de separación. Conserva el acabado nativo de WoW y el marco metálico dorado. En Opciones, «Tamaño del botón» permite ajustar del 50% al 150%, en pasos de 5%, el botón completo: texto, iconos, fondo y marco. El cambio se aplica al mover el control y queda guardado; «Restablecer configuración» devuelve el tamaño al 100%. Mantiene el arrastre y la posición guardada, y sigue abriendo la confirmación antes de enviar el llamado. La apariencia y la escala requieren comprobación visual dentro del juego.

Los componentes de filas, tarjetas y tablas comparten un ciclo de vida por instancia. Se unifican consultas de ofertas, lectura de cupos y comprobación de tamaño de mensajes; se conserva el comportamiento de negocio, salvo los filtros y cambios de presentación descritos. La revisión local declara 0.2.1 e incorpora presencia reciente de Tártaro en Miembros, control persistente de avisos y tarjetas de calendario apiladas sobre la base integrada 0.2.0. Está pendiente de validación manual; el propietario autoriza commit local e instalación en Forever para pruebas el 25/11/2026, sin publicación remota.

## Cambio local en revisión — Inicio y pedidos

En la rama `codex/mejoras-diseno-menu`, cada pedido mostrado en Inicio se puede pulsar para abrirlo en Profesiones → Pedidos. La tarjeta se identifica y se desplaza a la vista. Si dejó de estar disponible, aparece una explicación. Ver pedidos abre la lista general.

La lista de pendientes muestra pedidos propios, pedidos para los que te ofreciste y pedidos sin ofertas de miembros actuales cuya receta conoce tu personaje según los datos de profesiones del addon. Oculta los pedidos ajenos que solo tienen ofertas de otros personajes y los disponibles cuya receta no figura como conocida. Tus pedidos y aquellos para los que ya te ofreciste conservan su visibilidad. El addon registra ofertas, no una asignación exclusiva: el filtro depende de los datos recibidos. Los pedidos se conservan para sincronización aunque estén ocultos; ofrecerse no los cierra. El historial personal de completados conserva su funcionamiento.

Este cambio pasó pruebas locales con APIs simuladas. Está pendiente de revisión dentro de Forever; no es una nueva release publicada.

## Cambios locales en revisión — Calendario y Buscar grupo

Calendario muestra un mes de siete columnas y seis semanas, con navegación anterior/siguiente y Hoy. El resumen de hora y título permanece contenido en la celda del día; el título completo se consulta al pasar el mouse. + N más selecciona el día. Todas las tarjetas de ese día aparecen una debajo de otra en orden de hora y, en empate, ID. La cuadrícula y la cabecera de fecha/conteo permanecen fijas; solo se desplazan las tarjetas. No hay selector de eventos. Pulsar un evento en la cuadrícula o abrirlo desde Inicio o un aviso desplaza su tarjeta a la vista. Cada tarjeta conserva título destacado, fecha y hora local, tipo, descripción, cupos e inscritos y sus acciones autorizadas.

Los eventos futuros conservan creación, edición, inscripción, cambio/baja de rol, cupos/suplentes y acciones autorizadas sobre participantes. Los vencidos muestran Evento vencido · Solo lectura y los inscritos conservados, sin controles de edición, inscripción o invitación. Los nombres guardados de miembros que ya no están en la guild también se pueden consultar en ese historial. Solo se muestran registros que el sistema todavía conserva; no cambia la purga actual.

Entrar desde Inicio, un aviso o guardar un evento sitúa su mes/día por el mismo ID. Cambiar la fecha de un evento lo coloca en su nuevo día. La ventana de Calendario se amplía y mantiene el ajuste de escala existente; queda pendiente revisar su legibilidad real en Forever.

El editor sigue convirtiendo la fecha/hora local con time y transmitiendo el número when. Cada cliente usa date local para mostrarlo y agruparlo por día; los anuncios conservan date UTC. Un mismo evento puede caer en días locales distintos. No se añade una configuración por país ni se cambia la lógica horaria. Nuevo evento conserva el formulario y su fecha/hora inicial actual.

En las búsquedas de BG, «Faltan» muestra los roles que todavía tienen cupos disponibles, igual que el anuncio al volver a publicar. Cuando todos los cupos están cubiertos se muestra Cupos completos. Las otras actividades conservan sus necesidades publicadas, porque no tienen ese registro de inscripciones por rol.

El organizador de una BG puede pulsar un inscrito para invitarlo al grupo o banda. Si ya lidera un grupo, el menú permite convertirlo en banda, como en Calendario. Un inscrito desconectado no se puede invitar; las acciones se vuelven a comprobar al ejecutarse y dejan de estar disponibles si el participante se retira, vence/cierra la búsqueda o cambian permisos o guild. Si WoW rechaza la invitación directa, se prepara el comando de invitación en el chat para enviarlo manualmente.

Estos cambios solo pasaron pruebas locales simuladas; faltan pruebas visuales y de invitaciones dentro de Forever.

## Cambios locales en revisión — Avisos y Profesiones

Avisos separa cada publicación con el mismo fondo de tarjeta usado en Pedidos. El editor comprueba el tamaño del mensaje que se enviaría mientras escribís: si excede el límite, muestra una explicación y deshabilita Guardar hasta que lo acortes. No recorta el texto. La comprobación también contempla el mensaje del día y los eventos que usan ese editor; se mantiene la validación final al guardar.

Cuando la búsqueda de recetas queda vacía, distingue entre lectura de profesiones, recepción incompleta aún vigente, datos pendientes de objetos consultados, falta de recetas recibidas y búsqueda sin coincidencias en los datos disponibles. Una lista vacía por sí sola no implica que se esté cargando información.

Pedidos y solicitudes de donación reutilizan la fila de objeto con icono y tooltip. Los encantamientos sin objeto de salida conservan su nombre sin inventar un objeto. Donaciones sin solicitudes explica cómo solicitar desde los materiales de una receta e incluye un acceso a Buscar recetas.

Verificación local con APIs simuladas aprobada; faltan render, escalas, interacción real y aceptación del usuario en Forever. No se publica una versión nueva ni se instala esta rama.

## Cambios locales en revisión — Honor y Miembros

Miembros y Permisos solo aparecen en el menú para los índices de rango 0 y 1, o el índice 8 cuyo nombre sea exactamente Dev, conforme a la autorización administrativa compartida. Los demás no ven esas entradas ni pueden abrir sus vistas. El menú se reorganiza sin huecos. Si cambia el rango y se pierde acceso mientras una de esas áreas está abierta, se oculta el contenido y se vuelve a Inicio. No se utiliza el modo debug como permiso de administrador. El usuario confirmó que su rango Dev permite acceder a ambas secciones después de la instalación autorizada. Los demás escenarios de acceso y revocación siguen pendientes de prueba manual.

Miembros añade una columna Overlord. Cada Tártaro compatible consulta su propio cliente mediante las APIs de addons y comunica estado y versión de Overlord, además de su versión de Tártaro. Cargado significa que el cliente lo tiene cargado, sin certificar que todas sus funciones estén operativas; Desactivado indica instalación deshabilitada para ese personaje; Sin cargar indica instalación habilitada todavía no cargada; Instalado indica presencia reconocida sin poder precisar activación; No instalado indica que el cliente no reconoce Overlord. Sin datos significa que no hay informe compatible; no demuestra ausencia. Histórico conserva un informe cuya actualidad no está confirmada. Esto no detecta por sí solo a usuarios de Overlord que no ejecuten Tártaro compatible.

Pasar el mouse por la fila muestra ambas versiones y el momento del informe en hora local. La versión propia de Tártaro procede de su TOC; las ajenas son las últimas versiones comunicadas. El informe de Overlord remoto tiene confirmación de sesión y caduca a los 150 segundos, aunque continúen llegando otros mensajes de Tártaro. Desconexión o nueva sesión obligan a renovar la confirmación sin borrar el historial.

El informe se anuncia automáticamente al reconocer la hermandad al entrar o hacer /reload, a los 5 segundos y con la solicitud existente de cada 60 segundos, además de respuestas a sincronización. Es un mensaje interno del addon a la hermandad, no texto visible en chat ni un popup. No requiere pulsar botones o escribir comandos; los datos de personaje y rol conservan sus fuentes existentes. Puede demorarse si WoW bloquea el envío o hay cola. Clientes anteriores continúan comunicando la versión de Tártaro, pero no aportan estado de Overlord. El usuario ha autorizado reinstalar esta ampliación para pruebas desde una carpeta de addon vacía; la comprobación dentro del cliente sigue pendiente.

La columna Conexión utiliza el estado del personaje informado por WoW. La columna Tártaro distingue Activo (mensaje reconocido en los últimos 150 segundos de esta sesión), Sin confirmar (conectado y detectado anteriormente, sin confirmación reciente), Histórico (detectado antes, pero sin conexión confirmada) y Sin detectar (sin registro local previo). El propio personaje aparece Activo porque este cliente está ejecutando Tártaro. Pasar el mouse por una fila muestra la fecha/hora local del último mensaje recibido; en la fila propia se identifica como registro local. La detección histórica se conserva entre sesiones; no acredita instalación actual.

La confirmación remota se renueva con mensajes existentes, incluida la solicitud de sincronización de cada 60 segundos. No requiere compartir ubicación ni incorpora un mensaje periódico adicional. La caducidad se comprueba cada 5 segundos mientras Miembros está visible; solo se solicita redibujado cuando cambia un estado. Al volver a abrir la vista se calcula con el tiempo actual. Un mensaje retrasado puede recuperar la confirmación: Sin confirmar no implica desinstalación. No se garantiza un plazo de entrega de red.

Honor y Miembros comparten la construcción de las celdas de sus tablas, conservando alturas, colores y reglas de clasificación propios; Miembros amplía su ancho para alojar Overlord. Ambas áreas explican el orden actual. Honor conserva el botón semanal/total y los empates por nombre; Miembros conserva el orden inicial por conexión/nombre y la cabecera Tártaro para alternar detectados/sin detectar primero.

En Miembros, pulsar otro personaje abre un menú con Susurrar e Invitar al grupo o a la banda. Susurrar prepara el chat vacío para ese destinatario; no envía mensajes automáticamente. Estas acciones requieren conexión confirmada. Para invitar estando agrupado se exige ser líder; fuera de un grupo no se exige ese estado. Convertir grupo en banda se ofrece al líder de un grupo que aún no sea banda.

Las acciones vuelven a comprobar personaje, contexto de hermandad, pertenencia, conexión y liderazgo cuando corresponda. No se usan permisos de edición de eventos. Si falla la invitación directa, se prepara el comando de chat existente. Las acciones previas de Calendario y Buscar grupo conservan sus comprobaciones particulares.

Estos cambios solo se verificaron localmente con APIs simuladas. Faltan presentación, susurros e invitaciones reales en Forever y aceptación del usuario. No se instaló ni publicó la rama.

## Cambios locales en revisión — Mapa, Permisos y Opciones

Mapa organiza la información en Ubicación, Estado y Llamados. En los pedidos de grupo del llamado propio, pulsar otro solicitante permite invitarlo mediante el menú compartido. Se exige conexión confirmada y liderazgo si ya estás agrupado; convertir a banda conserva su condición de liderazgo. Antes de ejecutar se comprueba que el llamado siga siendo el propio y esté vigente, con permiso, solicitud, miembro y contexto actuales.

Permisos muestra Crear eventos y explica que solo el creador, el líder y los sublíderes pueden editar un evento. No se cambian las reglas ni los permisos guardados.

Opciones identifica el botón existente como Probar archivo: reproduce por SFX y no comprueba el modo completo de alerta. La explicación distingue la alerta que intenta usar Master y silenciar temporalmente otros canales; sin API de control de volumen usa SFX. No se cambia el audio ni se añade otra prueba. El volumen, selección de sonido y restablecimiento conservan su funcionamiento.

Pruebas locales con APIs simuladas aprobadas; siguen pendientes render, invitaciones y audio real en Forever. La rama no se ha instalado ni publicado.

## Donaciones y Pedidos: presentación compartida

Listar Solicitud de Donacion utiliza las mismas tarjetas de Pedidos: dos columnas, fondo, relleno, separación y altura adaptada al contenido. Cada tarjeta conserva objeto/cantidad, icono/tooltip, solicitante y conexión, fechas y aviso de copia compartida. Cerrar solicitud aparece solo para las propias. El flujo de creación, sincronización y vencimiento no cambia. La vista vacía conserva su guía hacia Buscar recetas.

Este ajuste está en la rama local y pasó regresiones simuladas; no está instalado en el juego y falta comprobar su presentación real.

## Buscar grupo: tarjetas compartidas

Cada búsqueda utiliza el mismo contenedor de dos columnas, fondo, relleno, separación y altura adaptable que Pedidos y Donaciones. Se conservan orden y filtros de búsquedas, roles restantes, contadores, inscripción/baja, acciones sobre participantes y edición/republicación/cierre del organizador. La solicitud de grupo conserva el destinatario de su tarjeta.

El ajuste está implementado localmente y pasó regresiones simuladas; no se instaló en el juego. Falta revisión visual real de nombres largos, escalas y tarjetas de BG con muchos inscritos.

## Honor y Miembros: desplazamiento de la tabla

El título, las explicaciones, los controles de orden y los encabezados de columnas permanecen fijos. Solo las filas de datos utilizan el desplazamiento vertical. En Miembros, la cabecera Tártaro que alterna la detección también queda fija. Al ordenar se vuelve arriba; si se reducen los datos, se limita el desplazamiento al contenido disponible. Las demás áreas conservan su organización.

Cambio implementado localmente y probado con APIs simuladas. No se actualizó el juego; falta comprobar render, fuentes y escalas dentro de Forever.

## Registro de depuración sin interfaz de pruebas

La propuesta 0.2.0 retira la ventana de pruebas guiadas y los botones Ejecutar pruebas/Ver informe. Solo conserva la trazabilidad controlada por /tartarodebug. Los logs de carga y ejecución se guardan en TartaroDB.loadTrace y TartaroDB.debugTrace; los informes antiguos pueden permanecer como datos históricos guardados, pero el addon no los muestra ni ejecuta.

## Versión base

El llamado a las armas admite personajes muertos antes de liberar espíritu y se bloquea como fantasma. Esta versión permite ofrecerse a fabricar un pedido compartido aunque su solicitante esté desconectado. La oferta identifica al fabricante que la envía y sigue asociada al ID original, sin confirmar ni cambiar en nombre del autor el contenido de la copia. El solicitante la recibe cuando coincide conectado con el fabricante, quien retransmite su propia oferta; no se atribuyen ofertas a terceros mediante una copia.

Pedidos y donaciones muestran **Publicado** y **Caduca**, con fecha y hora locales. Su duración sigue siendo siete días desde la creación original: ofrecerse, reenviar o recargar no la extiende. La purga automática se ejecuta al cargar el contexto y cada minuto, solo para la hermandad activa. Elimina pedidos, copias, ofertas y donaciones caducados; conserva sus cierres hasta que venza el plazo original. Para eventos, avisos y cancelaciones conserva el historial anterior de treinta días; no borra datos recientes de otras hermandades ni reinicia la configuración.

Cerrá el juego y copiá la carpeta `Tartaro` a `_forever_/Interface/AddOns/` dentro de la instalación de World of Warcraft. Si ya lo tenés instalado, reemplazá los archivos de esa carpeta. El archivo `Tartaro.toc` debe quedar directamente dentro de la carpeta del addon. En la selección de personaje, verificá que **Tártaro** esté habilitado. Entrá con un personaje de la hermandad y hacé clic en el emblema del borde inferior izquierdo del minimapa. También podés escribir `/tartaro`.

La replicación de 0.1.55 pasó pruebas simuladas y está pendiente de prueba manual en Forever. La confirmación anterior de pruebas manuales de #1–#4 corresponde a 0.1.54, no certifica este cambio. La publicación en CurseForge sigue aplazada.

## Replicación con el autor desconectado

Todos los miembros que reciben un evento conservan su copia en TartaroDB, se hayan anotado o no. Otro miembro puede recuperarla con el creador desconectado. Se conserva el identificador original: anotarse registra al personaje en ese mismo evento y los reenvíos no crean otro evento ni duplican participantes.

Los eventos, inscripciones y solicitudes recibidos por retransmisión se distinguen como **copias compartidas**. No equivalen a cambios autenticados del creador: una copia nunca sobrescribe un registro confirmado. Los cambios confirmados llegan directamente del actor autorizado. Esto puede dejar un registro confirmado antiguo hasta que vuelva ese actor; el canal del juego no permite demostrar la autoría de un paquete reenviado por un tercero. No hay firmas digitales ni servidor externo. Las inscripciones recibidas directamente pertenecen al personaje que envía el mensaje; sus copias se conservan por personaje y revisión.

**Solo el creador, el líder y los sublíderes pueden modificar o eliminar un evento**, aunque otro rango tenga permiso para crear eventos. La UI y la recepción de mensajes aplican esa regla. El creador se identifica por el ID original, no por quien compartió la copia.

Los pedidos de fabricación retransmitidos siguen visibles como **Copia compartida del pedido** y se guardan entre sesiones. Es posible ofrecerse si el fabricante conoce la receta, aunque el solicitante esté desconectado. Las solicitudes de donación también se retransmiten y sus copias se identifican en lista y tooltip. Los cierres y cancelaciones conservan registros que impiden reactivar copias antiguas. Guardar una copia u ofrecerse no concede permiso para editarla o cerrarla en nombre de otro.

Para probar: actualizar todos los participantes a 0.1.55, crear evento y pedidos en A, dejar que B los reciba sin anotarse y desconectar A. Entrar con C sin esos datos: comprobar que recupera el mismo evento, se anota y B ve una sola inscripción. Repetir la sincronización y reload; comprobar que no se duplican. Volver con A para cancelar/cerrar y comprobar la retirada y la recuperación de esos cierres en un nuevo cliente. Si no hay ningún miembro conectado con una copia, no hay datos que recuperar.

## Hermandad y solicitudes de donación

Tártaro solo funciona en una hermandad cuyo nombre sea exactamente **Tartaro**, en cualquier reino. Los datos se guardan por hermandad y reino. Fuera de ella, `/tartaro` muestra «Usted no está en la Guild Tartaro» y se suspenden las funciones y los mensajes del addon. Mientras el juego carga la pertenencia, muestra un estado de espera. Cambiar de hermandad cierra formularios y avisos pendientes sin borrar los datos guardados.

Para crear una solicitud, abrí **Profesiones → Buscar recetas**, seleccioná una receta y pulsá **Solicitar** junto a uno de sus materiales. El formulario muestra ese ingrediente y permite indicar una cantidad entera entre 1 y 1000000. No hace falta tenerlo en las bolsas ni conocer la receta. **Listar Solicitud de Donacion** conserva el listado y el cierre de las solicitudes propias. No hay entrada manual por nombre/enlace ni botón independiente de creación. Esto solicita el material, no la fabricación del producto final.

Se admiten objetos identificados por el cliente como materiales de fabricación o presentes entre los ingredientes de recetas ya consultadas. Si faltan metadatos, se solicita su carga; esperá unos segundos y volvé a publicar. Si el cliente no marca un material antiguo como tal, consultá primero una receta que lo utilice. No se inventan categorías ni se admiten todos los objetos del juego.

Cada personaje puede tener una sola solicitud activa por material. Otros personajes pueden solicitar el mismo material. La lista conserva las solicitudes recibidas aunque su autor esté desconectado. El solicitante puede cerrarlas; también vencen al cumplirse **7 días desde su creación**, según el reloj del servidor. Recibirlas de nuevo o usar `/reload` no renueva el plazo. Un cierre recibido prevalece sobre una copia activa anterior.

Al pasar el mouse sobre un material, el tooltip añade **Solicitado como donación por:** con los nombres de quienes lo solicitan. Solo usa los datos locales; no envía mensajes por cada consulta. No automatiza correo, comercio ni entregas, y no deduce que recibiste materiales por cambios en tus bolsas.

Las solicitudes y cierres se comparten por el mismo canal interno de hermandad, con distinción entre datos directos y copias compartidas. Publicar confirma que el mensaje entró en la cola, no que todos los miembros lo recibieron.

## Misiones en Buscar grupo

En tu búsqueda activa, **Volver a publicar** repite el anuncio en el chat de la hermandad. Conserva los participantes, cupos y vencimiento originales; no crea otra búsqueda. Para las BG anuncia únicamente los roles que aún faltan y no publica si los cupos ya están completos. Las misiones conservan su enlace. Solo puede hacerlo el organizador mientras mantenga el permiso para buscar grupo. Si el juego bloquea el envío, deja el mensaje preparado para enviarlo con Enter.

**Quest (Misiones)** muestra las misiones disponibles en el diario del personaje. Seleccioná una, completá lugar y roles, y publicá. El anuncio de hermandad incluye el enlace nativo de la misión sin cortarlo. Al publicar se comprueba que la misión continúe en el diario. Si el cliente todavía no entrega el enlace, se informa y permite reintentar. No requiere Questie y no acepta ni comparte misiones automáticamente.

## Verificación

La compilación Lua 5.1, el XML y las pruebas con APIs simuladas cubren el acceso por hermandad, destinos de grupos, enlaces de misiones, formularios, autoría de donaciones, duplicados, cierres, vencimiento y tooltips. El propietario confirmó que pasaron las pruebas manuales de #1–#4 en Forever con dos personajes. Esa confirmación fue reportada por el usuario; no es una ejecución independiente del agente ni incluye un build o capturas registrados. El ajuste final que retira la entrada manual de donaciones tiene además cobertura local de regresión. Las simulaciones no demuestran entrega real ni cobertura universal de objetos.

## Primera prueba

**Inicio** muestra el próximo evento, el mensaje del día y tus pedidos de fabricación. Podés ver cuáles solicitaste, cuántos compañeros se ofrecieron y cuáles te ofreciste a fabricar. **Ver pedidos** abre la lista de Profesiones.

Podés arrastrar el botón de Tártaro con el botón izquierdo para cambiarlo de lugar alrededor del minimapa. La posición se guarda entre sesiones.

1. Con dos miembros de la hermandad que tengan el addon, salgan a una misma zona al aire libre, fuera de grupo. Abran el mapa del mundo de WoW y muévanse unos segundos. Comprueben que el aro del color de clase se mueva y muestre el nombre al pasar el cursor. En **Mapa** pueden ver si el juego está aceptando los envíos de su posición y cuántas ubicaciones recientes recibieron.
2. Formen grupo y comprueben que WoW muestre un solo marcador por personaje. Salgan del grupo. En `/tartaro` → **Mapa**, desactiven **Compartir mi ubicación con la hermandad** desde uno de los personajes. El otro debería dejar de verlo.
3. Desde el líder y desde un personaje del rango inmediatamente inferior, abran **Permisos**. Ambos pueden administrar los permisos de Tártaro usando los nombres de los rangos de la hermandad. Para recibir cambios enviados por un sublíder, los miembros necesitan esta versión.
4. En **Avisos**, publiquen un aviso y editen el mensaje del día. Al entrar o usar `/reload`, Tártaro espera unos segundos a que se sincronice y muestra un solo recuadro con el texto vigente. Si lo cierran, el mismo texto no vuelve a abrirse durante esa sesión ese día.
5. En **Calendario**, abran **Nuevo evento**. El calendario debe ocultarse mientras se edita el formulario. **Crear y anunciar** guarda el evento y publica su título y hora en UTC en el chat de la hermandad, visible para los miembros conectados. Si WoW bloquea el envío, el mensaje queda preparado en el chat para enviarlo con Enter. El calendario muestra la hora local de cada jugador. Anoten al segundo personaje y comprueben que el organizador lo vea. Quiten la inscripción y revisen que su nombre desaparezca.
6. Los popups diarios de eventos pendientes de inscripción se limitan al día local de inicio y se muestran como máximo una vez por personaje, evento y día. Los de fechas posteriores no aparecen al entrar. En la ventana entre 30 minutos antes y 30 minutos después del inicio se ofrece un único recordatorio a todos, inscritos o no; si se entra directamente en esa ventana, el recordatorio sustituye al popup diario. Su visualización queda guardada y no se repite por /reload. La emisión manual de Crear y anunciar conserva su funcionamiento.
7. Abran **Miembros** para ver cada nombre con el color de su clase, el nivel, el rol, la conexión y la detección de Tártaro. Hacé clic en el encabezado **Tártaro** para ordenar por detección y volvé a hacer clic para invertir el orden. Si ramas con puntos y roles distintos quedan empatadas o a hasta tres puntos de la rama principal, se muestran los roles juntos. Los druidas muestran **Feral**, **Balance** o **Restauración**, o una combinación de esas ramas.
8. Fuera de grupo y en el exterior, acérquense hasta quedar dentro del alcance del minimapa. Cada uno debería ver el punto del otro. Alejense o cambien el zoom para comprobar que el marcador solo se muestra al alcance.
9. En **Editar evento**, seleccionen el tipo tildando una de las cuatro opciones. Prueben **Eliminar evento** y confirmen la eliminación. El evento y las inscripciones deben desaparecer del calendario de ambos miembros con esta versión.
10. Verificación manual pendiente: crear un evento para hoy a más de 30 minutos, consultar el aviso diario, recargar y comprobar que no se repite. Al entrar en la ventana de -30 a +30 minutos, comprobar un único segundo aviso; tras el inicio indica que ya comenzó, sin afirmar una duración del evento. Más de 30 minutos después no se ofrece. Comprobar también eventos del día siguiente y el cruce de medianoche.
11. Abrí en WoW las profesiones cuyo catálogo falte cargar. En **Profesiones → Buscar recetas**, buscá por receta u objeto y usá **Susurrar** para preparar un mensaje a un compañero conectado. Las fichas ya recibidas siguen disponibles aunque su dueño se desconecte. Para recibir una ficha por primera vez, el personaje que la comparte tiene que estar conectado con Tártaro.
12. En **Nuevo evento** o **Editar evento**, ingresá la fecha y la hora local en sus campos separados.
13. En **Buscar recetas**, buscá por objeto, receta o fabricante. Elegí una receta de la lista fija de la izquierda. La ficha de la derecha se puede desplazar y muestra los materiales y los fabricantes con sus botones de susurro. Probá también los filtros y las flechas de página. Si faltan materiales en el catálogo local, Tártaro los pide a los fabricantes conectados.
14. Abrí **Honor** para consultar y ordenar por honor semanal o total. La semana cambia el miércoles a las 24:00 (jueves a las 00:00), hora del reino. El total conserva el honor que Tártaro ya registró y el semanal empieza a contar al instalar 0.1.38. Gastar honor no reduce ninguno de los dos puntajes. Los empates comparten puesto.
15. En **Permisos**, el líder o un sublíder puede habilitar **Lanzar llamados a las armas** por rango. Al aire libre, pulsá **Llamado a las armas** debajo del minimapa para confirmar el punto de reunión. Un compañero conectado con Tártaro puede elegir **Ver en el mapa** o **Pedir grupo**. El pedido envía un susurro a quien hizo el llamado. Si WoW bloquea el envío, queda un borrador en el chat. El marcador dura cinco minutos.
16. Creá un evento con un cupo de DPS y anoten dos personajes para ese rol. El segundo queda suplente. Al quitar la primera inscripción, el suplente debe pasar a confirmado. Dejá los tres campos de cupos vacíos si querés inscripción abierta.
17. Seleccioná una receta y pulsá **Lo necesito fabricar**. Indicá la cantidad y si ya tenés materiales. En **Profesiones → Pedidos**, un miembro que tenga la receta cargada puede ofrecerse. El solicitante puede susurrarle, marcar el pedido como completado o cancelarlo. Los pedidos duran siete días. Si te llega una copia antes que el mensaje del solicitante, aparece como **Copia pendiente de confirmar** hasta que el addon reciba el pedido directamente de su autor. Al actualizar a 0.1.43 puede hacer falta volver a ofrecerse en pedidos anteriores, porque esas ofertas se guardaron sin poder confirmar el remitente.
18. En **Buscar grupo**, publicá una actividad con lugar y roles. El chat de la hermandad recibe la actividad y los roles que faltan. Si WoW bloquea el envío, presioná Enter en el borrador. Desde otro personaje usá **Pedir grupo** y comprobá que llegue el susurro o se abra el borrador. El aviso dura 30 minutos o hasta que lo cierres.
19. Después de un **Llamado a las armas**, abrí **Mapa** en Tártaro para ver quién pidió grupo. Cerrá el llamado y verificá con el otro miembro que desaparezcan su aviso y su marcador.
20. En **Opciones**, mové el control **Volumen del llamado** y pulsá **Probar sonido** para escuchar los tambores y el doble grito al nivel elegido. El ajuste se guarda entre sesiones. Llevá el control a cero para silenciar la alerta.
21. Al confirmar un **Llamado a las armas**, Tártaro publica en el chat de la hermandad el mismo pedido de refuerzos, con zona y coordenadas. Si el juego bloquea el envío automático, el mensaje queda preparado para enviarlo con Enter.
22. Arrastrá **Llamado a las armas** con el clic izquierdo para mover el botón. La posición se guarda entre sesiones. Un clic corto abre la confirmación del llamado.
23. En **Opciones**, **Restablecer configuración** recupera las posiciones y preferencias personales. Los datos compartidos de la hermandad se conservan. Las ventanas están ocultas durante el combate por defecto y podés cambiarlo desde Opciones. Cuando coinciden, el mensaje del día queda arriba, el aviso de evento en el medio y la ventana principal abajo.
24. En **Lo necesito fabricar**, cambiá la cantidad y revisá el total de cada material. Si faltan datos de la receta, aparecen cuando la ficha los recibe.
25. **Permisos → Publicar búsquedas de grupo** habilita esa acción por rango. Está activo por defecto y se ajusta por separado de avisos, eventos y llamados a las armas. La versión instalada figura en **Opciones**.
26. Al recibir un llamado con sonido habilitado, Tártaro silencia temporalmente los efectos, la música, el ambiente y los diálogos de WoW. Al terminar el MP3 recupera el volumen anterior de cada categoría.
27. Arrastrá el mensaje del día o el aviso de evento con clic izquierdo. Si hay varias ventanas apiladas, se mueven juntas y conservan el orden. La posición se guarda entre sesiones.
28. **Profesiones → Pedidos** muestra dos pedidos por fila. En **Opciones** podés elegir **Tambores y doble grito** o **Nature** y escuchar la selección con **Probar sonido**. El sonido original es el predeterminado.
29. Si Tártaro recibe una versión más nueva desde otro miembro de la hermandad, muestra un aviso en el chat y la versión detectada en **Opciones**. Para compartir su versión, ambos miembros necesitan 0.1.46 o posterior.
30. Quienes pueden editar eventos pueden hacer clic sobre el nombre de un inscrito para invitarlo al grupo o a la banda activa. Cuando ya lideran un grupo, el menú también permite convertirlo en banda.
31. **Buscar grupo** permite elegir **Mazmorra**, **Banda (Raid)**, **BGs** u **Otros**. Los destinos vienen de las actividades que ofrece el cliente del juego y pueden variar según el personaje. Si no hay datos, se informa en el formulario. **Otros** admite texto libre. Completá **Lugar** y cuántos tanques, sanadores y DPS faltan. Vacío o cero indica que no falta ese rol y debe faltar entre 1 y 40 jugadores en total.
32. El selector de **BGs** lee la lista de campos de batalla del cliente, con nombres como Cuenca de Arathi. Los botones usan texto y signos básicos para evitar símbolos que la fuente muestre como cuadrados.
33. En una búsqueda de BG, los cupos no pueden superar la capacidad que informa el cliente. Cada miembro se anota como tanque, sanador o DPS y el organizador confirma las inscripciones en orden de llegada. Los roles completos dejan de admitir inscripciones. Se cuentan las inscripciones del addon, incluido el organizador si se anota. Quitar una inscripción libera el cupo. El organizador debe estar conectado con esta versión para confirmar. **Pedir invitación** abre la coordinación con el organizador tras anotarte.

El addon usa la conexión de WoW y guarda una copia local de los datos. Los miembros actualizados retransmiten eventos, inscripciones y solicitudes recibidos, con las limitaciones de confirmación indicadas al principio. Avisos y mensaje del día conservan su sincronización anterior por el autor; esta prueba no cambia esos módulos.

Cuando el juego ofrece coordenadas válidas al aire libre, Tártaro envía la ubicación cada dos segundos si el personaje se mueve y cada ocho si está quieto. El mapa nativo y OpenMap muestran un punto del color de clase, con tamaño fijo al hacer zoom. La última posición recibida se conserva hasta 75 segundos para tolerar interrupciones breves. Si el compañero apaga el envío y el aviso llega, su marcador se retira en el momento.


## Avisos locales en revisión — 0.2.1

Mensaje del día se muestra una vez por día local y vuelve a mostrarse si cambia su contenido. El registro se conserva por personaje y hermandad en SavedVariables; recargar no lo reinicia. Mostrarlo es lo que consume el aviso, no cerrar la ventana. Un cambio A → B → A se considera cambio de contenido y vuelve a mostrarse.

Los popups de mensaje del día y eventos no aparecen en combate ni dentro de mazmorras, bandas, BG o arenas. Esta regla de avisos se aplica aunque se permita conservar otras ventanas durante combate. Al entrar en esos estados se ocultan; los eventos pendientes se vuelven a evaluar al salir, sin extender su ventana de tiempo. Los avisos ya presentados no se reabren al salir del bloqueo: el registro persistente conserva que se mostraron. Solo los todavía pendientes pueden aparecer si siguen vigentes.

El chat local imprime una línea por evento del día actual en cada carga o /reload, también si el evento se recibe después por sincronización. Cada ID se imprime una sola vez por día durante esa ejecución; no se publica en el chat de hermandad y no se imprime en combate, mazmorra, banda, BG o arena. Al salir se informa de los eventos del día que aún no se habían listado. Esta salida local no reinicia los registros persistentes de popups.

Criterios pendientes: repetir /reload y reconectar sin duplicar popups; cambiar contenido y día; entrar/salir de combate con hideWindowsInCombat activado y desactivado; entrar/salir de mazmorra/banda/BG/arena dentro y fuera de la ventana; revisar dos o más tarjetas, scroll solo lateral, foco de la segunda y botones correspondientes a cada evento. No se ha validado en Forever mediante esta revisión estática.
