import 'package:flutter/material.dart';

class ExclusaoDialog extends StatelessWidget {
  final String matricula;
  final Function() onConfirm;

  const ExclusaoDialog({
    required this.matricula,
    required this.onConfirm,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Excluir Colaborador"),
      content: Text("Deseja excluir o colaborador de matrícula $matricula?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancelar"),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          child: const Text("Excluir", style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    );
  }
}