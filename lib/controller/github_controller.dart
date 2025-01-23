import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubController {
  final String token; // Token de acceso personal
  final String repoOwner;
  final String repoName;
  final String filePath;

  GitHubController({
    required this.token,
    required this.repoOwner,
    required this.repoName,
    this.filePath = 'vegetales.json',
  });

  Future<List<dynamic>> fetchVegetales() async {
    final url = Uri.parse(
        'https://api.github.com/repos/$repoOwner/$repoName/contents/$filePath');
    final response = await http.get(
      url,
      headers: {'Authorization': 'token $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final encodedContent = data['content']; // Contenido en base64

      // Limpia los saltos de línea (\n) del contenido base64
      final cleanedContent = encodedContent.replaceAll('\n', '');

      // Decodifica base64 y luego utf8
      final decodedContent = utf8.decode(base64.decode(cleanedContent));

      // Decodifica JSON y lo devuelve como lista dinámica
      return json.decode(decodedContent);
    } else {
      throw Exception('Error al obtener el archivo: ${response.body}');
    }
  }



  Future<void> updateVegetales(List<dynamic> vegetales) async {
    final url = Uri.parse(
        'https://api.github.com/repos/$repoOwner/$repoName/contents/$filePath');
    final getResponse = await http.get(
      url,
      headers: {'Authorization': 'token $token'},
    );

    if (getResponse.statusCode == 200) {
      final data = json.decode(getResponse.body);
      final sha = data['sha'];

      // Codifica el nuevo contenido en base64
      final encodedContent = base64.encode(utf8.encode(json.encode(vegetales)));
      final updateResponse = await http.put(
        url,
        headers: {'Authorization': 'token $token'},
        body: json.encode({
          'message': 'Actualizando vegetales.json',
          'content': encodedContent,
          'sha': sha,
        }),
      );

      if (updateResponse.statusCode != 200) {
        throw Exception('Error al actualizar el archivo: ${updateResponse.body}');
      }
    } else {
      throw Exception('Error al obtener el SHA del archivo.');
    }
  }

}
