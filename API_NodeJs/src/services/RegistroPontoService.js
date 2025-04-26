const RegistroPontoRepository = require('../repositories/RegistroPontoRepository');
const ColaboradorService = require('./ColaboradorService');

class RegistroPontoService {
  async criarRegistro(registroData) {
    // Verifica se o colaborador existe
    await ColaboradorService.buscarColaborador(
      registroData.MATRICULA_COLABORADOR, 
      registroData.CNPJ_EMPRESA
    );
    
    return await RegistroPontoRepository.create(registroData);
  }

  async buscarRegistro(matricula, cnpjEmpresa, data) {
    const registro = await RegistroPontoRepository.findByColaboradorAndDate(
      matricula, 
      cnpjEmpresa, 
      new Date(data)
    );
    
    if (!registro) throw new Error('Registro não encontrado');
    return registro;
  }

  async deletarRegistro(matricula, cnpjEmpresa, data) {
    await this.buscarRegistro(matricula, cnpjEmpresa, data); // Verifica se existe
    return await RegistroPontoRepository.delete(
      matricula, 
      cnpjEmpresa, 
      new Date(data)
    );
  }

  async listarRegistrosPorColaborador(matricula, cnpjEmpresa) {
    await ColaboradorService.buscarColaborador(matricula, cnpjEmpresa);
    return await RegistroPontoRepository.findAllByColaborador(matricula, cnpjEmpresa);
  }
}

// Exporta uma instância Singleton (recomendado para serviços stateless)
module.exports = new RegistroPontoService();