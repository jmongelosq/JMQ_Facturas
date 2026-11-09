class Factura {
  final int idFactura;
  final int idCliente;
  final DateTime? fechaEmision;
  final String numeroFactura;
  final String condicionVenta;
  final String periodo;
  final double subtotal;
  final double iva5;
  final double iva10;
  final double total;
  final String estado;
  final int plazoCredito;
  final DateTime? fechaVencimiento;
  final double pagado;
  final double saldo;

  const Factura({
    required this.idFactura,
    required this.idCliente,
    this.fechaEmision,
    required this.numeroFactura,
    required this.condicionVenta,
    required this.periodo,
    required this.subtotal,
    required this.iva5,
    required this.iva10,
    required this.total,
    required this.estado,
    required this.plazoCredito,
    this.fechaVencimiento,
    this.pagado = 0,
    this.saldo = 0,
  });

  bool get anulada => estado.toUpperCase().contains('ANULAD');

  bool get tieneSaldo => !anulada && saldo > 0;

  static double _numero(dynamic valor) {
    if (valor == null) return 0;
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor.toString()) ?? 0;
  }

  static int _entero(dynamic valor) {
    if (valor == null) return 0;
    if (valor is num) return valor.toInt();
    return int.tryParse(valor.toString()) ?? 0;
  }

  static DateTime? _fecha(dynamic valor) {
    if (valor == null || valor.toString().isEmpty) return null;
    return DateTime.tryParse(valor.toString());
  }

  factory Factura.fromJson(Map<String, dynamic> json) {
    final total = _numero(json['total']);
    final pagado = _numero(json['pagado']);

    return Factura(
      idFactura: _entero(json['id_factura']),
      idCliente: _entero(json['id_cliente']),
      fechaEmision: _fecha(json['fecha_emision']),
      numeroFactura: json['numero_factura']?.toString() ?? '',
      condicionVenta: json['condicion_venta']?.toString() ?? '',
      periodo: json['periodo']?.toString() ?? '',
      subtotal: _numero(json['subtotal']),
      iva5: _numero(json['iva_5']),
      iva10: _numero(json['iva_10']),
      total: total,
      estado: json['estado']?.toString() ?? '',
      plazoCredito: _entero(json['plazo_credito']),
      fechaVencimiento: _fecha(json['fecha_vencimiento']),
      pagado: pagado,
      saldo: json['saldo'] == null
          ? (total - pagado).clamp(0, double.infinity).toDouble()
          : _numero(json['saldo']),
    );
  }
}
