import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/cliente.dart';
import '../modelos/factura.dart';

class HistorialConsulta {
  final String id;
  final int idCliente;
  final String nombreCliente;
  final int idFactura;
  final String numeroFactura;
  final double total;
  final DateTime fechaConsulta;

  const HistorialConsulta({
    required this.id,
    required this.idCliente,
    required this.nombreCliente,
    required this.idFactura,
    required this.numeroFactura,
    required this.total,
    required this.fechaConsulta,
  });

  factory HistorialConsulta.fromJson(Map<String, dynamic> json) {
    return HistorialConsulta(
      id: json['id']?.toString() ?? '',
      idCliente: _entero(json['id_cliente']),
      nombreCliente: json['nombre_cliente']?.toString() ?? '',
      idFactura: _entero(json['id_factura']),
      numeroFactura: json['numero_factura']?.toString() ?? '',
      total: _decimal(json['total']),
      fechaConsulta:
          DateTime.tryParse(json['fecha_consulta']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_cliente': idCliente,
      'nombre_cliente': nombreCliente,
      'id_factura': idFactura,
      'numero_factura': numeroFactura,
      'total': total,
      'fecha_consulta': fechaConsulta.toIso8601String(),
    };
  }

  static int _entero(dynamic valor) {
    if (valor is num) return valor.toInt();
    return int.tryParse(valor?.toString() ?? '') ?? 0;
  }

  static double _decimal(dynamic valor) {
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor?.toString() ?? '') ?? 0;
  }
}

class HistorialConsultasService {
  static const String _claveHistorial = 'jmq_historial_consultas';

  static Future<List<HistorialConsulta>> obtenerHistorial() async {
    final preferencias = await SharedPreferences.getInstance();
    final contenido = preferencias.getString(_claveHistorial);

    if (contenido == null || contenido.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(contenido);

      if (decoded is! List) {
        return [];
      }

      final historial = decoded
          .whereType<Map>()
          .map(
            (item) => HistorialConsulta.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      historial.sort(
        (a, b) => b.fechaConsulta.compareTo(a.fechaConsulta),
      );

      return historial;
    } catch (_) {
      return [];
    }
  }

  static Future<void> registrarConsulta({
    required Cliente cliente,
    required Factura factura,
  }) async {
    final historial = await obtenerHistorial();

    final consulta = HistorialConsulta(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      idCliente: cliente.idCliente,
      nombreCliente: cliente.nombreCompleto,
      idFactura: factura.idFactura,
      numeroFactura: factura.numeroFactura,
      total: factura.total,
      fechaConsulta: DateTime.now(),
    );

    historial.insert(0, consulta);

    final limitado = historial.take(100).toList();

    final preferencias = await SharedPreferences.getInstance();

    await preferencias.setString(
      _claveHistorial,
      jsonEncode(limitado.map((item) => item.toJson()).toList()),
    );
  }

  static Future<void> eliminarConsulta(String id) async {
    final historial = await obtenerHistorial();

    historial.removeWhere((consulta) => consulta.id == id);

    final preferencias = await SharedPreferences.getInstance();

    await preferencias.setString(
      _claveHistorial,
      jsonEncode(historial.map((item) => item.toJson()).toList()),
    );
  }

  static Future<void> limpiarHistorial() async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.remove(_claveHistorial);
  }
}