class ResultadoCobro {
  final int idPago;
  final String numeroRecibo;
  final DateTime? fechaPago;
  final double monto;
  final String metodoPago;
  final double saldo;
  final String estadoFactura;

  const ResultadoCobro({
    required this.idPago,
    required this.numeroRecibo,
    this.fechaPago,
    required this.monto,
    required this.metodoPago,
    required this.saldo,
    required this.estadoFactura,
  });

  static double _numero(dynamic valor) {
    if (valor == null) return 0;
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor.toString()) ?? 0;
  }

  factory ResultadoCobro.fromJson(Map<String, dynamic> json) {
    final pago = json['pago'] is Map
        ? Map<String, dynamic>.from(json['pago'] as Map)
        : <String, dynamic>{};

    return ResultadoCobro(
      idPago: _numero(pago['id_pago']).toInt(),
      numeroRecibo: pago['numero_recibo']?.toString() ?? '',
      fechaPago: DateTime.tryParse(pago['fecha_pago']?.toString() ?? ''),
      monto: _numero(pago['monto']),
      metodoPago: pago['metodo_pago']?.toString() ?? '',
      saldo: _numero(json['saldo']),
      estadoFactura: json['estado_factura']?.toString() ?? '',
    );
  }
}
