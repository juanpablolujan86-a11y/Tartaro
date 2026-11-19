# Implementaciones y aceptación

Versión: **0.1.54**. El propietario confirmó el 19/11/2026 que pasaron todas las pruebas manuales de #1–#4 en Forever con dos personajes. Se registra como validación reportada por el usuario, sin ejecución independiente del agente ni build o capturas proporcionados. El último ajuste de Donaciones pasó las regresiones locales. El cierre se realiza por instrucción expresa del propietario; #5 permanece abierto.

| Issue | Cambios realizados | Verificación local | Aceptación / estado |
| --- | --- | --- | --- |
| [#1](https://github.com/juanpablolujan86-a11y/Tartaro/issues/1) | Categorías, destinos del cliente, roles numéricos y cupos de BG | Listas simuladas, límites y formulario compartido | Pruebas manuales confirmadas por el propietario; listo para cierre |
| [#2](https://github.com/juanpablolujan86-a11y/Tartaro/issues/2) | Nombre exacto Tartaro, espera de datos, aviso fuera de guild, cancelación de estado transitorio y conservación de datos | Entrada/salida, otra guild, espera y cierre de formularios | Pruebas manuales confirmadas por el propietario; listo para cierre |
| [#3](https://github.com/juanpablolujan86-a11y/Tartaro/issues/3) | Misiones del diario, revalidación y enlace nativo en el anuncio | Selección, misión retirada, formulario y enlace sin cortar | Pruebas manuales confirmadas por el propietario; listo para cierre |
| [#4](https://github.com/juanpablolujan86-a11y/Tartaro/issues/4) | Donaciones desde ingredientes, cantidad, autoría, cierre, caducidad, persistencia y tooltip; entrada manual retirada | Ciclo de vida, cierre fuera de orden, duplicados, metadatos y UI/tooltip | Pruebas manuales confirmadas por el propietario; ajuste final con regresión local; listo para cierre |
| [#5](https://github.com/juanpablolujan86-a11y/Tartaro/issues/5) | Preparación local de ficha, licencia elegida, inventario de recursos, changelog y verificador del paquete | ZIP/CRC, contenido, rutas, recursos, versión y hashes | Derechos de recursos, avatar, cuenta, build, mediciones y publicación/instalación reales; CurseForge aplazado |

## Cómo registrar y cerrar un issue

Al terminar las pruebas reales, registrar en el comentario del issue:

- Cambio funcional y versión/commit que lo contiene.
- Cliente/build, versión del addon, personajes usados y addons relevantes para reproducir la prueba.
- Escenarios ejecutados, resultado observado y evidencia disponible; distinguir pruebas locales de pruebas en el juego.
- Limitaciones o fallos que sigan abiertos y su impacto sobre los criterios de aceptación.

Cerrar solo si la implementación y todos los criterios de aceptación del issue están satisfechos. No cerrar por la mera existencia del código, porque compile o porque pase una simulación. Los fallos de la prueba se corrigen y se vuelven a comprobar antes del cierre.

La republicación de búsquedas se añadió por solicitud directa del propietario: conserva identidad, inscritos y vencimiento; muestra roles restantes y respeta permisos. También requiere comprobar el anuncio real en la ronda de pruebas de grupos.
