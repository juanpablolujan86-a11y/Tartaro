Tártaro 0.1.54 reúne las mejoras de grupos, acceso por hermandad, misiones y donaciones.

- **Buscar grupo:** categorías y destinos del cliente, necesidades numéricas y cupos por rol en BG. **Volver a publicar** repite el anuncio con los roles restantes sin reiniciar inscritos ni vencimiento.
- **Hermandad:** funciones habilitadas para personajes de una guild llamada exactamente `Tartaro`, en cualquier reino. Espera durante la carga de datos y conservación de los registros al cambiar de pertenencia.
- **Misiones:** selección desde el diario y enlace nativo en el anuncio.
- **Donaciones:** creación exclusivamente desde **Buscar recetas → Materiales → Solicitar**. El formulario muestra el ingrediente seleccionado y pide la cantidad. Se retira el botón independiente y la entrada manual; se mantienen listado, cierre, vencimiento de siete días y avisos en tooltips. La edición de solicitudes no se incluye.
- **Distribución:** changelog, licencia elegida, registro de recursos y verificador del paquete. CurseForge sigue aplazado; el issue #5 permanece abierto.

**Instalación:** descargar `Tartaro-0.1.54.zip` y copiar la carpeta `Tartaro` dentro de `Interface/AddOns/`. Actualizar ambos personajes para probar el intercambio de datos. No reemplazar ni borrar los archivos de SavedVariables.

**Validación:** el propietario confirmó el 19/11/2026 que pasaron las pruebas manuales de los issues #1–#4 en Forever con dos personajes. Se registra como confirmación del usuario, sin ejecución independiente del agente ni build/capturas proporcionados. El último ajuste del formulario de Donaciones pasó las regresiones locales con APIs simuladas. También pasaron compilación Lua 5.1, XML, comprobación de caracteres y siete pruebas de empaquetado. El ZIP se verifica contra la carpeta instalable.
