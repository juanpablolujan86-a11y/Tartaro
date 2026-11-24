# Diagnóstico local con guía — 24/11/2026

> Documento histórico: el propietario ordenó retirar de la propuesta 0.2.0 esta ventana, sus botones y el ejecutor. Diagnostics.lua y DiagnosticsView.lua ya no forman parte del addon. Solo permanecen los logs descritos en DEPURACION-CARGA.md. Las secciones siguientes documentan el trabajo anterior, no una función vigente.

El registro continuo de ejecución, independiente del recorrido manual, se describe en [DEPURACION-CARGA.md](DEPURACION-CARGA.md). El comando off suspende el recorrido activo; este no se inicia automáticamente.

> Estado al 24/11/2026: pruebas y simulaciones externas eliminadas por instrucción del usuario. Las referencias siguientes a sus archivos y ejecuciones se conservan como historial; no representan programas disponibles ni validación real en Forever.

## Alcance inicial (sustituido por la corrección técnica al final)

El usuario elige «comprobaciones locales con pasos guiados» para un botón que compruebe características y conserve resultados. Se implementa en codex/mejoras-diseno-menu, base 0.1.60. No se autorizan publicaciones de prueba, invitaciones automáticas ni pruebas entre clientes.

- Opciones ofrece Ejecutar pruebas y Ver informe.
- Diez comprobaciones independientes se programan con temporizadores del cliente. Esto es concurrencia por callbacks, no hilos paralelos. Consultan datos/reglas locales sin enviar paquetes, reproducir audio, cambiar ajustes o crear/cerrar registros.
- Un panel separado muestra el resultado y una guía por las diez áreas, incluyendo recetas, pedidos y donaciones. Cada paso se confirma manualmente como Correcto, Falló o No pude probar, con observación opcional (obligatoria al señalar fallo).
- Cada entrada conserva origen automático/manual, fecha, esperado, observado y estado. Faltantes y pasos pendientes nunca cuentan como aprobados. Las comprobaciones de disponibilidad de APIs se identifican como tales.
- Se conserva el último informe en TartaroDB.diagnostics, sin historial ilimitado ni archivo de log arbitrario. El cliente guarda SavedVariables al recargar/salir. El informe registra versión y una identificación de esta función para distinguir la candidata de la base publicada.
- Ver informe conserva resultados y permite continuar la guía del mismo personaje/guild. Ejecutar/Repetir inicia un informe nuevo y lo indica en pantalla. Un /reload interrumpido no transforma comprobaciones pendientes en éxito.
- Cambiar personaje/guild invalida una ejecución pendiente. La ventana respeta la ocultación de combate. Al terminar las verificaciones se actualizará la candidata instalada para las pruebas solicitadas en esta sesión, sin backups ni publicación.

## Criterios verificables

1. El botón inicia las comprobaciones y presenta resultados locales identificados con precisión.
2. No se llama al transporte ni a operaciones de publicación/cierre/invitación/audio durante la ejecución automática.
3. Un error se registra sin impedir las comprobaciones independientes restantes. Sin registros para probar, se informa No ejecutada.
4. La guía conserva confirmaciones/notas, avanza sin realizar acciones de juego y permite retomarse desde Ver informe.
5. El informe no afirma éxito completo si hay fallos, omisiones o pasos pendientes; distingue confirmaciones humanas.
6. Cambios de contexto, repetición y recarga no permiten callbacks tardíos sobreescribir otro informe.
7. Lua 5.1, caracteres, XML, regresiones de las diez áreas y empaquetado deben pasar. Render, legibilidad y uso real siguen pendientes de Forever.

## Plan y límites

1. Crear Diagnostics.lua con estado encapsulado, comprobaciones de solo consulta, informe y guía.
2. Conectar el panel mediante las fábricas visuales existentes y añadir controles de Opciones sin nuevas locals principales en UI.lua.
3. Integrar limpieza de contexto/combate y carga TOC.
4. Probar datos válidos/vacíos, errores, aislamiento, guía, persistencia simulada y callbacks obsoletos. Ejecutar regresiones y generar ZIP local.
5. Registrar evidencia y pendientes. No implementar refactorizaciones pendientes de POO/DRY/SOLID de otras partes.

Las consultas locales no demuestran sincronización, recepción remota, envío efectivo de invitaciones o audio audible. Esos casos quedan descritos como no cubiertos por el diagnóstico automático.

## Implementación y verificación

