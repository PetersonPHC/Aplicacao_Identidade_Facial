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
            color: const Color.fromARGB(255, 2, 44, 79).withOpacity(0.8),
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
            color: const Color.fromARGB(255, 2, 44, 79).withOpacity(0.8),
            offset: const Offset(0, 6),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextFieldRow("Nome Fantasia:", _controller.nomeFantasiaController),
          const SizedBox(height: 8),
          _buildMaskedTextFieldRow("CNPJ:", _controller.cnpjController),
          const SizedBox(height: 8),
          _buildMaskedTextFieldRow("CEP:", _controller.cepController),
          const SizedBox(height: 8),
          _buildTextFieldRow("Estado / Cidade:", _controller.estadoCidadeController),
          const SizedBox(height: 8),
          _buildTextFieldRow("Bairro:", _controller.bairroController),
          const SizedBox(height: 8),
          _buildTextFieldRow("Rua / Avenida:", _controller.ruaAvenidaController),
          const SizedBox(height: 8),
          _buildTextFieldRow("Numero:", _controller.numeroController),
          const SizedBox(height: 8),
          _buildTextFieldRow("Complemento:", _controller.complementoController),
          const SizedBox(height: 8),
          _buildTextFieldRow("Responsavel:", _controller.responsavelController),
          const SizedBox(height: 8),
          _buildDateFieldRow("Data de Criação:", _controller.dataCriacaoController),
        ],
      ),
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

  Widget _buildRegisterButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () => _controller.cadastrar(context),
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
}