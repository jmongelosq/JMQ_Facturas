import 'package:flutter/material.dart';

import '../config/estilos.dart';
import '../modelos/pendientes.dart';
import '../servicios/api_service.dart';
import 'detalle_factura_screen.dart';
import 'registrar_cobro_screen.dart';

class PendientesContenido extends StatefulWidget {
  final int recarga;

  const PendientesContenido({
    super.key,
    this.recarga = 0,
  });

  @override
  State<PendientesContenido> createState() => _PendientesContenidoState();
}

class _PendientesContenidoState extends State<PendientesContenido> {
  final _busquedaController = TextEditingController();

  ResumenPendientes? _resumen;
  int? _idBarrioSeleccionado;
  bool _cargando = true;
  String? _error;
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void didUpdateWidget(covariant PendientesContenido oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.recarga != widget.recarga) {
      _cargar(silencioso: true);
    }
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _cargar({bool silencioso = false}) async {
    if ((!silencioso || _resumen == null) &&
        (!_cargando || _error != null)) {
      setState(() {
        _cargando = true;
        _error = null;
      });
    }

    try {
      final resumen = await ApiService.obtenerPendientes(
        idBarrio: _idBarrioSeleccionado,
      );

      if (!mounted) return;

      setState(() {
        _resumen = resumen;
        _idBarrioSeleccionado = resumen.idBarrioActual;
        _cargando = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = mensajeError(e);
      });
    }
  }

  Future<void> _cambiarZona(int idBarrio) async {
    if (idBarrio == _idBarrioSeleccionado) return;

    _busquedaController.clear();

    setState(() {
      _idBarrioSeleccionado = idBarrio;
      _filtro = '';
    });

    await _cargar();
  }

