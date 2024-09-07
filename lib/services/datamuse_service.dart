import 'dart:convert';
import 'package:http/http.dart' as http;

class DatamuseService {
  static const String _baseUrl = 'https://api.datamuse.com';

  Future<List<String>> getSuggestions(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl/sug?s=$query'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => item['word'] as String).toList();
    } else {
      throw Exception('Failed to load suggestions');
    }
  }
}
