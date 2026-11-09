# JMQ Facturas

Aplicación móvil del sistema **JMQ SYSTEM** para la consulta de facturas y el **cobro en campo**.

Proyecto final de carrera del **Técnico Superior en TIC en Desarrollo de Sistemas Informáticos** – Centro Tecnológico de Avanzada (CTA) – Servicio Nacional de Promoción Profesional (SNPP), San Lorenzo, Paraguay.

**Autor:** José Máximo Mongelós Quiroga

## Descripción

JMQ Facturas es la aplicación del cobrador. Se conecta al sistema web mediante la API **ApiJMQFacturas** y utiliza el mismo usuario y contraseña de JMQ SYSTEM. Los cobros registrados en la aplicación aparecen al instante en el sistema web.

## Funciones

- Inicio de sesión con el usuario del sistema y configuración de la dirección del servidor.
- Facturas pendientes de la zona asignada al cobrador, con opción de elegir otra zona y filtrar por cliente, documento o factura.
- Búsqueda de clientes por nombre, cédula, RUC o teléfono, y consulta de sus facturas.
- Detalle de cada factura con sus conceptos, pagos y PDF para ver, imprimir o compartir.
- Registro de cobros por el saldo completo o una parte, en efectivo, transferencia, tarjeta u otro método.
- Comprobante de cobro con número de recibo automático.
- Historial de consultas y perfil del usuario.

## Tecnologías

- Flutter y Dart.
- Paquetes: `http` (comunicación con la API), `shared_preferences` (configuración local) y `printing` (PDF).
- Plataforma: Android.

## Requisitos

- Flutter SDK con Dart 3.
- Android Studio o Visual Studio Code.
- La API ApiJMQFacturas instalada en el servidor de JMQ SYSTEM.

## Instalación

1. Ejecutar `flutter pub get` para descargar los paquetes.
2. Compilar el instalador con `flutter build apk --release`. El archivo se genera en `build/app/outputs/flutter-apk/app-release.apk`.
3. Instalar el APK en el dispositivo Android.
4. En la pantalla de ingreso, tocar el ícono del lápiz junto a «Servidor», escribir la dirección del servidor (`IP-DEL-SERVIDOR:8080`), probar la conexión y guardar.
5. Iniciar sesión con el usuario y la contraseña de JMQ SYSTEM.

## Estructura del proyecto

```
lib/config      Estilos de la aplicación
lib/modelos     Clases de datos (clientes, facturas, pagos, pendientes)
lib/servicios   Comunicación con la API e historial de consultas
lib/vistas      Pantallas de la aplicación
```
