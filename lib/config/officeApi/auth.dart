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

  // Registrar un nuevo usuario (incluyendo su nombre en public.usuarios)
  Future<String?> register(String email, String password, String nombre) async {
    try {
      // Registrar usuario en auth.users
      final authResponse =
          await supabase.auth.signUp(email: email.trim(), password: password.trim()).timeout(
        const Duration(seconds: 5), // Tiempo máximo de espera
        onTimeout: () {
          throw Exception(
              'La solicitud de registro ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );

      final user = authResponse.user;
      if (user == null) {
        throw const AuthException(
            'Error al registrar: No se pudo crear el usuario.');
      }

      // Insertar datos adicionales en la tabla public.usuarios
      await supabase.from('usuarios').insert({
        'auth_user_id': user.id,
        'nombre': nombre.trim(),
      }).timeout(
        const Duration(seconds: 5), // Tiempo máximo de espera
        onTimeout: () {
          throw Exception(
              'La solicitud para agregar datos del usuario ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );

      return null; // Éxito
    } on SocketException {
      return ErrorHandler.handleError(
          NetworkException('No hay conexión a internet.'));
    } catch (e) {
      return ErrorHandler.handleError(e);
    }
  }

  // Iniciar sesión
  Future<String?> login(String email, String password) async {
    try {
      final response = await supabase.auth
          .signInWithPassword(email: email.trim(), password: password.trim())
          .timeout(
        const Duration(seconds: 5), // Tiempo máximo de espera
        onTimeout: () {
          throw Exception(
              'La solicitud de inicio de sesión ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      if (response.session == null) {
        throw const AuthException(
            'Error al iniciar sesión: Usuario o contraseña incorrectos.');
      }

      return null; // Éxito
    } on SocketException {
      return ErrorHandler.handleError(
          NetworkException('No hay conexión a internet.'));
    } catch (e) {
      return ErrorHandler.handleError(e);
    }
  }

  // Cerrar sesión
  Future<String?> logout() async {
    try {
      await supabase.auth.signOut().timeout(
        const Duration(seconds: 5), // Tiempo máximo de espera
        onTimeout: () {
          throw Exception(
              'La solicitud de cierre de sesión ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      return null; // Éxito
    } on SocketException {
      return ErrorHandler.handleError(
          NetworkException('No hay conexión a internet.'));
    } catch (e) {
      return ErrorHandler.handleError(e);
    }
  }

  // Obtener el usuario actual
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  // Obtener información adicional del usuario desde public.usuarios
  Future<Map<String, dynamic>?> getUserDetails() async {
    try {
      final user = getCurrentUser();
      if (user == null) {
        throw Exception('Usuario no autenticado.');
      }

      final response = await supabase
          .from('usuarios')
          .select('*')
          .eq('auth_user_id', user.id)
          .single()
          .timeout(
        const Duration(seconds: 5), // Tiempo máximo de espera
        onTimeout: () {
          throw Exception(
              'La solicitud para obtener detalles del usuario ha tardado demasiado.');
        },
      );

      return response;
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }
}
