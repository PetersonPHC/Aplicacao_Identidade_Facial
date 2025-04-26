const ColaboradorRepository = require('../repositories/ColaboradorRepository');
const EmpresaRepository = require('../repositories/EmpresaRepository');

class ColaboradorService {

  async criarColaborador(dadosColaborador) {
    // Verifica se a empresa existe
    const cnpj = dadosColaborador.CNPJ || dadosColaborador.cnpj; // Adicionado fallback
    if (!cnpj) {
      throw new Error('CNPJ não fornecido');
    }

    const empresaExistente = await EmpresaRepository.findByCNPJ(cnpj);
    if (!empresaExistente) {
      throw new Error('Empresa não encontrada');
    }

    // Verifica se o colaborador já existe
    const colaboradorExistente = await ColaboradorRepository.findByMatricula(
      dadosColaborador.MATRICULA,
      cnpj
    );
    
    if (colaboradorExistente) {
      throw new Error('Colaborador já cadastrado');
    }

    // Cria o colaborador
    return await ColaboradorRepository.create({
      ...dadosColaborador,
      CNPJ: cnpj // Garante o CNPJ formatado corretamente
    });
  }

  async buscarColaborador(matricula, cnpjEmpresa) {
    // Logs mantidos exatamente iguais
    console.log('[ColaboradorService] Buscando colaborador com:');
    console.log('→ MATRICULA:', matricula);
    console.log('→ CNPJ_EMPRESA:', cnpjEmpresa);
    
    const colaborador = await ColaboradorRepository.findByMatricula(matricula, cnpjEmpresa);
    if (!colaborador) throw new Error('Colaborador não encontrado');
    
    // Conversão de campos mantida idêntica
    return {
      ...colaborador,
      CARGA_HORARIA: colaborador.CARGA_HORARIA.toTimeString().substring(0, 8),
      BANCO_DE_HORAS: colaborador.BANCO_DE_HORAS.toTimeString().substring(0, 8)
    };
  }
  async atualizarColaborador(matricula, cnpjEmpresa, colaboradorData) {
    // Verifica se existe
    await this.buscarColaborador(matricula, cnpjEmpresa);
    
    // Formatação dos campos de tempo
    if (colaboradorData.CARGA_HORARIA) {
      colaboradorData.CARGA_HORARIA = new Date(`1970-01-01T${colaboradorData.CARGA_HORARIA}`);
    }
    
    if (colaboradorData.BANCO_DE_HORAS) {
      colaboradorData.BANCO_DE_HORAS = new Date(`1970-01-01T${colaboradorData.BANCO_DE_HORAS}`);
    }
    
    // Remove campos que não devem ser atualizados
    const camposPermitidos = [
      'NOME', 'CPF', 'RG', 'DATA_NASCIMENTO', 'DATA_ADMISSAO',
      'NIS', 'CTPS', 'CARGA_HORARIA', 'CARGO', 'IMAGEM', 'BANCO_DE_HORAS'
    ];
    
    const dadosParaAtualizar = {};
    for (const campo of camposPermitidos) {
      if (colaboradorData[campo] !== undefined) {
        dadosParaAtualizar[campo] = colaboradorData[campo];
      }
    }
    
    return await ColaboradorRepository.update(matricula, cnpjEmpresa, dadosParaAtualizar);
  }
  async deletarColaborador(matricula, cnpjEmpresa) {
    try {
      await this.buscarColaborador(matricula, cnpjEmpresa);
      return await ColaboradorRepository.delete(matricula, cnpjEmpresa);
    } catch (error) {
      console.error('[ColaboradorService] Erro ao deletar:', {
        message: error.message,
        stack: error.stack,
        meta: error.meta || null
      });
      
      if (error.message.includes('Foreign key constraint')) {
        throw new Error('Não foi possível deletar: existem registros vinculados');
      }
      throw error;
    }
  }

  async listarColaboradoresPorEmpresa(cnpjEmpresa) {
    await EmpresaRepository.findByCNPJ(cnpjEmpresa); // Verifica se a empresa existe
    
    const colaboradores = await ColaboradorRepository.findAllByEmpresa(cnpjEmpresa);
    
    // Mapeamento mantido idêntico
    return colaboradores.map(colab => ({
      ...colab,
      CARGA_HORARIA: colab.CARGA_HORARIA.toTimeString().substring(0, 8),
      BANCO_DE_HORAS: colab.BANCO_DE_HORAS.toTimeString().substring(0, 8)
    }));
  }
}


// Exporta uma instância Singleton
module.exports = new ColaboradorService();