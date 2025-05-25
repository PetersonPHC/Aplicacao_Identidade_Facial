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
      res.status(400).json({ 
        error: error.message || 'Erro ao criar registro de ponto',
        details: process.env.NODE_ENV === 'development' ? error.stack : undefined
      });
    }
  }


    //Alteração -> CNPJ Removido
    async incluirPonto(req, res) {
      try {
        const { MATRICULA, DATA_PONTO, CNPJ_EMPRESA } = req.body;
        
        if (!MATRICULA) {
          throw new Error('Parâmetros obrigatórios não fornecidos');
        }
  
        const registro = await RegistroPontoService.incluir(CNPJ_EMPRESA, MATRICULA, DATA_PONTO);
        res.json(registro);
      } catch (error) {
        const statusCode = error.message === 'Registro não encontrado' ? 404 : 500;
        res.status(statusCode).json({ 
          error: error.message || 'Erro ao inserir registro de ponto',
          details: process.env.NODE_ENV === 'development' ? error.stack : undefined
        });
      }
    }
  
  //Alteração -> CNPJ Removido
  async buscar(req, res) {
    try {
      const { matricula, data, cnpjEmpresa } = req.params;
     
      
      if (!matricula) {
        throw new Error('Parâmetros obrigatórios não fornecidos');
      }

      const registro = await RegistroPontoService.buscar(cnpjEmpresa, matricula, data);
      res.json(registro);
    } catch (error) {
      const statusCode = error.message === 'Registro não encontrado' ? 404 : 500;
      res.status(statusCode).json({ 
        error: error.message || 'Erro ao buscar registro de ponto',
        details: process.env.NODE_ENV === 'development' ? error.stack : undefined
      });
    }
  }

  //Alteração -> CNPJ Removido
   deletar =  async (req, res) => {
   
    const { matricula, data, cnpjEmpresa } = req.params;
    
    try {
      if (!matricula || !data) {
      throw new Error('Parâmetros obrigatórios não fornecidos');
      }

      const registro = await RegistroPontoService.deletarRegistro(cnpjEmpresa, matricula, data);
      res.json({ message: 'Registro deletado com sucesso' });
    } catch (error) {
     
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
 
      
      if (!matricula) {
        throw new Error('Parâmetros obrigatórios não fornecidos');
      }

      const registro = await RegistroPontoService.buscarTodosRegistros(cnpjEmpresa, matricula);
      res.json(registro);
    } catch (error) {
      const statusCode = error.message === 'Registro não encontrado' ? 404 : 500;
      res.status(statusCode).json({ 
        error: error.message || 'Erro ao buscar registro de ponto',
        details: process.env.NODE_ENV === 'development' ? error.stack : undefined
      });
    }
  }

  

}

module.exports = new RegistroPontoController();