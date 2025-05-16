import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:reconhecimento/controller/registro_ponto_controller.dart';
import 'package:reconhecimento/service/registro_ponto_service.dart';

class RegistroPontoPage extends StatefulWidget {
  final String matricula;
  final String cnpj;

  const RegistroPontoPage({
    required this.matricula,
    required this.cnpj,
    Key? key,
  }) : super(key: key);

  @override
  _RegistroPontoPageState createState() => _RegistroPontoPageState();
}

class _RegistroPontoPageState extends State<RegistroPontoPage> {
  late RegistroPontoController _controller;
  bool _isLoading = false;
  bool _cameraInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = RegistroPontoController(
      matricula: widget.matricula,
      cnpj: widget.cnpj,
    );
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // 1. Busca as câmeras disponíveis
      final cameras = await availableCameras();

      // 2. Verifica se há câmeras disponíveis
      if (cameras.isEmpty) {
        throw Exception("Nenhuma câmera encontrada no dispositivo.");
      }

      // 3. Inicializa a câmera
      await _controller.initializeCamera(cameras);

      setState(() {
        _cameraInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erro ao acessar a câmera: $e";
      });
      _showSnackBar(_errorMessage!);
    }
  }

  Future<void> _capturarERegistrar() async {
    if (!_cameraInitialized || _isLoading) return;

    setState(() => _isLoading = true);

    try {
    await _controller.capturarFoto();
    final sucesso = await _controller.registrarPonto();
    
    if (sucesso) {
      _showSuccessDialog('Ponto registrado com sucesso!');
    }
  } on FacialRecognitionException catch (e) {
    _showFaceErrorDialog(
      e.message,
      isDetectionError: e.isFaceDetectionError,
      isMismatchError: e.isFaceMismatchError,
    );
  } on RegistrarPontoException catch (e) {
    _showErrorDialog(e.toString());
  } catch (e) {
    _showErrorDialog('Erro inesperado: ${e.toString()}');
  } finally {
    setState(() => _isLoading = false);
  }
}

void _showFaceErrorDialog(
  String message, {
  bool isDetectionError = false,
  bool isMismatchError = false,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        isDetectionError ? 'Rosto não detectado' : 'Rosto não corresponde',
        style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
      ),
      content: Text(
        message,
        style: TextStyle(color: Colors.red),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'OK',
            style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
          ),
        ),
      ],
    ),
  );
}

void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Erro', style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
      content: Text(message, style: TextStyle(color: Colors.red)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK', style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
        ),
      ],
    ),
  );
}


void _showSuccessDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Sucesso'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Fecha o dialog
            Navigator.pop(context); // Fecha a tela da câmera
          },
          child: Text('OK'),
        ),
      ],
    ),
  );
}



  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Registrar Ponto'),
    ),
    body: Stack(
      children: [
        // Exibe a câmera se estiver pronta, senão mostra erro ou loading
        if (_errorMessage != null)
          Center(
            child: Text(_errorMessage!, style: TextStyle(color: Colors.red)),
          )
        else if (!_cameraInitialized)
          Center(child: CircularProgressIndicator())
        else
          Positioned.fill( // Esta é a chave para preencher todo o espaço
            child: CameraPreview(_controller.cameraController),
          ),

        // Botão de registro (desabilitado se a câmera não estiver pronta)
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton(
              onPressed:
                  (_isLoading || !_cameraInitialized || _errorMessage != null)
                      ? null
                      : _capturarERegistrar,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('REGISTRAR PONTO'),
            ),
          ),
        ),
      ],
    ),
  );
}
}