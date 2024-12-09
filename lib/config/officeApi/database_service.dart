import 'dart:io'; // Para manejar SocketException
import 'package:supabase_flutter/supabase_flutter.dart';
import 'error_handler.dart';

class DatabaseService {
  final supabase = Supabase.instance.client;
  // Timeout global recomendado
  static const Duration requestTimeout = Duration(seconds: 5);

  // ****************** EXTRAS ******************
  Future<List<Map<String, dynamic>>> fetchExtras() async {
    try {
      final response = await supabase.from('extras').select().timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de select all extras ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      return List<Map<String, dynamic>>.from(response);
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  Future<void> addExtra(String nombre, String descripcion, String icono) async {
    try {
      final response = await supabase.from('extras').insert({
        'nombre': nombre,
        'descripcion': descripcion,
        'icono': icono,
      }).timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de añadir extras ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      if (response == null) {
        throw Exception('Error al agregar extra: No se recibió respuesta.');
      }
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  Future<void> updateExtra(
      int id, String nombre, String descripcion, String icono) async {
    try {
      final response = await supabase
          .from('extras')
          .update({
            'nombre': nombre,
            'descripcion': descripcion,
            'icono': icono,
          })
          .eq('id', id)
          .timeout(
            requestTimeout,
            onTimeout: () {
              throw Exception(
                  'La solicitud de actualizar extras ha tardado demasiado. Por favor, inténtalo de nuevo.');
            },
          );
      if (response == null) {
        throw Exception('Error al actualizar extra: No se recibió respuesta.');
      }
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  Future<void> deleteExtra(int id) async {
    try {
      final response =
          await supabase.from('extras').delete().eq('id', id).timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de eliminar extras ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      if (response == null) {
        throw Exception('Error al eliminar extra: No se recibió respuesta.');
      }
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  // ****************** FAVORITOS ******************
  Future<List<Map<String, dynamic>>> fetchFavoritos() async {
    try {
      final response = await supabase.from('favoritos').select().timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de fetch favoritos ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      return List<Map<String, dynamic>>.from(response);
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  Future<void> addFavorito(int usuarioId, int oficinaId) async {
    try {
      final response = await supabase.from('favoritos').insert({
        'usuario_id': usuarioId,
        'oficina_id': oficinaId,
      }).timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de añadir favorito ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      if (response == null) {
        throw Exception('Error al agregar favorito: No se recibió respuesta.');
      }
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  Future<void> deleteFavorito(int usuarioId, int oficinaId) async {
    try {
      final response = await supabase.from('favoritos').delete().match({
        'usuario_id': usuarioId,
        'oficina_id': oficinaId,
      }).timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de eliminar favorito ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      if (response == null) {
        throw Exception('Error al eliminar favorito: No se recibió respuesta.');
      }
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  // ****************** MÉTODOS DE PAGO ******************
  Future<List<Map<String, dynamic>>> fetchMetodosPago() async {
    try {
      final response = await supabase.from('metodos_pago').select().timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de fetch metodos_pago ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      return List<Map<String, dynamic>>.from(response);
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  Future<List<Map<String, dynamic>>> fetchMetodosPagoByUser(int userId) async {
    try {
      final response = await supabase
          .from('metodos_pago')
          .select()
          .eq('usuario_id', userId)
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception(
              'La solicitud de métodos de pago ha tardado demasiado.');
        },
      );
      return List<Map<String, dynamic>>.from(response);
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  Future<void> addMetodoPago(Map<String, dynamic> metodoPago) async {
    try {
      await supabase.from('metodos_pago').insert(metodoPago).timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de añadir metodo_pago ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  Future<void> updateMetodoPago(int id, Map<String, dynamic> metodoPago) async {
    try {
      final response = await supabase
          .from('metodos_pago')
          .update(metodoPago)
          .eq('id', id)
          .timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de actualizar metodo_pago ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      if (response == null) {
        throw Exception(
            'Error al actualizar método de pago: No se recibió respuesta.');
      }
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  Future<void> deleteMetodoPago(int cardId) async {
    try {
      // Realiza la operación de eliminación directamente
      final response = await supabase
          .from('metodos_pago') // Nombre de la tabla
          .delete()
          .eq('id', cardId) // Filtro para eliminar por ID
          .select(); // Asegúrate de incluir select() para obtener una respuesta clara

      // Verifica si la respuesta está vacía
      if (response.isEmpty) {
        throw Exception('No se encontró el método de pago para eliminar.');
      }

      print('Tarjeta eliminada con éxito. Respuesta: $response');
    } catch (e) {
      throw Exception('Error al intentar eliminar el método de pago: $e');
    }
  }

  // ****************** OFICINAS ******************
  Future<List<Map<String, dynamic>>> fetchOficinas() async {
    try {
      final response = await supabase.from('oficinas').select().timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de fetch oficinas ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      return List<Map<String, dynamic>>.from(response);
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  Future<void> addOficina(Map<String, dynamic> oficina) async {
    try {
      final response = await supabase.from('oficinas').insert(oficina).timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de añadir oficina ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      if (response == null) {
        throw Exception('Error al agregar oficina: No se recibió respuesta.');
      }
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  Future<void> updateOficina(int id, Map<String, dynamic> oficina) async {
    try {
      final response =
          await supabase.from('oficinas').update(oficina).eq('id', id).timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de actualizar oficina ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      if (response == null) {
        throw Exception(
            'Error al actualizar oficina: No se recibió respuesta.');
      }
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  Future<void> deleteOficina(int id) async {
    try {
      final response =
          await supabase.from('oficinas').delete().eq('id', id).timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de eliminar oficina ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      if (response == null) {
        throw Exception('Error al eliminar oficina: No se recibió respuesta.');
      }
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  // ****************** OFICINAS EXTRAS ******************
  Future<List<Map<String, dynamic>>> fetchOficinasExtras() async {
    try {
      final response = await supabase.from('oficinas_extras').select().timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de fetch oficinas_extras ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      return List<Map<String, dynamic>>.from(response);
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  Future<void> addOficinaExtra(Map<String, dynamic> oficinaExtra) async {
    try {
      final response =
          await supabase.from('oficinas_extras').insert(oficinaExtra).timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de añadir oficina_extra ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      if (response == null) {
        throw Exception(
            'Error al agregar oficina_extra: No se recibió respuesta.');
      }
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  Future<void> deleteOficinaExtra(int oficinaId, int extraId) async {
    try {
      final response = await supabase.from('oficinas_extras').delete().match({
        'oficina_id': oficinaId,
        'extra_id': extraId,
      }).timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de eliminar oficina_extra ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      if (response == null) {
        throw Exception(
            'Error al eliminar oficina_extra: No se recibió respuesta.');
      }
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  // ****************** OFICINAS IMÁGENES ******************
  Future<List<Map<String, dynamic>>> fetchOficinasImagenes() async {
    try {
      final response =
          await supabase.from('oficinas_imagenes').select().timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de fetch oficinas_imagenes ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      return List<Map<String, dynamic>>.from(response);
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  Future<void> addOficinaImagen(Map<String, dynamic> oficinaImagen) async {
    try {
      final response = await supabase
          .from('oficinas_imagenes')
          .insert(oficinaImagen)
          .timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de añadir oficina_imagen ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      if (response == null) {
        throw Exception(
            'Error al agregar oficina_imagen: No se recibió respuesta.');
      }
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  Future<void> deleteOficinaImagen(int id) async {
    try {
      final response = await supabase
          .from('oficinas_imagenes')
          .delete()
          .eq('id', id)
          .timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de eliminar oficina_imagen ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      if (response == null) {
        throw Exception(
            'Error al eliminar oficina_imagen: No se recibió respuesta.');
      }
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  // ****************** PAGOS ******************
  Future<List<Map<String, dynamic>>> fetchPagos() async {
    try {
      final response = await supabase.from('pagos').select().timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de fetch pagos ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      return List<Map<String, dynamic>>.from(response);
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  Future<void> addPago(Map<String, dynamic> pago) async {
    try {
      final response = await supabase.from('pagos').insert(pago).timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de añadir pago ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      if (response == null) {
        throw Exception('Error al agregar pago: No se recibió respuesta.');
      }
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  // ****************** RESERVAS ******************
  Future<List<Map<String, dynamic>>> fetchReservas() async {
    try {
      final response = await supabase.from('reservas').select().timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de fetch reservas ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      return List<Map<String, dynamic>>.from(response);
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  Future<void> addReserva(Map<String, dynamic> reserva) async {
    try {
      final response = await supabase.from('reservas').insert(reserva).timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de añadir reserva ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      if (response == null) {
        throw Exception('Error al agregar reserva: No se recibió respuesta.');
      }
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  // ****************** SECTORES ******************
  Future<List<Map<String, dynamic>>> fetchSectores() async {
    try {
      final response = await supabase.from('sectores').select().timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de fetch sectores ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      return List<Map<String, dynamic>>.from(response);
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  Future<void> addSector(Map<String, dynamic> sector) async {
    try {
      final response = await supabase.from('sectores').insert(sector).timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception(
              'La solicitud de añadir sector ha tardado demasiado. Por favor, inténtalo de nuevo.');
        },
      );
      if (response == null) {
        throw Exception('Error al agregar sector: No se recibió respuesta.');
      }
    } on SocketException {
      throw NetworkException('No hay conexión a internet.');
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }
}
