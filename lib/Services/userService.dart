import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final String _baseUrl = 'http://10.0.2.2:3000/api';

  // Obtener perfil del usuario
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('Token no encontrado');

      final response = await http.get(
        Uri.parse('$_baseUrl/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        print('❌ Error al obtener perfil: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Excepción en getUserProfile: $e');
      return null;
    }
  }

  // Actualizar avatar, correo, teléfono y opcionalmente contraseña
  Future<Map<String, dynamic>> updateUserAvatarWithToken({
    required int avatar,
    required String telefono,
    required String correo,
    String? nuevaContrasena,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('Token no encontrado');

      final Map<String, dynamic> payload = {
        'telefono': telefono,
        'correo': correo,
        'avatar': avatar,
      };

      if (nuevaContrasena != null && nuevaContrasena.isNotEmpty) {
        payload['password'] = nuevaContrasena;
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ Perfil actualizado exitosamente');

        return {
          'success': true,
          'token': responseData['token'],
        };
      } else {
        print('❌ Error al actualizar perfil: ${response.statusCode}');
        return { 'success': false };
      }
    } catch (e) {
      print('❌ Excepción en updateUserAvatarWithToken: $e');
      return { 'success': false };
    }
  }

  // Actualizar perfil completo (no usado en EditInformation actualmente)
  Future<bool> updateUserProfile({
    required String nombre,
    required String apellidos,
    required String telefono,
    required String direccion,
    required String fechaNacimiento,
    required int avatar,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('Token no encontrado');

      final body = jsonEncode({
        'nombre': nombre,
        'apellidos': apellidos,
        'telefono': telefono,
        'direccion': direccion,
        'fechaNacimiento': fechaNacimiento,
        'avatar': avatar,
      });

      final response = await http.put(
        Uri.parse('$_baseUrl/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        print('✅ Perfil actualizado exitosamente');
        return true;
      } else {
        print('❌ Error al actualizar perfil: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Excepción en updateUserProfile: $e');
      return false;
    }
  }
}
