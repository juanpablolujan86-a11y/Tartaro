Versión de prueba de la replicación de eventos y solicitudes. **Pendiente de validación manual en Forever.** La versión estable anterior sigue siendo 0.1.54.

- Los miembros guardan y comparten los eventos recibidos aunque no se hayan anotado. Si el creador está desconectado, otro miembro con una copia puede enviarla a quien recién entra.
- Se conserva el ID original. Las nuevas inscripciones pertenecen a ese mismo evento; los reenvíos no generan eventos ni participantes duplicados.
- Solo creador, líder y sublíderes pueden editar o eliminar eventos; tener permiso de creación no permite editar eventos ajenos.
- Se guardan también copias compartidas de pedidos y donaciones, incluyendo cierres para evitar reactivaciones antiguas.
- Las copias se identifican como compartidas y no sobrescriben registros confirmados. Ofrecerse en un pedido de fabricación todavía requiere confirmación directa del solicitante. Esto mantiene separadas las copias de las acciones autenticadas de su autor.

Pruebas locales aprobadas: creador desconectado, miembro sin inscripción que conserva y retransmite, recarga de datos, varios saltos entre miembros, mensajes duplicados, permisos, cierres y 180 eventos a través de la cola. También pasaron las regresiones anteriores y el empaquetado. Son simulaciones, no pruebas dentro del juego.

Para probar, actualizar **todos** los participantes a 0.1.55. A crea, B recibe sin anotarse y A se desconecta. C entra sin los datos, recupera el evento y se anota; B debe ver una sola inscripción en el evento original. Repetir con reload y cancelación. Si no hay nadie conectado con una copia, no se pueden recuperar esos datos.

El issue #6 sigue pendiente de diagnóstico. CurseForge continúa aplazado.
