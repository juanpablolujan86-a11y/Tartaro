# Entrega local adicional de Tartaro 0.2.1

Fecha: 26/11/2026. Rama: `main`. Base de este commit: `07155cdb3db3391753ccfca6a022db918e44d8ba`.

## Alcance y autorización

Este documento describe los cambios posteriores al commit base, conservando la versión 0.2.1. El usuario autoriza un nuevo commit local con documentación. No autoriza push, merge, tag, GitHub Release, CurseForge, ZIP o una nueva instalación por esta operación. El commit que contiene este documento es la referencia de esta entrega; se identifica mediante `git log -1`.

La base ya contiene la primera revisión de presencia, avisos y tarjetas de calendario de 0.2.1. Este commit añade anclaje/persistencia de ventana, informes de Overlord, acceso administrativo y las mejoras de memoria/CPU descritas abajo. No se presenta como una release publicada ni como validación E2E completa.

## Cambios funcionales adicionales

### Ventana principal

- Opción «Mantener centro horizontal y crecer hacia abajo», desmarcada por defecto. Mantiene la referencia del emblema al cambiar el tamaño, con compensación de escala y coordinación con avisos.
- Arrastre y desactivación de la opción conservan las reglas de posicionamiento descritas en la bitácora. Los límites de pantalla pueden recolocar una ventana que no cabe.
- Se corrige la falta de persistencia propia: `TartaroDB.windowPosition` guarda el anclaje, posición normalizada y referencia del emblema. Se restaura al iniciar; se guarda al mover, ocultar, salir o cambiar la preferencia.
- El apilado temporal de avisos no sustituye las coordenadas independientes. Restablecer configuración incluye la nueva posición. Una ubicación histórica no guardada no puede recuperarse.

### Miembros, permisos e informes de addons

- Miembros y Permisos se excluyen del menú sin autorización, compactando las demás entradas. Se comprueba acceso al abrir/renderizar y ejecutar acciones; perderlo redirige a Inicio.
- Política compartida: rangos 0 y 1, o índice 8 con nombre exactamente `Dev`. No hay bypass por debug. La ampliación administrativa se aplica también a escritura, recepción y replay de grants; no amplía automáticamente edición de eventos ajenos o permiso de llamado.
- Miembros incorpora columna Overlord y tooltips con versiones/fechas de Tartaro y Overlord. Se distinguen cargado, desactivado, instalado sin cargar, instalado, no instalado, sin datos e histórico.
- Cada cliente consulta su propia instalación; otros jugadores deben comunicar su informe con una versión compatible. No recibir datos no demuestra desinstalación. Se preserva la conexión del roster, presencia, ordenación y acciones.
- El mensaje V mantiene la versión de Tartaro como primer campo y añade campos opcionales de Overlord. Informes persistentes en `memberAddons`, confirmación de sesión y caducidad de 150 segundos con reloj monotónico, independiente de otros mensajes. Renovación sobre la sincronización existente, sin un ticker nuevo.

## Mejoras de memoria y CPU

El [plan propietario](PLAN-OPTIMIZACION-MEMORIA-CPU.md) conserva evidencia, propuestas y criterios manuales. Las consecuencias del código no son mediciones de ahorro.

