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
    async incluirPonto(req, res) {
      try {
        const { MATRICULA, DATA_PONTO, CNPJ_EMPRESA } = req.body;
        console.log('→ MATRICULA:', MATRICULA);
        console.log('→ DATA:', DATA_PONTO);
        
        if (!MATRICULA) {
          throw new Error('Parâmetros obrigatórios não fornecidos');
        }
  
        const registro = await RegistroPontoService.incluir(CNPJ_EMPRESA, MATRICULA, DATA_PONTO);
        res.json(registro);
      } catch (error) {
        console.error('Erro ao buscar registro:', error);
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
   deletar =  async (req, res) => {
   
    const { matricula, data, cnpjEmpresa } = req.params;
    console.log('→ MATRICULA:', matricula);
    console.log('→ cnpj:', cnpjEmpresa);
    console.log('→ data:', data);
    try {
      if (!matricula || !data) {
      throw new Error('Parâmetros obrigatórios não fornecidos');
      }

      const registro = await RegistroPontoService.deletarRegistro(cnpjEmpresa, matricula, data);
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