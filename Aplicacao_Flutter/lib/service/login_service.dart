import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:reconhecimento/pages/Colaborador/main_page_colaborador_Page.dart';

import 'package:reconhecimento/pages/Empresa/main_page_empresa.dart';
class LoginService {


  Future<void> loginColaborador(
      String login, String senha, BuildContext context) async {
    final url = Uri.parse("http://localhost:3000/loginColaborador");
    final body = {'USUARIO_ID': login, 'SENHA': senha};


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
          final String cnpjEmpresa =
              colaborador['CNPJ_EMPRESA']?.toString() ?? '';
          final String matricula =
              colaborador['MATRICULA']?.toString() ?? login;
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
            const SnackBar(
                content:
                    Text("Credenciais inválidas ou usuário não encontrado")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Senha ou Usuario invalido")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro durante a requisição: ${e.toString()}")),
      );
    }
  }

  Future<void> loginEmpresa(
      String cnpj, String senha, BuildContext context) async {
    final url = Uri.parse("http://localhost:3000/loginEmpresa");
    final body = {'USUARIO_ID': cnpj, 'SENHA': senha};


    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

   

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Verificação mais robusta dos dados recebidos
        if (data['USUARIO_ID'] != null && data['SENHA'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login efetuado com sucesso")),
          );

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MainPageEmpresa(
                isAdm: data['ADM'] ??
                    false, // Fornece um valor padrão caso seja null
                cnpj: data['USUARIO_ID'].toString(), // Garante que é uma String
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Dados de login inválidos ou incompletos")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Usuario ou senha errados")),
        );
      }
    } catch (e) {
     
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro durante a requisição")),
      );
    }
  }


}
