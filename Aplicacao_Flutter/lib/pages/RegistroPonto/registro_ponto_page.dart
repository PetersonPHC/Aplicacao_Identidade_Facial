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
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;

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
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        throw Exception("Nenhuma câmera encontrada no dispositivo.");
      }

      await _controller.initializeCamera(_cameras, _currentCameraIndex);

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

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2) return;

    setState(() {
      _cameraInitialized = false;
    });

    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;

    try {
      await _controller.switchCamera(_cameras, _currentCameraIndex);
      setState(() {
        _cameraInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erro ao alternar câmera: $e";
        _cameraInitialized = false;
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
        content: Text(message, style: TextStyle(color: Colors.red)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK',
                style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erro',
            style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
        content: Text(message, style: TextStyle(color: Colors.red)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK',
                style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
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
              Navigator.pop(context);
              Navigator.pop(context);
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
            Positioned.fill(
              child: CameraPreview(_controller.cameraController),
            ),

          // Botão para alternar câmera (se houver mais de uma)
          if (_cameras.length > 1)
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: IconButton(
                    icon:
                        Icon(Icons.cameraswitch, size: 36, color: Colors.white),
                    onPressed: _toggleCamera,
                  ),
                ),
              ),
            ),

          // Botão de registro
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
                  backgroundColor: Colors.blue, // Cor de fundo do botão
                  disabledBackgroundColor:
                      Colors.grey, // Cor quando desabilitado
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'REGISTRAR PONTO',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
