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

  bool _isAdm = false;
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
  final TextEditingController senhaController = TextEditingController();

  File? _imagemSelecionada;
  Uint8List? _imagemSelecionadaWeb;
  Uint8List? _imagemBytes;

  bool get isAdm => _isAdm;
  set isAdm(bool value) => _isAdm = value;

  bool get isLoading => _isLoading;
  set isLoading(bool value) => _isLoading = value;

  File? get imagemSelecionada => _imagemSelecionada;
  Uint8List? get imagemSelecionadaWeb => _imagemSelecionadaWeb;
  Uint8List? get imagemBytes => _imagemBytes;

  final ColaboradorService _colaboradorService = ColaboradorService();
  final ImageService _imageService = ImageService();

  Future<void> carregarDadosColaborador() async {
    try {
      final colaboradorData = await _colaboradorService.buscarColaborador(cnpj, matricula);

      nomeController.text = colaboradorData['Nome'] ?? '';
      cpfController.text = colaboradorData['CPF'] ?? '';
      rgController.text = colaboradorData['RG'] ?? '';
      dataNascimentoController.text = colaboradorData['DataNascimento'] != null
          ? DateFormat('dd/MM/yyyy').format(DateTime.parse(colaboradorData['DataNascimento']))
          : '';
      dataAdmissaoController.text = colaboradorData['DataAdmissao'] != null
          ? DateFormat('dd/MM/yyyy').format(DateTime.parse(colaboradorData['DataAdmissao']))
          : '';
      cargaHorariaController.text = colaboradorData['CargaHoraria']?.toString() ?? '';
      ctpsController.text = colaboradorData['CTPS'] ?? '';
      matriculaController.text = colaboradorData['Matricula'] ?? '';
      cargoController.text = colaboradorData['Cargo'] ?? '';
      nisController.text = colaboradorData['NIS'] ?? '';
      senhaController.text = colaboradorData['Senha'] ?? '';
      _isAdm = colaboradorData['IsAdm'] ?? false;

      if (colaboradorData['imagem'] != null && colaboradorData['imagem'] is String) {
        _imagemBytes = base64Decode(colaboradorData['imagem']);
      }

      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      throw Exception('Erro ao carregar dados do colaborador: $e');
    }
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
    if (nomeController.text.isEmpty ||
        cpfController.text.isEmpty ||
        rgController.text.isEmpty ||
        dataNascimentoController.text.isEmpty ||
        dataAdmissaoController.text.isEmpty ||
        matriculaController.text.isEmpty ||
        ctpsController.text.isEmpty ||
        nisController.text.isEmpty ||
        cargaHorariaController.text.isEmpty ||
        cargoController.text.isEmpty ||
        senhaController.text.isEmpty) {
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
        cargaHoraria: int.parse(cargaHorariaController.text),
        ctps: ctpsController.text,
        cargo: cargoController.text,
        nis: nisController.text,
        senha: senhaController.text,
        isAdm: _isAdm,
        imagem: kIsWeb ? _imagemSelecionadaWeb : _imagemSelecionada,
      );

      if (!response) {
        throw Exception('Erro ao atualizar colaborador');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar: $e');
    }
  }

  Future<void> selecionarData(BuildContext context, TextEditingController controller) async {
    final dataSelecionada = await dateUtils.selecionarData(context);
    if (dataSelecionada != null) {
      controller.text = dateUtils.formatarDataParaExibicao(dataSelecionada);
    }
  }
}