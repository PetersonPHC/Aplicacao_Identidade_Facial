import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:reconhecimento/service/colaborador_service.dart';

import 'package:reconhecimento/service/image_service.dart';

import 'package:reconhecimento/utils/date_utils.dart';

class AtualizarColaboradorController {
  final String cnpj;
  final String matricula;
  
  AtualizarColaboradorController({
    required this.cnpj,
    required this.matricula,
  });

 
  bool _isLoading = true;
  
  final cpfController = MaskedTextController(mask: '000.000.000-00');
  final rgController = MaskedTextController(mask: '00.000.000-0');
  final TextEditingController dataNascimentoController = TextEditingController();
  final TextEditingController dataAdmissaoController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cargaHorariaController = TextEditingController();
  final TextEditingController ctpsController = TextEditingController();
  final TextEditingController matriculaController = TextEditingController();
  final TextEditingController cargoController = TextEditingController();
  final TextEditingController nisController = TextEditingController();
  

  File? _imagemSelecionada;
  Uint8List? _imagemSelecionadaWeb;
  Uint8List? _imagemBytes;


  bool get isLoading => _isLoading;
  set isLoading(bool value) => _isLoading = value;

  File? get imagemSelecionada => _imagemSelecionada;
  Uint8List? get imagemSelecionadaWeb => _imagemSelecionadaWeb;
  Uint8List? get imagemBytes => _imagemBytes;

  final ColaboradorService _colaboradorService = ColaboradorService();
  final ImageService _imageService = ImageService();

Future<void> carregarDadosColaborador() async {
  print('DADOS FINAL METODO carregar');
  print('Status: {/$cnpj/$matricula}');
  
  try {
    final colaboradorData = await _colaboradorService.buscarColaborador(cnpj, matricula);

    print('DADOS FINAL METODO');
  
    
    // Acessando os campos com os nomes corretos que vieram da API
    final data = colaboradorData['data']; // Acessando o objeto dentro de 'data'
    
    nomeController.text = data['NOME'] ?? '';
    cpfController.text = data['CPF'] ?? '';
    rgController.text = data['RG'] ?? '';
    dataNascimentoController.text = data['DATA_NASCIMENTO'] != null
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(data['DATA_NASCIMENTO']))
        : '';
    dataAdmissaoController.text = data['DATA_ADMISSAO'] != null
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(data['DATA_ADMISSAO']))
        : '';
    
    // Tratamento especial para CARGA_HORARIA que vem no formato "HH:mm:ss"
      cargaHorariaController.text = data['CARGA_HORARIA'] ?? '';
    
    ctpsController.text = data['CTPS'] ?? '';
    matriculaController.text = data['MATRICULA'] ?? '';
    cargoController.text = data['CARGO'] ?? '';
    nisController.text = data['NIS'] ?? '';
   

   if (data['IMAGEM'] != null) {
      if (data['IMAGEM'] is String) {
        // Se for string de bytes separados por vírgulas (como no Postman)
        final bytesString = data['IMAGEM'] as String;
        final bytesList = bytesString.split(',').map((e) => int.parse(e.trim())).toList();
        _imagemBytes = Uint8List.fromList(bytesList);
      } else if (data['IMAGEM'] is List) {
        // Se for uma lista de bytes diretamente
        _imagemBytes = Uint8List.fromList(data['IMAGEM'].cast<int>());
      } else if (data['IMAGEM'].runtimeType.toString().contains('Buffer')) {
        // Se for um objeto Buffer (Node.js)
        final bufferData = data['IMAGEM']['data'] as List<dynamic>;
        _imagemBytes = Uint8List.fromList(bufferData.cast<int>());
      }
    }

    _isLoading = false;
  } catch (e) {
    _isLoading = false;
    throw Exception('Erro ao carregar dados do colaborador: $e');
  }
}



  void _limparCampos() {
    nomeController.clear();
    cpfController.clear();
    rgController.clear();
    matriculaController.clear();
    ctpsController.clear();
    dataNascimentoController.clear();
    dataAdmissaoController.clear();
    nisController.clear();
    cargoController.clear();
    cargaHorariaController.clear();
    _imagemSelecionada = null;
    _imagemSelecionadaWeb = null;
   
  }


  Future<void> selecionarImagem() async {
    final result = await _imageService.selecionarImagem();
    if (result != null) {
      if (kIsWeb) {
        _imagemSelecionadaWeb = result.webImage;
      } else {
        _imagemSelecionada = result.fileImage;
      }
    }
  }

  Future<void> atualizar(BuildContext context) async {
     print('Valores ANTES de enviar controller:');
  print('Nome: ${nomeController.text}');
  print('NIS: ${nisController.text}');
  print('CTPS: ${ctpsController.text}');
  print('Cargo: ${cargoController.text}');
    if (nomeController.text.isEmpty ||
        cpfController.text.isEmpty ||
        rgController.text.isEmpty ||
        dataNascimentoController.text.isEmpty ||
        dataAdmissaoController.text.isEmpty ||
        matriculaController.text.isEmpty ||
        ctpsController.text.isEmpty ||
        nisController.text.isEmpty ||
        cargaHorariaController.text.isEmpty ||
        cargoController.text.isEmpty ) {
      throw Exception('Todos os campos obrigatórios devem ser preenchidos.');
    }

    try {
      final response = await _colaboradorService.atualizarColaborador(
        cnpj: cnpj,
        matricula: matricula,
        nome: nomeController.text,
        cpf: cpfController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        rg: rgController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        dataNascimento: dateUtils.formatarDataParaISO(dataNascimentoController.text),
        dataAdmissao: dateUtils.formatarDataParaISO(dataAdmissaoController.text),
        cargaHoraria: dateUtils.formatarCargaHoraria(cargaHorariaController.text),
        ctps: ctpsController.text,
        cargo: cargoController.text,
        nis: nisController.text,
       imagem: kIsWeb ? _imagemSelecionadaWeb : _imagemSelecionada,
      );
       if (response) {
        _mostrarSnackBar(context, 'Colaborador cadastrado com sucesso!');
        _limparCampos();
      } else {
        _mostrarSnackBar(context, 'Erro ao cadastrar colaborador');
      }
    } catch (error) {
      _mostrarSnackBar(context, 'Erro ao conectar com a API: $error');
    }
     
  }

  void _mostrarSnackBar(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), duration: Duration(seconds: 2)),
    );
  }


  Future<void> selecionarData(BuildContext context, TextEditingController controller) async {
    final dataSelecionada = await dateUtils.selecionarData(context);
    if (dataSelecionada != null) {
      controller.text = dateUtils.formatarDataParaExibicao(dataSelecionada);
    }
  }
}