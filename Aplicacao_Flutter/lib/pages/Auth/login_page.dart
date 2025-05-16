import 'package:flutter/material.dart';
import 'package:reconhecimento/service/login_service.dart';
import 'package:reconhecimento/pages/Empresa/cadastro_empresa_page.dart';
import 'package:reconhecimento/pages/Colaborador/reset_senha_colaborador_page.dart';
import 'package:flutter/services.dart';

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
  final LoginService _loginService = LoginService();
  // Removemos os FocusNodes e usaremos o gerenciamento automático de foco

  @override
  void dispose() {
    matriculaController.dispose();
    senhaController.dispose();
    super.dispose();
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
      _loginService.loginEmpresa(matricula, senha, context);
    } else {
      _loginService.loginColaborador(matricula, senha, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 215, 221, 231),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
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
                          width: 180,
                          height: 180,
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
              const SizedBox(height: 30),
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
                  keyboardType: TextInputType.number,
                  maxLength: 14, // Limita a 14 caracteres
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly, // Aceita apenas números
                  ],
                  style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 30, 112, 243),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 30, 112, 243),
                      ),
                    ),
                    hintText: "ID do Usuario",
                    hintStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    prefixIcon: Icon(
                      Icons.person,
                      color: Color.fromARGB(255, 30, 112, 243),
                    ),
                    counterText: "", // Remove o contador de caracteres
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
                        color: Color.fromARGB(255, 30, 112, 243),
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 30, 112, 243),
                      ),
                    ),
                    hintText: "Senha",
                    hintStyle:
                        const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Color.fromARGB(255, 30, 112, 243),
                    ),
                    suffixIcon: InkWell(
                      onTap: () {
                        setState(() {
                          isObscureText = !isObscureText;
                        });
                      },
                      child: Icon(
                        isObscureText ? Icons.visibility_off : Icons.visibility,
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
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton(
                  onPressed: () {
                    _performLogin(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 30, 112, 243),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    "Entrar",
                    style: TextStyle(
                      
                      color: Colors.white,
                      fontSize: 16,
                      
                      fontWeight: FontWeight.bold,
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
    );
  }
}
