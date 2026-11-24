# Cambios

## 0.1.60

Los llamados a las armas se silencian en mazmorras, campos de batalla y raids. Al entrar se cierra el cartel, se descarta cualquier aviso pendiente y se detiene el sonido del llamado.

## 0.1.59

- Mapa y minimapa distinguen a la hermandad fuera del grupo con aros huecos del color de clase. Al entrar a tu grupo o banda se usa el marcador nativo de WoW. La leyenda está en Mapa.

## 0.1.58

- El mapa del mundo y OpenMap muestran dos espadas cruzadas en la ubicación de cada llamado a las armas.
- En Buscar grupo, el organizador puede editar una búsqueda activa, incluido el lugar y los cupos por rol. Se conservan los anotados y el vencimiento original. Los cupos de una BG deben cubrir a quienes ya están anotados.
- Con un grupo o banda reunido para un llamado, los nuevos llamados de sus miembros se registran en el mapa sin repetir la ventana ni el sonido. Los avisos de otros miembros de la hermandad siguen apareciendo.

## 0.1.57

- El llamado a las armas comprueba al abrir y al confirmar que el personaje esté fuera de instancias. Si entra a una raid, BG o mazmorra con la ventana abierta, el llamado se bloquea. Como fantasma también se bloquea en ambos pasos.

## 0.1.56 — Versión estable

- El llamado admite personajes muertos antes de liberar espíritu. Como fantasma se bloquea tanto al abrir la confirmación como al enviarla.

- Ofertas sobre pedidos compartidos con solicitante desconectado, conservando autoría del fabricante, ID, fecha original y estado de copia.
- Fechas de publicación y caducidad visibles en pedidos de fabricación y donaciones.
- Purga automática por fecha, al cargar el contexto y cada minuto, de registros caducados y ofertas asociadas. Conserva cierres todavía necesarios y la retención anterior de treinta días de eventos/avisos.
- Pruebas simuladas de oferta con solicitante desconectado, recarga, reconexión y límite exacto de siete días. Pendiente de prueba manual; no cambia el estado del issue #6.

## 0.1.55 — prueba de replicación

- Caché y retransmisión de eventos e inscripciones con el mismo ID, aunque el creador esté desconectado y el miembro que conserva la copia no se haya anotado.
- Copias compartidas identificadas, sin sobrescribir datos confirmados ni suplantar acciones del autor. Los pedidos de fabricación compartidos siguen pendientes de confirmación directa para ofrecerse.
- Persistencia y retransmisión de pedidos y donaciones compartidos, con registros de cierre para evitar reactivaciones antiguas.
- Edición y eliminación de eventos limitadas a creador, líder y sublíderes, tanto en UI como en mensajes recibidos.
- Prueba local con entrega duplicada, recarga de datos, varios saltos entre miembros y 180 eventos. Pendiente de validación manual de esta versión en Forever; no resuelve ni cierra el issue #6.

## 0.1.54

- Buscar grupo: botón **Volver a publicar** para repetir el anuncio sin reiniciar vencimiento, participantes o cupos. Las BG anuncian los roles que aún faltan; las misiones conservan su enlace.
- Donaciones: creación exclusivamente desde **Buscar recetas → Materiales → Solicitar**, con el ingrediente visible y cantidad. Se retiran la entrada manual y el botón independiente; el listado y cierre se conservan.
- Se documenta la licencia elegida y el estado de procedencia de los recursos.
- Se preparan documentación de distribución y verificaciones del paquete. La publicación en CurseForge está aplazada.

## 0.1.53 — candidata de pruebas

- Issue #2: acceso exclusivo a una hermandad cuyo nombre sea exactamente `Tartaro`, en cualquier reino. Espera durante la carga de pertenencia y cierre del estado transitorio al salir, conservando los datos guardados.
- Issue #3: categoría **Quest (Misiones)** desde el diario, revalidación de la selección y enlace nativo en el anuncio de hermandad.
- Issue #4: solicitudes de donación por enlace o ingrediente, cantidad, cierre del propietario, vencimiento a siete días, persistencia de solicitudes recibidas y nombres de solicitantes en tooltips.
- Corrección de la lectura del tipo de vínculo de objetos para los filtros de recetas.

## 0.1.49–0.1.52 — base publicada

- Issue #1: categorías, destinos del cliente, necesidades numéricas y cupos por rol en búsquedas de BG.
- Correcciones de caracteres de botones y carga del selector de destinos.

El 19/11/2026 el propietario confirmó que las pruebas manuales de #1–#4 pasaron en Forever con dos personajes. Se registra como confirmación del usuario, sin atribuir al agente ejecución real ni un build no capturado. El ajuste final de la entrada de donaciones pasó las pruebas locales con APIs simuladas. #5 permanece abierto y CurseForge aplazado.
