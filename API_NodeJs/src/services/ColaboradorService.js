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
    console.log('[ColaboradorService] Iniciando atualização', {
      matricula,
      colaboradorData: { ...colaboradorData, IMAGEM: colaboradorData.IMAGEM ? 'Buffer presente' : 'Nenhuma imagem' }
    });
  
    // Verifica se o colaborador existe
    await this.buscarColaboradorMatricula(matricula);
    console.log('[ColaboradorService] Colaborador encontrado, prosseguindo com atualização');
  
    // Formatação de datas
    if (colaboradorData.DATA_NASCIMENTO) {
      colaboradorData.DATA_NASCIMENTO = new Date(colaboradorData.DATA_NASCIMENTO + 'T00:00:00.000Z');
    }
    
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
      'NIS', 'CTPS', 'CARGA_HORARIA', 'CARGO', 'BANCO_DE_HORAS', 'IMAGEM'
    ];
    
    const dadosParaAtualizar = {};
    for (const campo of camposPermitidos) {
      if (colaboradorData[campo] !== undefined) {
        dadosParaAtualizar[campo] = colaboradorData[campo];
      }
    }
  
    console.log('[ColaboradorService] Dados filtrados para atualização:', dadosParaAtualizar);
  
    const resultado = await ColaboradorRepository.update(matricula, dadosParaAtualizar);
    console.log('[ColaboradorService] Atualização no repositório concluída:', resultado);
  
    return resultado;
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