  Future<void> _cobrar(FacturaPendiente item) async {
    final registrado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RegistrarCobroScreen(
          cliente: item.cliente,
          factura: item.factura,
          saldo: item.factura.saldo,
          desdeDetalle: false,
        ),
      ),
    );

    if (registrado == true && mounted) {
      await _cargar(silencioso: true);
    }
  }

  Future<void> _verFactura(FacturaPendiente item) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetalleFacturaScreen(
          cliente: item.cliente,
          factura: item.factura,
        ),
      ),
    );

    if (mounted) {
      await _cargar(silencioso: true);
    }
  }

  List<FacturaPendiente> _filtrar(List<FacturaPendiente> facturas) {
    final texto = _filtro.trim().toLowerCase();
    if (texto.isEmpty) return facturas;

    return facturas.where((item) {
      final cliente = item.cliente;
      final contenido = [
        cliente.nombreCompleto,
        cliente.cedula ?? '',
        cliente.ruc ?? '',
        cliente.direccion ?? '',
        item.factura.numeroFactura,
      ].join(' ').toLowerCase();

      return contenido.contains(texto);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final resumen = _resumen;

    if (_cargando && resumen == null) {
      return indicadorCarga(mensaje: 'Cargando pendientes de cobro...');
    }

    if (_error != null && resumen == null) {
      return RefreshIndicator(
        color: colorAcento,
        onRefresh: _cargar,
        child: ListView(
          children: [
            const SizedBox(height: 60),
            _aviso(
              'No se pudieron cargar los pendientes',
              _error!,
              icono: Icons.cloud_off_rounded,
              color: colorPeligro,
            ),
            Center(
              child: FilledButton.icon(
                onPressed: _cargar,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ),
          ],
        ),
      );
    }

    if (resumen == null) {
      return const SizedBox.shrink();
    }

    final facturas = _filtrar(resumen.facturas);

    return RefreshIndicator(
      color: colorAcento,
      onRefresh: () => _cargar(silencioso: true),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          _encabezado(resumen),
          const SizedBox(height: 18),
          tituloSeccion(
            'Zona de cobro',
            subtitulo: 'Elegí la zona que vas a recorrer.',
          ),
          const SizedBox(height: 10),
          _selectorZonas(resumen),
          if (_cargando) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(
              color: colorAcento,
              minHeight: 3,
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: colorPeligro, fontSize: 12),
            ),
          ],
          const SizedBox(height: 18),
          if (resumen.facturas.isNotEmpty) ...[
            TextField(
              controller: _busquedaController,
              onChanged: (valor) => setState(() => _filtro = valor),
              decoration: InputDecoration(
                hintText: 'Filtrar por cliente, documento o factura',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _filtro.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpiar',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _busquedaController.clear();
                          setState(() => _filtro = '');
                        },
                      ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (resumen.facturas.isEmpty)
            _sinPendientes(resumen)
          else if (facturas.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: _aviso(
                'Sin coincidencias',
                'Ninguna factura pendiente coincide con "$_filtro".',
                icono: Icons.search_off_rounded,
              ),
            )
          else
            ...facturas.map(_tarjetaFactura),
        ],
      ),
    );
  }

  Widget _encabezado(ResumenPendientes resumen) {
    final esAsignada = resumen.tieneZonaAsignada &&
        resumen.idBarrioActual == resumen.idBarrioAsignado;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: degradadoPrincipal,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorPrimario.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  resumen.nombreZonaActual,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (esAsignada)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'MI ZONA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
            ],
          ),
          if (resumen.tieneZonaAsignada && !esAsignada) ...[
            const SizedBox(height: 4),
            Text(
              'Zona asignada: ${resumen.barrioAsignado}',
              style: const TextStyle(
                color: Color(0xFFD6E2F3),
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _datoEncabezado(
                  'Facturas pendientes',
                  resumen.facturas.length.toString(),
                ),
              ),
              Expanded(
                child: _datoEncabezado(
                  'Saldo por cobrar',
                  formatearImporte(resumen.saldoZonaActual),
                ),
              ),
            ],
          ),
          if (resumen.idBarrioActual != 0) ...[
            const SizedBox(height: 12),
            Text(
              'En todas las zonas: ${resumen.totalPendientes} '
              '${resumen.totalPendientes == 1 ? 'factura' : 'facturas'} · '
              '${formatearImporte(resumen.totalSaldo)}',
              style: const TextStyle(
                color: Color(0xFFB8C8E0),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _datoEncabezado(String titulo, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(color: Color(0xFFB8C8E0), fontSize: 11),
        ),
        const SizedBox(height: 3),
        Text(
          valor,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _selectorZonas(ResumenPendientes resumen) {
    final opciones = <Widget>[
      _chipZona(
        idBarrio: 0,
        nombre: 'Todas',
        pendientes: resumen.totalPendientes,
        asignada: false,
      ),
      ...resumen.zonas.map(
        (zona) => _chipZona(
          idBarrio: zona.idBarrio,
          nombre: zona.nombre,
          pendientes: zona.pendientes,
          asignada: zona.idBarrio == resumen.idBarrioAsignado,
        ),
      ),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: opciones,
    );
  }

  Widget _chipZona({
    required int idBarrio,
    required String nombre,
    required int pendientes,
    required bool asignada,
  }) {
    final seleccionada = _idBarrioSeleccionado == idBarrio;

    return ChoiceChip(
      selected: seleccionada,
      onSelected: _cargando ? null : (_) => _cambiarZona(idBarrio),
      showCheckmark: false,
      avatar: asignada
          ? Icon(
              Icons.push_pin_rounded,
              size: 16,
              color: seleccionada ? Colors.white : colorAcento,
            )
          : null,
      label: Text('$nombre ($pendientes)'),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: seleccionada ? FontWeight.w800 : FontWeight.w600,
        color: seleccionada
            ? Colors.white
            : (pendientes == 0 ? colorSecundario : colorTexto),
      ),
      selectedColor: colorPrimario,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: seleccionada ? colorPrimario : colorBorde,
      ),
    );
  }

  Widget _sinPendientes(ResumenPendientes resumen) {
    final otras = resumen.zonas
        .where(
          (zona) =>
              zona.pendientes > 0 && zona.idBarrio != resumen.idBarrioActual,
        )
        .toList();

    return Column(
      children: [
        const SizedBox(height: 10),
        _aviso(
          resumen.idBarrioActual == 0
              ? 'No hay facturas pendientes'
              : 'Zona sin pendientes',
          resumen.idBarrioActual == 0
              ? 'Todas las facturas emitidas están cobradas.'
              : 'No quedan facturas por cobrar en '
                  '${resumen.nombreZonaActual}.',
          icono: Icons.task_alt_rounded,
          color: colorExito,
        ),
        if (otras.isNotEmpty && resumen.idBarrioActual != 0) ...[
          const Text(
            'Zonas con pendientes:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colorTexto,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: otras
                .map(
                  (zona) => ActionChip(
                    avatar: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: colorAcento,
                    ),
                    label: Text('${zona.nombre} (${zona.pendientes})'),
                    onPressed: () => _cambiarZona(zona.idBarrio),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _tarjetaFactura(FacturaPendiente item) {
    final factura = item.factura;
    final cliente = item.cliente;
    final puedeCobrar = ApiService.puedeRegistrarCobros;
    final parcial = factura.pagado > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: decoracionTarjeta(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _verFactura(item),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconoCaja(
                      Icons.person_outline_rounded,
                      color: item.vencida ? colorPeligro : colorAcento,
                      tamano: 42,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cliente.nombreCompleto,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: colorTexto,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            [
                              if ((cliente.direccion ?? '').trim().isNotEmpty)
                                cliente.direccion!.trim(),
                              if (item.barrio.isNotEmpty) item.barrio,
                            ].join(' · '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: colorSecundario,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    etiquetaEstado(
                      item.vencida
                          ? 'Vencida'
                          : (parcial ? 'Parcial' : 'Pendiente'),
                    ),
                  ],
                ),
                const Divider(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Factura N.º ${factura.numeroFactura}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colorTexto,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            factura.fechaVencimiento == null
                                ? 'Emitida ${formatearFecha(factura.fechaEmision)}'
                                : 'Vence ${formatearFecha(factura.fechaVencimiento)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: item.vencida
                                  ? colorPeligro
                                  : colorSecundario,
                              fontWeight: item.vencida
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Saldo',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorSecundario,
                          ),
                        ),
                        Text(
                          formatearImporte(factura.saldo),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: colorPrimario,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _verFactura(item),
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: const Text('Ver factura'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 42),
                        ),
                      ),
                    ),
                    if (puedeCobrar) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _cobrar(item),
                          icon: const Icon(
                            Icons.point_of_sale_rounded,
                            size: 18,
                          ),
                          label: const Text('Cobrar'),
                          style: FilledButton.styleFrom(
                            backgroundColor: colorExito,
                            minimumSize: const Size(0, 42),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _aviso(
    String titulo,
    String mensaje, {
    IconData icono = Icons.inbox_outlined,
    Color color = colorAcento,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: 34, color: color),
          ),
          const SizedBox(height: 14),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colorTexto,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: colorSecundario,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
