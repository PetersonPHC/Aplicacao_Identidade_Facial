import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:reconhecimento/service/empresa_service.dart';

class DadosEmpresaController {
  final String cnpj;
  final MaskedTextController cnpjController;
  final MaskedTextController cepController;
  final TextEditingController dataCriacaoController;
  final TextEditingController nomeFantasiaController;
  final TextEditingController estadoCidadeController;
  final TextEditingController bairroController;
  final TextEditingController ruaAvenidaController;
  final TextEditingController numeroController;
  final TextEditingController complementoController;
  final TextEditingController UFController;

  bool isLoading = true;
  final EmpresaService _empresaService = EmpresaService();

  DadosEmpresaController({required this.cnpj}) 
    : cnpjController = MaskedTextController(mask: '00.000.000/0000-00'),
      cepController = MaskedTextController(mask: '00000-000'),
      dataCriacaoController = TextEditingController(),
      nomeFantasiaController = TextEditingController(),
      estadoCidadeController = TextEditingController(),
      bairroController = TextEditingController(),
      ruaAvenidaController = TextEditingController(),
      numeroController = TextEditingController(),
      complementoController = TextEditingController(),
      UFController = TextEditingController() {
    cnpjController.text = cnpj;
  }
Future<void> carregarDadosEmpresa() async {
  try {
    final response = await _empresaService.buscarEmpresa(cnpj);
    final empresaData = response['data']; // Acessa o objeto dentro de 'data'

    nomeFantasiaController.text = empresaData['NOMEFANTASIA'] ?? '';
    cepController.text = empresaData['CEP']?.toString() ?? ''; // Converte número para string
    UFController.text = empresaData['UF'] ?? '';
    // Juntando UF e CIDADE para o campo estadoCidade
    estadoCidadeController.text = empresaData['CIDADE'] ?? '';
    bairroController.text = empresaData['BAIRRO'] ?? '';
    ruaAvenidaController.text = empresaData['LOGRADOURO'] ?? '';
    numeroController.text = empresaData['NUMERO']?.toString() ?? ''; // Converte número para string
    complementoController.text = empresaData['COMPLEMENTO'] ?? '';
    
    // Tratamento da data
    dataCriacaoController.text = empresaData['DATACRIACAO'] != null
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(empresaData['DATACRIACAO']))
        : '';
      
    isLoading = false;
  } catch (e) {
    isLoading = false;
    throw Exception('Erro ao carregar dados: $e');
  }
}

  Future<void> selecionarData(BuildContext context) async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

    if (dataSelecionada != null) {
      dataCriacaoController.text = 
        "${dataSelecionada.day.toString().padLeft(2, '0')}/"
        "${dataSelecionada.month.toString().padLeft(2, '0')}/"
        "${dataSelecionada.year}";
    }
  }

  void atualizar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dados atualizados com sucesso'),
        duration: Duration(seconds: 2),
      ),
    );

    limparCampos();
  }

  void limparCampos() {
    nomeFantasiaController.clear();
    cnpjController.clear();
    numeroController.clear();
    UFController.clear();
    bairroController.clear();
    dataCriacaoController.clear();
  }
}