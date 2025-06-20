import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TreatmentService {
  final String _baseUrl = 'http://10.0.2.2:3000/api';

  Future<List<Map<String, dynamic>>> getTreatments() async {
    try {
      // Obtener token del usuario logueado
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token no encontrado');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/treatment/tratamientos'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Respuesta del servidor (body): ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map<Map<String, dynamic>>((item) => {
              'id': item['id'],
              'titulo': item['titulo'], // Asegúrate que backend esté enviando 'titulo' o cambia a 'nombre'
              'estado': item['estado'],
              'fecha_inicio': item['fecha_inicio'],
              'fecha_fin': item['fecha_fin'],
              'descripcion': item['descripcion'],
              'proxima_cita': item['proxima_cita'],
              'doctor': item['doctor'],
              'medicamento': item['medicamento'] ?? {
                'nombre': '',
                'dosis': '',
                'frecuenciaHoras': '',
              }
            }).toList();
      } else {
        print('Error del servidor: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error al obtener tratamientos: $e');
      return [];
    }
  }
}
