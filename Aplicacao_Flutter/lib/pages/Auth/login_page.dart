import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:reconhecimento/pages/Colaborador/Main_Page_Colaborador_Page.dart';
import 'package:reconhecimento/pages/Empresa/main_page_empresa.dart';
import 'package:reconhecimento/pages/Empresa/cadastro_empresa_page.dart';
import 'package:reconhecimento/pages/Colaborador/reset_senha_colaborador_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool IsAdm = false;
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController matriculaController = TextEditingController();
  bool isObscureText = true;
  

  // Removemos os FocusNodes e usaremos o gerenciamento automático de foco

  @override
  void dispose() {
    matriculaController.dispose();
    senhaController.dispose();
    super.dispose();
  }
  Future<void> loginColaborador(String login, String senha, BuildContext context) async {
  final url = Uri.parse("http://localhost:3000/loginColaborador");
  final body = {'USUARIO_ID': login, 'SENHA': senha};

  print("Corpo da requisição de login (colaborador): ${jsonEncode(body)}");

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );


    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Considerando que o login é bem-sucedido se recebermos os dados do colaborador
      if (data['colaborador'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login efetuado com sucesso")),
        );
        
        // Extraindo os dados da estrutura correta
        final colaborador = data['colaborador'];
        final String cnpjEmpresa = colaborador['CNPJ_EMPRESA']?.toString() ?? '';
        final String matricula = colaborador['MATRICULA']?.toString() ?? login;
        final bool isAdm = data['ADM'] ?? false;
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainPage(
              cnpjEmpresa: cnpjEmpresa,
              matricula: matricula,
              isAdm: isAdm,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Credenciais inválidas ou usuário não encontrado")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro no servidor")),
      );
    }
  } catch (e) {
    print("Erro durante a requisição (colaborador): $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erro durante a requisição: ${e.toString()}")),
    );
  }
}
 Future<void> loginEmpresa(String cnpj, String senha, BuildContext context) async {
  final url = Uri.parse("http://localhost:3000/loginEmpresa");
  final body = {'cnpj': cnpj, 'senha': senha};

  print("Corpo da requisição de login (empresa): ${jsonEncode(body)}");

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print("Resposta do servidor (empresa): ${response.statusCode}, ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Verificação mais robusta dos dados recebidos
      if (data['CNPJ_EMPRESA'] != null && data['ADMIN'] != null && data['empresa'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login efetuado com sucesso")),
        );
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainPageEmpresa(
              isAdm: data['ADMIN'] ?? false, // Fornece um valor padrão caso seja null
              cnpj: data['CNPJ_EMPRESA'].toString(), // Garante que é uma String
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dados de login inválidos ou incompletos")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro no servidor: ${response.statusCode}")),
      );
    }
  } catch (e) {
    print("Erro durante a requisição (empresa): $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Erro durante a requisição")),
    );
  }
}
 

  void _performLogin(BuildContext context) {
    final matricula = matriculaController.text.trim();
    final senha = senhaController.text.trim();

    if (matricula.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Matrícula e senha são obrigatórios!")),
      );
      return;
    }

    if (matricula.length == 14) {
      loginEmpresa(matricula, senha, context);
    } else {
      loginColaborador(matricula, senha, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 215, 221, 231),
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Row(
                  children: [
                    Expanded(child: Container()),
                    Expanded(
                      flex: 8,
                      child: Column(
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            child: Image.asset(
                              'assets/1231099.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: Container()),
                  ],
                ),
                const Text(
                  "IDENTIDADE-FACIAL",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(255, 0, 0, 0)),
                ),
                const SizedBox(height: 50),
                const Text(
                  "LOGIN",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0)),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: matriculaController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 3, 33, 255),
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 3, 33, 255),
                        ),
                      ),
                      hintText: "Matricula",
                      hintStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      prefixIcon: Icon(
                        Icons.person,
                        color: Color.fromARGB(255, 3, 33, 255),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: senhaController,
                    obscureText: isObscureText,
                    style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 3, 33, 255),
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 3, 33, 255),
                        ),
                      ),
                      hintText: "Senha",
                      hintStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Color.fromARGB(255, 3, 33, 255),
                      ),
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            isObscureText = !isObscureText;
                          });
                        },
                        child: Icon(
                          isObscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      _performLogin(context);
                    },
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      _performLogin(context);
                    },
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      backgroundColor: WidgetStateProperty.all(
                        const Color.fromARGB(255, 3, 33, 255),
                      ),
                    ),
                    child: const Text(
                      "Entrar",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const Resetpage(),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    alignment: Alignment.center,
                    child: const Text(
                      "Esqueci minha senha",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 0, 0),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CadastroEmpresaPage(),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    alignment: Alignment.center,
                    child: const Text(
                      "Contrate nosso serviços",
                      style: TextStyle(
                        color: Color.fromARGB(223, 0, 0, 0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}