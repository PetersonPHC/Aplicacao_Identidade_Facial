const RegistroPontoService = require('../services/RegistroPontoService');

class RegistroPontoController {
  constructor() {
    this.registroPontoService = RegistroPontoService;
  }
  async criar(req, res) {
    try {
      if (!req.body) {
        throw new Error('Dados de registro não fornecidos');
      }
      
      const registro = await this.registroPontoService.criarRegistro(req.body);
      res.status(201).json(registro);
    } catch (error) {
      console.error('Erro ao criar registro:', error);
      res.status(400).json({ 
        error: error.message || 'Erro ao criar registro de ponto',
        details: process.env.NODE_ENV === 'development' ? error.stack : undefined
      });
    }
  }

  async buscar(req, res) {
    try {
      const { matricula, cnpjEmpresa, data } = req.params;
      
      if (!matricula || !cnpjEmpresa || !data) {
        throw new Error('Parâmetros obrigatórios não fornecidos');
      }

      const registro = await this.registroPontoService.buscarRegistro(matricula, cnpjEmpresa, data);
      res.json(registro);
    } catch (error) {
      console.error('Erro ao buscar registro:', error);
      const statusCode = error.message === 'Registro não encontrado' ? 404 : 500;
      res.status(statusCode).json({ 
        error: error.message || 'Erro ao buscar registro de ponto',
        details: process.env.NODE_ENV === 'development' ? error.stack : undefined
      });
    }
  }

  async deletar(req, res) {
    try {
      const { matricula, cnpjEmpresa, data } = req.query;
      
      if (!matricula || !cnpjEmpresa || !data) {
        throw new Error('Parâmetros obrigatórios não fornecidos');
      }

      await this.registroPontoService.deletarRegistro(matricula, cnpjEmpresa, data);
      res.json({ message: 'Registro deletado com sucesso' });
    } catch (error) {
      console.error('Erro ao deletar registro:', error);
      const statusCode = error.message === 'Registro não encontrado' ? 404 : 500;
      res.status(statusCode).json({ 
        error: error.message || 'Erro ao deletar registro de ponto',
        details: process.env.NODE_ENV === 'development' ? error.stack : undefined
      });
    }
  }

  async listarPorColaborador(req, res) {
    try {
      const { matricula, cnpjEmpresa } = req.params;
      
      if (!matricula || !cnpjEmpresa) {
        throw new Error('Parâmetros obrigatórios não fornecidos');
      }

      const registros = await this.registroPontoService.listarRegistrosPorColaborador(matricula, cnpjEmpresa);
      res.json(registros);
    } catch (error) {
      console.error('Erro ao listar registros por colaborador:', error);
      res.status(500).json({ 
        error: error.message || 'Erro ao listar registros de ponto',
        details: process.env.NODE_ENV === 'development' ? error.stack : undefined
      });
    }
  }
}

module.exports = new RegistroPontoController();