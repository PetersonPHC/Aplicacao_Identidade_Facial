

import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:reconhecimento/service/colaborador_service.dart';

import 'package:reconhecimento/utils/selecao_imagem.dart';

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
  
  try {
    final colaboradorData = await _colaboradorService.buscarColaborador(cnpj, matricula);

    
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
    ctpsController.clear();
    dataNascimentoController.clear();
    dataAdmissaoController.clear();
    nisController.clear();
    cargoController.clear();
    cargaHorariaController.clear();
    limparImagem();
    
  }

void limparImagem() {
  _imagemSelecionadaWeb = null;
  _imagemSelecionada = null;
  _imagemBytes = null;
  
}

Future<void> selecionarImagem() async {
  print("Iniciando seleção de imagem...");
  final result = await _imageService.selecionarImagem();
  print("Resultado recebido: $result");
  
  if (result != null) {
    if (kIsWeb) {
      print("Imagem web selecionada");
      _imagemSelecionadaWeb = result.webImage;
    } else {
      print("Imagem file selecionada");
      _imagemSelecionada = result.fileImage;
    }
    print("Imagem atribuída com sucesso");
  } else {
    print("Nenhuma imagem selecionada");
  }
}

  Future<void> atualizar(BuildContext context) async {
     if (nomeController.text.isEmpty ||
        cpfController.text.isEmpty ||
        rgController.text.isEmpty ||
        dataNascimentoController.text.isEmpty ||
        dataAdmissaoController.text.isEmpty ||
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
        _mostrarSnackBar(context, 'Colaborador atualizado com sucesso!');
        _limparCampos();
      } else {
         print('Response body: ${response}');
        _mostrarSnackBar(context, 'Erro ao atualizar colaborador');
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