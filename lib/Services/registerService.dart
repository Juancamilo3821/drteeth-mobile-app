import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterService {
  Future<Map<String, dynamic>> register({
    required String nombre,
    required String apellidos,
    required String correo,
    required String telefono,
    required String password,
  }) async {
    final url = Uri.parse('http://10.0.2.2:3000/api/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'apellidos': apellidos,
        'correo': correo,
        'telefono': telefono,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return {'ok': true, 'message': 'Usuario registrado'};
    } else {
      final data = jsonDecode(response.body);
      return {'ok': false, 'message': data['error'] ?? 'Error desconocido'};
    }
  }
}