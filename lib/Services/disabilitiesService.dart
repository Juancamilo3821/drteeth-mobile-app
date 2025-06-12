import 'dart:convert';
import 'package:http/http.dart' as http;

class DisabilitiesService {
  final String _baseUrl = 'http://10.0.2.2:3000/api';

  Future<List<Map<String, dynamic>>> getDisabilities() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/disabilitie/obtenerIncapacidades'));

      print('Respuesta del servidor (body): ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Mapeamos cada discapacidad a un Map<String, dynamic>
        return data.map<Map<String, dynamic>>((item) => {
          'id': item['id'],
          'titulo': item['titulo'],
          'fecha_inicio': item['fecha_inicio'],
          'fecha_fin': item['fecha_fin'],
          'duracion_dias': item['duracion_dias'],
          'motivo': item['motivo'],
          'estado': item['estado'],
          'archivo_pdf': item['archivo_pdf'],
          'usuario_id': item['usuario_id'],
          'perfil_id': item['perfil_id'],
          'doctor': item['doctor'],  // <--- agrega esto para incluir toda la info del doctor
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
