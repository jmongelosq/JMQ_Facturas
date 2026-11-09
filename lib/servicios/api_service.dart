
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/cliente.dart';
import '../modelos/factura.dart';
import '../modelos/detalle_factura.dart';
import '../modelos/pago.dart';
import '../modelos/pendientes.dart';
import '../modelos/resultado_cobro.dart';

class ApiService {
  static const String servidorPredeterminado = '192.168.1.7:8080';
  static const String rutaApi = 'ApiJMQFacturas';
  static const String _claveServidor = 'jmq_servidor_api';

  static String _servidor = servidorPredeterminado;

  static String get servidor => _servidor;

  static String get baseUrl => 'http://$_servidor/$rutaApi';

  static Future<void> cargarConfiguracion() async {
    try {
      final preferencias = await SharedPreferences.getInstance();
      final guardado = preferencias.getString(_claveServidor);

      if (guardado != null && guardado.trim().isNotEmpty) {
        _servidor = guardado.trim();
      }
    } catch (_) {
      _servidor = servidorPredeterminado;
    }
  }

  static String normalizarServidor(String texto) {
    var valor = texto.trim();

    valor = valor.replaceFirst(RegExp(r'^https?://'), '');

    final barra = valor.indexOf('/');
    if (barra >= 0) {
      valor = valor.substring(0, barra);
    }

    return valor;
  }

  static bool servidorValido(String texto) {
    final valor = normalizarServidor(texto);
    return RegExp(r'^[A-Za-z0-9.\-]+(:\d{1,5})?$').hasMatch(valor);
  }

  static Future<void> guardarServidor(String texto) async {
    final valor = normalizarServidor(texto);

    if (!servidorValido(valor)) {
      throw Exception(
        'Dirección no válida. Ejemplo: 192.168.1.7:8080',
      );
    }

    _servidor = valor;
    _cookieSesion = null;

    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setString(_claveServidor, valor);
  }

