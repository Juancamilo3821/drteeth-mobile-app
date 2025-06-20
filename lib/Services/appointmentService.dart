import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentService {
  final String _baseUrl = 'http://10.0.2.2:3000/api';

  Future<Map<String, List<Map<String, dynamic>>>> getCitas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token no encontrado');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/citas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final upcoming = <Map<String, dynamic>>[];
        final history = <Map<String, dynamic>>[];

        for (var item in data) {
          final dateString = item['fecha_hora'];
          final date = DateTime.tryParse(dateString ?? '');

          if (date != null) {
            (date.isAfter(DateTime.now()) ? upcoming : history).add(item);
          } else {
            print('Fecha inválida: $dateString');
          }
        }

        return {
          'upcoming': upcoming,
          'history': history,
        };
      } else {
        print('Error del servidor: ${response.statusCode}');
        throw Exception('Error al cargar las citas');
      }
    } catch (e) {
      print('Error al cargar citas: $e');
      return {
        'upcoming': [],
        'history': [],
      };
    }
  }
}
