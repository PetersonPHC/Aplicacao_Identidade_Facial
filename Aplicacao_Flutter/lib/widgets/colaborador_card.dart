import 'package:flutter/material.dart';
class ColaboradorCard extends StatelessWidget {
  final Map<String, dynamic> colaborador;
  final Widget popupMenu;

  const ColaboradorCard({
    required this.colaborador,
    required this.popupMenu,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text("Nome: ${colaborador['nome']}"),
        subtitle: Text(
          "Matrícula: ${colaborador['matricula']}\n"
          "Carga Horária: ${colaborador['cargaHoraria']}\n"
          "Saldo de Horas: ${colaborador['saldoHoras'].toStringAsFixed(2)} horas"
        ),
        trailing: popupMenu,
      ),
    );
  }
}