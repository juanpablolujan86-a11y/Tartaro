# Revisión del issue #6 — 19/11/2026

Código revisado: versión 0.1.54, commit 05ba2958b4a4dd44e37296930e0ae08e19e6a76d. No se modificó el comportamiento del addon ni se declaró resuelto el reporte.

## UI y estado del pedido

La UI ya tiene una rama para quien se ofreció: muestra «Te ofreciste para fabricar este pedido» y «Susurrar al solicitante». La tarjeta se sigue construyendo en la grilla de Pedidos. No hay una integración pendiente de esa rama.

El callback «Puedo fabricarlo» usa offerOrder, envía OF y registra una oferta verificada. No llama al cierre ni cambia closed/completed. Las recetas de encantamiento con itemID 0 están admitidas en la recepción del pedido; no necesitan un objeto de salida ficticio.

La lista de activos filtra por propietario presente en el roster, fecha vigente y closed falso. Una ausencia del propietario puede ocultar un registro todavía abierto; un cierre autenticado también lo quita de activos. Son rutas verificadas del código, no causas demostradas del incidente reportado.

## Pruebas locales añadidas

`tests/ui.lua` recorre el botón real de oferta para un pedido remoto de spell 7420 e itemID 0. Comprueba estado abierto, oferta propia, título, texto y susurro después del callback, los refrescos diferidos y el replay. Rechaza un cierre enviado por el fabricante. Aísla la desaparición/reaparición al retirar/restaurar al propietario en el roster y la retirada tras cancelación del propietario.

Durante el montaje se corrigió la selección simulada de la pestaña: el filtro de profesiones y la pestaña lateral comparten texto. El test debe seleccionar la pestaña hija de TartaroWindow, no el filtro oculto. Ese problema del montaje no se atribuye al addon real.

`tests/orders_flow.lua` ejecuta los módulos reales Orders y Professions en tres contextos simulados, con un solicitante y dos fabricantes. Recorre creación, transporte de OR/OF, ofertas múltiples/duplicadas, cierres falsificados, replay, reinicialización del módulo conservando datos y completado por el propietario. Repite con encantamiento sin objeto de salida y receta con objeto. Las ofertas no cierran ni ocultan los pedidos en este escenario.

Resultado: pruebas locales aprobadas. La reinicialización simulada de Orders no es un login/reload completo dentro del juego; el transporte simulado no certifica entrega real entre clientes.

## Lo que sigue sin conocerse

No se reprodujo la desaparición reportada ni se capturó la transición real. El registro cerrado mencionado en el issue no se vinculó de forma concluyente a la instancia del reporte. No permite atribuir la causa al botón de oferta ni al solicitante.

Falta confirmar la versión de ambos clientes y comparar el mismo identificador antes/después en solicitante y fabricante: closed/completed, pertenencia al roster, fecha, ofertas, inclusión en la lista y visibilidad de la tarjeta. Si cambia a cerrado, hace falta registrar la acción recibida y su origen; si sigue abierto, revisar roster, fecha, scroll y renderizado en esa sesión. No se solicita publicar SavedVariables completos.

El issue #6 permanece abierto. No se publicó una versión nueva porque no se ha demostrado una corrección funcional.
