import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

// Classe de exceção personalizada
class RegistrarPontoException implements Exception {
  final String message;
  RegistrarPontoException(this.message);
  
  @override
  String toString() => message;
}

class FacialRecognitionException implements Exception {
  final String message;
  final bool isFaceDetectionError;
  final bool isFaceMismatchError;
  
  FacialRecognitionException(
    this.message, {
    this.isFaceDetectionError = false,
    this.isFaceMismatchError = false,
  });
  
  @override
  String toString() => message;
}

class RegistroPontoService {
  static const String _baseUrl = 'http://localhost:3000/registros-ponto';
Future<bool> registrarPonto({
  required String matricula,
  required String cnpj,
  required Uint8List imagem,
  required String dataHora,
}) async {
  try {
    var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
    request.headers['Accept'] = 'application/json';
    
    request.fields.addAll({
      'MATRICULA': matricula,
      'CNPJ_EMPRESA': cnpj,
      'DATA_HORA': dataHora,
    });

    request.files.add(http.MultipartFile.fromBytes(
      'IMAGEM',
      imagem,
      filename: 'ponto_${matricula}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      contentType: MediaType('image', 'jpeg'),
    ));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

   if (response.statusCode == 201) {
      return true;
    } else {
      // Tratamento específico para erros de reconhecimento facial
      if (response.body.contains('Nenhuma face detectada na imagem de registro')) {
        throw FacialRecognitionException(
          'Não detectamos nenhum rosto na foto\n'
          'Por favor, posicione seu rosto corretamente',
          isFaceDetectionError: true,
        );
      } else if (response.body.contains('Error na comparação facial')) {
        throw FacialRecognitionException(
          'O rosto na foto não corresponde ao cadastro\n'
          'Por favor, tente novamente ou verifique seu cadastro',
          isFaceMismatchError: true,
        );
      } else {
        throw RegistrarPontoException('Não foi possível registrar ponto: ${response.body}');
      }
    }
  } catch (e) {
    if (e is FacialRecognitionException) {
      rethrow; // Mantém as exceções específicas
    } else {
      throw RegistrarPontoException('Erro: $e');
    }
  }
}


   Future<List<Map<String, dynamic>>> buscarRegistrosPonto({
    required String cnpjEmpresa,
    required String matricula,
    required DateTime data,
  }) async {
    try {
      final formattedDate = "${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}";
      final url = Uri.parse('$_baseUrl/$cnpjEmpresa/$matricula/$formattedDate');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 404) {
        return []; // Retorna lista vazia se não encontrar registros
      } else {
        throw Exception('Falha ao carregar registros de ponto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }
Future<Map<String, dynamic>> incluirRegistroPonto({
  required String matricula,
  required String cnpjEmpresa,
  required String dataPonto, 
}) async {
  try {
   
    

    final response = await http.post(
      Uri.parse('$_baseUrl/incluir'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "MATRICULA": matricula,
        "CNPJ_EMPRESA": cnpjEmpresa,
        "DATA_PONTO": dataPonto,
      }),
    );

    
    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, 'data': responseData};
    } else {
      return {
        'success': false,
        'error': responseData['message'] ?? 'Erro ao incluir registro',
      };
    }
  } catch (e) {
    
    return {
      'success': false,
      'error': 'Erro de conexão: ${e.toString()}',
    };
  }
}
  Future<Map<String, dynamic>> removerRegistroPonto({
    required String matricula,
    required String cnpjEmpresa,
    required String dataPonto,
  }) async {
    try {
      
      final response = await http.delete(
        Uri.parse('$_baseUrl/$cnpjEmpresa/$matricula/$dataPonto'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "MATRICULA": matricula,
          "CNPJ_EMPRESA": cnpjEmpresa,
          "DATA_PONTO": dataPonto,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'error': responseData['message'] ?? 'Erro ao remover registro de ponto',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro de conexão: ${e.toString()}',
      };
    }
  }
}