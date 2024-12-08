import 'dart:io'; // Import necesario para manejar SocketException
import 'package:supabase_flutter/supabase_flutter.dart';
import 'error_handler.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // Verificar si el usuario está autenticado
  bool isLoggedIn() {
    final session = supabase.auth.currentSession;
    return session != null;
  }

  // Registrar un nuevo usuario
  Future<String?> register(String email, String password) async {
    try {
      final response = await supabase.auth
          .signUp(email: email, password: password)
          .timeout(
            const Duration(seconds: 5), // Tiempo máximo de espera
            onTimeout: () {
              throw Exception('La solicitud de registro ha tardado demasiado. Por favor, inténtalo de nuevo.');
            },
          );
      if (response.user == null) {
        throw const AuthException('Error al registrar: No se pudo crear el usuario.');
      }
      return null; // Éxito
    } on SocketException {
      return ErrorHandler.handleError(NetworkException('No hay conexión a internet.'));
    } catch (e) {
      return ErrorHandler.handleError(e);
    }
  }

  // Iniciar sesión
  Future<String?> login(String email, String password) async {
    try {
      final response = await supabase.auth
          .signInWithPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 5), // Tiempo máximo de espera
            onTimeout: () {
              throw Exception('La solicitud de inicio de sesión ha tardado demasiado. Por favor, inténtalo de nuevo.');
            },
          );
      if (response.session == null) {
        throw const AuthException('Error al iniciar sesión: Usuario o contraseña incorrectos.');
      }
      //print(response);
      return null; // Éxito
    } on SocketException {
      return ErrorHandler.handleError(NetworkException('No hay conexión a internet.'));
    } catch (e) {
      return ErrorHandler.handleError(e);
    }
  }

  // Cerrar sesión
  Future<String?> logout() async {
    try {
      await supabase.auth
          .signOut()
          .timeout(
            const Duration(seconds: 5), // Tiempo máximo de espera
            onTimeout: () {
              throw Exception('La solicitud de cierre de sesión ha tardado demasiado. Por favor, inténtalo de nuevo.');
            },
          );
      return null; // Éxito
    } on SocketException {
      return ErrorHandler.handleError(NetworkException('No hay conexión a internet.'));
    } catch (e) {
      return ErrorHandler.handleError(e);
    }
  }

  // Obtener el usuario actual
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }
}
