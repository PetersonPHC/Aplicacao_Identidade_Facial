import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class EmpresaService {
  Future<bool> cadastrarEmpresa({
    required String nomeFantasia,
    required String cnpj,
    required String cep,
    required String estadoCidade,
    required String bairro,
    required String ruaAvenida,
    required String numero,
    required String complemento,
    required String responsavel,
    required String dataCriacao,
    required BuildContext context,
  }) async {
    final senha = await _mostrarDialogoSenha(context);
    if (senha == null || senha.isEmpty) {
      throw Exception("Senha é obrigatória!");
    }

    String? dataFormatada;
    if (dataCriacao.isNotEmpty) {
      try {
        List<String> partes = dataCriacao.split("/");
        if (partes.length == 3) {
          DateTime data = DateTime(
            int.parse(partes[2]),
            int.parse(partes[1]),
            int.parse(partes[0])
          );
          dataFormatada = DateFormat('yyyy-MM-dd').format(data);
        }
      } catch (e) {
        print("Erro ao formatar data: $e");
      }
    }

    var body = {
      "NomeFantasia": nomeFantasia,
      "CNPJ": cnpj,
      "CEP": cep,
      "EstadoCidade": estadoCidade,
      "Bairro": bairro,
      "RuaAvenida": ruaAvenida,
      "Numero": numero,
      "Complemento": complemento,
      "Responsavel": responsavel,
      "DataCriacao": dataFormatada,
      "IsAdm": true,
      "Senha": senha,
    };

    var response = await http.post(
      Uri.parse("http://localhost:3000/empresas"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      throw Exception("Erro ao cadastrar: ${response.body}");
    }

    return true;
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
                        const SnackBar(content: Text("As senhas não coincidem!")),
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
}