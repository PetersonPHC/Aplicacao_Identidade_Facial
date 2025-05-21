import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:reconhecimento/controller/atualizar_colaborador_controller.dart';

class AtualizarColaboradorPage extends StatefulWidget {
  final String cnpj;
  final String matricula;

  const AtualizarColaboradorPage({super.key, 
    required this.cnpj,
    required this.matricula,
  });

  @override
  State<AtualizarColaboradorPage> createState() =>
      _AtualizarColaboradorPageState();
}

class _AtualizarColaboradorPageState extends State<AtualizarColaboradorPage> {
  late AtualizarColaboradorController _controller;
  Uint8List? _imagemSelecionada;


  @override
  void initState() {
    super.initState();
    _controller = AtualizarColaboradorController(
      cnpj: widget.cnpj,
      matricula: widget.matricula,
    );
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      await _controller.carregarDadosColaborador();
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
        backgroundColor: const Color.fromARGB(2255, 148, 177, 255),
        appBar: AppBar(
          title: Text("Atualizar dados do Colaborador",
              style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 30, 112, 243),
        ),
        body: _controller.isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      _buildFormContainer(),
                      SizedBox(height: 10),
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
          _buildImageSelector(),
          SizedBox(height: 20),
          _buildTextFieldRow("Nome: ", _controller.nomeController,
              maxLength: 50),
          const SizedBox(height: 8),
          _buildTextFieldRow("CPF: ", _controller.cpfController,
              isNumber: true),
          SizedBox(height: 8),
          _buildDateFieldRow(
              "Data Nasc: ", _controller.dataNascimentoController),
          const SizedBox(height: 8),
          _buildTextFieldRow("RG: ", _controller.rgController),
          SizedBox(height: 8),
          _buildTextFieldRow("CTPS: ", _controller.ctpsController,
              isNumber: true),
          SizedBox(height: 8),
          _buildTextFieldRow("NIS: ", _controller.nisController,
              isNumber: true),
          SizedBox(height: 8),
          _buildCargaHorariaRow(
              "Carga Horaria: ", _controller.cargaHorariaController),
          SizedBox(height: 8),
          _buildTextFieldRow("Cargo: ", _controller.cargoController,
              maxLength: 50),
          SizedBox(height: 8),
          _buildDateFieldRow(
              "Data de Admissão: ", _controller.dataAdmissaoController),
        ],
      ),
    );
  }

  Widget _buildImageSelector() {
    return Row(
      children: [
        Expanded(child: Container()),
        Expanded(
          flex: 8,
          child: Column(
            children: [
              GestureDetector(
              onTap: () async {
  await _controller.selecionarImagem();
  if (mounted) {
    setState(() {
      _imagemSelecionada = _controller.imagemSelecionadaWeb;
    });
  }
},
  child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: _buildImageWidget(),
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Clique para adicionar uma imagem",
                style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
              ),
            ],
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }
Widget _buildImageWidget() {
  if (_imagemSelecionada != null) {
    return ClipOval(
      child: Image.memory(
        _imagemSelecionada!,
        fit: BoxFit.cover,
        width: 200,
        height: 200,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultIcon();
        },
      ),
    );
  }

  if (_controller.imagemBytes != null) {
    return ClipOval(
      child: Image.memory(
        _controller.imagemBytes!,
        fit: BoxFit.cover,
        width: 200,
        height: 200,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultIcon();
        },
      ),
    );
  }

  return _buildDefaultIcon();
}

  Widget _buildDefaultIcon() {
    return Icon(
      Icons.add_a_photo,
      color: Colors.black,
      size: 50,
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

  Widget _buildUpdateButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () async {
          try {
            await _controller.atualizar(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 3, 33, 255),
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
}
