import 'package:astro_office/config/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:astro_office/config/theme/app_theme.dart';
import 'package:astro_office/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  await Supabase.initialize(
    url: 'https://eucffpnlnprzvbgffmuo.supabase.co', // Cambia por tu URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV1Y2ZmcG5sbnByenZiZ2ZmbXVvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM1MjUyNDUsImV4cCI6MjA0OTEwMTI0NX0.FHH5wM7NundGzzK24OMmGY-Vv7PTnn-0Q5kwgN1Gcwc', // Cambia por tu clave pública (anon)
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Obtén el proveedor de tema

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme().lightTheme(),
      darkTheme: AppTheme().darkTheme(),
      themeMode: themeProvider.themeMode, // Controla el tema desde el provider
      home: const SplashScreen(), // La pantalla inicial será el SplashScreen
    );
  }
}