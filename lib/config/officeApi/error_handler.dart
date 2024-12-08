import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  // Método genérico para manejar errores
  static String handleError(dynamic error, {String? customMessage}) {
    // Si se proporciona un mensaje personalizado, se usa directamente
    if (customMessage != null) {
      return customMessage;
    }

    // Identificar el tipo de error y traducirlo al español
    if (error is AuthException) {
      return _authErrorMessages[error.message] ?? 'Error de autenticación: ${error.message}';
    }

    if (error is NetworkException) {
      return 'Error de red: Verifica tu conexión a internet.';
    }

    // Error desconocido
    return 'Ha ocurrido un error inesperado.';
  }

  // Mapa de mensajes de error comunes para errores de autenticación
  static const Map<String, String> _authErrorMessages = {
    'Invalid login credentials': 'Credenciales de inicio de sesión inválidas.',
    'User already registered': 'El usuario ya está registrado.',
    'Email not confirmed': 'El correo electrónico no ha sido confirmado.',
    'Password too short': 'La contraseña es demasiado corta.',
    'User not found': 'El usuario no fue encontrado.',
    'Access token expired': 'El token de acceso ha expirado.',
    'Invalid email format': 'El formato del correo electrónico es inválido.',
  };
}

class NetworkException implements Exception {
  final String message;

  NetworkException([this.message = 'Error de red desconocido']);

  @override
  String toString() => message;
}