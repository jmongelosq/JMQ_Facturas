
class Cliente {
  final int idCliente;
  final String nombre;
  final String apellido;
  final String? cedula;
  final String? ruc;
  final String? telefono;
  final String? direccion;
  final String? correo;

  const Cliente({
    required this.idCliente,
    required this.nombre,
    required this.apellido,
    this.cedula,
    this.ruc,
    this.telefono,
    this.direccion,
    this.correo,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      idCliente: _convertirInt(json['id_cliente']),
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      cedula: json['cedula']?.toString(),
      ruc: json['ruc']?.toString(),
      telefono: json['telefono']?.toString(),
      direccion: json['direccion']?.toString(),
      correo: json['correo']?.toString(),
    );
  }

  static int _convertirInt(dynamic valor) {
    if (valor is int) return valor;
    return int.tryParse(valor?.toString() ?? '') ?? 0;
  }

  String get nombreCompleto {
    return '$nombre $apellido'.trim();
  }
}
