# Depuración de carga — candidata local 0.1.60

## Restricción de operación

El usuario prohíbe inspeccionar o controlar la ventana de WoW. No usar capturas, teclas, clics, comandos ni automatización del cliente. La depuración del agente usa únicamente código, archivos y pruebas aisladas. Una copia de archivos verificada no demuestra que el cliente haya cargado el addon.

## Fallo investigado y corrección

El usuario reporta que la candidata instalada no carga/abre. La lectura posterior de Logs/General.log confirma el fallo de esa carga: 24/11 01:46:16.994, UI.lua:66, attempt to index a nil value; stack SetStyle → Calendar.lua:98 create → UI.lua:126 main chunk. Son las líneas de la candidata instalada anteriormente, no del archivo corregido. El archivo !BugGrabber.lua consultado tenía fecha 13/11/2026 y no contenía entradas de Tartaro. General.log tiene un prefijo de bytes NUL: rg sin -a lo trata como binario y no muestra sus líneas. Se obtuvo la evidencia mediante Get-Content, sin acceder al cliente.

Se comprobó un defecto de robustez en copperButton: SetStyle llamaba a GetFontString():SetTextColor sin garantizar una FontString. Calendar.create crea botones con texto vacío y aplica estilo durante la carga, antes de registrar /tartaro y el botón de minimapa. La prueba anterior creaba automáticamente una FontString incluso para texto vacío, impidiendo detectar ese caso.

El montaje ahora permite que un botón vacío no tenga etiqueta. Antes de corregir producción, la suite falla en UI.lua:66, attempt to index a nil value. La fábrica se corrige creando y asociando explícitamente su FontString centrada, independientemente del texto. Las regresiones pasan con el montaje más estricto. La coincidencia de archivo, línea y stack del registro real confirma este fallo de arranque de la candidata anterior; la carga real de la copia corregida todavía no está confirmada.

General.log registra a continuación Version.lua:21 resetVersionNotice (01:46:20.505) y Honor.lua:78 (01:46:22.035), ambos attempt to call a nil value. El código de esa candidata llama a A.updateVersionLabel y A.refreshHonor: ambas funciones se definen en UI.lua después del punto de interrupción, al igual que /tartaro y el botón de minimapa. La carga abortada deja esas funciones sin definir. No se agregan guardas que oculten los errores secundarios: se corrige la creación del control que interrumpe la carga. La prueba por TOC exige ahora también esos callbacks y accesos definidos.

## Pruebas externas eliminadas por instrucción del usuario

El 24/11/2026 se eliminaron las pruebas y simulaciones Lua/Python y su ejecutor externo. El modo --debug-load del antiguo ejecutor deja de existir; no es el modo de depuración que corre dentro del addon. También se elimina su informe generado Temporary/load-debug/latest.json. Las reproducciones y comprobaciones descritas antes de esta decisión son antecedentes históricos, no pruebas ejecutables vigentes.

Se mantienen la inspección del código, la compilación de sintaxis Lua 5.1, el análisis XML y la verificación de los archivos reales del paquete. Ninguna acredita carga o funcionamiento real del cliente.

## Registro vigente en la propuesta 0.2.0

El propietario ordena retirar la ventana Pruebas locales y guía, sus botones Ejecutar pruebas/Ver informe y el ejecutor Diagnostics. Se eliminan Diagnostics.lua y DiagnosticsView.lua de la fuente y del TOC. Los informes históricos en SavedVariables no se borran, pero no hay código que los muestre o ejecute. La copia previamente instalada 0.1.60 conserva esa interfaz hasta que se solicite actualizarla; el PR no instala archivos en el juego.

LoadTrace.lua se carga primero y registra módulos iniciados/finalizados, faltantes e inicialización. El resto de los 18 módulos contiene 565 funciones propias instrumentadas mediante A.traceCallback, incluyendo las revisiones locales de presencia, avisos, calendario y anclaje opcional de ventana. El registrador no se instrumenta a sí mismo. Se mantienen 24 puntos de llamadas protegidas mediante A.debugPcall, conservando sus resultados originales y registrando errores atrapados sin convertirlos en éxito. presence.changed identifica transiciones observadas en recepción y al caducar la confirmación con la tabla visible; notification.shown registra únicamente avisos efectivamente presentados con día, evento y clase de aviso; addons.report registra cambios de versión/estado recibidos del remitente validado; los logs permanecen apagados por defecto.

