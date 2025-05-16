import 'package:flutter/material.dart';
import 'package:reconhecimento/my_app.dart';

import 'package:intl/date_symbol_data_local.dart'; // Adicione esta importação


void main() async {  // Adicione 'async' aqui
  // Adicione estas duas linhas:
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  
  runApp(const MyApp());
}