# Cambios – JMQ Facturas (Flutter)

## Pendientes de cobro por zona

- Nueva pestaña **Pendientes** (también en el menú y en el inicio).
- Al entrar muestra la zona asignada al cobrador en Personal; el Administrador ve todas las zonas.
- Selector de zona con la cantidad de facturas pendientes de cada barrio; la zona asignada se marca con un pin.
- Resumen de la zona: facturas pendientes y saldo por cobrar.
- Cada factura muestra cliente, dirección, barrio, número, vencimiento (en rojo si está vencida) y saldo, con los botones **Ver factura** y **Cobrar**.
- Filtro por cliente, documento o número de factura.
- Después de cobrar, la lista se actualiza sola.
- `ApiService.obtenerPendientes` consulta `PendientesServlet` de la API.

## Cobro móvil

- Botón **Registrar cobro** en el detalle de la factura. Aparece cuando la factura tiene saldo y el usuario no tiene rol Consulta.
- Pantalla **Registrar cobro**: saldo pendiente, monto (saldo completo, mitad o un monto libre), método de pago (efectivo, transferencia, tarjeta u otro) y observaciones. Antes de guardar pide confirmación.
- Pantalla **Comprobante de cobro**: número de recibo (REC-COB-...), fecha, cliente, factura, método, monto cobrado, saldo y estado de la factura.
- Al volver, el detalle y la lista de facturas se actualizan con el nuevo saldo y el estado PAGADA cuando corresponde.
- Lista de facturas: saldo pendiente en cada factura y en el resumen del cliente.
- `ApiService.registrarPago` envía el cobro a `RegistrarPagoServlet` de la API.

## Anteriores

- Dirección del servidor configurable desde el inicio de sesión (ícono de red), con prueba de conexión.
- Diseño con los colores institucionales de JMQ SYSTEM, barra de navegación inferior y menú lateral.
- Factura en PDF para ver, imprimir o compartir.

## Uso

```
flutter pub get
flutter analyze
flutter run
```
