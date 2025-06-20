import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DisabilitiesService {
  final String _baseUrl = 'http://10.0.2.2:3000/api';

  Future<List<Map<String, dynamic>>> getDisabilities() async {
    try {
      // Leer token guardado localmente
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token no encontrado');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/disabilitie/obtenerIncapacidades'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Respuesta del servidor (body): ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map<Map<String, dynamic>>((item) => {
          'id': item['id'],
          'titulo': item['titulo'],
          'fecha_inicio': item['fecha_inicio'],
          'fecha_fin': item['fecha_fin'],
          'duracion_dias': item['duracion_dias'],
          'motivo': item['motivo'],
          'estado': item['estado'],
          'archivo_pdf': item['archivo_pdf'],
          'doctor': item['doctor'],
        }).toList();
      } else {
        print('Error del servidor: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error al obtener incapacidades: $e');
      return [];
    }
  }
}
