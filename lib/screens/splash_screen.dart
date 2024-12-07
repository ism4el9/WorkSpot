import 'package:flutter/material.dart';
import 'package:astro_office/screens/home_page.dart';
import 'package:astro_office/config/officeApi/auth.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 2000), () {
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(
            authService: AuthService(), // Pasa una instancia válida
            results: false,
          ),
        ),
      );
    }
  });

    return Scaffold(
      // Cambiamos el fondo al gradiente radial
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, 0.0), // Centro del gradiente
            radius: 1.0, // Radio del gradiente
            colors: [
              Color(0xFFE0F7FA), // Azul claro similar al borde
              Color(0xFFB2EBF2), // Azul más oscuro
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icon.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 20),
              Text(
                'WorkSpot',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu Espacio de Trabajo',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}