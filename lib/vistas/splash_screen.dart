import 'package:flutter/material.dart';

import '../config/estilos.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador;
  late final Animation<double> _opacidad;
  late final Animation<double> _escala;
  late final Animation<Offset> _desplazamiento;

  @override
  void initState() {
    super.initState();

    _controlador = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _opacidad = CurvedAnimation(
      parent: _controlador,
      curve: const Interval(0, 0.7, curve: Curves.easeIn),
    );

    _escala = Tween<double>(begin: 0.80, end: 1).animate(
      CurvedAnimation(
        parent: _controlador,
        curve: Curves.easeOutBack,
      ),
    );

    _desplazamiento = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controlador,
        curve: const Interval(0.3, 1, curve: Curves.easeOutCubic),
      ),
    );

    _controlador.forward();

    Future<void>.delayed(
      const Duration(milliseconds: 2200),
      () {
        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          PageRouteBuilder<void>(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, _, _) => const LoginScreen(),
            transitionsBuilder: (_, animacion, _, hijo) {
              return FadeTransition(opacity: animacion, child: hijo);
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorOscuro,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: degradadoPrincipal),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -70,
              child: _circuloDecorativo(260),
            ),
            Positioned(
              bottom: -110,
              left: -80,
              child: _circuloDecorativo(300),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: FadeTransition(
                        opacity: _opacidad,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ScaleTransition(
                              scale: _escala,
                              child: logoInstitucional(
                                tamano: 140,
                                radio: 32,
                              ),
                            ),
                            const SizedBox(height: 28),
                            SlideTransition(
                              position: _desplazamiento,
                              child: const Column(
                                children: [
                                  Text(
                                    'JMQ SYSTEM',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'JMQ Facturas · Cobro móvil',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFFD6E2F3),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  FadeTransition(
                    opacity: _opacidad,
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 34),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Gestión de Residuos · Villa Elisa',
                            style: TextStyle(
                              color: Color(0xFFB8C8E0),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circuloDecorativo(double tamano) {
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 2,
        ),
      ),
    );
  }
}
