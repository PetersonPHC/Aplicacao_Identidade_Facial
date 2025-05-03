import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class RegistroPontoService {
  static const String _baseUrl = 'http://localhost:3000/registros-ponto';

  Future<bool> registrarPonto({
    required String matricula,
    required String cnpj,
    required Uint8List imagem,
    required String dataHora,
  }) async {
    try {
      // 1. Preparar a requisição multipart
      var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
      
      // 2. Adicionar headers
      request.headers['Accept'] = 'application/json';
      
      // 3. Adicionar campos do formulário
      request.fields.addAll({
        'MATRICULA': matricula,
        'CNPJ_EMPRESA': cnpj,
        'DATA_HORA': dataHora,
      });

      // 4. Adicionar a imagem
      request.files.add(http.MultipartFile.fromBytes(
        'IMAGEM',
        imagem,
        filename: 'ponto_${matricula}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));

      // 5. Enviar a requisição
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // 6. Verificar resposta
      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Falha ao registrar ponto: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }
}