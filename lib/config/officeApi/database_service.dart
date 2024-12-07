import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final supabase = Supabase.instance.client;

  // ****************** EXTRAS ******************

  Future<List<Map<String, dynamic>>> fetchExtras() async {
    final response = await supabase.from('extras').select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addExtra(String nombre, String descripcion, String icono) async {
    final response = await supabase.from('extras').insert({
      'nombre': nombre,
      'descripcion': descripcion,
      'icono': icono,
    });
    if (response == null) throw Exception('Error al agregar extra: No se recibió respuesta.');
  }

  Future<void> updateExtra(int id, String nombre, String descripcion, String icono) async {
    final response = await supabase.from('extras').update({
      'nombre': nombre,
      'descripcion': descripcion,
      'icono': icono,
    }).eq('id', id);
    if (response == null) throw Exception('Error al actualizar extra: No se recibió respuesta.');
  }

  Future<void> deleteExtra(int id) async {
    final response = await supabase.from('extras').delete().eq('id', id);
    if (response == null) throw Exception('Error al eliminar extra: No se recibió respuesta.');
  }

  // ****************** FAVORITOS ******************

  Future<List<Map<String, dynamic>>> fetchFavoritos() async {
    final response = await supabase.from('favoritos').select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addFavorito(int usuarioId, int oficinaId) async {
    final response = await supabase.from('favoritos').insert({
      'usuario_id': usuarioId,
      'oficina_id': oficinaId,
    });
    if (response == null) throw Exception('Error al agregar favorito: No se recibió respuesta.');
  }

  Future<void> deleteFavorito(int usuarioId, int oficinaId) async {
    final response = await supabase
        .from('favoritos')
        .delete()
        .match({'usuario_id': usuarioId, 'oficina_id': oficinaId});
    if (response == null) throw Exception('Error al eliminar favorito: No se recibió respuesta.');
  }

  // ****************** MÉTODOS DE PAGO ******************

  Future<List<Map<String, dynamic>>> fetchMetodosPago() async {
    final response = await supabase.from('metodos_pago').select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addMetodoPago(Map<String, dynamic> metodoPago) async {
    final response = await supabase.from('metodos_pago').insert(metodoPago);
    if (response == null) throw Exception('Error al agregar método de pago: No se recibió respuesta.');
  }

  Future<void> updateMetodoPago(int id, Map<String, dynamic> metodoPago) async {
    final response = await supabase.from('metodos_pago').update(metodoPago).eq('id', id);
    if (response == null) throw Exception('Error al actualizar método de pago: No se recibió respuesta.');
  }

  Future<void> deleteMetodoPago(int id) async {
    final response = await supabase.from('metodos_pago').delete().eq('id', id);
    if (response == null) throw Exception('Error al eliminar método de pago: No se recibió respuesta.');
  }

  // ****************** OFICINAS ******************

  Future<List<Map<String, dynamic>>> fetchOficinas() async {
    final response = await supabase.from('oficinas').select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addOficina(Map<String, dynamic> oficina) async {
    final response = await supabase.from('oficinas').insert(oficina);
    if (response == null) throw Exception('Error al agregar oficina: No se recibió respuesta.');
  }

  Future<void> updateOficina(int id, Map<String, dynamic> oficina) async {
    final response = await supabase.from('oficinas').update(oficina).eq('id', id);
    if (response == null) throw Exception('Error al actualizar oficina: No se recibió respuesta.');
  }

  Future<void> deleteOficina(int id) async {
    final response = await supabase.from('oficinas').delete().eq('id', id);
    if (response == null) throw Exception('Error al eliminar oficina: No se recibió respuesta.');
  }

  // ****************** OFICINAS EXTRAS ******************

  Future<List<Map<String, dynamic>>> fetchOficinasExtras() async {
    final response = await supabase.from('oficinas_extras').select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addOficinaExtra(int oficinaId, int extraId) async {
    final response = await supabase.from('oficinas_extras').insert({
      'oficina_id': oficinaId,
      'extra_id': extraId,
    });
    if (response == null) throw Exception('Error al agregar oficina extra: No se recibió respuesta.');
  }

  Future<void> deleteOficinaExtra(int oficinaId, int extraId) async {
    final response = await supabase
        .from('oficinas_extras')
        .delete()
        .match({'oficina_id': oficinaId, 'extra_id': extraId});
    if (response == null) throw Exception('Error al eliminar oficina extra: No se recibió respuesta.');
  }

  // ****************** OFICINAS IMÁGENES ******************

  Future<List<Map<String, dynamic>>> fetchOficinasImagenes() async {
    final response = await supabase.from('oficinas_imagenes').select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addOficinaImagen(int oficinaId, String url) async {
    final response = await supabase.from('oficinas_imagenes').insert({
      'oficina_id': oficinaId,
      'url': url,
    });
    if (response == null) throw Exception('Error al agregar imagen de oficina: No se recibió respuesta.');
  }

  Future<void> deleteOficinaImagen(int id) async {
    final response = await supabase.from('oficinas_imagenes').delete().eq('id', id);
    if (response == null) throw Exception('Error al eliminar imagen de oficina: No se recibió respuesta.');
  }

  // ****************** PAGOS ******************

  Future<List<Map<String, dynamic>>> fetchPagos() async {
    final response = await supabase.from('pagos').select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addPago(Map<String, dynamic> pago) async {
    final response = await supabase.from('pagos').insert(pago);
    if (response == null) throw Exception('Error al agregar pago: No se recibió respuesta.');
  }

  Future<void> deletePago(int id) async {
    final response = await supabase.from('pagos').delete().eq('id', id);
    if (response == null) throw Exception('Error al eliminar pago: No se recibió respuesta.');
  }

  // ****************** RESERVAS ******************

  Future<List<Map<String, dynamic>>> fetchReservas() async {
    final response = await supabase.from('reservas').select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addReserva(Map<String, dynamic> reserva) async {
    final response = await supabase.from('reservas').insert(reserva);
    if (response == null) throw Exception('Error al agregar reserva: No se recibió respuesta.');
  }

  Future<void> deleteReserva(int id) async {
    final response = await supabase.from('reservas').delete().eq('id', id);
    if (response == null) throw Exception('Error al eliminar reserva: No se recibió respuesta.');
  }

  // ****************** SECTORES ******************

  Future<List<Map<String, dynamic>>> fetchSectores() async {
    final response = await supabase.from('sectores').select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addSector(Map<String, dynamic> sector) async {
    final response = await supabase.from('sectores').insert(sector);
    if (response == null) throw Exception('Error al agregar sector: No se recibió respuesta.');
  }

  Future<void> deleteSector(int id) async {
    final response = await supabase.from('sectores').delete().eq('id', id);
    if (response == null) throw Exception('Error al eliminar sector: No se recibió respuesta.');
  }
}
