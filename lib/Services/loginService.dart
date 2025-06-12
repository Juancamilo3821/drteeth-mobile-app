import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginService {
  Future<Map<String, dynamic>> login({
    required String correo,
    required String password,
  }) async {
    try {
      final url = Uri.parse('http://10.0.2.2:3000/api/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': correo,
          'password': password,
        }),
      );

      print('🔍 Status code: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['user'] != null) {
        return {'ok': true, 'user': data['user']};
      } else {
        return {
          'ok': false,
          'message': data['error'] ?? 'Credenciales inválidas'
        };
      }
    } catch (e) {
      print('❌ Error en login: $e');
      return {
        'ok': false,
        'message': 'Error de conexión al servidor',
      };
    }
  }
}
