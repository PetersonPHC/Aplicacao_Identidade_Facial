const EmpresaRepository = require('../repositories/EmpresaRepository');
const ColaboradorRepository = require('../repositories/ColaboradorRepository');

class ColaboradorService {

  async criarColaborador(dadosColaborador) {
    if (!dadosColaborador) {
      throw new Error('Dados do colaborador não fornecidos');
    }
    const cnpj = dadosColaborador.CNPJ_EMPRESA ; // Adicionado fallback
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
    console.log('→ service:');
    // Cria o colaborador
    return await ColaboradorRepository.create({
      ...dadosColaborador,
      CNPJ: cnpj // Garante o CNPJ formatado corretamente
    });
  }


  
  async buscarColaboradorMatricula( matricula) {
    console.log('[ColaboradorService] Buscando colaborador com metodo de matricula:');
    console.log('→ MATRICULA:', matricula);
  
    
    const colaborador = await ColaboradorRepository.findByMatricula( matricula);
    if (!colaborador) throw new Error('Colaborador não encontrado');
    
    return {
      ...colaborador,
      CARGA_HORARIA: colaborador.CARGA_HORARIA?.toTimeString().substring(0, 8) || null,
      BANCO_DE_HORAS: colaborador.BANCO_DE_HORAS?.toTimeString().substring(0, 8) || null
    };
  }



  async buscarColaboradorMatriculaCnpj(cnpj, matricula) {
    console.log('[ColaboradorService] Buscando colaborador com:');
    console.log('→ MATRICULA:', matricula);
    console.log('→ cnpj:', cnpj);
    
    const colaborador = await ColaboradorRepository.findByMatriculaAndCNPJ(cnpj, matricula);
    if (!colaborador) throw new Error('Colaborador não encontrado');
    
    return {
      ...colaborador,
      CARGA_HORARIA: colaborador.CARGA_HORARIA?.toTimeString().substring(0, 8) || null
    };
  }



  async atualizarColaborador(matricula, colaboradorData) {
    // Verifica se existe - passa apenas a matrícula
    await this.buscarColaboradorMatricula(matricula);
    
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
      'NIS', 'CTPS', 'CARGA_HORARIA', 'CARGO', 'BANCO_DE_HORAS', 'IMAGEM'
    ];
    
    const dadosParaAtualizar = {};
    for (const campo of camposPermitidos) {
      if (colaboradorData[campo] !== undefined) {
        dadosParaAtualizar[campo] = colaboradorData[campo];
      }
    }
    
    return await ColaboradorRepository.update(matricula, dadosParaAtualizar);
  }

  //Alteração -> CNPJ Removido
  async deletarColaborador( cnpj, matricula) {

    try {
      
      console.log('SERVICE');
      console.log('→ MATRICULA:', matricula);
      console.log('→ cnpj:', cnpj);
      await this.buscarColaboradorMatriculaCnpj(cnpj, matricula);
      return await ColaboradorRepository.delete(matricula);
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
    
    return colaboradores.map(colab => ({
      ...colab,
      CARGA_HORARIA: colab.CARGA_HORARIA.toTimeString().substring(0, 8)
    }));
  }
}


// Exporta uma instância Singleton
module.exports = new ColaboradorService();