// src/services/EmpresaService.js
const EmpresaRepository = require('../repositories/EmpresaRepository');

class EmpresaService {
  async criarEmpresa(empresaData) {
    const empresaExistente = await EmpresaRepository.findByCNPJ(empresaData.CNPJ);
    
    // Validações (mantidas idênticas)
    if (!empresaData.CNPJ) throw new Error('CNPJ é obrigatório');
    if (!empresaData.NOMEFANTASIA) throw new Error('Nome fantasia é obrigatório');
    if (empresaExistente) {
      throw new Error('Já existe uma empresa cadastrada com este CNPJ');
    }

    try {
      return await EmpresaRepository.create(empresaData);
    } catch (error) {
      throw new Error(`Falha ao criar empresa: ${error.message}`);
    }
  }

  async buscarEmpresaPorCNPJ(cnpj) {
    const empresa = await EmpresaRepository.findByCNPJ(cnpj);
    if (!empresa) throw new Error('Empresa não encontrada');
    return empresa;
  }

  async atualizarEmpresa(cnpj, empresaData) {
    await this.buscarEmpresaPorCNPJ(cnpj); // Agora usando this para reutilizar o método
    return await EmpresaRepository.update(cnpj, empresaData);
  }

  async deletarEmpresa(cnpj) {
    await this.buscarEmpresaPorCNPJ(cnpj); // Reutiliza a verificação de existência
    return await EmpresaRepository.delete(cnpj);
  }

  async listarEmpresas() {
    return await EmpresaRepository.findAll();
  }
}

// Exporta uma instância Singleton (recomendado para serviços stateless)
module.exports = new EmpresaService();