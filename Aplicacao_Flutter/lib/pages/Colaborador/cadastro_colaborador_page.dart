import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:reconhecimento/controller/colaborador_controller.dart';

class CadastroColaboradorPage extends StatefulWidget {
  final String cnpj;

  const CadastroColaboradorPage({required this.cnpj});

  @override
  State<CadastroColaboradorPage> createState() =>
      _CadastroColaboradorPageState();
}

class _CadastroColaboradorPageState extends State<CadastroColaboradorPage> {
  late ColaboradorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ColaboradorController(cnpj: widget.cnpj);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(2255, 148, 177, 255),
        appBar: AppBar(
          title: Text("Cadastro de Colaboradores",
              style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 30, 112, 243),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: const Color.fromARGB(255, 4, 47, 115),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 2, 44, 79)
                                  .withOpacity(0.8),
                              offset: const Offset(0, 6),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: Container()),
                                Expanded(
                                  flex: 8,
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          await _controller.selecionarImagem();
                                          setState(
                                              () {}); // Força a reconstrução do widget
                                        },
                                        child: Container(
                                          width: 200,
                                          height: 200,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            shape: BoxShape.circle,
                                          ),
                                          child: _controller
                                                      .imagemSelecionada !=
                                                  null
                                              ? ClipOval(
                                                  child: Image.file(
                                                    _controller
                                                        .imagemSelecionada!,
                                                    fit: BoxFit.cover,
                                                    width: 200,
                                                    height: 200,
                                                  ),
                                                )
                                              : _controller
                                                          .imagemSelecionadaWeb !=
                                                      null
                                                  ? ClipOval(
                                                      child: Image.memory(
                                                        _controller
                                                            .imagemSelecionadaWeb!,
                                                        fit: BoxFit.cover,
                                                        width: 200,
                                                        height: 200,
                                                      ),
                                                    )
                                                  : Icon(
                                                      Icons.add_a_photo,
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 0, 0, 0),
                                                      size: 50,
                                                    ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "Clique para adicionar uma imagem",
                                        style: TextStyle(
                                            color: const Color.fromARGB(
                                                255, 0, 0, 0)),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(child: Container()),
                              ],
                            ),
                            SizedBox(height: 20),
                            _buildTextFieldRow(
                                "Nome: ", _controller.nomeController,
                                maxLength: 50),
                            const SizedBox(height: 8),
                            _buildTextFieldRow(
                                "CPF: ", _controller.cpfController,
                                isNumber: true),
                            SizedBox(height: 8),
                            _buildDateFieldRow("Data Nasc: ",
                                _controller.dataNascimentoController),
                            const SizedBox(height: 8),
                            _buildTextFieldRow(
                                "RG: ", _controller.rgController),
                            SizedBox(height: 8),
                            _buildTextFieldRow(
                                "Matricula: ", _controller.matriculaController,
                                isNumber: true),
                            SizedBox(height: 8),
                            _buildTextFieldRow(
                                "CTPS: ", _controller.ctpsController,
                                isNumber: true),
                            SizedBox(height: 8),
                            _buildTextFieldRow(
                                "NIS: ", _controller.nisController,
                                isNumber: true),
                            SizedBox(height: 8),
                            _buildTextFieldRow("Carga Horaria: ",
                                _controller.cargaHorariaController,
                                isNumber: true),
                            SizedBox(height: 8),
                            _buildTextFieldRow(
                                "Cargo: ", _controller.cargoController,
                                maxLength: 50),
                            SizedBox(height: 8),
                            _buildDateFieldRow("Data de Admissão: ",
                                _controller.dataAdmissaoController),
                            SizedBox(height: 8),
                            _buildTextFieldRow(
                                "Senha: ", _controller.senhaController,
                                maxLength: 50, isPassword: true),
                            SizedBox(height: 8),
                            _buildAdminCheckbox(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () => _controller.cadastrar(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 3, 33, 255),
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldRow(String label, TextEditingController controller,
      {bool isNumber = false, int? maxLength, bool isPassword = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label,
            style: GoogleFonts.roboto(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        Expanded(
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: TextStyle(color: Colors.black),
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            inputFormatters: [
              if (isNumber) FilteringTextInputFormatter.digitsOnly,
              if (maxLength != null)
                LengthLimitingTextInputFormatter(maxLength),
            ],
            decoration: InputDecoration(
              labelText: label.replaceAll(':', '').trim(),
              labelStyle: TextStyle(color: Colors.black),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
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

  Widget _buildDateFieldRow(String label, TextEditingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label,
            style: GoogleFonts.roboto(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        Expanded(
          child: TextField(
            controller: controller,
            readOnly: true,
            onTap: () => _controller.selecionarData(context, controller),
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              labelText: label.replaceAll(':', '').trim(),
              labelStyle: TextStyle(color: Colors.black),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
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

  Widget _buildAdminCheckbox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Administrador: ",
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Checkbox(
          value: _controller.isAdm,
          onChanged: (bool? value) {
            setState(() {
              _controller.isAdm = value ?? false;
            });
          },
        ),
        Text(_controller.isAdm ? "Sim" : "Não"),
      ],
    );
  }
}
