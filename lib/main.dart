import 'package:flutter/material.dart';

import 'config/estilos.dart';
import 'servicios/api_service.dart';
import 'vistas/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ApiService.cargarConfiguracion();

  runApp(const JmqFacturasApp());
}

class JmqFacturasApp extends StatelessWidget {
  const JmqFacturasApp({super.key});

  @override
  Widget build(BuildContext context) {
    final bordeCampo = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: colorBorde),
    );

    return MaterialApp(
      title: 'JMQ Facturas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: colorFondo,
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorPrimario,
          primary: colorPrimario,
          secondary: colorAcento,
          surface: Colors.white,
          error: colorPeligro,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: colorPrimario,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: colorBorde),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: colorBorde,
          thickness: 1,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: colorPrimario,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: colorAcento.withValues(alpha: 0.14),
          elevation: 0,
          height: 68,
          labelTextStyle: WidgetStateProperty.resolveWith((estados) {
            final seleccionado = estados.contains(WidgetState.selected);

            return TextStyle(
              fontSize: 11,
              fontWeight: seleccionado ? FontWeight.w800 : FontWeight.w500,
              color: seleccionado ? colorPrimario : colorSecundario,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((estados) {
            final seleccionado = estados.contains(WidgetState.selected);

            return IconThemeData(
              color: seleccionado ? colorPrimario : colorSecundario,
            );
          }),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          prefixIconColor: colorSecundario,
          border: bordeCampo,
          enabledBorder: bordeCampo,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: colorAcento,
              width: 1.6,
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
