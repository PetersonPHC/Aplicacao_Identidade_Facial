import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:reconhecimento/controller/colaborador_controller.dart';
import 'package:reconhecimento/controller/dados_empresa_controller.dart';
import 'package:reconhecimento/utils/date_utils.dart';

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
                            _buildMatriculaWithCodigoEmpresa(), 

                            SizedBox(height: 8),
                            _buildTextFieldRow(
                                "CTPS: ", _controller.ctpsController,
                                requiredLength: 11,
                                isNumber: true),
                            SizedBox(height: 8),
                            _buildTextFieldRow(
                                "NIS: ", _controller.nisController,
                                 requiredLength: 11,
                                isNumber: true),
                            SizedBox(height: 8),
                            _buildCargaHorariaRow("Carga Horaria Diaria: ",
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
                            
                            _buildTextFieldRow(
                                "Repita a Senha: ",  _controller.confirmarSenhaController,
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
                      if (_validarCampos() & validateDates(context)) {
                        await _controller.cadastrar(context);
                        setState(() {});
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
  bool hasMask = false,
}) {
  bool isTouched = false;
  bool showPassword = false; // Novo estado para controlar a visibilidade da senha

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
              obscureText: isPassword && !showPassword, // Alterado para considerar showPassword
              style: TextStyle(color: Colors.black),
              keyboardType:
                  isNumber ? TextInputType.number : TextInputType.text,
              inputFormatters: [
                if (requiredLength != null && !hasMask)
                  LengthLimitingTextInputFormatter(requiredLength),
                if (maxLength != null)
                  LengthLimitingTextInputFormatter(maxLength),
                if (isNumber && !hasMask)
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
                // Adicionando o ícone de visibilidade quando for campo de senha
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      )
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
      // Valida horas (00-23)
      var horas = text.substring(0, 2);
      if (int.parse(horas) > 23) {
        horas = '23';
      }
      formatted = horas;
      
      if (text.length >= 4) {
        // Valida minutos (00-59)
        var minutos = text.substring(2, 4);
        if (int.parse(minutos) > 59) {
          minutos = '59';
        }
        formatted += ':$minutos';
        
        if (text.length >= 6) {
          // Valida segundos (00-59)
          var segundos = text.substring(4, 6);
          if (int.parse(segundos) > 59) {
            segundos = '59';
          }
          formatted += ':$segundos';
        } else if (text.length > 4) {
          var segundos = text.substring(4);
          if (segundos.length == 1 && int.parse(segundos) > 5) {
            segundos = '5';
          }
          formatted += ':$segundos';
        }
      } else if (text.length > 2) {
        var minutos = text.substring(2);
        if (minutos.length == 1 && int.parse(minutos) > 5) {
          minutos = '5';
        }
        formatted += ':$minutos';
      }
    } else {
      formatted = text;
      // Valida primeiro dígito das horas (0-2)
      if (text.isNotEmpty && int.parse(text) > 2) {
        formatted = '2';
      }
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
            // Verifica o formato e os valores válidos
            if (!RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$').hasMatch(value)) {
              return 'Formato inválido (use HH:MM:SS entre 00:00:00 e 23:59:59)';
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
 bool validateDates(BuildContext context) {
  bool isValid = true;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Função para converter data no formato dd/MM/yyyy para DateTime
  DateTime? parseBrazilianDate(String dateText, String fieldName) {
    try {
      final parts = dateText.split('/');
      if (parts.length != 3) throw FormatException();
      
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      final date = DateTime(year, month, day);
      
      if (date.isAfter(today)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('A data de $fieldName não pode ser maior que a data atual')),
        );
        isValid = false;
      }
      return date;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Formato inválido na data de $fieldName. Use DD/MM/AAAA')),
      );
      isValid = false;
      return null;
    }
  }

  // Validação data de admissão
  final dataAdmissao = _controller.dataAdmissaoController.text.isNotEmpty
      ? parseBrazilianDate(_controller.dataAdmissaoController.text, 'admissão')
      : null;

  // Validação data de nascimento
  final dataNascimento = _controller.dataNascimentoController.text.isNotEmpty
      ? parseBrazilianDate(_controller.dataNascimentoController.text, 'nascimento')
      : null;

  // Validação admissão > nascimento
  if (dataAdmissao != null && dataNascimento != null) {
    if (dataAdmissao.isBefore(dataNascimento)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A data de admissão não pode ser antes da data de nascimento')),
      );
      isValid = false;
    }
  }

  return isValid;
}
bool _validarCampos() {
  bool isValid = true;
  
  // Validação do Nome
  if (_controller.nomeController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por favor, informe o nome completo')),
    );
    isValid = false;
  }
// Validação das senhas
if (_controller.senhaController.text.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Por favor, informe a senha')),
  );
  isValid = false;
} else if (_controller.confirmarSenhaController.text.isEmpty) { // Exemplo: mínimo 6 caracteres
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Por favir confirme a senha ')),
  );
  isValid = false;
} else if (_controller.senhaController.text != _controller.confirmarSenhaController.text) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('As senhas não coincidem')),
  );
  isValid = false;
}
  // Validação do CPF
  final cpfDigits = _controller.cpfController.text.replaceAll(RegExp(r'[^0-9]'), '');
  if (cpfDigits.length != 11) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CPF inválido! Deve conter 11 dígitos')),
    );
    isValid = false;
  }

  // Validação do RG
  final rgDigits = _controller.rgController.text.replaceAll(RegExp(r'[^0-9]'), '');
  if (rgDigits.length != 9) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('RG inválido! Deve conter 9 dígitos')),
    );
    isValid = false;
  }

  // Validação da Matrícula
  final matriculaDigits = _controller.matriculaController.text.replaceAll(RegExp(r'[^0-9]'), '');
  if (matriculaDigits.length != 10) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Matrícula inválida! Deve conter 10 dígitos')),
    );
    isValid = false;
  }

  // Validação de campos obrigatórios
  if (_controller.dataNascimentoController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por favor, informe a data de nascimento')),
    );
    isValid = false;
  }
   // Validação de campos obrigatórios
  if (_controller.cargaHorariaController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por favor, informe a data de nascimento')),
    );
    isValid = false;
  }

  if (_controller.cargoController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por favor, informe o cargo')),
    );
    isValid = false;
  }

 
  final cargadigits = _controller.cargaHorariaController.text.replaceAll(RegExp(r'[^0-9]'), '');
  if (cargadigits.length != 06) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por favor, preencha carga horaria no formato correto HH:MM:SS')),
    );
    isValid = false;
  }
  if (_controller.dataAdmissaoController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por favor, informe a data de admissão')),
    );
    isValid = false;
  }

  if (_controller.senhaController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por favor, crie uma senha')),
    );
    isValid = false;
  }

  final nisDigits = _controller.nisController.text.replaceAll(RegExp(r'[^0-9]'), '');
  if (nisDigits.length != 11) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('NIS inválido! Deve conter exatamente 11 dígitos')),
    );
    isValid = false;
  }
   final ctpsDigits = _controller.ctpsController.text.replaceAll(RegExp(r'[^0-9]'), '');
  if (ctpsDigits.length != 11) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CTPS inválido! Deve conter exatamente 11 dígitos')),
    );
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
