import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:reconhecimento/service/empresa_service.dart';

class EmpresaController {
  final MaskedTextController cnpjController = MaskedTextController(mask: '00.000.000/0000-00');
  final MaskedTextController cepController = MaskedTextController(mask: '00000-000');
  final TextEditingController dataCriacaoController = TextEditingController();
  final TextEditingController responsavelController = TextEditingController();
  final TextEditingController nomeFantasiaController = TextEditingController();
  final TextEditingController estadoCidadeController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController ruaAvenidaController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController complementoController = TextEditingController();

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
        estadoCidade: estadoCidadeController.text,
        bairro: bairroController.text,
        ruaAvenida: ruaAvenidaController.text,
        numero: numeroController.text,
        complemento: complementoController.text,
        responsavel: responsavelController.text,
        dataCriacao: dataCriacaoController.text,
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
    estadoCidadeController.clear();
    bairroController.clear();
    ruaAvenidaController.clear();
    numeroController.clear();
    complementoController.clear();
    responsavelController.clear();
    dataCriacaoController.clear();
  }
}