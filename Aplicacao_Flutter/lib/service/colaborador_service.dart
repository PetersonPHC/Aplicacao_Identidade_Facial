import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class ColaboradorService {
  static const String _baseUrlColaboradores = 'http://localhost:3000/colaboradores';
  static const String _baseUrlUsuarios = 'http://localhost:3000/usuarios';

  Future<bool> cadastrarColaborador({
    required String cnpj,
    required String nome,
    required String cpf,
    required String rg,
    required String dataNascimento,
    required String dataAdmissao,
    required String matricula,
    required String ctps,
    required String nis,
    required String cargaHoraria,
    required String cargo,
    required String senha,
    required bool isAdm,
    dynamic imagem,
  }) async {
    try {
      // Log dos dados básicos
      print('=== INICIANDO CADASTRO ===');
      print('Matrícula: $matricula');
      print('CNPJ: $cnpj');
      print('Nome: $nome');

      // 1. Preparação da requisição para o colaborador
      var requestColab = http.MultipartRequest('POST', Uri.parse(_baseUrlColaboradores));
      
      // Adiciona headers importantes
      requestColab.headers['Accept'] = 'application/json';
      
      // Adiciona todos os campos (em MAIÚSCULAS conforme o backend espera)
      requestColab.fields.addAll({
        'MATRICULA': matricula.trim(),
        'CNPJ_EMPRESA': cnpj.trim(),
        'NOME': nome.trim(),
        'CPF': cpf.replaceAll(RegExp(r'[^0-9]'), ''),
        'RG': rg.replaceAll(RegExp(r'[^0-9]'), ''),
        'DATA_NASCIMENTO': dataNascimento,
        'DATA_ADMISSAO': dataAdmissao,
        'CTPS': ctps.trim(),
        'NIS': nis.trim(),
        'CARGA_HORARIA': cargaHoraria.toString(),
        'CARGO': cargo.trim(),
      });

      // Adiciona a imagem se existir
      if (imagem != null) {
        final String fileName = 'foto_${matricula.trim()}.jpg';
        
        if (imagem is File) {
          // Para arquivo físico
          requestColab.files.add(await http.MultipartFile.fromPath(
            'IMAGEM',
            imagem.path,
            filename: fileName,
            contentType: MediaType('image', 'jpeg'),
          ));
          print('Imagem (File) adicionada: $fileName');
        } else if (imagem is Uint8List) {
          // Para bytes em memória
          requestColab.files.add(http.MultipartFile.fromBytes(
            'IMAGEM',
            imagem,
            filename: fileName,
            contentType: MediaType('image', 'jpeg'),
          ));
          print('Imagem (Uint8List) adicionada: $fileName');
        }
      }

      // Log dos dados que serão enviados
      print('\nDados que serão enviados:');
      print('URL: ${requestColab.url}');
      print('Headers: ${requestColab.headers}');
      print('Campos:');
      requestColab.fields.forEach((key, value) => print('  $key: $value'));
      print('Arquivos: ${requestColab.files.map((f) => f.filename).toList()}');

      // 2. Envio da requisição e tratamento da resposta
      var streamedResponse = await requestColab.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('\nResposta do servidor (Colaborador):');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Falha ao cadastrar colaborador: ${response.body}');
      }

      // 3. Cadastro do usuário associado
      var responseUser = await http.post(
        Uri.parse(_baseUrlUsuarios),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'USUARIO_ID': matricula.trim(),
          'SENHA': senha,
          'ADM': isAdm
        }),
      );

      print('\nResposta do servidor (Usuário):');
      print('Status: ${responseUser.statusCode}');
      print('Body: ${responseUser.body}');

      if (responseUser.statusCode != 201) {
        throw Exception('Falha ao cadastrar usuário: ${responseUser.body}');
      }

      return true;
    } catch (e) {
      print('\nERRO NO CADASTRO: $e');
      print('Stack trace: ${e is Error ? e.stackTrace : ''}');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> buscarColaborador(String cnpj, String matricula) async {
    final url = Uri.parse("$_baseUrlColaboradores/$cnpj/$matricula");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Colaborador não encontrado');
    } else {
      throw Exception('Erro ao buscar colaborador');
    }
  }

  Future<bool> atualizarColaborador({
    required String cnpj,
    required String matricula,
    required String nome,
    required String cpf,
    required String rg,
    required String dataNascimento,
    required String dataAdmissao,
    required String cargaHoraria,
    required String ctps,
    required String cargo,
    required String nis,
  
    dynamic imagem,
  }) async {
print('Dados recebidos pelo service:');
  print('Nome: $nome');
  print('NIS: $nis');
  print('CTPS: $ctps');
  print('Cargo: $cargo');


  
 try {
    var request = http.MultipartRequest(
      'PUT', 
      Uri.parse('$_baseUrlColaboradores/$cnpj/$matricula')
    );

    // Adicione os campos como form-data
    request.fields.addAll({
      'MATRICULA': matricula,
      'NOME': nome,
      'CPF': cpf,
      'RG': rg,
      'DATA_NASCIMENTO': dataNascimento,
      'DATA_ADMISSAO': dataAdmissao,
      'NIS': nis,
      'CTPS': ctps,
      'CARGA_HORARIA': cargaHoraria,
      'CARGO': cargo,
      'CNPJ': cnpj,
    });
      print('Dados sendo enviados para atualização:');
print('MATRICULA: $matricula');
print('NOME: $nome');
print('CPF: $cpf');
print('RG: $rg');
print('DATA_NASCIMENTO: $dataNascimento');
print('DATA_ADMISSAO: $dataAdmissao');
print('CARGA_HORARIA: $cargaHoraria');
print('CTPS: $ctps');
print('CARGO: $cargo');
print('NIS: $nis');
print('CNPJ: $cnpj');



      if (imagem != null) {
        if (imagem is File) {
          var imagemFile = await http.MultipartFile.fromPath(
            'imagem',
            imagem.path,
            filename: 'imagem.jpg',
            contentType: MediaType('image', 'jpeg'),
          );
          request.files.add(imagemFile);
        } else if (imagem is Uint8List) {
          var imagemBytes = http.MultipartFile.fromBytes(
            'imagem',
            imagem,
            filename: 'imagem.jpg',
            contentType: MediaType('image', 'jpeg'),
          );
          request.files.add(imagemBytes);
        }
      }
        print('request: {$request}');
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Erro ao atualizar colaborador: $e');
    }
  }
