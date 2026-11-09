
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../config/estilos.dart';
import '../modelos/cliente.dart';
import '../modelos/factura.dart';
import '../modelos/detalle_factura.dart';
import '../modelos/pago.dart';
import '../servicios/api_service.dart';
import '../servicios/historial_consultas_service.dart';
import 'registrar_cobro_screen.dart';

class DetalleFacturaScreen extends StatefulWidget {
  final Cliente cliente;
  final Factura factura;

  const DetalleFacturaScreen({
    super.key,
    required this.cliente,
    required this.factura,
  });

  @override
  State<DetalleFacturaScreen> createState() =>
      _DetalleFacturaScreenState();
}

class _DetalleFacturaScreenState
    extends State<DetalleFacturaScreen> {
  late Future<List<DetalleFactura>> _detallesFuture;
  late Future<List<Pago>> _pagosFuture;
  late Factura _factura;

  bool _abriendoPdf = false;

  @override
  void initState() {
    super.initState();

    _factura = widget.factura;

    _detallesFuture =
        ApiService.listarDetalles(widget.factura.idFactura);

    _pagosFuture =
        ApiService.listarPagos(widget.factura.idFactura);

    _registrarConsulta();
  }

  Future<void> _registrarConsulta() async {
    try {
      await HistorialConsultasService.registrarConsulta(
        cliente: widget.cliente,
        factura: widget.factura,
      );
    } catch (_) {
      return;
    }
  }

  Future<Uint8List> _descargarPdf() async {
    final respuesta = await ApiService.obtenerPdfFactura(
      widget.factura.idFactura,
    );

    final Uint8List bytes = respuesta.bodyBytes;

    if (bytes.isEmpty) {
      throw Exception('El PDF recibido está vacío.');
    }

    return bytes;
  }

  Future<void> _abrirPdf({bool compartir = false}) async {
    if (_abriendoPdf) return;

    setState(() => _abriendoPdf = true);

    try {
      final bytes = await _descargarPdf();
      final nombre = 'Factura_${widget.factura.numeroFactura}.pdf';

      if (compartir) {
        await Printing.sharePdf(bytes: bytes, filename: nombre);
      } else {
        await Printing.layoutPdf(
          name: nombre,
          onLayout: (_) async => bytes,
        );
      }
    } catch (e) {
      if (!mounted) return;
      mostrarError(context, e);
    } finally {
      if (mounted) setState(() => _abriendoPdf = false);
    }
  }

  Future<void> _actualizarDetalle() async {
    setState(() {
      _detallesFuture =
          ApiService.listarDetalles(widget.factura.idFactura);
      _pagosFuture =
          ApiService.listarPagos(widget.factura.idFactura);
    });

    try {
      final facturas =
          await ApiService.listarFacturas(widget.factura.idCliente);

      for (final candidata in facturas) {
        if (candidata.idFactura == widget.factura.idFactura) {
          if (mounted) setState(() => _factura = candidata);
          break;
        }
      }

      await Future.wait([_detallesFuture, _pagosFuture]);
    } catch (_) {
      return;
    }
  }

  double _calcularSaldo(List<Pago> pagos) {
    if (_factura.anulada) return 0;

    final pagado = pagos
        .where((p) => !p.estado.toLowerCase().contains('anulad'))
        .fold<double>(0.0, (suma, p) => suma + p.monto);

    final saldo = _factura.total - pagado;
    return saldo < 0 ? 0 : saldo;
  }

  Future<void> _abrirCobro(double saldo) async {
    final registrado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RegistrarCobroScreen(
          cliente: widget.cliente,
          factura: _factura,
          saldo: saldo,
        ),
      ),
    );

    if (registrado == true && mounted) {
      await _actualizarDetalle();
    }
  }

  @override
  Widget build(BuildContext context) {
    final factura = _factura;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: degradadoPrincipal),
        ),
        title: const Text('Detalle de factura'),
        actions: [
          IconButton(
            tooltip: 'Compartir PDF',
            onPressed: _abriendoPdf ? null : () => _abrirPdf(compartir: true),
            icon: const Icon(Icons.share_outlined),
          ),
          IconButton(
            tooltip: 'Actualizar información',
            onPressed: _actualizarDetalle,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: colorAcento,
        onRefresh: _actualizarDetalle,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          children: [
            _encabezadoFactura(factura),
            const SizedBox(height: 14),
            _resumenPagos(factura),
            const SizedBox(height: 22),
            tituloSeccion(
              'Conceptos facturados',
              subtitulo: 'Servicios incluidos en la factura.',
            ),
            const SizedBox(height: 12),
            _construirDetalles(),
            const SizedBox(height: 10),
            _tarjetaTotales(factura),
            const SizedBox(height: 22),
            tituloSeccion(
              'Datos de la factura',
              subtitulo: 'Cliente y condiciones de la venta.',
            ),
            const SizedBox(height: 12),
            _tarjetaSeccion(
              titulo: 'Cliente',
              icono: Icons.person_outline_rounded,
              contenido: Column(
                children: [
                  filaDato('Nombre', widget.cliente.nombreCompleto),
                  filaDato('Cédula', textoSeguro(widget.cliente.cedula)),
                  filaDato('RUC', textoSeguro(widget.cliente.ruc)),
                  filaDato('Teléfono', textoSeguro(widget.cliente.telefono)),
                  filaDato('Dirección', textoSeguro(widget.cliente.direccion)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _tarjetaSeccion(
              titulo: 'Condiciones',
              icono: Icons.fact_check_outlined,
              contenido: Column(
                children: [
                  filaDato(
                    'Fecha de emisión',
                    formatearFecha(factura.fechaEmision),
                  ),
                  filaDato('Período', textoSeguro(factura.periodo)),
                  filaDato(
                    'Condición de venta',
                    textoSeguro(factura.condicionVenta),
                  ),
                  if (factura.plazoCredito > 0)
                    filaDato(
                      'Plazo de crédito',
                      '${factura.plazoCredito} días',
                    ),
                  filaDato(
                    'Vencimiento',
                    formatearFecha(factura.fechaVencimiento),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            tituloSeccion(
              'Pagos registrados',
              subtitulo: 'Cobros asociados a esta factura.',
            ),
            const SizedBox(height: 12),
            _construirPagos(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: colorBorde)),
        ),
        child: SafeArea(
          top: false,
          child: FutureBuilder<List<Pago>>(
            future: _pagosFuture,
            builder: (context, snapshot) {
              final saldo = snapshot.hasData
                  ? _calcularSaldo(snapshot.data!)
                  : 0.0;

              final puedeCobrar = snapshot.hasData &&
                  saldo > 0 &&
                  ApiService.puedeRegistrarCobros;

              final botonPdf = puedeCobrar
                  ? OutlinedButton.icon(
                      onPressed: _abriendoPdf ? null : () => _abrirPdf(),
                      icon: _abriendoPdf
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('PDF'),
                    )
                  : FilledButton.icon(
                      onPressed: _abriendoPdf ? null : () => _abrirPdf(),
                      icon: _abriendoPdf
                          ? const SizedBox(
                              width: 19,
                              height: 19,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.picture_as_pdf_outlined),
                      label: Text(
                        _abriendoPdf
                            ? 'Preparando documento...'
                            : 'VER / IMPRIMIR FACTURA',
                      ),
                    );

              if (!puedeCobrar) {
                return SizedBox(height: 52, child: botonPdf);
              }

              return Row(
                children: [
                  SizedBox(width: 104, height: 52, child: botonPdf),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: colorExito,
                        ),
                        onPressed: () => _abrirCobro(saldo),
                        icon: const Icon(Icons.point_of_sale_rounded),
                        label: const Text('REGISTRAR COBRO'),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _encabezadoFactura(Factura factura) {
    return Container(
      decoration: BoxDecoration(
        gradient: degradadoPrincipal,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colorPrimario.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -24,
            child: Icon(
              Icons.receipt_long_rounded,
              size: 130,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'FACTURA',
                        style: TextStyle(
                          color: Color(0xFFB8C8E0),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.6,
                        ),
                      ),
                    ),
                    etiquetaEstado(factura.estado, sobreFondoOscuro: true),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'N.º ${factura.numeroFactura}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Total a pagar',
                  style: TextStyle(
                    color: Color(0xFFB8C8E0),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatearImporte(factura.total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _datoEncabezado(
                      Icons.calendar_today_outlined,
                      formatearFecha(factura.fechaEmision),
                    ),
                    const SizedBox(width: 16),
                    _datoEncabezado(
                      Icons.event_note_outlined,
                      'Período ${textoSeguro(factura.periodo)}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _datoEncabezado(IconData icono, String texto) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: const Color(0xFFD6E2F3)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              texto,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFD6E2F3),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumenPagos(Factura factura) {
    return FutureBuilder<List<Pago>>(
      future: _pagosFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final anulada = factura.estado.toLowerCase().contains('anulad');

        final pagado = snapshot.data!
            .where((p) => !p.estado.toLowerCase().contains('anulad'))
            .fold<double>(0.0, (suma, p) => suma + p.monto);

        final saldo = anulada ? 0.0 : (factura.total - pagado);
        final saldado = !anulada && saldo <= 0;

        final double avance = factura.total <= 0
            ? 0.0
            : (pagado / factura.total).clamp(0.0, 1.0).toDouble();

        final colorSaldo = anulada
            ? colorSecundario
            : (saldado ? colorExito : colorAdvertencia);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: decoracionTarjeta(),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _montoResumen(
                      'Pagado',
                      formatearImporte(pagado),
                      colorExito,
                    ),
                  ),
                  Container(width: 1, height: 38, color: colorBorde),
                  Expanded(
                    child: _montoResumen(
                      anulada ? 'Factura anulada' : 'Saldo pendiente',
                      anulada
                          ? '—'
                          : formatearImporte(saldo < 0 ? 0 : saldo),
                      colorSaldo,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: avance,
                  minHeight: 8,
                  backgroundColor: colorFondo,
                  color: saldado ? colorExito : colorAcento,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    saldado
                        ? Icons.check_circle_rounded
                        : Icons.schedule_rounded,
                    size: 15,
                    color: colorSaldo,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      anulada
                          ? 'Esta factura fue anulada.'
                          : saldado
                              ? 'Factura totalmente pagada.'
                              : '${(avance * 100).round()}% pagado · '
                                  'vence ${formatearFecha(factura.fechaVencimiento)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorSaldo,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _montoResumen(String titulo, String valor, Color color) {
    return Column(
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 11,
            color: colorSecundario,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _tarjetaTotales(Factura factura) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: decoracionTarjeta(),
      child: Column(
        children: [
          filaDato('Subtotal', formatearImporte(factura.subtotal)),
          if (factura.iva5 > 0)
            filaDato('IVA 5%', formatearImporte(factura.iva5)),
          filaDato('IVA 10%', formatearImporte(factura.iva10)),
          const Divider(height: 22),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'TOTAL',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: colorTexto,
                  ),
                ),
              ),
              Text(
                formatearImporte(factura.total),
                style: const TextStyle(
                  color: colorPrimario,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tarjetaSeccion({
    required String titulo,
    required IconData icono,
    required Widget contenido,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: decoracionTarjeta(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              iconoCaja(icono, tamano: 34),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: colorTexto,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 22),
          contenido,
        ],
      ),
    );
  }

  Widget _cargandoSeccion() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: CircularProgressIndicator(color: colorAcento),
      ),
    );
  }

  Widget _construirDetalles() {
    return FutureBuilder<List<DetalleFactura>>(
      future: _detallesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _cargandoSeccion();
        }

        if (snapshot.hasError) {
          return _mensajeErrorTarjeta(
            'No se pudieron cargar los conceptos.',
            mensajeError(snapshot.error!),
          );
        }

        final detalles = snapshot.data ?? [];

        if (detalles.isEmpty) {
          return _mensajeInformativo(
            'La factura no tiene conceptos registrados.',
          );
        }

        return Column(
          children: detalles.map((detalle) {
            final cantidad = detalle.cantidad.toStringAsFixed(
              detalle.cantidad % 1 == 0 ? 0 : 2,
            );

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: decoracionTarjeta(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  iconoCaja(Icons.recycling_rounded, tamano: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detalle.descripcion,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: colorTexto,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$cantidad × ${formatearImporte(detalle.precioUnitario)}'
                          '  ·  IVA ${detalle.porcentajeIva.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: colorSecundario,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatearImporte(detalle.total),
                    style: const TextStyle(
                      color: colorPrimario,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _construirPagos() {
    return FutureBuilder<List<Pago>>(
      future: _pagosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _cargandoSeccion();
        }

        if (snapshot.hasError) {
          return _mensajeErrorTarjeta(
            'No se pudieron consultar los pagos.',
            mensajeError(snapshot.error!),
          );
        }

        final pagos = snapshot.data ?? [];

        if (pagos.isEmpty) {
          return _mensajeInformativo(
            'Todavía no hay pagos registrados para esta factura.',
          );
        }

        return Column(
          children: pagos.map((pago) {
            final color = colorEstado(pago.estado);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: decoracionTarjeta(),
              child: Column(
                children: [
                  Row(
                    children: [
                      iconoCaja(
                        Icons.payments_outlined,
                        color: color,
                        tamano: 40,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pago.numeroRecibo.isEmpty
                                  ? 'Pago N.º ${pago.idPago}'
                                  : 'Recibo ${pago.numeroRecibo}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: colorTexto,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${formatearFecha(pago.fechaPago)}  ·  '
                              '${textoSeguro(pago.metodoPago)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: colorSecundario,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatearImporte(pago.monto),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          etiquetaEstado(pago.estado),
                        ],
                      ),
                    ],
                  ),
                  if (pago.observaciones.trim().isNotEmpty) ...[
                    const Divider(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.notes_rounded,
                          size: 16,
                          color: colorSecundario,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pago.observaciones,
                            style: const TextStyle(
                              fontSize: 12,
                              color: colorSecundario,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _mensajeInformativo(String texto) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: decoracionTarjeta(),
      child: Row(
        children: [
          iconoCaja(Icons.info_outline_rounded,
              color: colorSecundario, tamano: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 13,
                color: colorSecundario,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mensajeErrorTarjeta(String titulo, String detalle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorPeligro.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorPeligro.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: colorPeligro),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: colorTexto,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  detalle,
                  style: const TextStyle(
                    color: colorSecundario,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
