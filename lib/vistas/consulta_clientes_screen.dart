
import 'package:flutter/material.dart';
import '../config/estilos.dart';
import '../modelos/cliente.dart';
import '../modelos/factura.dart';
import '../servicios/api_service.dart';
import 'facturas_cliente_screen.dart';

class ConsultaContenido extends StatefulWidget {
  final Future<void> Function(Cliente cliente, Factura factura)
      alAbrirFactura;

  const ConsultaContenido({
    super.key,
    required this.alAbrirFactura,
  });

  @override
  State<ConsultaContenido> createState() => _ConsultaContenidoState();
}

class _ConsultaContenidoState extends State<ConsultaContenido> {
  final _busquedaController = TextEditingController();

  List<Cliente> _clientes = [];
  bool _cargando = false;
  bool _busquedaRealizada = false;
  String? _error;

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _buscarClientes() async {
    final criterio = _busquedaController.text.trim();

    if (criterio.isEmpty) {
      setState(() {
        _error = 'Ingresá un nombre, documento, RUC o teléfono para buscar.';
        _clientes = [];
        _busquedaRealizada = false;
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _cargando = true;
      _error = null;
      _busquedaRealizada = true;
      _clientes = [];
    });

    try {
      final resultado = await ApiService.buscarClientes(criterio);

      if (!mounted) return;

      setState(() {
        _clientes = resultado;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = mensajeError(e));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _abrirCliente(Cliente cliente) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FacturasClienteScreen(
          cliente: cliente,
          alAbrirFactura: widget.alAbrirFactura,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: colorBorde)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              tituloSeccion(
                'Buscar cliente',
                subtitulo: 'Encontrá al cliente para ver sus facturas.',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _busquedaController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _buscarClientes(),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Nombre, cédula, RUC o teléfono',
                        fillColor: colorFondo,
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _busquedaController.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Limpiar',
                                onPressed: () {
                                  _busquedaController.clear();
                                  setState(() {
                                    _clientes = [];
                                    _error = null;
                                    _busquedaRealizada = false;
                                  });
                                },
                                icon: const Icon(Icons.close_rounded),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 54,
                    height: 54,
                    child: FilledButton(
                      onPressed: _cargando ? null : _buscarClientes,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(54, 54),
                      ),
                      child: _cargando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.arrow_forward_rounded),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(child: _construirResultados()),
      ],
    );
  }

  Widget _construirResultados() {
    if (_cargando) {
      return indicadorCarga(mensaje: 'Buscando clientes...');
    }

    if (_error != null) {
      return mensajeVacio(
        'No se pudo completar la búsqueda',
        _error!,
        icono: Icons.cloud_off_rounded,
        color: colorPeligro,
      );
    }

    if (!_busquedaRealizada) {
      return mensajeVacio(
        'Buscá un cliente',
        'Escribí el nombre, número de cédula, RUC o teléfono '
            'y presioná buscar.',
        icono: Icons.person_search_outlined,
      );
    }

    if (_clientes.isEmpty) {
      return mensajeVacio(
        'No se encontraron clientes',
        'Probá con otro nombre, número de documento o RUC.',
        icono: Icons.search_off_rounded,
        color: colorAdvertencia,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: _clientes.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              '${_clientes.length} cliente'
              '${_clientes.length == 1 ? '' : 's'} encontrado'
              '${_clientes.length == 1 ? '' : 's'}',
              style: const TextStyle(
                color: colorSecundario,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        final cliente = _clientes[index - 1];
        final documento = (cliente.ruc != null &&
                cliente.ruc!.trim().isNotEmpty)
            ? 'RUC ${cliente.ruc!.trim()}'
            : 'C.I. ${textoSeguro(cliente.cedula)}';

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _abrirCliente(cliente),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorBorde),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: colorAcento.withValues(alpha: 0.12),
                    child: Text(
                      iniciales(cliente.nombreCompleto),
                      style: const TextStyle(
                        color: colorPrimario,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cliente.nombreCompleto,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: colorTexto,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _chip(Icons.badge_outlined, documento),
                            if (cliente.telefono != null &&
                                cliente.telefono!.trim().isNotEmpty)
                              _chip(
                                Icons.phone_outlined,
                                cliente.telefono!.trim(),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: colorAcento,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _chip(IconData icono, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 13, color: colorSecundario),
          const SizedBox(width: 4),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 11,
              color: colorSecundario,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
