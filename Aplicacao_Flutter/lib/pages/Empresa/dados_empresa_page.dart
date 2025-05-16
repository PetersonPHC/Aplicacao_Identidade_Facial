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
          _buildTextFieldRow("UF:", _controller.UFController),
          const SizedBox(height: 8),
          _buildTextFieldRow("Cidade:", _controller.cidadeController),
          const SizedBox(height: 8),
          _buildTextFieldRow("Bairro:", _controller.bairroController),
          const SizedBox(height: 8),
          _buildTextFieldRow("logradouro:", _controller.logradouroController),
          const SizedBox(height: 8),
          _buildTextFieldRow("Numero:", _controller.numeroController),
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

  Widget _buildUpdateButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () => _controller.atualizar(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 3, 33, 255),
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
}