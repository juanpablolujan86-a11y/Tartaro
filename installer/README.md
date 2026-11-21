# Instalador de Tártaro

Aplicación de escritorio en Rust para la hermandad. Abrí el programa, elegí la instalación de Forever y pulsá **Instalar Tártaro**. Reconoce la carpeta del juego, la de la edición Forever y su carpeta de addons. En instalaciones personalizadas, incluida Wine, se puede elegir la ruta manualmente.

El instalador lee la versión del archivo TOC, consulta la última publicación estable de GitHub y comprueba el tamaño y SHA-256 del ZIP. Prepara los archivos junto a la instalación y conserva la versión anterior en Interface/.tartaro-installer/previous. El directorio WTF y los demás addons quedan fuera del reemplazo.

Con la ventana abierta, busca actualizaciones cada hora si está activa la opción automática. Para Overlord Forever muestra la versión publicada y abre la página oficial de descarga. La instalación automática de Overlord está pendiente de autorización del autor.

## Desarrollo

Ejecutar desde esta carpeta con Rust estable y curl disponible en el sistema:

    cargo run --locked

Las pruebas crean una carpeta de juego temporal:

    cargo test --locked
    cargo test --locked official_release_round_trip -- --ignored

La segunda prueba necesita acceso público a GitHub. El flujo de GitHub Actions compila el programa para Windows, macOS y Linux por separado. La bandeja del sistema, los avisos del escritorio y las vistas de calendario corresponden a entregas posteriores.
