
import 'package:flutter/material.dart';

import '../config/estilos.dart';
import '../servicios/historial_consultas_service.dart';

class HistorialContenido extends StatefulWidget {
  final Future<void> Function(HistorialConsulta consulta)
      alAbrirConsulta;

  const HistorialContenido({
    super.key,
    required this.alAbrirConsulta,
  });

  @override
  State<HistorialContenido> createState() =>
      _HistorialContenidoState();
}

class _HistorialContenidoState extends State<HistorialContenido> {
  late Future<List<HistorialConsulta>> _historialFuture;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  void _cargarHistorial() {
    _historialFuture =
        HistorialConsultasService.obtenerHistorial();
  }

  Future<void> _actualizarHistorial() async {
    setState(_cargarHistorial);

    try {
      await _historialFuture;
    } catch (_) {
      return;
    }
  }

  Future<void> _eliminarConsulta(
    HistorialConsulta consulta,
  ) async {
    await HistorialConsultasService.eliminarConsulta(consulta.id);

    if (!mounted) return;

    setState(_cargarHistorial);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Consulta eliminada del historial.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _limpiarHistorial() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar historial'),
        content: const Text(
          '¿Deseás eliminar todas las consultas guardadas en este dispositivo? '
          'Esta acción no modifica las facturas ni los datos del sistema.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorPeligro,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar todo'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await HistorialConsultasService.limpiarHistorial();

    if (!mounted) return;

    setState(_cargarHistorial);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Historial eliminado.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 12, 14),
          child: tituloSeccion(
            'Historial de consultas',
            subtitulo:
                'Facturas consultadas desde este dispositivo.',
            accion: IconButton(
              tooltip: 'Actualizar historial',
              onPressed: _actualizarHistorial,
              icon: const Icon(
                Icons.refresh_rounded,
                color: colorPrimario,
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: FutureBuilder<List<HistorialConsulta>>(
            future: _historialFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return indicadorCarga(
                  mensaje: 'Cargando historial...',
                );
              }

              if (snapshot.hasError) {
                return mensajeVacio(
                  'No se pudo cargar el historial',
                  mensajeError(snapshot.error!),
                  icono: Icons.error_outline,
                );
              }

              final historial = snapshot.data ?? [];

              if (historial.isEmpty) {
                return mensajeVacio(
                  'Todavía no hay consultas',
                  'Cuando abras una factura, aparecerá en este historial.',
                  icono: Icons.history_rounded,
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      12,
                      20,
                      4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${historial.length} consulta'
                            '${historial.length == 1 ? '' : 's'} '
                            'guardada'
                            '${historial.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              color: colorSecundario,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _limpiarHistorial,
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                          ),
                          label: const Text('Limpiar'),
                          style: TextButton.styleFrom(
                            foregroundColor: colorPeligro,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      color: colorPrimario,
                      onRefresh: _actualizarHistorial,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          10,
                          16,
                          24,
                        ),
                        itemCount: historial.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final consulta = historial[index];

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () =>
                                        widget.alAbrirConsulta(consulta),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 45,
                                          height: 45,
                                          decoration: BoxDecoration(
                                            color: colorPrimario
                                                .withValues(alpha: 0.09),
                                            borderRadius:
                                                BorderRadius.circular(13),
                                          ),
                                          child: const Icon(
                                            Icons.receipt_long_outlined,
                                            color: colorPrimario,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                consulta.nombreCliente,
                                                style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.w800,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                'Factura ${consulta.numeroFactura}',
                                                style: const TextStyle(
                                                  color: colorSecundario,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                formatearFechaHora(
                                                  consulta.fechaConsulta,
                                                ),
                                                style: const TextStyle(
                                                  color: colorSecundario,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right_rounded,
                                          color: colorPrimario,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 22),
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Total de factura',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colorSecundario,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        formatearImporte(consulta.total),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: colorPrimario,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      IconButton(
                                        tooltip: 'Eliminar consulta',
                                        visualDensity:
                                            VisualDensity.compact,
                                        onPressed: () =>
                                            _eliminarConsulta(consulta),
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: colorPeligro,
                                          size: 21,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