  static Future<bool> probarConexion() async {
    try {
      final response = await _clienteHttp
          .get(Uri.parse('$baseUrl/PruebaConexionServlet'))
          .timeout(const Duration(seconds: 8));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static const Duration tiempoEspera = Duration(seconds: 60);

  static String? _cookieSesion;

  static String _rolUsuario = '';

  static String get rolUsuario => _rolUsuario;

  static bool get puedeRegistrarCobros =>
      _rolUsuario.trim().toLowerCase() != 'consulta';

  static final http.Client _clienteHttp = http.Client();

  static Map<String, String> get _headers {
    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (_cookieSesion != null) {
      headers['Cookie'] = _cookieSesion!;
    }

    return headers;
  }

  static Future<Map<String, dynamic>> iniciarSesion({
    required String nombreUsuario,
    required String clave,
  }) async {
    final uri = Uri.parse('$baseUrl/LoginServlet');

    try {
      final response = await _clienteHttp
          .post(
            uri,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {
              'nombre_usuario': nombreUsuario.trim(),
              'clave': clave,
            },
          )
          .timeout(tiempoEspera);

      final setCookie = response.headers['set-cookie'];

      if (setCookie != null) {
        final coincidencia =
            RegExp(r'JSESSIONID=[^;]+').firstMatch(setCookie);

        if (coincidencia != null) {
          _cookieSesion = coincidencia.group(0);
        }
      }

      dynamic resultado;

      try {
        resultado = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
      } on FormatException {
        _cookieSesion = null;
        throw Exception(
          'El servidor devolvió una respuesta no válida '
          '(código ${response.statusCode}). '
          'Verificá que la API esté desplegada correctamente.',
        );
      }

      if (resultado is! Map<String, dynamic>) {
        _cookieSesion = null;
        throw Exception(
          'La respuesta del inicio de sesión no es válida.',
        );
      }

      if (response.statusCode != 200 ||
          resultado['exito'] != true) {
        _cookieSesion = null;

        throw Exception(
          resultado['mensaje']?.toString() ??
              'No se pudo iniciar sesión.',
        );
      }

      if (_cookieSesion == null) {
        throw Exception(
          'El servidor no entregó la cookie de sesión.',
        );
      }

      final usuario = resultado['usuario'];
      _rolUsuario = usuario is Map ? (usuario['rol']?.toString() ?? '') : '';

      return resultado;
    } on TimeoutException {
      throw Exception(
        'El servidor tardó más de 60 segundos en responder. '
        'Verificá que Tomcat siga ejecutándose.',
      );
    } on http.ClientException catch (e) {
      throw Exception(
        'No se pudo conectar con la API. '
        'Verificá que Tomcat esté encendido y la dirección del servidor '
        '($_servidor). Detalle: ${e.message}',
      );
    }
  }

  static void cerrarSesion() {
    _cookieSesion = null;
    _rolUsuario = '';
  }

  static Future<dynamic> _getJson(String ruta) async {
    if (_cookieSesion == null) {
      throw Exception(
        'Debés iniciar sesión antes de consultar los datos.',
      );
    }

    final uri = Uri.parse('$baseUrl/$ruta');

    try {
      final response = await _clienteHttp
          .get(
            uri,
            headers: _headers,
          )
          .timeout(tiempoEspera);

      if (response.statusCode == 401) {
        _cookieSesion = null;

        throw Exception(
          'La sesión venció. Iniciá sesión nuevamente.',
        );
      }

      if (response.statusCode != 200) {
        throw Exception(
          'Error HTTP ${response.statusCode}: ${response.body}',
        );
      }

      try {
        return jsonDecode(
          utf8.decode(response.bodyBytes),
        );
      } on FormatException {
        throw Exception(
          'El servidor devolvió JSON no válido para $ruta.',
        );
      }
    } on TimeoutException {
      throw Exception(
        'La consulta tardó más de 60 segundos: $ruta',
      );
    } on http.ClientException catch (e) {
      throw Exception(
        'Error de conexión al consultar $ruta: ${e.message}',
      );
    }
  }

  static Future<List<Cliente>> buscarClientes(
    String criterio,
  ) async {
    final busqueda = criterio.trim();

    if (busqueda.isEmpty) {
      return [];
    }

    final ruta = Uri(
      path: 'ClientesServlet',
      queryParameters: {
        'criterio': busqueda,
      },
    ).toString();

    final json = await _getJson(ruta);

    if (json is! Map<String, dynamic> ||
        json['clientes'] is! List) {
      throw Exception(
        'La respuesta de clientes no es válida.',
      );
    }

    return (json['clientes'] as List)
        .map(
          (item) => Cliente.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  static Future<List<Factura>> listarFacturas(
    int idCliente,
  ) async {
    final json = await _getJson(
      'FacturasServlet?id_cliente=$idCliente',
    );

    if (json is! Map<String, dynamic> ||
        json['facturas'] is! List) {
      throw Exception(
        'La respuesta de facturas no es válida.',
      );
    }

    return (json['facturas'] as List)
        .map(
          (item) => Factura.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  static Future<List<DetalleFactura>> listarDetalles(
    int idFactura,
  ) async {
    final json = await _getJson(
      'DetalleFacturaServlet?id_factura=$idFactura',
    );

    if (json is! Map<String, dynamic> ||
        json['detalles'] is! List) {
      throw Exception(
        'La respuesta de detalles no es válida.',
      );
    }

    return (json['detalles'] as List)
        .map(
          (item) => DetalleFactura.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  static Future<List<Pago>> listarPagos(
    int idFactura,
  ) async {
    final json = await _getJson(
      'PagosServlet?id_factura=$idFactura',
    );

    if (json is! Map<String, dynamic> ||
        json['pagos'] is! List) {
      throw Exception(
        'La respuesta de pagos no es válida.',
      );
    }

    return (json['pagos'] as List)
        .map(
          (item) => Pago.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  static Future<ResumenPendientes> obtenerPendientes({
    int? idBarrio,
  }) async {
    final ruta = idBarrio == null
        ? 'PendientesServlet'
        : 'PendientesServlet?id_barrio=$idBarrio';

    final json = await _getJson(ruta);

    if (json is! Map<String, dynamic> || json['exito'] != true) {
      throw Exception(
        'La respuesta de pendientes no es válida.',
      );
    }

    return ResumenPendientes.fromJson(json);
  }

  static Uri urlFacturaPdf(int idFactura) {
    return Uri.parse(
      '$baseUrl/FacturaPdfServlet?id_factura=$idFactura',
    );
  }

  static Future<http.Response> obtenerPdfFactura(
    int idFactura,
  ) async {
    if (_cookieSesion == null) {
      throw Exception(
        'Debés iniciar sesión para consultar el PDF.',
      );
    }

    try {
      final response = await _clienteHttp
          .get(
            urlFacturaPdf(idFactura),
            headers: {
              'Accept': 'application/pdf',
              'Cookie': _cookieSesion!,
            },
          )
          .timeout(tiempoEspera);

      if (response.statusCode == 401) {
        _cookieSesion = null;

        throw Exception(
          'La sesión venció. Iniciá sesión nuevamente.',
        );
      }

      if (response.statusCode != 200) {
        throw Exception(
          'No se pudo obtener el PDF. '
          'Código HTTP: ${response.statusCode}',
        );
      }

      return response;
    } on TimeoutException {
      throw Exception(
        'La descarga del PDF tardó más de 60 segundos.',
      );
    } on http.ClientException catch (e) {
      throw Exception(
        'Error de conexión al descargar el PDF: ${e.message}',
      );
    }
  }

  static Future<ResultadoCobro> registrarPago({
    required int idFactura,
    required int monto,
    required String metodoPago,
    String observaciones = '',
  }) async {
    if (_cookieSesion == null) {
      throw Exception(
        'Debés iniciar sesión para registrar el cobro.',
      );
    }

    try {
      final response = await _clienteHttp
          .post(
            Uri.parse('$baseUrl/RegistrarPagoServlet'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/x-www-form-urlencoded',
              'Cookie': _cookieSesion!,
            },
            body: {
              'id_factura': idFactura.toString(),
              'monto': monto.toString(),
              'metodo_pago': metodoPago,
              'observaciones': observaciones.trim(),
            },
          )
          .timeout(tiempoEspera);

      dynamic resultado;

      try {
        resultado = jsonDecode(utf8.decode(response.bodyBytes));
      } on FormatException {
        throw Exception(
          'El servidor devolvió una respuesta no válida '
          '(código ${response.statusCode}).',
        );
      }

      if (response.statusCode == 401) {
        _cookieSesion = null;

        throw Exception(
          'La sesión venció. Iniciá sesión nuevamente.',
        );
      }

      if (resultado is! Map<String, dynamic>) {
        throw Exception('La respuesta del cobro no es válida.');
      }

      if (response.statusCode != 200 || resultado['exito'] != true) {
        throw Exception(
          resultado['mensaje']?.toString() ??
              'No se pudo registrar el cobro.',
        );
      }

      return ResultadoCobro.fromJson(resultado);
    } on TimeoutException {
      throw Exception(
        'El servidor tardó demasiado en responder. '
        'Verificá si el cobro quedó registrado antes de repetirlo.',
      );
    } on http.ClientException catch (e) {
      throw Exception(
        'Error de conexión al registrar el cobro: ${e.message}',
      );
    }
  }
}
