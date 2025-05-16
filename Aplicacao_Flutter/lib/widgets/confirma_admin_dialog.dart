import 'package:flutter/material.dart';

class ConfirmarAdminDialog extends StatelessWidget {
  final String matricula;
  final Function onConfirm;

  const ConfirmarAdminDialog({
    required this.matricula,
    required this.onConfirm,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmar Administrador'),
      content: Text('Deseja realmente tornar o usuário com matrícula $matricula um administrador?'),
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