import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmacaoDialog extends StatelessWidget {
  final Function() onConfirm;

  const ConfirmacaoDialog({required this.onConfirm, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      title: Text("Cancelar plano",
          style: GoogleFonts.roboto(
            color: const Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,
          )),
      content: Text("Deseja mesmo cancelar esse plano?",
          style: GoogleFonts.roboto(
            color: const Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,
          )),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Voltar",
              style: GoogleFonts.roboto(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
              )),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          child: const Text(
            "Cancelar Plano",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}