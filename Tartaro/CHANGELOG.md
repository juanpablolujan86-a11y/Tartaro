# Cambios

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
