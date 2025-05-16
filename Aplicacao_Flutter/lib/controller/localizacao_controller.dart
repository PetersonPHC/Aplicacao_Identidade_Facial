import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class LocationVerifier {
  static const String _baseUrl = 'http://localhost:3000'; 

  // Método principal para verificar proximidade
  static Future<bool> isNearCompany(String cnpj) async {
  try {

    // 1. Obter dados da empresa
    final companyData = await _getCompanyData(cnpj);
    final fullAddress = _buildFullAddress(companyData);
    

    // 2. Geocodificar endereço da empresa
    final nominatimResult = await _getNominatimResult(fullAddress);
    final companyLat = double.parse(nominatimResult['lat']);
    final companyLon = double.parse(nominatimResult['lon']);
    

    // 3. Obter localização atual
    final Position currentPosition = kIsWeb 
        ? await _getWebPosition() 
        : await _getCurrentPosition();
    

    // 4. Calcular distância com tolerância
    const double toleranceMeters = 1000; // 1km de tolerância
    final distance = Geolocator.distanceBetween(
      companyLat,
      companyLon,
      currentPosition.latitude,
      currentPosition.longitude,
    );


    final isNear = distance <= toleranceMeters;
   
    return isNear;
  } catch (e) {
    return false;
  }
}
  static Future<Map<String, dynamic>> _getCompanyData(String cnpj) async {
    final response = await http.get(Uri.parse('$_baseUrl/empresas/$cnpj'));
    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar dados da empresa');
    }
    final data = json.decode(response.body);
    if (data['data'] == null) {
      throw Exception('Dados da empresa não encontrados');
    }
    return data['data'];
  }

 static String _buildFullAddress(Map<String, dynamic> companyData) {
 
  // Versão simplificada (fallback)
  final simpleAddress = [
    companyData['LOGRADOURO'],
    companyData['NUMERO']?.toString(),
    companyData['CIDADE'],
    companyData['UF']
  ].where((p) => p != null).join(', ');

  return simpleAddress; 
}static Future<Map<String, dynamic>> _getNominatimResult(String address) async {
  try {
    final encodedAddress = Uri.encodeComponent(address);
    final url = 'https://nominatim.openstreetmap.org/search?q=$encodedAddress&format=json&addressdetails=1';

    final response = await http.get(Uri.parse(url), headers: {
      'User-Agent': 'YourApp/1.0 (contact@yourapp.com)',
    });

    if (response.statusCode != 200) throw Exception('Erro no Nominatim');

    final data = json.decode(response.body) as List;
    if (data.isEmpty) {
      // Tentativa alternativa com formato simplificado
      return await _tryAlternativeAddressFormats(address);
    }

    return data.first;
  } catch (e) {
    throw Exception('Falha na geocodificação: $e');
  }
}

static Future<Map<String, dynamic>> _tryAlternativeAddressFormats(String originalAddress) async {
  final alternatives = [
    originalAddress.replaceAll(', Brasil', ''), // Remove país
    originalAddress.split(',').take(3).join(','), // Pega só rua, número e bairro
    originalAddress.split(',').first, // Apenas o logradouro + número
  ];

  for (final address in alternatives) {
    try {
      final encoded = Uri.encodeComponent(address);
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?q=$encoded&format=json'),
      );
      
      final data = json.decode(response.body) as List;
      if (data.isNotEmpty) return data.first;
    } catch (_) {}
  }

  throw Exception('Endereço não encontrado após várias tentativas');
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