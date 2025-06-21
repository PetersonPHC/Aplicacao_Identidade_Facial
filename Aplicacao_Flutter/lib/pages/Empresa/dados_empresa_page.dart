import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reconhecimento/controller/dados_empresa_controller.dart';

import 'package:reconhecimento/widgets/confirmacao_dialog.dart';

class DadosEmpresaPage extends StatefulWidget {
  final String cnpj;
  
  const DadosEmpresaPage({required this.cnpj, Key? key}) : super(key: key);

  @override
  State<DadosEmpresaPage> createState() => _DadosEmpresaPageState();
}

class _DadosEmpresaPageState extends State<DadosEmpresaPage> {
  late DadosEmpresaController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DadosEmpresaController(cnpj: widget.cnpj);
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      await _controller.carregarDadosEmpresa();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 148, 177, 255),
        appBar: AppBar(
          title: const Text("Dados da empresa", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 30, 112, 243),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == "cancelar") {
                  _mostrarDialogoConfirmacao(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: "cancelar",
                  child: Text("Cancelar plano",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
          ],
        ),
        body: _controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      _buildFormContainer(),
                      _buildUpdateButton(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildFormContainer() {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 215, 221, 231),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color.fromARGB(255, 4, 47, 115),
          width: 2.0,
        ),
       boxShadow: [
  BoxShadow(
    color: Color.fromRGBO(2, 44, 79, 0.8), // Using RGBO constructor which takes opacity directly
    offset: const Offset(0, 6),
    blurRadius: 15,
  ),
],
      ),
      child: Column(
        children: [
          _buildTextFieldRow("Nome Fantasia:", _controller.nomeFantasiaController),
          const SizedBox(height: 8),
          _buildMaskedTextFieldRow("CNPJ:", _controller.cnpjController, enabled: false),
          const SizedBox(height: 8),
           _buildCodigoTextFieldRow("CODIGO_EMPRESA:", _controller.codigoEmpresaController, enabled: false),
          const SizedBox(height: 8),
          _buildMaskedTextFieldRow("CEP:", _controller.cepController),
          const SizedBox(height: 8),
          _buildUfTextFieldRow("UF:", _controller.UFController),
          const SizedBox(height: 8),
          _buildTextFieldRow("Cidade:", _controller.cidadeController),
          const SizedBox(height: 8),
          _buildTextFieldRow("Bairro:", _controller.bairroController),
          const SizedBox(height: 8),
          _buildTextFieldRow("logradouro:", _controller.logradouroController),
          const SizedBox(height: 8),
          _buildNumericTextFieldRow("Numero:", _controller.numeroController),
          const SizedBox(height: 8),
          _buildTextFieldRow("Complemento:", _controller.complementoController),
          const SizedBox(height: 8),
          _buildTextFieldRow("Email:", _controller.emailController),
          const SizedBox(height: 8),
          _buildDateFieldRow("Data de Criação:", _controller.dataCriacaoController),
        ],
      ),
    );
  }



Widget _buildNumericTextFieldRow(String label, TextEditingController controller) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(label,
          style: GoogleFonts.roboto(
              color: const Color.fromARGB(255, 0, 0, 0),
              fontSize: 16,
              fontWeight: FontWeight.w700)),
      Expanded(
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number, // Teclado numérico
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, // Permite apenas dígitos
          ],
          style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          decoration: InputDecoration(
            labelStyle: const TextStyle(color: Colors.black87),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black87),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
      ),
    ],
  );
}

  Widget _buildTextFieldRow(String label, TextEditingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label,
            style: GoogleFonts.roboto(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            decoration: InputDecoration(
              labelStyle: const TextStyle(color: Colors.black87),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black87),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaskedTextFieldRow(String label, MaskedTextController controller, {bool enabled = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label,
            style: GoogleFonts.roboto(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled,
            style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelStyle: const TextStyle(color: Colors.black87),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black87),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
        ),
      ],
    );
  }
   Widget _buildCodigoTextFieldRow(String label, TextEditingController controller, {bool enabled = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label,
            style: GoogleFonts.roboto(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled,
            style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelStyle: const TextStyle(color: Colors.black87),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black87),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
        ),
      ],
    );
  }


