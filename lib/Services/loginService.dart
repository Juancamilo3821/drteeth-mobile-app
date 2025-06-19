import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

      if (response.statusCode == 200 && data['token'] != null) {
        // Guardar el token en local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        print('✅ Token guardado localmente');

        return {
          'ok': true,
          'user': data['user'],
        };
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
