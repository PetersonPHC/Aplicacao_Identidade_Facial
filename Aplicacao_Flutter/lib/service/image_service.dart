import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageSelectionResult {
  final File? fileImage;
  final Uint8List? webImage;

  ImageSelectionResult({this.fileImage, this.webImage});
}

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<ImageSelectionResult?> selecionarImagem() async {
    try {
      final XFile? imagem = await _picker.pickImage(source: ImageSource.gallery);

      if (imagem != null) {
        if (kIsWeb) {
          final bytes = await imagem.readAsBytes();
          return ImageSelectionResult(webImage: bytes);
        } else {
          File imagemFile = File(imagem.path);
          File? imagemComprimida = await _comprimirImagem(imagemFile);
          return ImageSelectionResult(fileImage: imagemComprimida ?? imagemFile);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao selecionar imagem: $e');
    }
  }

  Future<File?> _comprimirImagem(File file) async {
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        '${file.path}_comprimida.jpg',
        quality: 50,
        format: CompressFormat.jpeg,
      );
      return result != null ? File(result.path) : null;
    } catch (e) {
      return null;
    }
  }
}