Cada entrada incluye secuencia, hora, tiempo relativo, operación, argumentos/resultados resumidos y relación de la salida con su llamada. Se conservan self y retornos múltiples/nil. Las tablas y cadenas se resumen con límites y se evitan valores secretos. También se registran directamente vistas, ventanas, longitud del editor, selección, recetas/pedidos, tooltips, ordenación y transporte. No hay batería de comprobaciones, pasos guiados, registros ficticios ni acciones automáticas de juego para validarlos.

La captura de errores de Tartaro continúa durante la ejecución con debug activo y reenvía el error al manejador previo. captureFailures indica fallos del capturador; un manejador ajeno que no reenvíe puede limitar esta captura. El registro no demuestra ausencia de errores ni sustituye comprobaciones reales.

## Activación y apagado

- `/tartarodebug on`: guarda debugMode/debugLoad=true y activa el registro.
- `/tartarodebug off`: guarda ambos false y detiene las nuevas entradas de ejecución y la captura de debug. Conserva logs anteriores; los errores normales siguen su manejador.
- `/tartarodebug`: muestra estado y cantidad de entradas/reemplazos.

Apagado por defecto mediante developmentBuild=false, respetando una preferencia explícita guardada. Antes de leer SavedVariables hay un buffer de arranque en memoria; no se adjunta si la preferencia está apagada. Los adaptadores permanecen y delegan sin registrar cuando el modo está apagado; no se promete coste cero.

## Persistencia y límites

- TartaroDB.loadTrace: módulos/hitos de carga, faltantes e inicialización, con hasta 160 entradas.
- TartaroDB.debugTrace: anillo de las últimas 1.000 entradas. Se ordenan por sequence, no por posición física después de completar una vuelta. overwritten contabiliza reemplazos.
- counts conserva contadores y última entrada/salida por operación; errors conserva hasta 30 errores recientes, distinguiendo error de caught.error, y errorsOverwritten indica reemplazos. Un error atrapado puede ser una alternativa prevista de compatibilidad, no un defecto confirmado.
- WoW guarda SavedVariables/Tartaro.lua al recargar o salir normalmente. No se escribe un archivo inmediato, no se envían logs ni se controla el cliente. Una lectura en disco durante la sesión puede corresponder a un guardado anterior.

## Verificación de entrega

La comprobación de compilación de esta entrega utiliza la biblioteca local LuaJIT compatible con Lua 5.1; no certifica un intérprete idéntico al del cliente ni ejecuta APIs de WoW.

Inspección de código, auditoría estructural de cobertura, sintaxis Lua 5.1, XML, caracteres, TOC/recursos y diff --check. No se recrean las pruebas externas eliminadas ni se ejecuta el addon mediante APIs simuladas. Pendiente comprobación real por el usuario; el agente no inspecciona ni controla WoW.

## Preparación de datos con debug apagado — 26/11/2026

isDebugEnabled consulta runtimeEnabled del registrador. Diecisiete llamadas de UI comprueban ese estado antes de construir tablas o consultar controles solo para registrar contexto; no se añaden closures de evaluación diferida. Los logs de carga/errores/operaciones, límites y preferencias se mantienen. Siguen existiendo wrappers y llamadas de argumentos simples; no se afirma coste total cero. Implementación local de los puntos 9/10 del plan de CPU/RAM, pendiente comprobación dentro de Forever.


## Consulta de cadáver — 26/11/2026

Map.corpseContext y Map.corpsePosition están instrumentados. Las consultas de posición, lectura de vector y mapa padre emplean debugPcall; errores quedan como caught.error cuando debug está activo. Cobertura total actual: 565 funciones instrumentadas y 24 sitios de llamada protegida. Contexto de muerte solo en memoria, sin nuevos logs persistentes o temporizadores; apagado por defecto conservado.