- `Tartaro/Diagnostics.lua`: controlador separado con fábricas visuales existentes inyectadas; estado/callbacks encapsulados y API limitada para conectar Opciones, contexto y combate. No incrementa las variables locales del bloque principal de UI.lua.
- Comprobaciones independientes programadas con C_Timer.After(0), capturan el contexto y el informe de la ejecución. Se registra cada error con pcall y continúan las restantes; callbacks antiguos no escriben el informe nuevo.
- Cobertura local explícita: filtro de pedidos sobre datos actuales; consulta de inscritos; estructura de grupos/cupos sin ejecutar groupAttendance (esa función inicializa estado); límite de texto/reloj del editor; estado de profesiones; honor local; identidades/roles; disponibilidad de funciones del mapa; consulta de permisos; preferencias de sonido. Datos ausentes se distinguen de éxito. Disponibilidad no equivale a ejecución del flujo.
- Doce pasos guiados cubren las diez áreas, separando recetas, pedidos y donaciones. Los botones registran el origen manual, esperado, observado y hora, y avanzan. Falló exige observación; notas y errores se limitan sin cortar caracteres UTF-8.
- `Tartaro/Tartaro.toc`: Diagnostics.lua antes de UI.lua. `Tartaro/UI.lua`: dos botones en Opciones, conexión a resetGuildWindows/updateCombatWindows y panel de opciones de 345 de alto. No se cambian permisos ni protocolo. Nuevo archivo requiere reinicio del cliente para esta instalación.
- `tests/diagnostics_ui.lua`, integrado en tests/ui.lua: consultas con datos válidos/vacíos, captura de errores, continuidad, informe/manuales, notas, cierre/consulta, recarga simulada de módulo, repetición, contexto, combate y callbacks viejos. Verifica igualdad de datos/ajustes antes/después excluyendo solo el informe y bloquea llamadas de envío/audio/crear/cerrar/invitar.
- Ajuste de la prueba previa de Opciones: expectativa de altura de 320 a 345 por los botones nuevos. Se conserva la cobertura del resto del panel.
- `python -B tests/run_local.py`: pasaron Lua 5.1, XML, caracteres y todas las regresiones, incluidas las diez áreas anteriores y el diagnóstico.
- `python -B tests/test_package.py`: 7 casos aprobados. `git diff --check`: sin errores.
- No se ejecutó el nuevo botón en Forever; no se afirma render, persistencia real a disco o funcionamiento E2E. La recarga de módulo y las APIs del cliente están simuladas en las pruebas locales.

## Revisión manual pendiente

1. Reiniciar el cliente, entrar con un miembro de Tartaro, abrir Opciones y pulsar Ejecutar pruebas. Revisar que aparecen diez entradas automáticas y doce pasos pendientes; sin registros debe mostrar No ejecutada donde corresponda.
2. Cerrar el panel para recorrer las áreas, volver mediante Ver informe y responder pasos con Correcto, Falló y No pude probar. Un fallo sin nota debe impedir avanzar. Revisar escalas, scroll y textos largos.
3. Recargar después de responder y confirmar que conserva el informe y los resultados; continuar la guía. Repetir debe iniciar un informe nuevo, sin mostrar todo aprobado por defecto.
4. Comprobar ocultación/restauración en combate según ajuste, salida de contexto y recarga durante ejecución sin atribuir éxito a comprobaciones interrumpidas.
5. Confirmar que el recorrido automático no publica, cierra, invita, reproduce audio ni cambia preferencias. La guía solo describe acciones; las realiza el usuario.
6. Verificar el informe guardado tras recargar/salir. No confundir confirmación manual con prueba automática o con sincronización entre personajes.

## Paquete e instalación para pruebas

- ZIP local verificado: Tartaro-0.1.60.zip, 38 archivos, SHA256 `38a7c2e8cac92ccb11c35231cae013d8bf17f8d64e10493646bb4e44c12f7e84`. Informe con cambios sin commit; no es una release publicada.
- Actualizada la candidata ya instalada para pruebas en `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\Tartaro`: 38 archivos copiados y comprobados por SHA256, cero diferencias y ningún archivo adicional. Sin respaldos, borrados, cambios a SavedVariables ni publicación.
- El usuario debe cerrar y volver a abrir el cliente por el nuevo archivo/TOC. Copiar/verificar archivos no demuestra que el diagnóstico haya sido cargado o ejecutado en Forever.

