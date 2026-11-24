# Prueba de replicación 0.1.55

> Estado al 24/11/2026: pruebas y simulaciones externas eliminadas por instrucción del usuario. Las referencias siguientes a sus archivos y ejecuciones se conservan como historial; no representan programas disponibles ni validación real en Forever.

Resultado local: aprobado, con APIs simuladas. No se ejecutó dentro de Forever ni demuestra entrega real del canal de hermandad.

`tests/replication.lua` utiliza Core, Replication, Orders, Donations y Professions reales, incluida la cola y la recepción de Core. El transporte duplica deliberadamente cada mensaje.

1. A crea un evento, un pedido de encantamiento y una solicitud de material.
2. B los recibe sin anotarse al evento. Se desconecta A.
3. B se reconstruye usando solo sus datos persistidos. C empieza con una base vacía.
4. C recupera de B el evento con el mismo ID, el pedido y la solicitud. Se distinguen las copias compartidas de los datos directos.
5. C se anota; B recibe una sola inscripción vinculada al evento original. Tres retransmisiones adicionales no duplican evento, inscripción, pedidos ni avisos de recepción.
6. C recarga sus datos y retransmite a D. Se conservan evento, inscripción y solicitudes.
7. Un miembro normal y un rango con permiso de creación no pueden editar el evento ajeno. Creador, líder y sublíder están autorizados.
8. A vuelve, cierra pedidos y elimina el evento. Vuelve a desconectarse. Un cliente nuevo recibe registros de cierre desde las copias; no reaparece el evento ni los pedidos activos.
9. Se repite con 180 eventos, generando más de 160 fragmentos de retransmisión. La cola termina de distribuirlos: 180 IDs y un aviso por ID, sin omisiones ni duplicados.

También pasaron las regresiones anteriores, compilación Lua 5.1, XML, caracteres de UI y siete pruebas del verificador de paquetes.

## Límites y prueba manual

Las copias retransmitidas no son una firma del autor: nunca sobrescriben registros confirmados y se identifican como compartidas. Un evento compartido permite anotarse al mismo ID; el actor de cada inscripción se autentica en los mensajes directos. Los pedidos de fabricación compartidos siguen necesitando confirmación directa del solicitante para ofrecerse. Los datos confirmados de un cliente pueden seguir antiguos hasta recibir el cambio directamente de su actor autorizado. No se cambió la sincronización de avisos, mensaje del día ni el diagnóstico del issue #6.

Para la prueba real, actualizar A, B y C a 0.1.55. Repetir creación, desconexión de A, recuperación en C e inscripción. Comprobar la misma lista en B/C, reload y reenvíos, y finalmente la cancelación por A. Registrar build, versiones y resultado observado. Hasta entonces esta versión es una prueba y no se presenta como validación E2E.
