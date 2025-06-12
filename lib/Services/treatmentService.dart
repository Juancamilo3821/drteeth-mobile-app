import 'dart:convert';
import 'package:http/http.dart' as http;

class TreatmentService {
  final String _baseUrl = 'http://10.0.2.2:3000/api';

  Future<List<Map<String, dynamic>>> getTreatments() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/treatment/tratamientos'));

      print('Respuesta del servidor (body): ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map<Map<String, dynamic>>((item) => {
          'id': item['id'],
          'titulo': item['titulo'],
          'estado': item['estado'],
          'fecha_inicio': item['fecha_inicio'],
          'fecha_fin': item['fecha_fin'],
          'descripcion': item['descripcion'],
          'proxima_cita': item['proxima_cita'],
          'doctor': item['doctor'],
          'medicamento': {
            'nombre': item['medicamento']['nombre'],
            'dosis': item['medicamento']['dosis'],
            'frecuenciaHoras': item['medicamento']['frecuenciaHoras'],
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
