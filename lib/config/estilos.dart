import 'package:flutter/material.dart';

const Color colorPrimario = Color(0xFF1F3864);
const Color colorOscuro = Color(0xFF14264A);
const Color colorAcento = Color(0xFF2E75B6);
const Color colorExito = Color(0xFF1E8E4E);
const Color colorAdvertencia = Color(0xFFD97706);
const Color colorPeligro = Color(0xFFB42318);
const Color colorFondo = Color(0xFFF3F6FA);
const Color colorTexto = Color(0xFF1C2635);
const Color colorSecundario = Color(0xFF6B7789);
const Color colorBorde = Color(0xFFE2E8F0);

const LinearGradient degradadoPrincipal = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [colorOscuro, colorPrimario, colorAcento],
  stops: [0, 0.55, 1],
);

String formatearNumero(double importe) {
  final negativo = importe < 0;
  final entero = importe.abs().round().toString();
  final buffer = StringBuffer();

  for (int i = 0; i < entero.length; i++) {
    buffer.write(entero[i]);

    final restantes = entero.length - i - 1;
    if (restantes > 0 && restantes % 3 == 0) {
      buffer.write('.');
    }
  }

  return negativo ? '-$buffer' : buffer.toString();
}

String formatearImporte(double importe) {
  return 'Gs. ${formatearNumero(importe)}';
}

String formatearFecha(DateTime? fecha) {
  if (fecha == null) return 'No disponible';

  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');

  return '$dia/$mes/${fecha.year}';
}

String formatearFechaHora(DateTime fecha) {
  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');
  final hora = fecha.hour.toString().padLeft(2, '0');
  final minuto = fecha.minute.toString().padLeft(2, '0');

  return '$dia/$mes/${fecha.year} - $hora:$minuto';
}

String fechaLarga(DateTime fecha) {
  const dias = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  const meses = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  return '${dias[fecha.weekday - 1]}, ${fecha.day} de '
      '${meses[fecha.month - 1]} de ${fecha.year}';
}

String saludoSegunHora() {
  final hora = DateTime.now().hour;

  if (hora < 12) return 'Buenos días';
  if (hora < 19) return 'Buenas tardes';
  return 'Buenas noches';
}

String iniciales(String nombre) {
  final partes = nombre
      .trim()
      .split(RegExp(r'\s+'))
      .where((parte) => parte.isNotEmpty)
      .toList();

  if (partes.isEmpty) return 'JM';
  if (partes.length == 1) {
    return partes.first.substring(0, 1).toUpperCase();
  }

  return (partes[0].substring(0, 1) + partes[1].substring(0, 1))
      .toUpperCase();
}

String textoSeguro(String? valor) {
  if (valor == null || valor.trim().isEmpty) {
    return 'No disponible';
  }

  return valor.trim();
}

String mensajeError(Object error) {
  return error.toString().replaceFirst('Exception: ', '');
}

Color colorEstado(String estado) {
  final valor = estado.toLowerCase();

  if (valor.contains('pagad') ||
      valor.contains('activo') ||
      valor.contains('cancelad')) {
    return colorExito;
  }

  if (valor.contains('emitid')) {
    return colorAcento;
  }

  if (valor.contains('pendiente') ||
      valor.contains('parcial') ||
      valor.contains('vencid') ||
      valor.contains('debe')) {
    return colorAdvertencia;
  }

  if (valor.contains('anulad') || valor.contains('inactivo')) {
    return colorPeligro;
  }

  return colorSecundario;
}

Widget etiquetaEstado(String estado, {bool sobreFondoOscuro = false}) {
  final color = colorEstado(estado);

  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 5,
    ),
    decoration: BoxDecoration(
      color: sobreFondoOscuro
          ? Colors.white.withValues(alpha: 0.16)
          : color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(
        color: sobreFondoOscuro
            ? Colors.white.withValues(alpha: 0.35)
            : color.withValues(alpha: 0.30),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: sobreFondoOscuro ? Colors.white : color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          textoSeguro(estado).toUpperCase(),
          style: TextStyle(
            color: sobreFondoOscuro ? Colors.white : color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ],
    ),
  );
}

BoxDecoration decoracionTarjeta({double radio = 16}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radio),
    border: Border.all(color: colorBorde),
    boxShadow: [
      BoxShadow(
        color: colorPrimario.withValues(alpha: 0.05),
        blurRadius: 14,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

Widget logoInstitucional({double tamano = 72, double radio = 18}) {
  return Container(
    width: tamano,
    height: tamano,
    padding: EdgeInsets.all(tamano * 0.11),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radio),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.16),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Image.asset(
      'assets/logo.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.business_rounded,
          size: tamano * 0.5,
          color: colorPrimario,
        );
      },
    ),
  );
}

Widget iconoCaja(
  IconData icono, {
  Color color = colorAcento,
  double tamano = 46,
}) {
  return Container(
    width: tamano,
    height: tamano,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(tamano * 0.3),
    ),
    child: Icon(
      icono,
      color: color,
      size: tamano * 0.52,
    ),
  );
}

Widget tituloSeccion(
  String titulo, {
  String? subtitulo,
  Widget? accion,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        width: 4,
        height: subtitulo == null ? 20 : 36,
        decoration: BoxDecoration(
          color: colorAcento,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colorTexto,
              ),
            ),
            if (subtitulo != null) ...[
              const SizedBox(height: 3),
              Text(
                subtitulo,
                style: const TextStyle(
                  fontSize: 12,
                  color: colorSecundario,
                ),
              ),
            ],
          ],
        ),
      ),
      ?accion,
    ],
  );
}

Widget filaDato(
  String etiqueta,
  String valor, {
  IconData? icono,
  bool destacado = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icono != null) ...[
          Icon(
            icono,
            size: 18,
            color: colorAcento,
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          flex: 4,
          child: Text(
            etiqueta,
            style: const TextStyle(
              color: colorSecundario,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 6,
          child: Text(
            valor,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: destacado ? colorPrimario : colorTexto,
              fontSize: destacado ? 14 : 13,
              fontWeight: destacado ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget mensajeVacio(
  String titulo,
  String mensaje, {
  IconData icono = Icons.inbox_outlined,
  Color color = colorAcento,
}) {
  return Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icono,
                  size: 32,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colorTexto,
            ),
          ),
          const SizedBox(height: 8),
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
    ),
  );
}

Widget indicadorCarga({
  String mensaje = 'Cargando información...',
}) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 34,
          height: 34,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: colorAcento,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          mensaje,
          style: const TextStyle(
            color: colorSecundario,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}

void mostrarError(BuildContext context, Object error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(child: Text(mensajeError(error))),
        ],
      ),
      backgroundColor: colorPeligro,
    ),
  );
}

void mostrarAviso(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(child: Text(mensaje)),
        ],
      ),
      backgroundColor: colorPrimario,
    ),
  );
}
