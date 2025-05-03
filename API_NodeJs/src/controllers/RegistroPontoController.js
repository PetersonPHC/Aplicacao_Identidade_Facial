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
      const colaboradorData = {
        ...req.body,
        IMAGEM: req.file?.buffer
      };


      const registro = await RegistroPontoService.criarRegistro(colaboradorData);
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
      const { matricula, data, cnpjEmpresa } = req.params;
      console.log('→ MATRICULA:', matricula);
      console.log('→ cnpj:', cnpjEmpresa);
      
      if (!matricula) {
        throw new Error('Parâmetros obrigatórios não fornecidos');
      }

      const registro = await RegistroPontoService.buscar(cnpjEmpresa, matricula, data);
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
      const { matricula, cnpjEmpresa } = req.params;
      console.log('→ MATRICULA:', matricula);
      console.log('→ cnpj:', cnpjEmpresa);
      
      if (!matricula) {
        throw new Error('Parâmetros obrigatórios não fornecidos');
      }

      const registro = await RegistroPontoService.buscarTodosRegistros(cnpjEmpresa, matricula);
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

  concatMatricula(req){
    //return MATRICULA = String(req.body.CODIGO_EMPRESA).trim() + String(req.body.MATRICULA).trim();
    return MATRICULA = String(req.body.CODIGO_EMPRESA).trim().concat(String(req.body.MATRICULA).trim());
  }

}

module.exports = new RegistroPontoController();