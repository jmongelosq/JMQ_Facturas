
class Pago {
  final int idPago;
  final DateTime? fechaPago;
  final String periodo;
  final double monto;
  final String metodoPago;
  final String numeroRecibo;
  final String estado;
  final String observaciones;
  final int idFactura;

  const Pago({
    required this.idPago,
    this.fechaPago,
    required this.periodo,
    required this.monto,
    required this.metodoPago,
    required this.numeroRecibo,
    required this.estado,
    required this.observaciones,
    required this.idFactura,
  });

  static int _entero(dynamic valor) {
    if (valor == null) return 0;
    if (valor is num) return valor.toInt();
    return int.tryParse(valor.toString()) ?? 0;
  }

  static double _numero(dynamic valor) {
    if (valor == null) return 0;
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor.toString()) ?? 0;
  }

  static DateTime? _fecha(dynamic valor) {
    if (valor == null || valor.toString().isEmpty) return null;
    return DateTime.tryParse(valor.toString());
  }

  factory Pago.fromJson(Map<String, dynamic> json) {
    return Pago(
      idPago: _entero(json['id_pago']),
      fechaPago: _fecha(json['fecha_pago']),
      periodo: json['periodo']?.toString() ?? '',
      monto: _numero(json['monto']),
      metodoPago: json['metodo_pago']?.toString() ?? '',
      numeroRecibo: json['numero_recibo']?.toString() ?? '',
      estado: json['estado']?.toString() ?? '',
      observaciones: json['observaciones']?.toString() ?? '',
      idFactura: _entero(json['id_factura']),
    );
  }
}
