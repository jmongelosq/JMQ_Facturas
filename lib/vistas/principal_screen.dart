
import 'package:flutter/material.dart';

import '../config/estilos.dart';
import '../modelos/cliente.dart';
import '../modelos/factura.dart';
import '../servicios/api_service.dart';
import '../servicios/historial_consultas_service.dart';
import 'consulta_clientes_screen.dart';
import 'detalle_factura_screen.dart';
import 'historial_screen.dart';
import 'inicio_screen.dart';
import 'login_screen.dart';
import 'menu_vista.dart';
import 'pendientes_screen.dart';
import 'perfil_screen.dart';

class PrincipalScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const PrincipalScreen({
    super.key,
    required this.usuario,
  });

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  int _indiceSeleccionado = 0;
  int _recargaPendientes = 0;

  String get _nombreUsuario {
    final nombre = widget.usuario['nombre_completo'] ??
        widget.usuario['nombre'] ??
        widget.usuario['nombre_usuario'] ??
        widget.usuario['usuario'];

    if (nombre == null || nombre.toString().trim().isEmpty) {
      return 'Usuario JMQ';
    }

    return nombre.toString();
  }

  void _seleccionarPantalla(int indice) {
    if (!mounted) return;

    setState(() {
      if (indice == 1 && _indiceSeleccionado != 1) {
        _recargaPendientes++;
      }
      _indiceSeleccionado = indice;
    });
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text(
          '¿Deseás salir de JMQ Facturas? Tendrás que volver a ingresar tu usuario y contraseña.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorPeligro,
              minimumSize: const Size(0, 42),
            ),
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    ApiService.cerrarSesion();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> _abrirDesdeHistorial(
    HistorialConsulta consulta,
  ) async {
    try {
      final clientes = await ApiService.buscarClientes(
        consulta.idCliente.toString(),
      );

      Cliente? cliente;

      for (final candidato in clientes) {
        if (candidato.idCliente == consulta.idCliente) {
          cliente = candidato;
          break;
        }
      }

      if (cliente == null) {
        throw Exception(
          'No se encontró el cliente asociado a esta consulta.',
        );
      }

      final facturas = await ApiService.listarFacturas(
        cliente.idCliente,
      );

      Factura? factura;

      for (final candidata in facturas) {
        if (candidata.idFactura == consulta.idFactura) {
          factura = candidata;
          break;
        }
      }

      if (factura == null) {
        throw Exception(
          'La factura ya no está disponible para consultar.',
        );
      }

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DetalleFacturaScreen(
            factura: factura!,
            cliente: cliente!,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      mostrarError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    const titulos = [
      'Inicio',
      'Pendientes de cobro',
      'Consultar facturas',
      'Historial de consultas',
      'Mi perfil',
    ];

    final pantallas = [
      InicioContenido(
        nombreUsuario: _nombreUsuario,
        alConsultar: () => _seleccionarPantalla(2),
        alVerPendientes: () => _seleccionarPantalla(1),
        alVerHistorial: () => _seleccionarPantalla(3),
        alVerPerfil: () => _seleccionarPantalla(4),
      ),
      PendientesContenido(
        recarga: _recargaPendientes,
      ),
      ConsultaContenido(
        alAbrirFactura: (cliente, factura) async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DetalleFacturaScreen(
                cliente: cliente,
                factura: factura,
              ),
            ),
          );
        },
      ),
      HistorialContenido(
        alAbrirConsulta: _abrirDesdeHistorial,
      ),
      PerfilContenido(
        usuario: widget.usuario,
        alCerrarSesion: _cerrarSesion,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: degradadoPrincipal),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulos[_indiceSeleccionado],
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'JMQ SYSTEM · Facturas',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 0.8,
                color: Color(0xFFD6E2F3),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: InkWell(
              onTap: () => _seleccionarPantalla(4),
              customBorder: const CircleBorder(),
              child: CircleAvatar(
                radius: 19,
                backgroundColor: Colors.white,
                child: Text(
                  iniciales(_nombreUsuario),
                  style: const TextStyle(
                    color: colorPrimario,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: MenuVista(
        nombreUsuario: _nombreUsuario,
        indiceSeleccionado: _indiceSeleccionado,
        alSeleccionar: _seleccionarPantalla,
        alCerrarSesion: _cerrarSesion,
      ),
      body: IndexedStack(
        index: _indiceSeleccionado,
        children: pantallas,
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: colorBorde)),
        ),
        child: NavigationBar(
          selectedIndex: _indiceSeleccionado,
          onDestinationSelected: _seleccionarPantalla,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.pending_actions_outlined),
              selectedIcon: Icon(Icons.pending_actions_rounded),
              label: 'Pendientes',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Facturas',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_rounded),
              selectedIcon: Icon(Icons.manage_history_rounded),
              label: 'Historial',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
