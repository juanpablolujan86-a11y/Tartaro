# Estado de desarrollo de Tartaro

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
