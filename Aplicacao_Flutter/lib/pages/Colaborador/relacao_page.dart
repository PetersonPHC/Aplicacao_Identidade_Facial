import 'package:flutter/material.dart';
import 'package:reconhecimento/pages/Colaborador/relacao_ponto_colaborador_page.dart';
import 'package:reconhecimento/pages/colaborador/atualizar_colaborador_page.dart';
import 'package:reconhecimento/pages/colaborador/perfil_page.dart';
import 'package:reconhecimento/widgets/colaborador_card.dart';
import 'package:reconhecimento/widgets/exclusao_dialog.dart';
import 'package:reconhecimento/widgets/reset_senha_dialog.dart';
import 'package:reconhecimento/controller/relacao_controller.dart';

class RelacaoPage extends StatefulWidget {
  final String cnpj;
  
  const RelacaoPage({required this.cnpj, Key? key}) : super(key: key);

  @override
  State<RelacaoPage> createState() => _RelacaoPageState();
}

class _RelacaoPageState extends State<RelacaoPage> {
  final RelacaoController _controller = RelacaoController();

  @override
  void initState() {
    super.initState();
    _carregarColaboradores();
  }

   Future<void> _carregarColaboradores() async {
    try {
      // Passa o CNPJ que veio como parâmetro para a página
      await _controller.fetchColaboradores(cnpj: widget.cnpj);
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  void _redirecionarPonto(String matricula, String cnpj) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => relacaoPontoPage( matricula: matricula, cnpj: cnpj),
      ),
    );
  }

  void _redirecionarPerfil(String matricula, String cnpj) {
    Navigator.push(
     context,
    MaterialPageRoute(
    builder: (context) => PerfilPage(matricula: matricula, cnpj: cnpj),
      ),
    );
  }

  void _redirecionarCadastro(String matricula, String cnpj) {
    
    print('DADOS FINAL METODO ' '$matricula' '$cnpj' );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AtualizarColaboradorPage(
          matricula: matricula, 
          cnpj: cnpj,
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, Map<String, dynamic> colaborador) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        switch (value) {
          case 'excluir':
            showDialog(
              context: context,
              builder: (context) => ExclusaoDialog(
                matricula: colaborador['matricula'],
                onConfirm: () => _controller.excluirColaborador(
                  
                  colaborador['cnpj'],
                  colaborador['matricula'], 
                  context,
                  mounted,
                ).then((_) => _carregarColaboradores()),
              ),
            );
            break;
          case 'reset_de_senha':
            showModalBottomSheet(
              context: context,
              builder: (context) => ResetSenhaDialog(
                
                matricula: colaborador['matricula'],
                onConfirm: (novaSenha) => _controller.resetarSenha(
                  colaborador['cnpj'],
                  colaborador['matricula'], 
                  novaSenha, 
                  context,
                ),
              ),
            );
            break;
          case 'Relacao_Ponto':
            _redirecionarPonto(colaborador['matricula'], colaborador['cnpj']);
            break;
          case 'Alterar_Dados':
            _redirecionarCadastro(colaborador['matricula'], colaborador['cnpj']);
            break;
          case 'Perfil_Colaborador':
            _redirecionarPerfil(colaborador['matricula'], colaborador['cnpj']);
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return const [
          PopupMenuItem(value: 'excluir', child: Text("Excluir Colaborador")),
          PopupMenuItem(value: 'reset_de_senha', child: Text("Configurar nova senha")),
          PopupMenuItem(value: 'Relacao_Ponto', child: Text("Relação de ponto")),
          PopupMenuItem(value: 'Alterar_Dados', child: Text("Alterar dados")),
          PopupMenuItem(value: 'Perfil_Colaborador', child: Text("Perfil do colaborador")),
        ];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 178, 205, 220),
      appBar: AppBar(
        title: const Text(
          "Relação de colaboradores",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 30, 112, 243),
      ),
      body: _controller.loading
          ? const Center(child: CircularProgressIndicator())
          : _controller.colaboradores.isEmpty
              ? const Center(
                  child: Text(
                    "Nenhum colaborador cadastrado ainda.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _controller.colaboradores.length,
                  itemBuilder: (context, index) {
                    final colaborador = _controller.colaboradores[index];
                    return ColaboradorCard(
                      colaborador: colaborador,
                      popupMenu: _buildPopupMenu(context, colaborador),
                    );
                  },
                ),
    );
  }
}