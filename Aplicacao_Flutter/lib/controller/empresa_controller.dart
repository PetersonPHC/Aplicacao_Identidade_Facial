import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:reconhecimento/service/empresa_service.dart';
import 'package:reconhecimento/utils/date_utils.dart';
import 'package:intl/intl.dart';
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
  TextEditingController controller = TextEditingController();
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
                   // Verifica se a data selecionada é maior que a data atual
                  final dataAtual = DateTime.now();
                  final dataAtualSemHora = DateTime(dataAtual.year, dataAtual.month, dataAtual.day);
                  final novaDataSemHora = DateTime(novaData.year, novaData.month, novaData.day);
                  
                  if (novaDataSemHora.isAfter(dataAtualSemHora)) {
                    setState(() => errorMessage = 'A data não pode ser maior que a data atual');
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
    dataCriacaoController.text = DateFormat('dd/MM/yyyy').format(dataSelecionada);
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
        SnackBar(content: Text("Erro $e")),
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
    emailController.clear();
    complementoController.clear();
    UFController.clear();
    dataCriacaoController.clear();
    
  }
}