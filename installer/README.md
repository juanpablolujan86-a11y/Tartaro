# Instalador de Tártaro

Aplicación de escritorio en Rust para la hermandad. Abrí el programa, elegí la instalación de Forever y pulsá **Instalar Tártaro**. Reconoce la carpeta del juego, la de la edición Forever y su carpeta de addons. En instalaciones personalizadas, incluida Wine, se puede elegir la ruta manualmente.

El instalador lee la versión del archivo TOC, consulta la última publicación estable de GitHub y comprueba el tamaño y SHA-256 del ZIP. Prepara los archivos junto a la instalación y conserva la versión anterior en Interface/.tartaro-installer/previous. El directorio WTF y los demás addons quedan fuera del reemplazo.

En Windows, ejecutá Tartaro-Setup-Windows-x64.exe. Instala Tártaro para el usuario actual, agrega un acceso al menú Inicio y ofrece iniciarlo junto al reloj al entrar en Windows. Cerrá la ventana con la X para continuar en segundo plano. Hacé clic en el ícono para abrirla y clic derecho para elegir Salir. Con la actualización automática activa, el residente comprueba cada hora si hay una versión nueva y avisa al instalarla. En Linux y macOS la comprobación requiere que la ventana esté abierta. Para Overlord Forever muestra la versión publicada y abre la página oficial de descarga. La instalación automática de Overlord está pendiente de autorización del autor.

## Desarrollo

Ejecutar desde esta carpeta con Rust estable y curl disponible en el sistema:

    cargo run --locked

Las pruebas crean una carpeta de juego temporal:

    cargo test --locked
    cargo test --locked official_release_round_trip -- --ignored

La segunda prueba necesita acceso público a GitHub. El flujo de GitHub Actions compila el programa para Windows, macOS y Linux por separado. La bandeja en Linux y macOS y las vistas de calendario corresponden a entregas posteriores.
## Actualizaciones del programa en Windows

El residente consulta GitHub al iniciar y cada hora. Al detectar una versión estable posterior, muestra un aviso y habilita **Actualizar programa** en el menú de bandeja. Se puede consultar también desde la ventana principal. La instalación espera la confirmación del jugador, verifica el tamaño y SHA-256 del Setup publicado y reinicia el programa. Los datos del addon y la configuración se guardan fuera de la carpeta del programa.

Para publicar una actualización del escritorio, usar una etiqueta propia, por ejemplo `instalador-v0.3.0`, que coincida con la versión del paquete Rust. Adjuntar `Tartaro-Setup-Windows-x64.exe` al release antes de publicarlo como estable y usar `--latest=false` en GitHub para que el canal de descargas del addon siga apuntando al ZIP de Forever. Los borradores, versiones de prueba y etiquetas del addon quedan fuera de la detección. La versión 0.2 del escritorio requiere instalar una vez el Setup actualizado.
