import 'package:flutter/material.dart';

class ResetSenhaDialog extends StatefulWidget {
  final String matricula;
  final Function(String) onConfirm;

  const ResetSenhaDialog({
    required this.matricula,
    required this.onConfirm,
    Key? key,
  }) : super(key: key);

  @override
  _ResetSenhaDialogState createState() => _ResetSenhaDialogState();
}

class _ResetSenhaDialogState extends State<ResetSenhaDialog> {
  final TextEditingController novaSenhaController = TextEditingController();
  final TextEditingController confirmarSenhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Resetar senha para matrícula: ${widget.matricula}"),
          const SizedBox(height: 16),
          TextField(
            controller: novaSenhaController,
            decoration: const InputDecoration(labelText: 'Nova senha'),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: confirmarSenhaController,
            decoration: const InputDecoration(labelText: 'Repita a senha'),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (novaSenhaController.text != confirmarSenhaController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('As senhas não coincidem!')),
                );
                return;
              }
              widget.onConfirm(novaSenhaController.text);
              Navigator.pop(context);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    novaSenhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }
}