import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class LocationVerifier {
static Future<Map<String, dynamic>> obterLocalizacao() async {
  Map<String, dynamic> localizacao = {'latitude': 'NA', 'longitude': 'NA'};

  try {
    // 1. Tenta obter localização real via GPS
    Position currentPosition = kIsWeb
        ? await _getWebPosition()
        : await _getCurrentPosition();

    localizacao = {
      'latitude': currentPosition.latitude,
      'longitude': currentPosition.longitude,
    };
  } catch (_) {
    try {
      // 2. Se falhar, tenta estimar localização por endereço genérico
      final fallbackEndereco = 'Brasil'; // ou algo como 'São Paulo, SP'
      final encoded = Uri.encodeComponent(fallbackEndereco);
      final url = 'https://nominatim.openstreetmap.org/search?q=$encoded&format=json';

      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body) as List;

      if (data.isNotEmpty) {
        final first = data.first;
        localizacao = {
          'latitude': double.parse(first['lat']),
          'longitude': double.parse(first['lon']),
        };
      }
    } catch (_) {
      // 3. Se tudo falhar, permanece como 'NA'
      localizacao = {'latitude': 'NA', 'longitude': 'NA'};
    }
  }

  return localizacao;
}

  // Geolocalização no navegador (Web)
  static Future<Position> _getWebPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      timeLimit: Duration(seconds: 20),
    );
  }

  // Geolocalização em dispositivos móveis
  static Future<Position> _getCurrentPosition() async {
    // Verifica permissões
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception('Ative o GPS nas configurações');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse) {
        throw Exception('Permissão negada');
      }
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      timeLimit: Duration(seconds: 20),
    );
  }
}