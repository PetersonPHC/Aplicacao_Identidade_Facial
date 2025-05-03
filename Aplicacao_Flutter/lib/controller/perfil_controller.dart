import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:reconhecimento/service/colaborador_service.dart';

class PerfilController {
  final String matricula;
  final String cnpj;
  
  PerfilController({
    required this.matricula,
    required this.cnpj,
  });

  final ColaboradorService _colaboradorService = ColaboradorService();

  // Variáveis para armazenar os dados
  String nome = '';
  String cpf = '';
  String rg = '';
  String dataNascimento = '';
  String dataAdmissao = '';
  String cargaHoraria = '';
  String ctps = '';
  String matriculaColab = '';
  String cargo = '';
  String nis = '';
  Uint8List? imagemBytes;
  bool isLoading = true;

  Future<void> carregarDadosColaborador() async {
    try {
      final colaboradorData = await _colaboradorService.buscarColaborador(cnpj, matricula);

      // Acessando os campos com os nomes corretos que vieram da API
      final data = colaboradorData['data']; // Acessando o objeto dentro de 'data'
      
      nome = data['NOME'] ?? '';
      cpf = data['CPF'] ?? '';
      rg = data['RG'] ?? '';
      dataNascimento = data['DATA_NASCIMENTO'] != null
          ? DateFormat('dd/MM/yyyy').format(DateTime.parse(data['DATA_NASCIMENTO']))
          : '';
      dataAdmissao = data['DATA_ADMISSAO'] != null
          ? DateFormat('dd/MM/yyyy').format(DateTime.parse(data['DATA_ADMISSAO']))
          : '';
      cargaHoraria = data['CARGA_HORARIA'] ?? '';
      ctps = data['CTPS'] ?? '';
      matriculaColab = data['MATRICULA'] ?? '';
      cargo = data['CARGO'] ?? '';
      nis = data['NIS'] ?? '';

      // Tratamento da imagem igual ao da AtualizarColaboradorController
      if (data['IMAGEM'] != null) {
        if (data['IMAGEM'] is String) {
          // Se for string de bytes separados por vírgulas (como no Postman)
          final bytesString = data['IMAGEM'] as String;
          final bytesList = bytesString.split(',').map((e) => int.parse(e.trim())).toList();
          imagemBytes = Uint8List.fromList(bytesList);
        } else if (data['IMAGEM'] is List) {
          // Se for uma lista de bytes diretamente
          imagemBytes = Uint8List.fromList(data['IMAGEM'].cast<int>());
        } else if (data['IMAGEM'].runtimeType.toString().contains('Buffer')) {
          // Se for um objeto Buffer (Node.js)
          final bufferData = data['IMAGEM']['data'] as List<dynamic>;
          imagemBytes = Uint8List.fromList(bufferData.cast<int>());
        }
      }

      isLoading = false;
    } catch (e) {
      isLoading = false;
      throw Exception('Erro ao carregar dados do perfil: $e');
    }
  }
}