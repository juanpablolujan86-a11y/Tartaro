# Pruebas locales de los issues 1 a 4

Ejecutar `python tests/run_local.py` desde la raíz. Requiere Python y una biblioteca Lua 5.1. En este equipo se usa `lua51.dll` de OBS. Se puede indicar otra ruta mediante `TARTARO_LUA51_DLL`.

El ejecutor compila todos los Lua, analiza MapPin.xml, comprueba los caracteres usados y ejecuta el código real de los módulos con APIs de WoW simuladas. No establece conexiones ni modifica el juego.

Cobertura automatizada:

- Rechazo de otra hermandad, espera con datos pendientes, entrada/salida de Tartaro y conservación de SavedVariables.
- Destinos de mazmorra/banda/BG, capacidad de BG, validación de roles y revalidación de una misión al publicar.
- Formulario de grupo y anuncio con enlace completo de misión dentro de 250 bytes.
- Volver a publicar una búsqueda sin cambiar su identidad, vencimiento ni inscritos; roles restantes de BG, cupos completos, permiso retirado y borrador de chat cuando el envío está bloqueado.
- Donaciones exclusivamente por ingrediente sin exigir inventario; metadatos pendientes, materiales válidos, cantidades y ausencia de entrada manual.
- Unicidad por propietario/material, varios solicitantes, autoría en el despacho real de mensajes, cierre antes del alta, replay y vencimiento.
- Construcción de la UI con GetFontString nulo hasta SetText, formularios de donaciones y restauración tras cerrarlos.
- Tooltip repetido/reconstruido, nombres desconectados, cierre, respeto de una línea reemplazada por otro addon y ausencia de mensajes por hover.

La ejecución local pasó el 19 de noviembre de 2026. Los límites temporales se comprobaron moviendo el reloj simulado, no esperando una semana real.

Escenarios manuales: el propietario confirmó el 19/11/2026 que las pruebas de #1–#4 pasaron con dos personajes. Se conserva abajo el alcance del plan; no hay una ejecución independiente del agente, build ni capturas registrados. El ajuste final de entrada por ingrediente se verificó localmente, incluida la selección de otro ingrediente y el rechazo de cantidades inválidas y duplicados.

1. En Forever, comprobar la lista real de mazmorras, bandas, BG y misiones con el personaje utilizado. Publicar una misión y abrir su enlace desde otro personaje.
2. Con dos personajes de Tartaro y la misma versión, crear una donación desde un ingrediente de receta; verla en el receptor, desconectar al solicitante y comprobar que sigue visible. Volver a conectar y cerrar la solicitud.
3. Comprobar el tooltip en las bolsas nativas y en los addons de bolsas utilizados. Repetir sobre otro material, tras un cierre y tras una reconstrucción. Verificar que no afecta mover/dividir/usar objetos.
4. Comprobar un personaje sin hermandad o de otra hermandad, el cierre de formularios al perder elegibilidad y la ocultación/restauración de ventanas durante combate.
5. Revisar recetas, pedidos de fabricación, filtros de objetos ligados y los demás módulos habituales después de instalar.

El propietario autorizó subir el código a GitHub después de las verificaciones locales. Esto no autoriza cerrar issues con pruebas reales pendientes ni publicar en CurseForge. Las instrucciones persistentes están en AGENTS.md y el estado de cada issue en distribution/ISSUES.md.

El empaquetado se comprueba con `python tests/test_package.py` y `python tools/package_addon.py --build`. El último genera el ZIP y un informe local con hashes, sin publicar nada. El informe se excluye de Git para no presentar el estado de una copia modificada como evidencia de un commit posterior.
