import 'dart:convert';
import 'package:http/http.dart' as http;

class AppointmentService {
  final String _baseUrl = 'http://10.0.2.2:3000/api';

  Future<Map<String, List<Map<String, dynamic>>>> getCitas() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/citas'));

      if (response.statusCode == 200) {
        final body = response.body;
        print('Respuesta del servidor: $body');

        final List<dynamic> data = json.decode(body);

        final upcoming = <Map<String, dynamic>>[];
        final history = <Map<String, dynamic>>[];

        for (var item in data) {
          if (item is Map<String, dynamic>) {
            final dateString = item['fecha_hora'];

            if (dateString != null && dateString is String && dateString.isNotEmpty) {
              final date = DateTime.tryParse(dateString);
              if (date != null) {
                if (date.isAfter(DateTime.now())) {
                  upcoming.add(item);
                } else {
                  history.add(item);
                }
              } else {
                print('Fecha inválida: $dateString');
              }
            } else {
              print('Cita sin fecha válida: $item');
            }
          } else {
            print('Item inválido (no es un mapa): $item');
          }
        }

        print('Citas próximas: ${upcoming.length}');
        print('Citas pasadas: ${history.length}');

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
