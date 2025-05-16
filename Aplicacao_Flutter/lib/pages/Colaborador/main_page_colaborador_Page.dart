import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reconhecimento/pages/Colaborador/Relacao_Ponto_Colaborador_Page.dart';
import 'package:reconhecimento/pages/Colaborador/perfil_page.dart';
import 'package:reconhecimento/pages/Colaborador/relacao_page.dart';

// import 'package:reconhecimento/pages/Colaborador/perfil_page.dart';
import 'package:reconhecimento/pages/RegistroPonto/registro_ponto_page.dart';
import 'package:reconhecimento/pages/Auth/login_page.dart';

//import 'package:reconhecimento/pages/PerfilPage.dart';

class MainPage extends StatefulWidget {
  final bool isAdm;
  final String cnpjEmpresa;
  final String matricula;

  const MainPage(
      {super.key,
      required this.isAdm,
      required  this.cnpjEmpresa,
      required  this.matricula});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 215, 221, 231),
        appBar: AppBar(
          title: Text(
            "Home",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 30, 112, 243),
        ),
        drawer: Drawer(
          child: Column(
            children: [
              Container(
                color: const Color.fromARGB(255, 30, 112, 243),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Menu",
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Color.fromARGB(255, 215, 221, 231),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.home,
                            color: Color.fromARGB(255, 0, 0, 0)),
                        title: Text(
                          "Home",
                          style: GoogleFonts.roboto(
                              color: const Color.fromARGB(255, 0, 0, 0)),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => MainPage(
                                    isAdm: widget.isAdm,
                                    cnpjEmpresa: widget.cnpjEmpresa,
                                    matricula: widget.matricula)),
                          );
                        },
                      ),
                      SizedBox(height: 15),
                      ListTile(
                        leading: const Icon(Icons.access_time_filled_sharp,
                            color: Color.fromARGB(255, 0, 0, 0)),
                        title: Text(
                          "Registre seu ponto",
                          style: GoogleFonts.roboto(
                              color: const Color.fromARGB(255, 0, 0, 0)),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegistroPontoPage(
                                cnpj: widget.cnpjEmpresa,
                                matricula: widget.matricula,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 15),
                      ListTile(
                        leading: const Icon(Icons.calendar_month_outlined,
                            color: Color.fromARGB(255, 0, 0, 0)),
                        title: Text(
                          "Relação de Registros",
                          style: GoogleFonts.roboto(
                              color: const Color.fromARGB(255, 0, 0, 0)),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => RelacaoPontoPage(
                                cnpj: widget.cnpjEmpresa,
                                matricula: widget.matricula,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 15),
                      ListTile(
                        leading: const Icon(Icons.supervised_user_circle,
                            color: Color.fromARGB(255, 0, 0, 0)),
                        title: Text(
                          "Perfil",
                          style: GoogleFonts.roboto(
                              color: const Color.fromARGB(255, 0, 0, 0)),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PerfilPage(
                                  cnpj: widget.cnpjEmpresa,
                                  matricula: widget.matricula),
                            ),
                          );
                        },
                      ),
                      if (widget.isAdm) SizedBox(height: 15),
                      if (widget.isAdm)
                        ListTile(
                          leading: const Icon(Icons.people,
                              color: Color.fromARGB(255, 0, 0, 0)),
                          title: Text(
                            "Relacao de colaboradores",
                            style: GoogleFonts.roboto(
                                color: const Color.fromARGB(255, 0, 0, 0)),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    RelacaoPage(cnpj: widget.cnpjEmpresa),
                              ),
                            );
                          },
                        ),
                      SizedBox(height: 15),
                      ListTile(
                        leading: const Icon(Icons.exit_to_app_sharp,
                            color: Color.fromARGB(255, 0, 0, 0)),
                        title: Text(
                          "Sair",
                          style: GoogleFonts.roboto(
                              color: const Color.fromARGB(255, 0, 0, 0)),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(height: 20),
              Text(
                "IDENTIDADE-FACIAL o seu sistema de ponto",
                style: GoogleFonts.roboto(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Column(
                children: [
                  Container(
                    width: double.infinity,
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
                          color: Color.fromRGBO(2, 44, 79,
                              0.8), // Using RGBO constructor which takes opacity directly
                          offset: const Offset(0, 6),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Registre seu ponto",
                              style: GoogleFonts.roboto(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.access_time_filled_sharp,
                              color: Color.fromARGB(255, 29, 80, 163),
                              size: 22.0,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Transforme sua jornada de trabalho em algo simples e ágil com IDENTIDADE-FACIAL",
                          style: GoogleFonts.roboto(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 29, 80, 163),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 24.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegistroPontoPage(
                                  cnpj: widget.cnpjEmpresa,
                                  matricula: widget.matricula,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "Registrar Ponto",
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
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
                          color: Color.fromRGBO(2, 44, 79,
                              0.8), // Using RGBO constructor which takes opacity directly
                          offset: const Offset(0, 6),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Histórico de ponto",
                              style: GoogleFonts.roboto(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.edit_calendar_rounded,
                              color: Color.fromARGB(255, 29, 80, 163),
                              size: 22.0,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "IDENTIDADE-FACIAL, a ferramenta que mudará sua concepção de registro de ponto",
                          style: GoogleFonts.roboto(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 29, 80, 163),
                            foregroundColor: Color.fromARGB(255, 215, 221, 231),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 24.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RelacaoPontoPage(
                                  cnpj: widget.cnpjEmpresa,
                                  matricula: widget.matricula,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "Histórico de Ponto",
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
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
                          color: Color.fromRGBO(2, 44, 79,
                              0.8), // Using RGBO constructor which takes opacity directly
                          offset: const Offset(0, 6),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Acesse seu perfil",
                              style: GoogleFonts.roboto(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.access_time_filled_sharp,
                              color: Color.fromARGB(255, 29, 80, 163),
                              size: 22.0,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Veja e confira seus dados no IDENTIDADE-FACIAL",
                          style: GoogleFonts.roboto(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 29, 80, 163),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 24.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PerfilPage(
                                    cnpj: widget.cnpjEmpresa,
                                    matricula: widget.matricula),
                              ),
                            );
                          },
                          child: Text(
                            "Perfil",
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
