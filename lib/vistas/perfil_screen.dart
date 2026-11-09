
import 'package:flutter/material.dart';

import '../config/estilos.dart';

class PerfilContenido extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final Future<void> Function() alCerrarSesion;

  const PerfilContenido({
    super.key,
    required this.usuario,
    required this.alCerrarSesion,
  });

  String _valorUsuario(List<String> claves) {
    for (final clave in claves) {
      final valor = usuario[clave];

      if (valor != null && valor.toString().trim().isNotEmpty) {
        return valor.toString();
      }
    }

    return 'No disponible';
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _valorUsuario([
      'nombre_completo',
      'nombre',
      'nombre_usuario',
      'usuario',
    ]);

    final usuarioLogin = _valorUsuario([
      'nombre_usuario',
      'usuario',
      'username',
    ]);

    final rol = _valorUsuario([
      'nombre_rol',
      'rol',
      'cargo',
      'nombre_cargo',
    ]);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
            decoration: BoxDecoration(
              gradient: degradadoPrincipal,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white,
                    child: Text(
                      iniciales(nombre),
                      style: const TextStyle(
                        color: colorPrimario,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  nombre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    rol,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  filaDato(
                    'Nombre',
                    nombre,
                    icono: Icons.person_outline_rounded,
                  ),
                  const Divider(height: 20),
                  filaDato(
                    'Usuario',
                    usuarioLogin,
                    icono: Icons.account_circle_outlined,
                  ),
                  const Divider(height: 20),
                  filaDato(
                    'Rol',
                    rol,
                    icono: Icons.badge_outlined,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 17),
          Card(
            child: const Padding(
              padding: EdgeInsets.all(17),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: colorAcento,
                    size: 25,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Permisos en la aplicación',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Podés consultar clientes, facturas, pagos y '
                          'documentos PDF, y registrar cobros si tu rol lo '
                          'permite. No se modifican clientes, tarifas ni '
                          'facturas emitidas.',
                          style: TextStyle(
                            color: colorSecundario,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: alCerrarSesion,
              icon: const Icon(Icons.logout_rounded),
              label: const Text(
                'CERRAR SESIÓN',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorPeligro,
                side: BorderSide(
                  color: colorPeligro.withValues(alpha: 0.4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