Future<List<Map<String, dynamic>>?> buscarTodosColaboradores({required String cnpj}) async {
  try {
    final response = await http.get(
      Uri.parse('http://localhost:3000/colaboradores/$cnpj'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body) as Map<String, dynamic>?;
      
      if (decodedData == null) {
        return null;
      }

      if (decodedData['status'] != 'success') {
        throw Exception('Resposta da API não foi bem-sucedida');
      }

      final data = decodedData['data'] as List?;
      if (data == null) {
        return null;
      }

      return [{'data': data}]; // Mantém a estrutura esperada pelo controller
    } else {
      throw Exception('Falha na requisição: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Erro ao buscar colaboradores: $e');
  }
}
  Future<void> excluirColaborador(String cnpj, String matricula) async {
    
    print('DADOS FINAL METODO ');
     print('Status: {$_baseUrlColaboradores/$cnpj/$matricula}');
    final response = await http.delete(
      Uri.parse('$_baseUrlColaboradores/$cnpj/$matricula'),
    );

    if (response.statusCode != 204) {
      throw Exception('Erro ao excluir colaborador');
    }
  }

  Future<void> resetarSenha(String cnpj, String matricula, String novaSenha) async {
    final response = await http.put(
      Uri.parse('$_baseUrlUsuarios/$cnpj/$matricula'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'SENHA': novaSenha,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar senha');
    }
  }

}
  



