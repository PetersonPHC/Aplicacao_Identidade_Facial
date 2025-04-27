const RegistroPontoRepository = require('../repositories/RegistroPontoRepository');
const ColaboradorService = require('./ColaboradorService');

class RegistroPontoService {

  //Alteração -> CNPJ Removido
  async criarRegistro(registroData) {
    // Verifica se o colaborador existe
    await ColaboradorService.buscarColaborador(
      registroData.MATRICULA_COLABORADOR, 
      //registroData.CNPJ_EMPRESA
    );
    
    return await RegistroPontoRepository.create(registroData);
  }

  //Alteração -> CNPJ Removido
  async buscarRegistro(matricula, data) {
    const registro = await RegistroPontoRepository.findByColaboradorAndDate(
      matricula, 
      new Date(data)
    );
    
    if (!registro) throw new Error('Registro não encontrado');
    return registro;
  }

  //Alteração -> CNPJ Removido
  async deletarRegistro(matricula, data) {
    await this.buscarRegistro(matricula, data); // Verifica se existe
    return await RegistroPontoRepository.delete(
      matricula, 
      new Date(data)
    );
  }

  //Alteração -> CNPJ Removido
  async listarRegistrosPorColaborador(matricula) {
    await ColaboradorService.buscarColaborador(matricula);
    return await RegistroPontoRepository.findAllByColaborador(matricula);
  }
}

// Exporta uma instância Singleton (recomendado para serviços stateless)
module.exports = new RegistroPontoService();