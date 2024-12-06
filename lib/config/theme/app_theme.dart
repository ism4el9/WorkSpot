import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {

  ThemeData lightTheme(){
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness:  Brightness.light,
        primary:  Color(0xFF1F4E78),       
        onPrimary: Color.fromARGB(255, 255, 255, 255), 
        secondary:  Color(0xFFE5E5E5), 
        onSecondary:  Color.fromARGB(255, 0, 0, 0), 
        error:  Color(0xFFB00020), 
        onError:  Color.fromARGB(255, 255, 255, 255),
        surface:  Color(0xFFE5E5E5), 
        onSurface:  Color.fromARGB(255, 0, 0, 0),
        tertiary:  Color.fromARGB(255, 119, 157, 69), 
        onTertiary:  Color.fromARGB(255, 0, 0, 0),
        surfaceDim: Color.fromARGB(255, 165, 165, 165),
      ),
      textTheme: GoogleFonts.firaSansCondensedTextTheme()
    );
  } 


  ThemeData darkTheme(){
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
      brightness: Brightness.dark,  // Cambiado a tema oscuro
      primary: Color.fromARGB(255, 49, 136, 212),   // Azul Marino (#1F4E78)
      onPrimary: Color(0xFFFFFFFF), // Texto o íconos sobre el color primario (blanco)
      secondary: Color.fromARGB(255, 46, 46, 46), // Gris Oscuro (#2E2E2E) para fondos o elementos secundarios
      onSecondary: Color(0xFFFFFFFF), // Texto o íconos sobre el color secundario (blanco)
      error: Color(0xFFCF6679),     // Rojo más claro para errores en tema oscuro
      onError: Color(0xFFFFFFFF),   // Texto o íconos sobre el color de error (blanco)
      surface: Color.fromARGB(255, 46, 46, 46),   // Superficie oscura (color de fondo principal)
      onSurface: Color(0xFFFFFFFF), // Texto o íconos sobre superficies oscuras (blanco)
      tertiary: Color.fromARGB(255, 119, 157, 69),  // Verde Limón (mismo color de acento)
      onTertiary: Color(0xFF000000), // Texto o íconos sobre el color de acento (negro)
      surfaceDim: Color.fromARGB(255, 136, 136, 136),
      ),
      textTheme: GoogleFonts.firaSansCondensedTextTheme().apply(
        bodyColor: Colors.white,          // Blanco para texto principal
        displayColor: Colors.white,
      ),

      iconTheme: const IconThemeData(
        color: Colors.white,              // Blanco para íconos
      ),
      
      // Tema de app bar para asegurar que use los colores correctos en fondo oscuro
      
      
      // Configuración del botón para que los textos sean visibles en fondo oscuro
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 49, 136, 212),  // Color primario para botones
          foregroundColor: Colors.white,       // Texto blanco en botones
        ),
      ),
      
      // Botones de texto o planos
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF77A13F), // Verde limón para botones de texto
        ),
      ),

      // Color de iconos específicos como FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color.fromARGB(255, 49, 136, 212),  // Azul Marino
        foregroundColor: Colors.white,       // Texto o íconos blancos en FAB
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF2E2E2E),       // Fondo oscuro para el BottomNavigationBar
        selectedItemColor: Color.fromARGB(255, 49, 136, 212),     // Ícono y texto blanco cuando está seleccionado
        unselectedItemColor: Color(0xFFB0B0B0),   // Ícono y texto gris claro cuando no está seleccionado
        selectedIconTheme: IconThemeData(
          color: Color.fromARGB(255, 49, 136, 212),               // Ícono blanco seleccionado
        ),
        unselectedIconTheme: IconThemeData(
          color: Color(0xFFB0B0B0),               // Ícono gris claro no seleccionado
        ),
        selectedLabelStyle: TextStyle(color: Color.fromARGB(255, 49, 136, 212)),
        unselectedLabelStyle: TextStyle(color: Color(0xFFB0B0B0)),
      ),
    );

  }
}