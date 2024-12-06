import 'package:astro_office/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 0;

  final List<String> _routes = ['/home', '/reserved', '/profile'];
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    Navigator.pushReplacementNamed(context, _routes[index]);
  }

  bool isDarkMode = false; // Estado del modo oscuro
  bool isUserLoggedIn = false; // Estado de sesión
  String userName = "Invitado"; // Nombre de usuario (por defecto es "Invitado")

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado de perfil con neumorfismo
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                padding: const EdgeInsets.all(20),
                decoration: _neumorphicDecoration(true),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isUserLoggedIn ? userName : 'Invitado',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // Botón de iniciar sesión o registrarse
              if (!isUserLoggedIn)
                Center(
                  child: GestureDetector(
                    onTap: () {
                      // Acción para iniciar sesión
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: _neumorphicDecoration(true),
                      child: const Text(
                        'Inicia Sesión o Regístrate!',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),

              const Divider(height: 30),

              // Sección de configuración
              const Text(
                'Configuración',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Cambiar a Modo Oscuro con neumorfismo
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: _neumorphicDecoration(false),
                child: ListTile(
                  leading: Icon(
                    Icons.dark_mode,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Modo Oscuro'),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        isDarkMode = value;
                      });
                    },
                  ),
                ),
              ),

              // Modificar Datos del Perfil (si el usuario está autenticado)
              if (isUserLoggedIn)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: _neumorphicDecoration(false),
                  child: ListTile(
                    leading: Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Modificar Datos del Perfil'),
                    onTap: () {
                      // Navegar a la pantalla de modificación del perfil
                    },
                  ),
                ),

              // Cerrar sesión (si está autenticado)
              if (isUserLoggedIn)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: _neumorphicDecoration(false),
                  child: ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: const Text('Cerrar Sesión'),
                    onTap: () {
                      setState(() {
                        isUserLoggedIn = false;
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }

  BoxDecoration _neumorphicDecoration(bool isHighlighted) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: isHighlighted
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(6, 6),
                blurRadius: 12,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.7),
                offset: const Offset(-6, -6),
                blurRadius: 12,
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(4, 4),
                blurRadius: 8,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                offset: const Offset(-4, -4),
                blurRadius: 8,
              ),
            ],
    );
  }
}