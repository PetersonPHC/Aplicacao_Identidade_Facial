import 'package:flutter/material.dart';

class RetiraAdminDialog extends StatelessWidget {
  final String matricula;
  final Function onConfirm;

  const RetiraAdminDialog({
    required this.matricula,
    required this.onConfirm,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmar Administrador'),
      content: Text('Deseja realmente retirar o privilegio de administrador  do usuário com matrícula $matricula ?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}