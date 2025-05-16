import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:reconhecimento/controller/colaborador_controller.dart';
import 'package:reconhecimento/controller/dados_empresa_controller.dart';

class CadastroColaboradorPage extends StatefulWidget {
  final String cnpj;

  const CadastroColaboradorPage({required this.cnpj});

  @override
  State<CadastroColaboradorPage> createState() =>
      _CadastroColaboradorPageState();
}

class _CadastroColaboradorPageState extends State<CadastroColaboradorPage> {
  late ColaboradorController _controller;
  late DadosEmpresaController empresaController;
  bool _showPopup = true; // Controla se o popup deve ser mostrado

  @override
  void initState() {
    super.initState();
    _controller = ColaboradorController(cnpj: widget.cnpj);
    empresaController = DadosEmpresaController(cnpj: widget.cnpj);
    _carregarCodigoEmpresa();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_showPopup) {
        _mostrarPopupInformacao();
      }
    });
  }

  Future<void> _carregarCodigoEmpresa() async {
    try {
      final codigo = await empresaController.carregarCodigoEmpresa();
      setState(() {
        _controller.codigoEmpresaController.text = codigo;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Erro ao carregar código da empresa: ${e.toString()}')),
      );
    }
  }

  Future<void> _mostrarPopupInformacao() async {
    return showDialog(
      context: context,
      barrierDismissible: true, // Permite fechar clicando fora
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Formato da Matrícula"),
          content: Text(
            "A matrícula do colaborador é composta pelo código da empresa + matrícula.\n\n"
            "Exemplo:\n"
            "Código da empresa: 111\n"
            "Matrícula: 000000001\n"
            "Matrícula completa: 111000000001",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              child: Text("ENTENDI"),
              onPressed: () {
                setState(() {
                  _showPopup =
                      false; // Marca como visto para não mostrar novamente
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                              color: Color.fromRGBO(2, 44, 79,
                                  0.8), // Using RGBO constructor which takes opacity directly
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
                              "CPF: ",
                              _controller.cpfController,
                              isNumber: true,
                              requiredLength: 11,
                              hasMask: true,
                            ),
                            SizedBox(height: 8),
                            _buildDateFieldRow("Data Nasc: ",
                                _controller.dataNascimentoController),
                            const SizedBox(height: 8),
                            _buildTextFieldRow(
                              "RG: ",
                              _controller.rgController,
                              requiredLength: 9,
                              hasMask: true,
                            ),
                            SizedBox(height: 8),
                            _buildMatriculaWithCodigoEmpresa(), // Substitui o campo matrícula original

                            SizedBox(height: 8),
                            _buildTextFieldRow(
                                "CTPS: ", _controller.ctpsController,
                                isNumber: true),
                            SizedBox(height: 8),
                            _buildTextFieldRow(
                                "NIS: ", _controller.nisController,
                                isNumber: true),
                            SizedBox(height: 8),
                            _buildCargaHorariaRow("Carga Horaria: ",
                                _controller.cargaHorariaController),
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
                    onPressed: () async {
                      if (_validarCampos()) {
                        await _controller.cadastrar(context);
                        setState(() {});
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Preencha todos os campos corretamente'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
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

  Widget _buildTextFieldRow(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    int? maxLength,
    bool isPassword = false,
    int? requiredLength,
    bool hasMask = false, // Novo parâmetro para indicar campos com máscara
  }) {
    bool isTouched = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.roboto(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: isPassword,
                style: TextStyle(color: Colors.black),
                keyboardType:
                    isNumber ? TextInputType.number : TextInputType.text,
                inputFormatters: [
                  if (requiredLength != null && !hasMask)
                    LengthLimitingTextInputFormatter(requiredLength),
                  if (maxLength != null)
                    LengthLimitingTextInputFormatter(maxLength),
                  if (isNumber &&
                      !hasMask) // Não aplica digitsOnly se tiver máscara
                    FilteringTextInputFormatter.digitsOnly,
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
                  errorText: isTouched && requiredLength != null
                      ? _validateField(controller.text, requiredLength, hasMask)
                      : null,
                ),
                onTap: () => setState(() => isTouched = true),
                onChanged: (value) {
                  if (requiredLength != null) {
                    setState(() {});
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCargaHorariaRow(
    String label,
    TextEditingController controller,
  ) {
    // Função interna para formatar o texto enquanto digita
    void _formatarInput(String value) {
      final text = value.replaceAll(RegExp(r'[^0-9]'), '');
      var formatted = '';

      if (text.length >= 2) {
        formatted = '${text.substring(0, 2)}';
        if (text.length >= 4) {
          formatted += ':${text.substring(2, 4)}';
          if (text.length >= 6) {
            formatted += ':${text.substring(4, 6)}';
          } else if (text.length > 4) {
            formatted += ':${text.substring(4)}';
          }
        } else if (text.length > 2) {
          formatted += ':${text.substring(2)}';
        }
      } else {
        formatted = text;
      }

      // Atualiza o controlador apenas se o texto foi modificado
      if (controller.text != formatted) {
        controller.value = controller.value.copyWith(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
          composing: TextRange.empty,
        );
      }
    }

    return Row(
      children: [
        Text(label,
            style: GoogleFonts.roboto(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'HH:MM:SS',
              border: OutlineInputBorder(),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
            ],
            onChanged: _formatarInput,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira a carga horária';
              }
              if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$')
                  .hasMatch(value)) {
                return 'Formato inválido (use HH:MM:SS)';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  String? _validateField(String text, int requiredLength, bool hasMask) {
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (hasMask) {
      // Para campos com máscara, verifique se a máscara está completa
      if (text.length < text.runes.length) {
        // Verificação simplificada
        return 'Preencha o campo completo';
      }
    }

    if (digitsOnly.length != requiredLength) {
      return 'Deve ter exatamente $requiredLength dígitos';
    }

    return null;
  }

  Widget _buildMatriculaWithCodigoEmpresa() {
    return Row(
      children: [
        // Campo código empresa (somente leitura)
        SizedBox(
          width: 100,
          child: TextField(
            controller: _controller.codigoEmpresaController,
            readOnly: true, // Torna o campo somente leitura
            decoration: InputDecoration(
              labelText: "Cód Emp",
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors
                  .grey[200], // Cor de fundo para indicar que é somente leitura
            ),
          ),
        ),
        SizedBox(width: 8),
        // Campo matrícula (expande para o restante do espaço)
        Expanded(
          child: _buildTextFieldRow(
            "Matricula: ",
            _controller.matriculaController,
            isNumber: true,
            requiredLength: 10,
          ),
        ),
      ],
    );
  }

  bool _validarCampos() {
    bool isValid = true;

    // Validação do RG (9 dígitos)
    if (_controller.rgController.text
            .replaceAll(RegExp(r'[^0-9]'), '')
            .length !=
        9) {
      isValid = false;
    }

    // Validação do CPF (11 dígitos)
    if (_controller.cpfController.text
            .replaceAll(RegExp(r'[^0-9]'), '')
            .length !=
        11) {
      isValid = false;
    }

    // Validação da Matrícula (10 dígitos)
    if (_controller.matriculaController.text
            .replaceAll(RegExp(r'[^0-9]'), '')
            .length !=
        10) {
      isValid = false;
    }

    // Validação de campos obrigatórios não vazios
    if (_controller.nomeController.text.isEmpty ||
        _controller.dataNascimentoController.text.isEmpty ||
        _controller.cargoController.text.isEmpty ||
        _controller.dataAdmissaoController.text.isEmpty ||
        _controller.senhaController.text.isEmpty) {
      isValid = false;
    }

    return isValid;
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
