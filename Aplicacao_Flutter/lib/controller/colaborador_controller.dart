import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:reconhecimento/service/colaborador_service.dart';

import 'package:reconhecimento/service/image_service.dart';
import 'package:reconhecimento/utils/date_utils.dart';

class ColaboradorController {
  final String cnpj;
  ColaboradorController({required this.cnpj});

  bool _isAdm = false;
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

  bool get isAdm => _isAdm;
  set isAdm(bool value) => _isAdm = value;

  File? get imagemSelecionada => _imagemSelecionada;
  Uint8List? get imagemSelecionadaWeb => _imagemSelecionadaWeb;

  final ColaboradorService _colaboradorService = ColaboradorService();
  final ImageService _imageService = ImageService();

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

  Future<void> cadastrar(BuildContext context) async {
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
      _mostrarSnackBar(context, 'Todos os campos obrigatórios devem ser preenchidos.');
      return;
    }

    if (!kIsWeb && _imagemSelecionada == null || (kIsWeb && _imagemSelecionadaWeb == null)) {
      _mostrarSnackBar(context, 'Por favor, selecione uma imagem antes de cadastrar.');
      return;
    }

    try {
      final response = await _colaboradorService.cadastrarColaborador(
        cnpj: cnpj,
        nome: nomeController.text,
        cpf: cpfController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        rg: rgController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        dataNascimento: dateUtils.formatarDataParaISO(dataNascimentoController.text),
        dataAdmissao: dateUtils.formatarDataParaISO(dataAdmissaoController.text),
        matricula: matriculaController.text,
        ctps: ctpsController.text,
        nis: nisController.text,
        cargaHoraria: dateUtils.formatarCargaHoraria(cargaHorariaController.text),
        cargo: cargoController.text,
        senha: senhaController.text,
        isAdm: _isAdm,
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
    senhaController.clear();
    cargaHorariaController.clear();
    _imagemSelecionada = null;
    _imagemSelecionadaWeb = null;
    _isAdm = false;
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