
import 'package:flutter/material.dart';
import '../config/estilos.dart';
import '../modelos/cliente.dart';
import '../modelos/factura.dart';
import '../servicios/api_service.dart';

class FacturasClienteScreen extends StatefulWidget {
  final Cliente cliente;
  final Future<void> Function(Cliente cliente, Factura factura)
      alAbrirFactura;

  const FacturasClienteScreen({
    super.key,
    required this.cliente,
    required this.alAbrirFactura,
  });

  @override
  State<FacturasClienteScreen> createState() =>
      _FacturasClienteScreenState();
}

class _FacturasClienteScreenState
    extends State<FacturasClienteScreen> {
  late Future<List<Factura>> _facturasFuture;

  @override
  void initState() {
    super.initState();
    _facturasFuture =
        ApiService.listarFacturas(widget.cliente.idCliente);
  }

  Future<void> _recargar() async {
    final nuevaConsulta =
        ApiService.listarFacturas(widget.cliente.idCliente);

    setState(() => _facturasFuture = nuevaConsulta);

    try {
      await nuevaConsulta;
    } catch (_) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cliente = widget.cliente;
    final documento = (cliente.ruc != null && cliente.ruc!.trim().isNotEmpty)
        ? 'RUC ${cliente.ruc!.trim()}'
        : 'C.I. ${textoSeguro(cliente.cedula)}';

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: degradadoPrincipal),
        ),
        title: const Text('Facturas del cliente'),
        actions: [
          IconButton(
            onPressed: _recargar,
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<Factura>>(
        future: _facturasFuture,
        builder: (context, snapshot) {
          final facturas = snapshot.data ?? [];
          final cargando =
              snapshot.connectionState == ConnectionState.waiting;

          return RefreshIndicator(
            color: colorAcento,
            onRefresh: _recargar,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _encabezadoCliente(
                    cliente,
                    documento,
                    cargando ? null : facturas,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
                    child: tituloSeccion(
                      'Facturas registradas',
                      subtitulo:
                          'Tocá una factura para ver su detalle y pagos.',
                    ),
                  ),
                ),
                if (cargando)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: indicadorCarga(mensaje: 'Cargando facturas...'),
                  )
                else if (snapshot.hasError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: mensajeVacio(
                      'No se pudieron cargar las facturas',
                      mensajeError(snapshot.error!),
                      icono: Icons.cloud_off_rounded,
                      color: colorPeligro,
                    ),
                  )
                else if (facturas.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: mensajeVacio(
                      'Sin facturas registradas',
                      'No hay facturas disponibles para este cliente.',
                      icono: Icons.receipt_long_outlined,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList.separated(
                      itemCount: facturas.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _tarjetaFactura(facturas[index]),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _encabezadoCliente(
    Cliente cliente,
    String documento,
    List<Factura>? facturas,
  ) {
    final validas = facturas
            ?.where((f) => !f.estado.toLowerCase().contains('anulad'))
            .toList() ??
        [];

    final totalFacturado =
        validas.fold<double>(0.0, (suma, f) => suma + f.total);

    final saldoPendiente =
        validas.fold<double>(0.0, (suma, f) => suma + f.saldo);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 18),
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white,
                  child: Text(
                    iniciales(cliente.nombreCompleto),
                    style: const TextStyle(
                      color: colorPrimario,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cliente.nombreCompleto,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$documento  ·  Cliente N.º ${cliente.idCliente}',
                        style: const TextStyle(
                          color: Color(0xFFD6E2F3),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(22),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _indicador(
                    'Facturas',
                    facturas == null ? '—' : '${facturas.length}',
                  ),
                ),
                Container(
                  width: 1,
                  height: 34,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
                Expanded(
                  child: _indicador(
                    'Total facturado',
                    facturas == null ? '—' : formatearImporte(totalFacturado),
                  ),
                ),
                Container(
                  width: 1,
                  height: 34,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
                Expanded(
                  child: _indicador(
                    'Saldo pendiente',
                    facturas == null ? '—' : formatearImporte(saldoPendiente),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _indicador(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFB8C8E0),
            fontSize: 11,
          ),
        ),
      ],
      ),
    );
  }

  Widget _tarjetaFactura(Factura factura) {
    final colorBarra = colorEstado(factura.estado);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () async {
          await widget.alAbrirFactura(widget.cliente, factura);
          if (mounted) await _recargar();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorBorde),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: colorBarra,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(16),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            iconoCaja(
                              Icons.receipt_long_rounded,
                              color: colorPrimario,
                              tamano: 40,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'N.º ${factura.numeroFactura}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: colorTexto,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Emitida el ${formatearFecha(factura.fechaEmision)}',
                                    style: const TextStyle(
                                      color: colorSecundario,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            etiquetaEstado(factura.estado),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _dato(
                              Icons.event_note_outlined,
                              'Período ${textoSeguro(factura.periodo)}',
                            ),
                            const SizedBox(width: 12),
                            _dato(
                              Icons.sell_outlined,
                              textoSeguro(factura.condicionVenta),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _estadoCobro(factura),
                        const Divider(height: 22),
                        Row(
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                color: colorSecundario,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              formatearImporte(factura.total),
                              style: const TextStyle(
                                color: colorPrimario,
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: colorAcento,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dato(IconData icono, String texto) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 15, color: colorSecundario),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              texto,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: colorSecundario,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _estadoCobro(Factura factura) {
    if (factura.anulada) {
      return const SizedBox.shrink();
    }

    final saldada = factura.saldo <= 0;
    final color = saldada ? colorExito : colorAdvertencia;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            saldada ? Icons.check_circle_rounded : Icons.schedule_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              saldada
                  ? 'Sin saldo pendiente'
                  : 'Saldo pendiente: ${formatearImporte(factura.saldo)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
