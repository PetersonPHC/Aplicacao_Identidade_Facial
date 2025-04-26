import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reconhecimento/controller/perfil_controller.dart';
import 'package:reconhecimento/widgets/termos_dialog.dart';

class PerfilPage extends StatefulWidget {
  final String matricula;
  final String cnpj;

  const PerfilPage({
    required this.matricula,
    required this.cnpj,
    Key? key,
  }) : super(key: key);

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  late PerfilController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PerfilController(
      matricula: widget.matricula,
      cnpj: widget.cnpj,
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
        backgroundColor: const Color.fromARGB(255, 148, 177, 255),
        appBar: AppBar(
          title: const Text("Perfil", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 30, 112, 243),
        ),
        body: _controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      _buildProfileCard(),
                      _buildTermsCard(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 215, 221, 231),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color.fromARGB(255, 0, 22, 57),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 22, 57).withOpacity(0.8),
            offset: const Offset(0, 6),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileImage(),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.emoji_people_rounded, "Nome:", _controller.nome),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.today, "Data de Nascimento:", _controller.dataNascimento),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.wallet_sharp, "CPF:", _controller.cpf),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.featured_play_list_sharp, "RG:", _controller.rg),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.view_timeline, "CTPS:", _controller.ctps),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.badge_rounded, "NIS:", _controller.nis),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.receipt, "Matricula:", _controller.matriculaColab),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.diversity_3_sharp, "Cargo:", _controller.cargo),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.calendar_today_outlined, "Data de Admissão:", _controller.dataAdmissao),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Row(
      children: [
        Expanded(child: Container()),
        Expanded(
          flex: 8,
          child: Column(
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 5,
                  ),
                ),
                child: ClipOval(
                  child: _controller.imagemBytes != null
                      ? Image.memory(
                          _controller.imagemBytes!,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/user.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: const Color.fromARGB(255, 29, 80, 163),
          size: 20.0,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.roboto(
            color: const Color.fromARGB(255, 0, 0, 0),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.roboto(
              color: const Color.fromARGB(255, 0, 0, 0),
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCard() {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 215, 221, 231),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color.fromARGB(255, 0, 22, 57),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 22, 57).withOpacity(0.8),
            offset: const Offset(0, 6),
            blurRadius: 15,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.description, color: Color.fromARGB(255, 0, 0, 0)),
          const SizedBox(width: 8.0),
          GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (context) => const TermosDialog(),
            ),
            child: Text(
              "Termos de Uso",
              style: GoogleFonts.roboto(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}