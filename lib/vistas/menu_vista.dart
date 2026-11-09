
import 'package:flutter/material.dart';

import '../config/estilos.dart';

class MenuVista extends StatelessWidget {
  final String nombreUsuario;
  final int indiceSeleccionado;
  final ValueChanged<int> alSeleccionar;
  final VoidCallback alCerrarSesion;

  const MenuVista({
    super.key,
    required this.nombreUsuario,
    required this.indiceSeleccionado,
    required this.alSeleccionar,
    required this.alCerrarSesion,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 27, 22, 24),
              decoration: const BoxDecoration(
                gradient: degradadoPrincipal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  logoInstitucional(tamano: 72, radio: 18),
                  const SizedBox(height: 15),
                  const Text(
                    'JMQ SYSTEM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    nombreUsuario.trim().isEmpty
                        ? 'Usuario JMQ'
                        : nombreUsuario,
                    style: const TextStyle(
                      color: Color(0xFFD6E2F3),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _elementoMenu(
              context: context,
              icono: Icons.home_outlined,
              titulo: 'Inicio',
              indice: 0,
            ),
            _elementoMenu(
              context: context,
              icono: Icons.pending_actions_outlined,
              titulo: 'Pendientes de cobro',
              indice: 1,
            ),
            _elementoMenu(
              context: context,
              icono: Icons.search_rounded,
              titulo: 'Consultar facturas',
              indice: 2,
            ),
            _elementoMenu(
              context: context,
              icono: Icons.history_rounded,
              titulo: 'Historial de consultas',
              indice: 3,
            ),
            _elementoMenu(
              context: context,
              icono: Icons.person_outline_rounded,
              titulo: 'Mi perfil',
              indice: 4,
            ),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: colorPeligro,
              ),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: colorPeligro,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: alCerrarSesion,
            ),
            const Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                'JMQ SYSTEM · Cobro móvil v1.0',
                style: TextStyle(
                  fontSize: 11,
                  color: colorSecundario,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _elementoMenu({
    required BuildContext context,
    required IconData icono,
    required String titulo,
    required int indice,
  }) {
    final seleccionado = indiceSeleccionado == indice;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 3,
      ),
      child: ListTile(
        selected: seleccionado,
        selectedColor: colorPrimario,
        selectedTileColor: colorAcento.withValues(alpha: 0.10),
        iconColor: colorSecundario,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        leading: Icon(icono),
        title: Text(
          titulo,
          style: TextStyle(
            fontSize: 14,
            fontWeight: seleccionado
                ? FontWeight.w800
                : FontWeight.w500,
          ),
        ),
        onTap: () {
          Navigator.of(context).pop();
          alSeleccionar(indice);
        },
      ),
    );
  }
}
