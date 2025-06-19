import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  final String _baseUrl = 'http://10.0.2.2:3000/api';

  Future<Map<String, List<Map<String, dynamic>>>> fetchPayments() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/pagos'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print('📦 Datos recibidos del backend: $data');

        final List<dynamic> pendientes = data['pendientes'] ?? [];
        final List<dynamic> pagados = data['pagados'] ?? [];

        return {
          'pending': List<Map<String, dynamic>>.from(pendientes),
          'paid': List<Map<String, dynamic>>.from(pagados),
        };
      } else {
        print('❌ Error del servidor: ${response.statusCode}');
        return {
          'pending': [],
          'paid': [],
        };
      }
    } catch (e) {
      print('❌ Error al obtener pagos: $e');
      return {
        'pending': [],
        'paid': [],
      };
    }
  }
}
