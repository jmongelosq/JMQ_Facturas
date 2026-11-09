import 'package:flutter/material.dart';

import '../config/estilos.dart';
import '../servicios/api_service.dart';
import 'principal_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _claveController = TextEditingController();

  bool _cargando = false;
  bool _ocultarClave = true;

  @override
  void dispose() {
    _usuarioController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _cargando = true);

    try {
      final resultado = await ApiService.iniciarSesion(
        nombreUsuario: _usuarioController.text.trim(),
        clave: _claveController.text,
      );

      if (!mounted) return;

      final usuario = resultado['usuario'] is Map
          ? Map<String, dynamic>.from(
              resultado['usuario'] as Map,
            )
          : <String, dynamic>{};

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PrincipalScreen(
            usuario: usuario,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      mostrarError(context, e);
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _configurarServidor() async {
    final guardado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _ConfiguracionServidor(),
    );

    if (!mounted) return;

    setState(() {});

    if (guardado == true) {
      mostrarAviso(
        context,
        'Servidor actualizado: ${ApiService.servidor}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final alto = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: alto * 0.46,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: degradadoPrincipal,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(36),
              ),
            ),
          ),
          Positioned(
            top: -60,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 6, 8, 0),
                    child: IconButton(
                      tooltip: 'Configurar servidor',
                      onPressed: _cargando ? null : _configurarServidor,
                      icon: const Icon(
                        Icons.settings_ethernet_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Column(
                          children: [
                            logoInstitucional(tamano: 104, radio: 26),
                            const SizedBox(height: 16),
                            const Text(
                              'JMQ SYSTEM',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.6,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Consulta y cobro de facturas',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFD6E2F3),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 30),
                            _tarjetaFormulario(),
                            const SizedBox(height: 18),
                            _indicadorServidor(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaFormulario() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorOscuro.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Iniciar sesión',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: colorTexto,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ingresá con tu usuario de JMQ SYSTEM.',
              style: TextStyle(
                fontSize: 13,
                color: colorSecundario,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _usuarioController,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              enabled: !_cargando,
              decoration: const InputDecoration(
                labelText: 'Usuario',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Ingresá tu usuario.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _claveController,
              obscureText: _ocultarClave,
              enabled: !_cargando,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _iniciarSesion(),
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip:
                      _ocultarClave ? 'Mostrar contraseña' : 'Ocultar contraseña',
                  onPressed: () {
                    setState(() => _ocultarClave = !_ocultarClave);
                  },
                  icon: Icon(
                    _ocultarClave
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (valor) {
                if (valor == null || valor.isEmpty) {
                  return 'Ingresá tu contraseña.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _cargando ? null : _iniciarSesion,
                child: _cargando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('INGRESAR'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 15,
                  color: colorSecundario,
                ),
                SizedBox(width: 6),
                Text(
                  'Acceso exclusivo para personal autorizado',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorSecundario,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _indicadorServidor() {
    return InkWell(
      onTap: _cargando ? null : _configurarServidor,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.dns_outlined,
              size: 16,
              color: colorSecundario,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Servidor: ${ApiService.servidor}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: colorSecundario,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.edit_outlined,
              size: 14,
              color: colorAcento,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfiguracionServidor extends StatefulWidget {
  const _ConfiguracionServidor();

  @override
  State<_ConfiguracionServidor> createState() =>
      _ConfiguracionServidorState();
}

class _ConfiguracionServidorState extends State<_ConfiguracionServidor> {
  late final TextEditingController _servidorController;

  bool _probando = false;
  bool? _conexionCorrecta;
  String? _error;

  @override
  void initState() {
    super.initState();
    _servidorController = TextEditingController(text: ApiService.servidor);
  }

  @override
  void dispose() {
    _servidorController.dispose();
    super.dispose();
  }

  Future<void> _probar() async {
    if (!ApiService.servidorValido(_servidorController.text)) {
      setState(() => _error = 'Ejemplo de dirección: 192.168.1.7:8080');
      return;
    }

    final anterior = ApiService.servidor;

    setState(() {
      _probando = true;
      _error = null;
      _conexionCorrecta = null;
    });

    try {
      await ApiService.guardarServidor(_servidorController.text);
      final correcto = await ApiService.probarConexion();

      if (!correcto) {
        await ApiService.guardarServidor(anterior);
      }

      if (!mounted) return;
      setState(() => _conexionCorrecta = correcto);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = mensajeError(e));
    } finally {
      if (mounted) setState(() => _probando = false);
    }
  }

  Future<void> _guardar() async {
    try {
      await ApiService.guardarServidor(_servidorController.text);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = mensajeError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final teclado = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(22, 12, 22, 22 + teclado),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: colorBorde,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              iconoCaja(Icons.dns_outlined),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Servidor de la API',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: colorTexto,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'IP y puerto de la PC donde corre Tomcat.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorSecundario,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _servidorController,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'Dirección (IP:puerto)',
              hintText: '192.168.1.7:8080',
              prefixIcon: const Icon(Icons.lan_outlined),
              errorText: _error,
            ),
            onChanged: (_) {
              setState(() {
                _conexionCorrecta = null;
                _error = null;
              });
            },
          ),
          const SizedBox(height: 10),
          Text(
            'Se conectará a: http://'
            '${ApiService.normalizarServidor(_servidorController.text)}'
            '/${ApiService.rutaApi}',
            style: const TextStyle(fontSize: 11, color: colorSecundario),
          ),
          if (_conexionCorrecta != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_conexionCorrecta! ? colorExito : colorPeligro)
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _conexionCorrecta!
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                    color: _conexionCorrecta! ? colorExito : colorPeligro,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _conexionCorrecta!
                          ? 'Conexión correcta con la API y la base de datos.'
                          : 'No hubo respuesta. Verificá la IP, el puerto y que '
                              'Tomcat esté encendido.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _conexionCorrecta! ? colorExito : colorPeligro,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _probando ? null : _probar,
                  icon: _probando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_tethering_rounded),
                  label: const Text('Probar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _probando ? null : _guardar,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: _probando
                  ? null
                  : () => setState(() {
                        _servidorController.text =
                            ApiService.servidorPredeterminado;
                        _conexionCorrecta = null;
                        _error = null;
                      }),
              child: const Text('Restablecer dirección predeterminada'),
            ),
          ),
        ],
      ),
    );
  }
}
