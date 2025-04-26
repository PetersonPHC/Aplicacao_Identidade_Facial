import 'package:image/image.dart' as img;
import 'dart:io';

class ImageUtils {
  static Future<File> compressImage(File file) async {
    final image = img.decodeImage(await file.readAsBytes());
    final resized = img.copyResize(image!, width: 800);
    final compressed = File(file.path)..writeAsBytesSync(img.encodeJpg(resized, quality: 85));
    return compressed;
  }
}