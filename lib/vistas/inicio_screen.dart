import 'package:flutter/material.dart';

import '../config/estilos.dart';
import '../servicios/api_service.dart';

class InicioContenido extends StatelessWidget {
  final String nombreUsuario;
  final VoidCallback alConsultar;
  final VoidCallback alVerPendientes;
  final VoidCallback alVerHistorial;
  final VoidCallback alVerPerfil;

  const InicioContenido({
    super.key,
    required this.nombreUsuario,
    required this.alConsultar,
    required this.alVerPendientes,
    required this.alVerHistorial,
    required this.alVerPerfil,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bienvenida(),
          const SizedBox(height: 26),
          tituloSeccion(
            'Accesos rápidos',
            subtitulo: 'Elegí qué información necesitás consultar.',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _accesoRapido(
                  icono: Icons.person_search_outlined,
                  titulo: 'Buscar cliente',
                  descripcion: 'Por nombre, cédula o RUC',
                  color: colorAcento,
                  onTap: alConsultar,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _accesoRapido(
                  icono: Icons.pending_actions_outlined,
                  titulo: 'Pendientes',
                  descripcion: 'Facturas por cobrar en tu zona',
                  color: colorPrimario,
                  onTap: alVerPendientes,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _accesoRapido(
                  icono: Icons.history_rounded,
                  titulo: 'Historial',
                  descripcion: 'Consultas anteriores',
                  color: colorExito,
                  onTap: alVerHistorial,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _accesoRapido(
                  icono: Icons.badge_outlined,
                  titulo: 'Mi perfil',
                  descripcion: 'Usuario y rol',
                  color: colorAdvertencia,
                  onTap: alVerPerfil,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          tituloSeccion(
            '¿Qué podés consultar?',
            subtitulo: 'Información disponible en la aplicación.',
          ),
          const SizedBox(height: 14),
          Container(
            decoration: decoracionTarjeta(),
            child: Column(
              children: [
                _itemFuncion(
                  Icons.description_outlined,
                  'Facturas emitidas',
                  'Número, período, condición de venta y estado.',
                ),
                const Divider(height: 1, indent: 70),
                _itemFuncion(
                  Icons.list_alt_rounded,
                  'Conceptos facturados',
                  'Cantidades, precios e IVA de cada servicio.',
                ),
                const Divider(height: 1, indent: 70),
                _itemFuncion(
                  Icons.map_outlined,
                  'Pendientes por zona',
                  'Facturas con saldo del barrio que vas a recorrer.',
                ),
                const Divider(height: 1, indent: 70),
                _itemFuncion(
                  Icons.point_of_sale_rounded,
                  'Registro de cobros',
                  'Cobro total o parcial con recibo automático.',
                ),
                const Divider(height: 1, indent: 70),
                _itemFuncion(
                  Icons.picture_as_pdf_outlined,
                  'Factura en PDF',
                  'El mismo formato que emite JMQ SYSTEM.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorAcento.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorAcento.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  color: colorAcento,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Integrado con JMQ SYSTEM',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: colorTexto,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Los cobros registrados en la aplicación quedan '
                        'guardados al instante en el sistema web.',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorSecundario,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Conectado a ${ApiService.servidor}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: colorAcento,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bienvenida() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: degradadoPrincipal,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorPrimario.withValues(alpha: 0.25),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -50,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Color(0xFFB8C8E0),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        fechaLarga(DateTime.now()),
                        style: const TextStyle(
                          color: Color(0xFFB8C8E0),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  '${saludoSegunHora()},',
                  style: const TextStyle(
                    color: Color(0xFFD6E2F3),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nombreUsuario,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Consultá facturas, revisá el saldo de cada cliente y registrá los cobros en el momento.',
                  style: TextStyle(
                    color: Color(0xFFD6E2F3),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: alConsultar,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: colorPrimario,
                    ),
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('CONSULTAR FACTURAS'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _accesoRapido({
    required IconData icono,
    required String titulo,
    required String descripcion,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 132,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colorBorde),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  iconoCaja(icono, color: color, tamano: 42),
                  const Spacer(),
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 18,
                    color: color.withValues(alpha: 0.7),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: colorTexto,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                descripcion,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: colorSecundario,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemFuncion(IconData icono, String titulo, String descripcion) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          iconoCaja(icono, tamano: 42),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: colorTexto,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  descripcion,
                  style: const TextStyle(
                    fontSize: 12,
                    color: colorSecundario,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
