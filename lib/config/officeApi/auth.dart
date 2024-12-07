import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // Verificar si el usuario está autenticado
  bool isLoggedIn() {
    final session = supabase.auth.currentSession;
    return session != null;
  }

  // Registrar un nuevo usuario
  Future<void> register(String email, String password) async {
    try {
      final response = await supabase.auth.signUp(email: email, password: password);
      if (response.user == null) {
        throw Exception('Error al registrar: No se pudo crear el usuario.');
      }
      //print('Usuario registrado: ${response.user?.email}');
    } catch (e) {
      //print('Error en registro: $e');
      rethrow;
    }
  }

  // Iniciar sesión
  Future<void> login(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(email: email, password: password);
      if (response.session == null) {
        throw Exception('Error al iniciar sesión: Usuario o contraseña incorrectos.');
      }
      //print('Sesión iniciada para: ${response.user?.email}');
    } catch (e) {
      //print('Error en login: $e');
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
      //print('Sesión cerrada.');
    } catch (e) {
      //print('Error en logout: $e');
      rethrow;
    }
  }

  // Obtener el usuario actual
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }
}
