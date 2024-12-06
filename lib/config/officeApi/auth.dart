class AuthService {
  // Simulación de estado de autenticación (puedes usar algo real aquí)
  bool isLoggedIn = false;

  // Método para verificar el estado de autenticación
  bool checkAuthentication() {
    //await Future.delayed(const Duration(seconds: 2)); // Simula una verificación de 2 segundos
    return isLoggedIn;
  }

  // Métodos para iniciar y cerrar sesión
  login() {
    isLoggedIn = true;
  }

  logout() {
    isLoggedIn = false;
  }
}