Widget _buildUfTextFieldRow(String label, TextEditingController controller) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(label,
          style: GoogleFonts.roboto(
              color: const Color.fromARGB(255, 0, 0, 0),
              fontSize: 16,
              fontWeight: FontWeight.w700)),
      Expanded(
        child: TextField(
          controller: controller,
          style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          maxLength: 2, // Limita a 2 caracteres
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')), // Permite apenas letras
            ],
          decoration: InputDecoration(
            counterText: '', // Remove o contador de caracteres
            labelStyle: const TextStyle(color: Colors.black87),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black87),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
      ),
    ],
  );
}


  Widget _buildDateFieldRow(String label, TextEditingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label,
            style: GoogleFonts.roboto(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        Expanded(
          child: TextField(
            controller: controller,
            readOnly: true,
            onTap: () => _controller.selecionarData(context),
            style: const TextStyle(color: Colors.black87),
            decoration: const InputDecoration(
              labelStyle: TextStyle(color: Colors.black87),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black87),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
        ),
      ],
    );
  }

  

  void _mostrarDialogoConfirmacao(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ConfirmacaoDialog(
        onConfirm: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Plano cancelado")),
          );
        },
      ),
    );
  }


  
// Formatter para converter texto para maiúsculas
  Widget _buildUpdateButton() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: ElevatedButton(
      onPressed: () async {
        if (_validarCampos()) {
          try {
            await _controller.atualizar(context);
            // Mostra mensagem de sucesso se o cadastro foi bem-sucedido
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Atualização realizada com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {});
          } catch (e) {
            // Mostra mensagem de erro se ocorrer uma exceção
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao atualizar: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          // Mostra mensagem detalhada sobre os campos inválidos
          String mensagemErro = _obterMensagemErroValidacao();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mensagemErro),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 77, 94, 226),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      ),
      child: Text(
        'Atualizar',
        style: GoogleFonts.roboto(
          color: const Color.fromARGB(255, 255, 255, 255),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}


bool _validarCampos() {
  bool isValid = true;

  // Validação do CNPJ (14 dígitos)
  if (_controller.cnpjController.text.replaceAll(RegExp(r'[^0-9]'), '').length != 14) {
    isValid = false;
  }

  // Validação do CEP (8 dígitos)
  if (_controller.cepController.text.replaceAll(RegExp(r'[^0-9]'), '').length != 8) {
    isValid = false;
  }

  // Validação do UF (exatamente 2 letras)
  if (_controller.UFController.text.length != 2 || 
      !RegExp(r'^[a-zA-Z]{2}$').hasMatch(_controller.UFController.text)) {
    isValid = false;
  }

  // Validação de campos obrigatórios não vazios
  if (_controller.nomeFantasiaController.text.isEmpty ||
      _controller.cepController.text.isEmpty ||
      _controller.UFController.text.isEmpty ||
      _controller.cidadeController.text.isEmpty ||
      _controller.bairroController.text.isEmpty ||
      _controller.logradouroController.text.isEmpty ||
      _controller.numeroController.text.isEmpty ||
      _controller.emailController.text.isEmpty ||
      _controller.dataCriacaoController.text.isEmpty) {
    isValid = false;
  }

  return isValid;
}

// Método para obter mensagens detalhadas de erro
String _obterMensagemErroValidacao() {
  String mensagem = 'Por favor, corrija os seguintes campos:\n';
  
  // Validação do CNPJ
  if (_controller.cnpjController.text.replaceAll(RegExp(r'[^0-9]'), '').length != 14) {
    mensagem += '- CNPJ deve ter 14 dígitos\n';
  }

  // Validação do CEP
  if (_controller.cepController.text.replaceAll(RegExp(r'[^0-9]'), '').length != 8) {
    mensagem += '- CEP deve ter 8 dígitos\n';
  }

  // Validação do UF
  if (_controller.UFController.text.length != 2 || 
      !RegExp(r'^[a-zA-Z]{2}$').hasMatch(_controller.UFController.text)) {
    mensagem += '- UF deve ter exatamente 2 letras\n';
  }

  // Validação de campos obrigatórios
  List<String> camposObrigatorios = [
    'Nome Fantasia', 'CEP', 'UF', 'Cidade', 'Bairro', 
    'Logradouro', 'Número', 'Email', 'Data de Criação'
  ];
  
  List<TextEditingController> controllers = [
    _controller.nomeFantasiaController,
    _controller.cepController,
    _controller.UFController,
    _controller.cidadeController,
    _controller.bairroController,
    _controller.logradouroController,
    _controller.numeroController,
    _controller.emailController,
    _controller.dataCriacaoController
  ];

  for (int i = 0; i < camposObrigatorios.length; i++) {
    if (controllers[i].text.isEmpty) {
      mensagem += '- ${camposObrigatorios[i]} é obrigatório\n';
    }
  }

  // Validação do email (opcional)
  

  return mensagem;
}
}


