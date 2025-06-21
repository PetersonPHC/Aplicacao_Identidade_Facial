import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class LocationVerifier {
  static Future<Map<String, dynamic>> obterLocalizacao() async {
    try {
      print("Verificando permissões de localização...");
      bool permissaoConcedida = await _verificarPermissoes();

      if (!permissaoConcedida) {
        print("Permissão de localização não concedida.");
        return await _getFallbackLocation();
      }

      bool gpsAtivo = await Geolocator.isLocationServiceEnabled();
      if (!gpsAtivo) {
        print("Serviço de localização está desativado.");
        return await _getFallbackLocation();
      }

      print("Obtendo localização atual...");
      Position position = await _getPositionWithTimeout();
      print("Localização obtida: ${position.latitude}, ${position.longitude}");

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      print("Erro ao obter localização: $e");
      return await _getFallbackLocation();
    }
  }

  static Future<Position> _getPositionWithTimeout() async {
    try {
      if (kIsWeb) {
        return await Geolocator.getCurrentPosition(
          locationSettings: WebSettings(
            accuracy: LocationAccuracy.best,
            timeLimit: Duration(seconds: 10),
          ),
        ).timeout(Duration(seconds: 12));
      } else {
        return await Geolocator.getCurrentPosition(
          locationSettings: AndroidSettings(
            accuracy: LocationAccuracy.best,
            timeLimit: Duration(seconds: 10),
          ),
        ).timeout(Duration(seconds: 12));
      }
    } catch (e) {
      print("Erro ao tentar obter posição precisa: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> _getFallbackLocation() async {
    print("Usando localização de fallback...");
    try {
      final fallbackEndereco = 'Brasil';
      final encoded = Uri.encodeComponent(fallbackEndereco);
      final url =
          'https://nominatim.openstreetmap.org/search?q=$encoded&format=json';

      final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;

        if (data.isNotEmpty) {
          final first = data.first;
          print("Fallback location: ${first['lat']}, ${first['lon']}");
          return {
            'latitude': double.parse(first['lat']),
            'longitude': double.parse(first['lon']),
          };
        }
      }
    } catch (e) {
      print('Erro no fallback location: $e');
    }

    return {'latitude': 'N/A', 'longitude': 'N/A'};
  }

  static Future<bool> _verificarPermissoes() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }
}
