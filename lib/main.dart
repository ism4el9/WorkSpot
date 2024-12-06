import 'package:astro_office/config/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:astro_office/config/theme/app_theme.dart';
import 'package:astro_office/screens/splash_screen.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
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