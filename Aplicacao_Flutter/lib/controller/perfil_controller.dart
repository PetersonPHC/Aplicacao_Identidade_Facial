import 'dart:convert';
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

  String nome = '';
  String cpf = '';
  String rg = '';
  String dataNascimento = '';
  String ctps = '';
  String matriculaColab = '';
  String cargo = '';
  String nis = '';
  String dataAdmissao = '';
  Uint8List? imagemBytes;
  bool isLoading = true;

  Future<void> carregarDadosColaborador() async {
    try {
      final colaboradorData = await _colaboradorService.buscarColaborador(cnpj, matricula);

      nome = colaboradorData['Nome'] ?? '';
      cpf = colaboradorData['CPF'] ?? '';
      rg = colaboradorData['RG'] ?? '';
      dataNascimento = colaboradorData['DataNascimento'] != null
          ? DateFormat('dd/MM/yyyy').format(DateTime.parse(colaboradorData['DataNascimento']))
          : '';
      dataAdmissao = colaboradorData['DataAdmissao'] != null
          ? DateFormat('dd/MM/yyyy').format(DateTime.parse(colaboradorData['DataAdmissao']))
          : '';
      ctps = colaboradorData['CTPS'] ?? '';
      matriculaColab = colaboradorData['Matricula'] ?? '';
      cargo = colaboradorData['Cargo'] ?? '';
      nis = colaboradorData['NIS'] ?? '';

      if (colaboradorData['imagem'] != null && colaboradorData['imagem'] is String) {
        imagemBytes = base64Decode(colaboradorData['imagem']);
      }

      isLoading = false;
    } catch (e) {
      isLoading = false;
      throw Exception('Erro ao carregar dados do perfil: $e');
    }
  }
}