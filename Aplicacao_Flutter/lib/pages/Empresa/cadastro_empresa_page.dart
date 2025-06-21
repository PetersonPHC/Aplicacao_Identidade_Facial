import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reconhecimento/controller/empresa_controller.dart';

import 'package:flutter/services.dart';

class CadastroEmpresaPage extends StatefulWidget {
  const CadastroEmpresaPage({super.key});

  @override
  State<CadastroEmpresaPage> createState() => _CadastroEmpresaPageState();
}

class _CadastroEmpresaPageState extends State<CadastroEmpresaPage> {
  final EmpresaController _controller = EmpresaController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 148, 177, 255),
        appBar: AppBar(
          title: const Text("Cadastre sua empresa", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 30, 112, 243),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 15),
                _buildWelcomeCard(),
                const SizedBox(height: 15),
                _buildFormContainer(),
                _buildRegisterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
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
      child: const Text(
        "Venha conhecer o IDENTIDADE-FACIAL a ferramenta que vai simplificar o seu registro de ponto",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFormContainer() {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 236, 232, 232),
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
          
          _buildMaskedTextFieldRow("CNPJ:", _controller.cnpjController),
          const SizedBox(height: 8),
          _buildTextFieldRow("Nome Fantasia:", _controller.nomeFantasiaController),
          const SizedBox(height: 8),
          _buildMaskedTextFieldRow("CEP:", _controller.cepController),
          const SizedBox(height: 8),
          _buildUfTextFieldRow("UF:", _controller.UFController),
          const SizedBox(height: 8),
          _buildTextFieldRow("Cidade:", _controller.cidadeController),
          const SizedBox(height: 8),
          _buildTextFieldRow("Bairro:", _controller.bairroController),
          const SizedBox(height: 8),
          _buildTextFieldRow("Logradouro:", _controller.logradouroController),
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

  Widget _buildMaskedTextFieldRow(String label, MaskedTextController controller) {
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

  Widget _buildDateFieldRow(String label, TextEditingController controller) {
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
            readOnly: true,
            onTap: () => _controller.selecionarData(context),
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


// Formatter para converter texto para maiúsculas
  Widget _buildRegisterButton() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: ElevatedButton(
      onPressed: () async {
        if (_validarCampos()) {
          try {
            await _controller.cadastrar(context);
            // Mostra mensagem de sucesso se o cadastro foi bem-sucedido
            
            setState(() {});
          } catch (e) {
            // Mostra mensagem de erro se ocorrer uma exceção
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao cadastrar: ${e.toString()}'),
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
        'Cadastrar',
        style: GoogleFonts.roboto(
          color: const Color.fromARGB(255, 255, 255, 255),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
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

