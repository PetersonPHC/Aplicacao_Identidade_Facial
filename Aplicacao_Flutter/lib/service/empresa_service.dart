import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class EmpresaService {
  Future<bool> cadastrarEmpresa({
    required String nomeFantasia,
    required String cnpj,
    required String cep,
    required String cidade,
    required String bairro,
    required String logradouro,
    required String numero,
    required String complemento,
    required String UF,
    required String dataCriacao,
    required String senha,
    required String email,
    required BuildContext context,
  }) async {
    final senha = await _mostrarDialogoSenha(context);
    if (senha == null || senha.isEmpty) {
      throw Exception("Senha é obrigatória!");
    }

    final formattedDate = formatDateStringToIso8601WithMillis(dataCriacao);

    var body = {
      "CNPJ": cnpj,
      "NOMEFANTASIA": nomeFantasia,
      "CEP": int.parse(cep),
      "UF": UF,
      "CIDADE": cidade,
      "BAIRRO": bairro,
      "LOGRADOURO": logradouro,
      "NUMERO": int.parse(numero),
      "COMPLEMENTO": complemento,
      "EMAIL": email,
      "DATACRIACAO": formattedDate,
    };

    var response = await http.post(
      Uri.parse("http://localhost:3000/empresas"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      throw Exception("Erro ao cadastrar: ${response.body}");
    }

    if (response.statusCode != 201) {
      throw Exception('Falha ao cadastrar colaborador: ${response.body}');
    }

    // 3. Cadastro do usuário associado
    var responseUser = await http.post(
      Uri.parse("http://localhost:3000/usuarios/empresa"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body:
          jsonEncode({'USUARIO_ID': cnpj.trim(), 'SENHA': senha, 'ADM': true}),
    );

    if (responseUser.statusCode != 201) {
      throw Exception('Falha ao cadastrar usuário: ${responseUser.body}');
    }

    return true;
  }

  String formatDateStringToIso8601WithMillis(String dateStr) {
    DateTime date;

    if (dateStr.contains('-')) {
      final parts = dateStr.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      date = DateTime(year, month, day);
    } else {
      throw FormatException(
          'Formato de data inválido. Use DD/MM/YYYY ou YYYY-MM-DD.');
    }

    // 2. Formata como ISO 8601 com .000Z (UTC à meia-noite)
    final isoString = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}'
        'T00:00:00.000Z';

    return isoString;
  }

  Future<String?> _mostrarDialogoSenha(BuildContext context) async {
    final senhaController = TextEditingController();
    final confirmarSenhaController = TextEditingController();

    return await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: senhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'nova senha'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmarSenhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'repita a senha'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (senhaController.text == confirmarSenhaController.text) {
                      Navigator.pop(context, senhaController.text);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("As senhas não coincidem!")),
                      );
                    }
                  },
                  child: const Text('Confirmar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> buscarEmpresa(String cnpj) async {
    final url = Uri.parse("http://localhost:3000/empresas/$cnpj");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body); // Retorna todo o JSON
    } else if (response.statusCode == 404) {
      throw Exception('Empresa não encontrada');
    } else {
      throw Exception('Erro ao buscar empresa');
    }
  }

  Future<bool> atualizarEmpresa({
    required String cnpj,
    required String nomeFantasia,
    required String CEP,
    required String UF,
    required String cidade,
    required String bairro,
    required String logradouro,
    required String numero,
    required String complemento,
    required String email,
    required String dataCriacao,
  }) async {
    try {
      final formattedDate = formatDateStringToIso8601WithMillis(dataCriacao);
      final response = await http.put(
        Uri.parse("http://localhost:3000/empresas/$cnpj"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'NOMEFANTASIA': nomeFantasia,
          'CEP': int.parse(CEP),
          'UF': UF,
          'CIDADE': cidade,
          'BAIRRO': bairro,
          'LOGRADOURO': logradouro,
          'NUMERO': int.parse(numero),
          'COMPLEMENTO': complemento,
          'EMAIL': email,
          'DATACRIACAO': formattedDate,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Falha na atualização: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar empresa: $e');
    }
  }
}
