
class DetalleFactura {
  final int idDetalleFactura;
  final int idFactura;
  final int? idTarifa;
  final String descripcion;
  final double cantidad;
  final double precioUnitario;
  final double porcentajeIva;
  final double subtotal;
  final double montoIva;
  final double total;

  const DetalleFactura({
    required this.idDetalleFactura,
    required this.idFactura,
    this.idTarifa,
    required this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    required this.porcentajeIva,
    required this.subtotal,
    required this.montoIva,
    required this.total,
  });

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

  factory DetalleFactura.fromJson(Map<String, dynamic> json) {
    return DetalleFactura(
      idDetalleFactura: _entero(json['id_detalle_factura']),
      idFactura: _entero(json['id_factura']),
      idTarifa: json['id_tarifa'] == null
          ? null
          : _entero(json['id_tarifa']),
      descripcion: json['descripcion']?.toString() ?? '',
      cantidad: _numero(json['cantidad']),
      precioUnitario: _numero(json['precio_unitario']),
      porcentajeIva: _numero(json['porcentaje_iva']),
      subtotal: _numero(json['subtotal']),
      montoIva: _numero(json['monto_iva']),
      total: _numero(json['total']),
    );
  }
}
