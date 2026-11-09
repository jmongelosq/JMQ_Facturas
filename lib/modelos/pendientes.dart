import 'cliente.dart';
import 'factura.dart';

class ZonaPendiente {
  final int idBarrio;
  final String nombre;
  final int pendientes;
  final double saldo;

  const ZonaPendiente({
    required this.idBarrio,
    required this.nombre,
    required this.pendientes,
    required this.saldo,
  });

  factory ZonaPendiente.fromJson(Map<String, dynamic> json) {
    return ZonaPendiente(
      idBarrio: _entero(json['id_barrio']),
      nombre: json['nombre']?.toString() ?? '',
      pendientes: _entero(json['pendientes']),
      saldo: _numero(json['saldo']),
    );
  }
}

class FacturaPendiente {
  final Factura factura;
  final Cliente cliente;
  final int idBarrio;
  final String barrio;

  const FacturaPendiente({
    required this.factura,
    required this.cliente,
    required this.idBarrio,
    required this.barrio,
  });

  bool get vencida {
    final vencimiento = factura.fechaVencimiento;
    if (vencimiento == null) return false;

    final hoy = DateTime.now();
    final inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
    return vencimiento.isBefore(inicioHoy);
  }

  factory FacturaPendiente.fromJson(Map<String, dynamic> json) {
    final datosCliente = json['cliente'] is Map
        ? Map<String, dynamic>.from(json['cliente'] as Map)
        : <String, dynamic>{'id_cliente': json['id_cliente']};

    return FacturaPendiente(
      factura: Factura.fromJson(json),
      cliente: Cliente.fromJson(datosCliente),
      idBarrio: _entero(json['id_barrio']),
      barrio: json['barrio']?.toString() ?? '',
    );
  }
}

class ResumenPendientes {
  final int? idBarrioAsignado;
  final String? barrioAsignado;
  final int idBarrioActual;
  final List<ZonaPendiente> zonas;
  final int totalPendientes;
  final double totalSaldo;
  final List<FacturaPendiente> facturas;

  const ResumenPendientes({
    this.idBarrioAsignado,
    this.barrioAsignado,
    required this.idBarrioActual,
    required this.zonas,
    required this.totalPendientes,
    required this.totalSaldo,
    required this.facturas,
  });

  bool get tieneZonaAsignada =>
      idBarrioAsignado != null && idBarrioAsignado! > 0;

  String get nombreZonaActual {
    if (idBarrioActual == 0) return 'Todas las zonas';

    for (final zona in zonas) {
      if (zona.idBarrio == idBarrioActual) return zona.nombre;
    }

    return 'Zona seleccionada';
  }

  double get saldoZonaActual {
    return facturas.fold<double>(
      0,
      (suma, item) => suma + item.factura.saldo,
    );
  }

  factory ResumenPendientes.fromJson(Map<String, dynamic> json) {
    final asignado = json['barrio_asignado'];

    return ResumenPendientes(
      idBarrioAsignado:
          asignado is Map ? _entero(asignado['id_barrio']) : null,
      barrioAsignado: asignado is Map ? asignado['nombre']?.toString() : null,
      idBarrioActual: _entero(json['id_barrio_actual']),
      zonas: json['barrios'] is List
          ? (json['barrios'] as List)
              .map(
                (item) => ZonaPendiente.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList()
          : const [],
      totalPendientes: _entero(json['total_pendientes']),
      totalSaldo: _numero(json['total_saldo']),
      facturas: json['facturas'] is List
          ? (json['facturas'] as List)
              .map(
                (item) => FacturaPendiente.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList()
          : const [],
    );
  }
}

int _entero(dynamic valor) {
  if (valor == null) return 0;
  if (valor is num) return valor.toInt();
  return int.tryParse(valor.toString()) ?? 0;
}

double _numero(dynamic valor) {
  if (valor == null) return 0;
  if (valor is num) return valor.toDouble();
  return double.tryParse(valor.toString()) ?? 0;
}