| Punto | Implementado en este commit | Límite o pendiente |
|---|---|---|
| 1. Filas | Texto/botón/checkbox creados según uso; limpieza de callbacks de controles y acciones al reutilizar/ocultar. | Parcial: sin virtualización; el pool conserva su máximo y se construyen listas completas. |
| 2. Catálogo | Actualización por objeto de metadatos compartidos; invalida resultados si cambian, conservando la estructura; solicitudes resueltas se limpian y las pendientes pueden reintentarse al consultar después de 15 segundos. | Verificación real de metadatos/filtros pendiente. El índice por objeto añade referencias. |
| 3. Sincronización | Cola circular de 160 mensajes, serialización única por intento de replay y liberación de paquetes consumidos en replay, pedidos, donaciones y asistencia. | Parcial: recuperación completa y frecuencias existentes conservadas; tráfico multicliente no medido. |
| 4. Mapa | Agrupa callbacks, cancela repintados diferidos ya cubiertos, reutiliza posiciones, evita propiedades iguales y limpia caducados con mapa cerrado. | Mantiene ticker mundial de 1 segundo, minimapa de 0,25 y SetPosition nativo. Fluidez/consumo pendientes. |
| 5. Transferencias | Elimina recepción vencida tras 240 segundos solo si coinciden contexto e identidad. | Capturas de callbacks antiguos permanecen hasta su plazo; sin cancelación nueva. |
| 6. Avisos | Lista ordenada reutilizable y próxima entrada en ventana de recordatorio; invalidación por datos/contexto/día/reloj/desfase. | Reglas de avisos y bloqueo conservadas; ejecución real pendiente. |
| 7. Historia | Catálogo preparado desde el roster disponible; cambios de identificadores invalidan estructura. | No se borra historia ni se considera expulsión una ausencia en roster parcial. |
| 8. Roster | Fichas iguales reutilizadas, cambios reemplazados sin mutar la instantánea previa y mapas de miembros/rangos conservados cuando son iguales. | Parcial: consultas completas y mapas candidatos siguen existiendo; sin demorar autoridad/conexión. |
| 9. Refrescos | Listas por datos/plazos, Mapa por comparación de estado, navegador por cambios; ofertas/asistencia reutilizadas en un render. Invalida grupos al limpiar pendientes/FULL. | Sigue el render completo ante invalidaciones y la comprobación periódica. Plazos referidos al inicio del render. |
| 10. Diagnóstico | `isDebugEnabled` consulta el estado real; 17 llamadas costosas preparan argumentos solo con debug activo. | Wrappers/argumentos simples mantienen coste; no equivale a coste cero. |

Se mantienen recibos de avisos, hora local/UTC, ventana -30/+30 minutos, restricciones por combate/instancias, filtros de pedidos, autoridades y protocolos. No se añaden simuladores, baterías de pruebas, temporizadores periódicos o dependencias para estas optimizaciones. Las etiquetas de trazabilidad se renumeraron al cambiar líneas.

## Verificación realizada

- Los 19 módulos compilan con la biblioteca local LuaJIT compatible con Lua 5.1. No se ejecutaron el addon ni APIs de WoW para esta comprobación; no se certifica un intérprete idéntico al del cliente.
- XML, TOC, archivos/recursos y caracteres comprobados; carpeta instalable de 40 archivos. Sin generar ZIP.
- 563 funciones propias instrumentadas fuera del registrador y 21 llamadas protegidas. Debug de desarrollo apagado por defecto y preferencias existentes conservadas.
- Revisión estática de orden de carga, llamadas, argumentos de mensajes, eventos, temporizadores y destinos de las diez secciones y tres vistas de Profesiones. No se encontraron conexiones obligatorias ausentes en las referencias revisadas. `groupsChanged` es un hook opcional protegido, no un requisito de actualización.
- Las instalaciones autorizadas previas se compararon por SHA256 con sus respectivas fuentes. Esta operación de commit no vuelve a instalar. La actualización documental de LEEME/CHANGELOG queda en el repositorio; la copia instalada conserva sus documentos anteriores.
- `git diff --check` y comprobación de enlaces documentales. Sin pruebas/simulaciones externas ejecutables nuevas, interacción con el juego o edición externa de SavedVariables.

## Evidencia del usuario y límites

- El usuario confirmó acceso a Miembros y Permisos con su rango Dev.
- Reportó 2 MB menos de RAM después de una entrega previa de filas/catálogo. No comunicó el método; se conserva como observación manual, no como resultado independiente o ahorro atribuible a todos los cambios.
- No hay certificación de funcionamiento completo dentro de Forever, ausencia de errores de ejecución o convergencia entre clientes. La compilación y la coincidencia de archivos no sustituyen esas pruebas.

## Pendientes de aceptación

1. Ejecutar los criterios manuales del plan: navegación, filtros, acciones, scroll/posición, cambios de rango, roster parcial y presencia/versiones.
2. Revisar login/reload, cambio de día/desfase, avisos, ventanas temporales, bloqueo/reanudación y transferencias incompletas/reemplazadas.
3. Probar colas, recuperación, cierres/inscripciones y compatibilidad con más de un cliente; mapa/OpenMap, movimiento, zoom, grupo y caducidad.
4. Comprobar logs con debug apagado/activado/apagado y medir CPU/RAM bajo condiciones equivalentes.
5. Decidir etapas restantes de los puntos parciales 1/3/8; no se declaran cerrados por este commit.

Estado vigente: [MAESTRO-DESARROLLO.md](../MAESTRO-DESARROLLO.md). Historial de UI: [bitácora](MEJORAS-DISENO-MENU.md). Diagnóstico: [DEPURACION-CARGA.md](DEPURACION-CARGA.md).
