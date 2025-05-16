import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:reconhecimento/service/empresa_service.dart';
import 'package:reconhecimento/utils/date_utils.dart';
class EmpresaController {
  final MaskedTextController cnpjController = MaskedTextController(mask: '00.000.000/0000-00');
  final MaskedTextController cepController = MaskedTextController(mask: '00000-000');
  final TextEditingController dataCriacaoController = TextEditingController();
  final TextEditingController UFController = TextEditingController();
  final TextEditingController nomeFantasiaController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController logradouroController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController complementoController = TextEditingController();
  
  final TextEditingController emailController = TextEditingController();
final TextEditingController senhaController = TextEditingController();
  final EmpresaService _empresaService = EmpresaService();

  Future<void> selecionarData(BuildContext context) async {
    DateTime? dataSelecionada = await showDatePicker(
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

  Future<void> cadastrar(BuildContext context) async {
    try {
      final response = await _empresaService.cadastrarEmpresa(
        nomeFantasia: nomeFantasiaController.text,
        cnpj: cnpjController.text.replaceAll(RegExp(r'\D'), ''),
        cep: cepController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        cidade: cidadeController.text,
        bairro: bairroController.text,
        logradouro: logradouroController.text,
        numero: numeroController.text,
        complemento: complementoController.text,
        UF: UFController.text,
        senha: senhaController.text,
        email: emailController.text,
        dataCriacao: dateUtils.formatarDataParaISO(dataCriacaoController.text),
        context: context,
      );

      if (response) {
        limparCampos();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cadastro realizado com sucesso!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao cadastrar: $e")),
      );
    }
  }

  void limparCampos() {
    nomeFantasiaController.clear();
    cnpjController.clear();
    cepController.clear();
    cidadeController.clear();
    bairroController.clear();
   logradouroController.clear();
    numeroController.clear();
    complementoController.clear();
    UFController.clear();
    dataCriacaoController.clear();
  }
}