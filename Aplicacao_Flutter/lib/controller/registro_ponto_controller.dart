import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import 'package:reconhecimento/service/registro_ponto_service.dart';

class RegistroPontoController {
  final String matricula;
  final String cnpj;
  final RegistroPontoService _service = RegistroPontoService();

  RegistroPontoController({
    required this.matricula,
    required this.cnpj,
  });

  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  Uint8List? _fotoCapturada;

  CameraController get cameraController => _cameraController;
  bool get isCameraInitialized => _isCameraInitialized;
  Uint8List? get fotoCapturada => _fotoCapturada;

  Future<void> initializeCamera(List<CameraDescription> cameras) async {
    try {
      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController.initialize();
      _isCameraInitialized = true;
    } catch (e) {
      throw Exception('Erro ao inicializar câmera: $e');
    }
  }

  Future<void> capturarFoto() async {
    if (!_isCameraInitialized) {
      throw Exception('Câmera não inicializada');
    }

    try {
      final foto = await _cameraController.takePicture();
      final bytes = await foto.readAsBytes();
      _fotoCapturada = bytes;
    } catch (e) {
      throw Exception('Erro ao capturar foto: $e');
    }
  }

Future<bool> registrarPonto() async {
  if (_fotoCapturada == null) {
    throw RegistrarPontoException('Nenhuma foto foi capturada');
  }

  final dataHoraAtual = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
/*
 try {
      final isNear = await LocationVerifier.isNearCompany(cnpj);
      if (!isNear) {
        throw RegistrarPontoException(
          'Você não está próximo o suficiente da empresa (mínimo 10 metros). '
          'Por favor, aproxime-se do local para registrar o ponto.'
        );
      }
    } catch (e) {
      // Transforma qualquer erro de localização em RegistrarPontoException
      throw RegistrarPontoException(e.toString());
    }

*/

  try {
    return await _service.registrarPonto(
      matricula: matricula,
      cnpj: cnpj,
      imagem: _fotoCapturada!,
      dataHora: dataHoraAtual,
    );
  } on FacialRecognitionException catch (e) {
   
    throw e;
  } catch (e) {
    throw RegistrarPontoException('Erro ao registrar ponto: $e');
  }
}


  Future<void> dispose() async {
    if (_isCameraInitialized) {
      await _cameraController.dispose();
      _isCameraInitialized = false;
    }
  }
  
 Future<Map<String, dynamic>> buscarRegistrosPonto({
  required String cnpjEmpresa,
  required String matricula,
  required DateTime data,
}) async {
  try {
    final registros = await _service.buscarRegistrosPonto(
      cnpjEmpresa: cnpjEmpresa,
      matricula: matricula,
      data: data,
    );
    
    final horarios = registros
        .map((r) => DateTime.parse(r['DATA_PONTO'] as String))
        .toList();

    horarios.sort();

    // Modificado para incluir os segundos
    final horariosFormatados = horarios
        .map((h) => '${h.hour.toString().padLeft(2, '0')}:${h.minute.toString().padLeft(2, '0')}:${h.second.toString().padLeft(2, '0')}')
        .toList();

    Duration total = Duration();
    for (int i = 0; i < horarios.length; i += 2) {
      if (i + 1 < horarios.length) {
        final entrada = horarios[i];
        final saida = horarios[i + 1];
        total += saida.difference(entrada);
      }
    }

    final horas = total.inHours;
    final minutos = total.inMinutes.remainder(60);
    final tempoFormatado = '${horas.toString()}:${minutos.toString().padLeft(2, '0')} HR';

    return {
      'pontos': horariosFormatados,
      'tempo_trabalhado': tempoFormatado,
      'total_minutos': total.inMinutes,
      'total_registros': registros.length,
    };

  } catch (e) {
    throw Exception('Erro ao buscar registros: ${e.toString()}');
  }
}

  Future<bool> adicionarRegistroPonto({
    required BuildContext context,
    required String dataPonto,
  }) async {
    final result = await _service.incluirRegistroPonto(
      matricula: matricula,
      cnpjEmpresa: cnpj,
      dataPonto: dataPonto,
    );

    if (result['success']) {
      _showSuccessDialog(context, 'Registro adicionado com sucesso!');
      return true;
    } else {
      _showErrorDialog(context, result['error']);
      return false;
    }
  }

  Future<bool> removerRegistroPonto({
    required BuildContext context,
    required String dataPonto,
  }) async {
    final result = await _service.removerRegistroPonto(
      matricula: matricula,
      cnpjEmpresa: cnpj,
      dataPonto: dataPonto,
    );

    if (result['success']) {
      _showSuccessDialog(context, 'Registro removido com sucesso!');
      return true;
    } else {
      _showErrorDialog(context, result['error']);
      return false;
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}