## Corrección autorizada del objetivo — captura técnica

El usuario aclara que el log debe servir al agente para detectar problemas con sustento, no depender de texto libre o aprobación manual. Se corrige la guía: retirar el campo y Correcto/Falló, capturar trazas de vistas/acciones y comparaciones locales, errores Lua con stack cuando la API esté disponible y estados antes/después. Continuar solo registra evidencia local observada; no certifica presentación ni audio audible. Sin evidencia, no se aprueba; No pude probar conserva omisión. Informes anteriores quedan identificados como sin esta evidencia. Captura acotada y restauración del manejador de errores, sin alterar acciones del juego.

## Resultado de la corrección técnica — revisión 2

- Diagnostics.lua usa esquema 2/build menu-local-diagnostico-2. Los informes de esquema 1 conservan identificación de declaraciones manuales y quedan solo para consulta.
- Eliminados el campo de observación y las aprobaciones Correcto/Falló. Registrar evidencia y seguir valida hechos capturados; sin hechos rechaza avanzar. No pude probar registra omisión. El estado observed significa evidencia local, separado de ok de consultas automáticas; revisión visual/audible permanece sin verificar.
- Trazas de vistas y fin de render con dimensiones, paneles, texto real asignado (muestra limitada), selección y scroll. Métricas de renders por vista, sin afirmar causa de parpadeo o rendimiento. Cada entrada tiene secuencia, fecha, paso, vista, datos, condición/resultado y enlace previo del mismo tipo cuando existe.
- Puntos de observación en UI.lua: acceso por ID de pedidos (incluido aviso de indisponibilidad), selección de calendario con posiciones antes/después, ajuste de longitud y enabled real del editor, búsqueda/resultados, filas de pedidos, apertura de formulario de material, orden de Honor (valida resultado del comparador), alternancia de Miembros/menú, tooltip solicitado/resuelto y reproducción solicitada/aceptada por API. No se ejecutan acciones por cuenta del usuario.
- Durante captura se instala un manejador de errores si el cliente ofrece la API; guarda mensaje/stack y encadena el anterior. Al detener, solo restaura si sigue siendo el instalado por esta función. Si otro addon lo sustituyó, no lo pisa. Se excluyen los frames del propio hook de Diagnostics.lua al determinar el origen, evitando culpar a Tartaro por errores externos. Se informa si no hay captura disponible.
- Registro máximo de 400 entradas con contador explícito de omisiones. No se declara registro exhaustivo cuando se supera. La captura se mantiene con el panel cerrado y se detiene al terminar pasos o perder contexto; se retoma desde Ver informe con contexto válido. Recarga y datos sin completar no producen aprobaciones.
- tests/diagnostics_ui.lua ajustado a evidencia observada; prueba acceso real desde Inicio y selección real de Calendario. tests/diagnostics_capture.lua verifica errores/stack/origen, encadenamiento/restauración, respeto a otros handlers, contadores de render, condiciones de pasos, mismatch de tooltip, límites y captura real del bloqueo/recuperación del editor sin publicar.
- El montaje añadió IsEnabled realista para consultar el estado del botón; sin cambiar implementación del cliente ni el criterio de longitud.
- Pasan Lua 5.1, XML, caracteres, regresiones de las diez áreas y diagnóstico; 7 pruebas de empaquetado aprobadas y diff --check sin errores.
- Las pruebas son simuladas. No se ejecutó el recorrido en Forever. El log permite análisis técnico de las condiciones instrumentadas, no certificación completa de todas las características.

## Cierre de implementación de la revisión 2

- El usuario indica expresamente no actualizar el juego y avisar al terminar el desarrollo. No se copiaron archivos de la revisión 2 a Forever.
- Implementación terminada localmente, pendiente de revisión del usuario y ejecución real. Paquete local verificado: Tartaro-0.1.60.zip, 38 archivos, SHA256 `8f9378c05e02babb90f85ac3b50d13eb0a22756df41b8dd029f4ef2075fc64df`.
- La instalación previa permanece con el diagnóstico anterior; no usarla como evidencia de esta corrección. No se ejecutó el botón nuevo en el cliente, no se modificaron SavedVariables del juego, ni se hizo commit/push.
- Pruebas locales ya ejecutadas: compilación Lua 5.1, XML, caracteres, todas las regresiones y captura; 7 pruebas de paquete y diff --check aprobados. Las fuentes de esta corrección no cambiaron después de esas pruebas.
