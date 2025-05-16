import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:reconhecimento/service/empresa_service.dart';
import 'package:reconhecimento/utils/date_utils.dart';
class DadosEmpresaController {
  final String cnpj;
  final MaskedTextController cnpjController;
  final MaskedTextController cepController;
  
  final TextEditingController emailController;
  final TextEditingController dataCriacaoController;
  final TextEditingController nomeFantasiaController;
  final TextEditingController cidadeController;
  final TextEditingController bairroController;
  final TextEditingController codigoEmpresaController;
  final TextEditingController logradouroController;
  final TextEditingController numeroController;
  final TextEditingController complementoController;
  final TextEditingController UFController;

  bool isLoading = true;
  final EmpresaService _empresaService = EmpresaService();

  DadosEmpresaController({required this.cnpj}) 
    : cnpjController = MaskedTextController(mask: '00.000.000/0000-00'),
      cepController = MaskedTextController(mask: '00000-000'),
      dataCriacaoController = TextEditingController(),
      emailController = TextEditingController(),
      nomeFantasiaController = TextEditingController(),
      codigoEmpresaController = TextEditingController(),
      cidadeController = TextEditingController(),
      bairroController = TextEditingController(),
      logradouroController = TextEditingController(),
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
    codigoEmpresaController.text = empresaData['CODIGO_EMPRESA']?.toString() ?? '';
    cidadeController.text = empresaData['CIDADE'] ?? '';
    bairroController.text = empresaData['BAIRRO'] ?? '';
    logradouroController.text = empresaData['LOGRADOURO'] ?? '';
    numeroController.text = empresaData['NUMERO']?.toString() ?? ''; // Converte número para string
    complementoController.text = empresaData['COMPLEMENTO'] ?? '';
    emailController.text = empresaData['EMAIL'] ?? '';
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
Future<String> carregarCodigoEmpresa() async {
  try {
    final response = await _empresaService.buscarEmpresa(cnpj);
    final empresaData = response['data'];
    String codigo = empresaData['CODIGO_EMPRESA']?.toString() ?? '';
    
    // Formatação específica conforme o número de dígitos
    if (codigo.length == 1) {
      codigo = '00$codigo';  // Adiciona dois zeros se tiver apenas 1 dígito
    } else if (codigo.length == 2) {
      codigo = '0$codigo';   // Adiciona um zero se tiver 2 dígitos
    }
    // Se tiver 3 dígitos, mantém como está
    
    return codigo;
  } catch (e) {
    throw Exception('Erro ao carregar código da empresa: $e');
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

 Future<void> atualizar(BuildContext context) async {
  // DEBUG: Mostrar valores atuais
  
  try {
    final response = await _empresaService.atualizarEmpresa(
      nomeFantasia: nomeFantasiaController.text,
      cnpj: cnpjController.text.replaceAll(RegExp(r'\D'), ''),
      CEP: cepController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      cidade: cidadeController.text,
      bairro: bairroController.text,
      logradouro: logradouroController.text,
      numero: numeroController.text,
      complemento: complementoController.text,
      UF: UFController.text,
      email: emailController.text,
      dataCriacao: dateUtils.formatarDataParaISO(dataCriacaoController.text), // Experimente enviar sem formatação

    );

    if (response) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Atualização realizada com sucesso!")),
      );
      // Opcional: Recarregar os dados após atualização
      await carregarDadosEmpresa();
    }
  } catch (e) {
    debugPrint('Erro na atualização: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erro ao atualizar: ${e.toString()}")),
    );
  }
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