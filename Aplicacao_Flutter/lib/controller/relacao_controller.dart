import 'package:flutter/material.dart';
import 'package:reconhecimento/service/colaborador_service.dart';

class RelacaoController {
  final ColaboradorService _colaboradorService = ColaboradorService();
  List<Map<String, dynamic>> colaboradores = [];
  bool loading = true;
 
 Future<void> fetchColaboradores({required String cnpj}) async {
  loading = true;
  try {
    final rawData = await _colaboradorService.buscarTodosColaboradores(cnpj: cnpj);
    
    // Verifica se rawData não é nulo e contém a estrutura esperada
    if (rawData == null || rawData.isEmpty) {
      colaboradores = [];
      loading = false;
      return;
    }

    // Processamento dos dados com type casting explícito
    final List<Map<String, dynamic>> processedData = rawData
        .where((item) => item is Map<String, dynamic>) // Filtra apenas Maps válidos
        .map<Iterable<Map<String, dynamic>>>((item) {
          final data = (item as Map<String, dynamic>)['data'] as List?;
          
          if (data == null || data.isEmpty) {
            return <Map<String, dynamic>>[];
          }

          // Processa cada colaborador
          return data
              .whereType<Map<String, dynamic>>()
              .map<Map<String, dynamic>>((colab) {
                return {
                  'nome': colab['NOME']?.toString() ?? '',
                  'matricula': colab['MATRICULA']?.toString() ?? '',
                  'cargaHoraria': colab['CARGA_HORARIA']?.toString() ?? '00:00:00',
                  'saldoHoras': _convertHorasToDouble(colab['BANCO_DE_HORAS']?.toString() ?? '00:00:00'),
                  'cnpj': colab['CNPJ_EMPRESA']?.toString() ?? '',
                };
              });
        })
        .expand<Map<String, dynamic>>((e) => e) // Achata a lista de listas
        .toList();

    // Atribuição final com garantia de tipo
    colaboradores = processedData;
    
    loading = false;
  } catch (error) {
    loading = false;
    throw Exception('Erro ao carregar colaboradores: $error');
  }
}

// Função auxiliar para converter "HH:MM:SS" para horas decimais
double _convertHorasToDouble(String horaString) {
  try {
    final parts = horaString.split(':');
    final horas = int.parse(parts[0]);
    final minutos = int.parse(parts[1]);
    return horas + (minutos / 60);
  } catch (e) {
    return 0.0;
  }
}


Future<void> excluirColaborador(String cnpj, String matricula, BuildContext context,  bool mounted,) async {
  print('DADOS FINAL METODO ');
  print('Status: {$cnpj/$matricula}');
  
  try {
    await _colaboradorService.excluirColaborador(cnpj, matricula);
    await fetchColaboradores(cnpj: matricula);
    
    // Verifica se o widget ainda está montado antes de mostrar o SnackBar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Colaborador excluído com sucesso!')),
      );
    }
  } catch (error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir colaborador: $error')),
      );
    }
  }
}

  Future<void> resetarSenha(
     String cnpj,
    String matricula, 
    String novaSenha, 
    BuildContext context,
   
  ) async {
    try {
      await _colaboradorService.resetarSenha(cnpj ,matricula, novaSenha);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha atualizada com sucesso!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar senha: $error')),
      );
    }
  }
}