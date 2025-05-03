import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:reconhecimento/controller/registro_ponto_controller';

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
        _showSnackBar('Ponto registrado com sucesso!');
        Navigator.pop(context);
      } else {
        _showSnackBar('Falha ao registrar ponto');
      }
    } catch (e) {
      _showSnackBar('Erro: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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
                child:
                    Text(_errorMessage!, style: TextStyle(color: Colors.red)))
          else if (!_cameraInitialized)
            Center(child: CircularProgressIndicator())
          else
            CameraPreview(_controller.cameraController),

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
