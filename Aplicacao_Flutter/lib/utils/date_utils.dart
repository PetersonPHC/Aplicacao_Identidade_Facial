import 'package:flutter/material.dart';

class dateUtils {
  static Future<DateTime?> selecionarData(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );
  }

  static String formatarDataParaISO(String data) {
    final partes = data.split('/');
    if (partes.length == 3) {
      return "${partes[2]}-${partes[1]}-${partes[0]}";
    }
    return data;
  }

  static String formatarDataParaExibicao(DateTime data) {
    return "${data.day.toString().padLeft(2, '0')}/"
        "${data.month.toString().padLeft(2, '0')}/"
        "${data.year}";
  }
 
 
  static String format(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 4) return input.substring(0, 5);
    
    if (digits.length > 2) {
      return '${digits.substring(0, 2)}:${digits.substring(2)}';
    }
    return digits;
  }
  
static String formatarCargaHoraria(String input) {
  try {
    // Remove possíveis espaços em branco
    input = input.trim();
    
    // Verifica se já está no formato HH:mm:ss
    if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(input)) {
      return input;
    }
    
    // Tenta converter de outros formatos
    if (input.contains(':')) {
      final parts = input.split(':');
      if (parts.length == 2) {
        return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}:00';
      }
    }
    
    // Se for apenas números, assume que são horas
    if (RegExp(r'^\d+$').hasMatch(input)) {
      final hours = int.tryParse(input) ?? 0;
      return '${hours.toString().padLeft(2, '0')}:00:00';
    }
    
    // Retorna um valor padrão se não conseguir parsear
    return '00:00:00';
  } catch (e) {
    return '00:00:00';
  }
}
  
}