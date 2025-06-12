import 'dart:convert';
import 'package:http/http.dart' as http;

class CarruselService {
  static Future<List<String>> fetchImagenes() async {
    final url = Uri.parse('http://10.0.2.2:3000/api/carrusel'); 
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<String>();
      } else {
        throw Exception('Error al cargar imágenes');
      }
    } catch (e) {
      print('Error en fetchImagenes: $e');
      return [];
    }
  }
}