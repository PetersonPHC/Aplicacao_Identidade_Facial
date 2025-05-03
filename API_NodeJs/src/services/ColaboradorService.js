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
    
    if (colaboradorData.DATA_ADMISSAO) {
      colaboradorData.DATA_ADMISSAO = new Date(colaboradorData.DATA_ADMISSAO + 'T00:00:00.000Z');
    }
  
    // Formatação da carga horária (corrigida)
    if (colaboradorData.CARGA_HORARIA) {
      console.log('[ColaboradorService] Formatando CARGA_HORARIA:', colaboradorData.CARGA_HORARIA);
      
      // Garante o formato HH:mm:ss
      const timeParts = colaboradorData.CARGA_HORARIA.split(':');
      if (timeParts.length < 2 || timeParts.length > 3) {
        throw new Error('Formato de CARGA_HORARIA inválido. Use HH:mm ou HH:mm:ss');
      }
      
      // Completa com segundos se necessário
      const formattedTime = timeParts.length === 2 
        ? `${colaboradorData.CARGA_HORARIA}:00` 
        : colaboradorData.CARGA_HORARIA;
      
      const dateObj = new Date(`1970-01-01T${formattedTime}`);
      
      if (isNaN(dateObj.getTime())) {
        throw new Error(`Falha ao converter CARGA_HORARIA: ${colaboradorData.CARGA_HORARIA}`);
      }
      
      colaboradorData.CARGA_HORARIA = dateObj;
    }
  
    // Filtra campos permitidos
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