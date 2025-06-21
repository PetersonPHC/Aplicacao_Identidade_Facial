import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:reconhecimento/service/colaborador_service.dart';

import 'package:reconhecimento/utils/selecao_imagem.dart';
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
  final TextEditingController codigoEmpresaController = TextEditingController();
  final TextEditingController cargoController = TextEditingController();
  final TextEditingController nisController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();
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
        matricula: '${codigoEmpresaController.text}${matriculaController.text}',
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
  String? errorMessage;

  final DateTime? dataSelecionada = await showDialog<DateTime>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Informe a data'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'DD/MM/AAAA',
                    errorText: null, // Sempre null para usar nosso próprio erro
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  onChanged: (value) {
                    if (errorMessage != null) {
                      setState(() => errorMessage = null);
                    }

                    String newValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                    String formatted = '';

                    for (int i = 0; i < newValue.length && i < 8; i++) {
                      if (i == 2 || i == 4) formatted += '/';
                      formatted += newValue[i];
                    }

                    if (formatted != value) {
                      controller.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  },
                ),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('CANCELAR'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text('CONFIRMAR'),
                onPressed: () {
                  final text = controller.text;
                  final regex = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');

                  if (!regex.hasMatch(text)) {
                    setState(() => errorMessage = 'Formato inválido. Use DD/MM/AAAA');
                    return;
                  }

                  final match = regex.firstMatch(text)!;
                  final dia = int.parse(match.group(1)!);
                  final mes = int.parse(match.group(2)!);
                  final ano = int.parse(match.group(3)!);

                  // Validações
                  if (mes < 1 || mes > 12) {
                    setState(() => errorMessage = 'Mês deve ser entre 01 e 12');
                    return;
                  }

                  if (dia < 1 || dia > 31) {
                    setState(() => errorMessage = 'Dia deve ser entre 01 e 31');
                    return;
                  }

                  if (ano == 0) {
                    setState(() => errorMessage = 'Ano não pode ser 0000');
                    return;
                  }

                  // Valida meses com 30 dias
                  if ((mes == 4 || mes == 6 || mes == 9 || mes == 11) && dia > 30) {
                    setState(() => errorMessage = 'Este mês só tem 30 dias');
                    return;
                  }

                  // Valida fevereiro
                  if (mes == 2) {
                    final bissexto = (ano % 4 == 0 && (ano % 100 != 0 || ano % 400 == 0));
                    if ((bissexto && dia > 29) || (!bissexto && dia > 28)) {
                      setState(() => errorMessage = 'Fevereiro tem ${bissexto ? 29 : 28} dias neste ano');
                      return;
                    }
                  }

                  final novaData = DateTime(ano, mes, dia);
                  if (novaData.day != dia || novaData.month != mes || novaData.year != ano) {
                    setState(() => errorMessage = 'Data inválida para o mês informado');
                    return;
                  }

                  Navigator.pop(context, novaData);
                },
              ),
            ],
          );
        },
      );
    },
  );

  if (dataSelecionada != null) {
    controller.text = DateFormat('dd/MM/yyyy').format(dataSelecionada);
  }
}

 
}