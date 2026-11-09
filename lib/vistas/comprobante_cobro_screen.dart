import 'package:flutter/material.dart';

import '../config/estilos.dart';
import '../modelos/cliente.dart';
import '../modelos/factura.dart';
import '../modelos/resultado_cobro.dart';
import '../servicios/api_service.dart';
import 'detalle_factura_screen.dart';

class ComprobanteCobroScreen extends StatelessWidget {
  final Cliente cliente;
  final Factura factura;
  final ResultadoCobro resultado;
  final bool desdeDetalle;

  const ComprobanteCobroScreen({
    super.key,
    required this.cliente,
    required this.factura,
    required this.resultado,
    this.desdeDetalle = true,
  });

  Future<void> _verFactura(BuildContext context) async {
    var actual = factura;

    try {
      final facturas = await ApiService.listarFacturas(cliente.idCliente);

      for (final candidata in facturas) {
        if (candidata.idFactura == factura.idFactura) {
          actual = candidata;
          break;
        }
      }
    } catch (_) {
      actual = factura;
    }

    if (!context.mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetalleFacturaScreen(
          cliente: cliente,
          factura: actual,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pagada = resultado.estadoFactura.toUpperCase() == 'PAGADA' ||
        resultado.saldo <= 0;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: degradadoPrincipal),
        ),
        title: const Text('Comprobante de cobro'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 110),
        children: [
          Center(
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: colorExito.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: colorExito,
                size: 60,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Cobro registrado',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: colorTexto,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'El pago ya figura en JMQ SYSTEM.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: colorSecundario),
          ),
          const SizedBox(height: 22),
          Container(
            decoration: decoracionTarjeta(radio: 20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: const BoxDecoration(
                    color: colorFondo,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'RECIBO N.º',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w800,
                          color: colorSecundario,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        resultado.numeroRecibo,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: colorPrimario,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    children: [
                      filaDato(
                        'Fecha',
                        formatearFecha(resultado.fechaPago),
                        icono: Icons.event_outlined,
                      ),
                      filaDato(
                        'Cliente',
                        cliente.nombreCompleto,
                        icono: Icons.person_outline_rounded,
                      ),
                      filaDato(
                        'Factura',
                        'N.º ${factura.numeroFactura}',
                        icono: Icons.receipt_long_outlined,
                      ),
                      filaDato(
                        'Método de pago',
                        resultado.metodoPago,
                        icono: Icons.payments_outlined,
                      ),
                      const Divider(height: 24),
                      filaDato(
                        'Monto cobrado',
                        formatearImporte(resultado.monto),
                        destacado: true,
                      ),
                      filaDato(
                        'Saldo pendiente',
                        formatearImporte(resultado.saldo),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: etiquetaEstado(
                          pagada ? 'PAGADA' : 'PAGO PARCIAL',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!pagada) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorAdvertencia.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: colorAdvertencia),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'La factura sigue con saldo de '
                      '${formatearImporte(resultado.saldo)}. '
                      'Podés registrar otro cobro cuando el cliente pague.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: colorTexto,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: colorBorde)),
        ),
        child: SafeArea(
          top: false,
          child: desdeDetalle
              ? SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: const Icon(Icons.done_rounded),
                    label: const Text('VOLVER A LA FACTURA'),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () => _verFactura(context),
                          icon: const Icon(Icons.receipt_long_outlined),
                          label: const Text('VER FACTURA'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: () => Navigator.of(context).pop(true),
                          icon: const Icon(Icons.done_rounded),
                          label: const Text('VOLVER'),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
