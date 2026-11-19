# Implementaciones y aceptación

Versión candidata: **0.1.54**. Los cambios de #2–#4 y la republicación se verificaron localmente con APIs simuladas. #1 conserva implementación publicada en 0.1.52 y cobertura local ampliada. No hay pruebas E2E/manuales de esta candidata registradas dentro de Forever.

| Issue | Cambios realizados | Verificación local | Pendiente para cierre |
| --- | --- | --- | --- |
| [#1](https://github.com/juanpablolujan86-a11y/Tartaro/issues/1) | Categorías, destinos del cliente, roles numéricos y cupos de BG | Listas simuladas, límites y formulario compartido | Datos reales por categoría, publicación/recepción/cierre con dos personajes y regresión de pedidos |
| [#2](https://github.com/juanpablolujan86-a11y/Tartaro/issues/2) | Nombre exacto Tartaro, espera de datos, aviso fuera de guild, cancelación de estado transitorio y conservación de datos | Entrada/salida, otra guild, espera y cierre de formularios | Login/reload reales, otra guild/sin guild, tráfico y combate/transiciones |
| [#3](https://github.com/juanpablolujan86-a11y/Tartaro/issues/3) | Misiones del diario, revalidación y enlace nativo en el anuncio | Selección, misión retirada, formulario y enlace sin cortar | Diario y enlace reales, anuncio y recepción en otro personaje |
| [#4](https://github.com/juanpablolujan86-a11y/Tartaro/issues/4) | Donaciones por enlace/ingrediente, cantidad, autoría, cierre, caducidad, persistencia y tooltip | Ciclo de vida, cierre fuera de orden, duplicados, metadatos y UI/tooltip | Dos clientes, bolsas reales, reconexión/reload y compatibilidad de materiales |
| [#5](https://github.com/juanpablolujan86-a11y/Tartaro/issues/5) | Preparación local de ficha, licencia elegida, inventario de recursos, changelog y verificador del paquete | ZIP/CRC, contenido, rutas, recursos, versión y hashes | Cierre de #1–#4, derechos de recursos, avatar, cuenta, build, mediciones y publicación/instalación reales; CurseForge aplazado |

## Cómo registrar y cerrar un issue

Al terminar las pruebas reales, registrar en el comentario del issue:

- Cambio funcional y versión/commit que lo contiene.
- Cliente/build, versión del addon, personajes usados y addons relevantes para reproducir la prueba.
- Escenarios ejecutados, resultado observado y evidencia disponible; distinguir pruebas locales de pruebas en el juego.
- Limitaciones o fallos que sigan abiertos y su impacto sobre los criterios de aceptación.

Cerrar solo si la implementación y todos los criterios de aceptación del issue están satisfechos. No cerrar por la mera existencia del código, porque compile o porque pase una simulación. Los fallos de la prueba se corrigen y se vuelven a comprobar antes del cierre.

La republicación de búsquedas se añadió por solicitud directa del propietario: conserva identidad, inscritos y vencimiento; muestra roles restantes y respeta permisos. También requiere comprobar el anuncio real en la ronda de pruebas de grupos.
