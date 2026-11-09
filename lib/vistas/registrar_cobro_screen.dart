import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/estilos.dart';
import '../modelos/cliente.dart';
import '../modelos/factura.dart';
import '../servicios/api_service.dart';
import 'comprobante_cobro_screen.dart';

class RegistrarCobroScreen extends StatefulWidget {
  final Cliente cliente;
  final Factura factura;
  final double saldo;
  final bool desdeDetalle;

  const RegistrarCobroScreen({
    super.key,
    required this.cliente,
    required this.factura,
    required this.saldo,
    this.desdeDetalle = true,
  });

  @override
  State<RegistrarCobroScreen> createState() => _RegistrarCobroScreenState();
}

class _RegistrarCobroScreenState extends State<RegistrarCobroScreen> {
  static const _metodos = <String, IconData>{
    'EFECTIVO': Icons.payments_outlined,
    'TRANSFERENCIA': Icons.account_balance_outlined,
    'TARJETA': Icons.credit_card_outlined,
    'OTRO': Icons.more_horiz_rounded,
  };

  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _observacionesController = TextEditingController();

  String _metodo = 'EFECTIVO';
  bool _guardando = false;

  int get _saldoEntero => widget.saldo.round();

  @override
  void initState() {
    super.initState();
    _montoController.text = _saldoEntero.toString();
  }

  @override
  void dispose() {
    _montoController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  int get _montoIngresado =>
      int.tryParse(_montoController.text.replaceAll('.', '').trim()) ?? 0;

  String? _validarMonto(String? valor) {
    final monto = int.tryParse((valor ?? '').replaceAll('.', '').trim());

    if (monto == null || monto <= 0) {
      return 'Ingresá un monto mayor a cero.';
    }

    if (monto > _saldoEntero) {
      return 'El monto no puede superar el saldo '
          '(${formatearImporte(widget.saldo)}).';
    }

    return null;
  }

  Future<void> _confirmarYRegistrar() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final monto = _montoIngresado;
    final saldoRestante = _saldoEntero - monto;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar cobro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            filaDato('Cliente', widget.cliente.nombreCompleto),
            filaDato('Factura', 'N.º ${widget.factura.numeroFactura}'),
            filaDato('Método', _metodo),
            const Divider(height: 20),
            filaDato(
              'Monto a cobrar',
              formatearImporte(monto.toDouble()),
              destacado: true,
            ),
            filaDato(
              'Saldo después del cobro',
              formatearImporte(saldoRestante.toDouble()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: colorExito,
              minimumSize: const Size(0, 42),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.check_rounded),
            label: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    setState(() => _guardando = true);

    try {
      final resultado = await ApiService.registrarPago(
        idFactura: widget.factura.idFactura,
        monto: monto,
        metodoPago: _metodo,
        observaciones: _observacionesController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ComprobanteCobroScreen(
            cliente: widget.cliente,
            factura: widget.factura,
            resultado: resultado,
            desdeDetalle: widget.desdeDetalle,
          ),
        ),
        result: true,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      mostrarError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final factura = widget.factura;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: degradadoPrincipal),
        ),
        title: const Text('Registrar cobro'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: degradadoPrincipal,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.cliente.nombreCompleto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Factura N.º ${factura.numeroFactura}  ·  '
                    'Período ${textoSeguro(factura.periodo)}',
                    style: const TextStyle(
                      color: Color(0xFFD6E2F3),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _datoEncabezado(
                          'Total factura',
                          formatearImporte(factura.total),
                        ),
                      ),
                      Expanded(
                        child: _datoEncabezado(
                          'Saldo pendiente',
                          formatearImporte(widget.saldo),
                          grande: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            tituloSeccion(
              'Monto a cobrar',
              subtitulo: 'Podés cobrar el saldo completo o una parte.',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _montoController,
              enabled: !_guardando,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: colorPrimario,
              ),
              decoration: InputDecoration(
                prefixText: 'Gs. ',
                prefixStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: colorPrimario,
                ),
                helperText: 'Saldo: ${formatearImporte(widget.saldo)}',
              ),
              validator: _validarMonto,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.done_all_rounded, size: 18),
                  label: const Text('Saldo completo'),
                  onPressed: _guardando
                      ? null
                      : () => setState(() {
                            _montoController.text = _saldoEntero.toString();
                          }),
                ),
                if (_saldoEntero >= 2)
                  ActionChip(
                    avatar: const Icon(Icons.splitscreen_outlined, size: 18),
                    label: const Text('Mitad'),
                    onPressed: _guardando
                        ? null
                        : () => setState(() {
                              _montoController.text =
                                  (_saldoEntero ~/ 2).toString();
                            }),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            tituloSeccion('Método de pago'),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.9,
              children: _metodos.entries.map((entrada) {
                final seleccionado = _metodo == entrada.key;

                return Material(
                  color: seleccionado
                      ? colorAcento.withValues(alpha: 0.10)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _guardando
                        ? null
                        : () => setState(() => _metodo = entrada.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: seleccionado ? colorAcento : colorBorde,
                          width: seleccionado ? 1.6 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            entrada.value,
                            color:
                                seleccionado ? colorAcento : colorSecundario,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entrada.key,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: seleccionado
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color:
                                    seleccionado ? colorPrimario : colorTexto,
                              ),
                            ),
                          ),
                          if (seleccionado)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: colorAcento,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            tituloSeccion('Observaciones', subtitulo: 'Opcional.'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _observacionesController,
              enabled: !_guardando,
              maxLength: 150,
              maxLines: 3,
              minLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Ej.: pagó en el domicilio, entregó el titular.',
              ),
            ),
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
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: colorExito),
              onPressed: _guardando ? null : _confirmarYRegistrar,
              icon: _guardando
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.point_of_sale_rounded),
              label: Text(
                _guardando
                    ? 'Registrando cobro...'
                    : 'COBRAR ${formatearImporte(_montoIngresado.toDouble())}',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _datoEncabezado(String titulo, String valor, {bool grande = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(color: Color(0xFFB8C8E0), fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          valor,
          style: TextStyle(
            color: Colors.white,
            fontSize: grande ? 20 : 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
