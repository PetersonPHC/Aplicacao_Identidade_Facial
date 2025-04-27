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

  //Alteração -> CNPJ Removido
  async buscar(req, res) {
    try {
      //const { matricula, codigo_empresa, data } = req.params;
      const matricula = this.concatMatricula(req);
      const data = req.body.DATA;
      if (!matricula || !data) {
        throw new Error('Parâmetros obrigatórios não fornecidos');
      }

      const registro = await this.registroPontoService.buscarRegistro(matricula, data);
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

  //Alteração -> CNPJ Removido
  async deletar(req, res) {
    try {
      //const { matricula, cnpjEmpresa, data } = req.query;
      const matricula = this.concatMatricula(req);
      const data = req.body.DATA;
      if (!matricula || !data) {
        throw new Error('Parâmetros obrigatórios não fornecidos');
      }

      await this.registroPontoService.deletarRegistro(matricula, data);
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

  //Alteração -> CNPJ Removido
  async listarPorColaborador(req, res) {
    try {
      //const { matricula, cnpjEmpresa } = req.params;
      
      const matricula = this.concatMatricula(req);

      if (!matricula) {
        throw new Error('Parâmetros obrigatórios não fornecidos');
      }

      const registros = await this.registroPontoService.listarRegistrosPorColaborador(matricula);
      res.json(registros);
    } catch (error) {
      console.error('Erro ao listar registros por colaborador:', error);
      res.status(500).json({ 
        error: error.message || 'Erro ao listar registros de ponto',
        details: process.env.NODE_ENV === 'development' ? error.stack : undefined
      });
    }
  }

  concatMatricula(req){
    //return MATRICULA = String(req.body.CODIGO_EMPRESA).trim() + String(req.body.MATRICULA).trim();
    return MATRICULA = String(req.body.CODIGO_EMPRESA).trim().concat(String(req.body.MATRICULA).trim());
  }

}

module.exports = new RegistroPontoController();