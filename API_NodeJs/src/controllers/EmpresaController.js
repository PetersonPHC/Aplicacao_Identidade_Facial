const EmpresaService = require('../services/EmpresaService');
// Classe de erro personalizado para empresas
class EmpresaError extends Error {
  constructor(message, statusCode = 400, details = {}) {
    super(message);
    this.name = 'EmpresaError';
    this.statusCode = statusCode;
    this.details = details;
  }
}

// Classe de tratamento de erros
class EmpresaErrorHandler {
  static handle(error, res) {
    console.error('[EmpresaController] Erro:', error);
    
    const statusCode = error.statusCode || 
                      (error.message === 'Usuário não encontrado' ? 404 : 
                       error.message === 'Não autorizado' ? 401 : 
                       500);
    
    res.status(statusCode).json({ 
      error: error.message,
      ...(process.env.NODE_ENV === 'development' && { details: error.stack })
    });
  }
}
  

class EmpresaController {
 
  // 
  
  // Valida e formata a data de criação
  _processarDataCriacao(dataString) {
    try {
      let data;
      
      if (dataString) {
        if (dataString.includes('T')) {
          data = new Date(dataString);
        } else {
          data = new Date(`${dataString}T00:00:00.000Z`);
        }
        
        if (isNaN(data.getTime())) {
          throw new EmpresaError(
            'Formato de data inválido. Use YYYY-MM-DD ou ISO-8601', 
            400,
            { receivedDate: dataString }
          );
        }
      } else {
        data = new Date();
      }
      
      return data;
    } catch (error) {
      throw new EmpresaError(
        error.message || 'Erro ao processar data de criação',
        error.statusCode || 400,
        error.details
      );
    }
  }

  //Alteração -> Pegar o objeto empresa do banco e retornar ao Front, junto com o código da empresa
  async criar(req, res) {
    console.log('[EmpresaController] Requisição recebida com body:', req.body);
    try {
      // Validação e formatação da data
     

      
       
      const empresa = await EmpresaService.criarEmpresa(req.body);
        
      res.status(201).json({
        success: true,
        data: empresa,
        message: 'Empresa criada com sucesso'
      });
    } catch (error) {
      EmpresaErrorHandler.handle(error, res);
    }
  }

   buscarPorCNPJ = async (req, res) => {
    try {
      if (!req.params.cnpj) {
        throw new EmpresaError('CNPJ é obrigatório', 400);
      }

      const empresa = await EmpresaService.buscarEmpresaPorCNPJ(req.params.cnpj)
        .catch(err => {
          throw new EmpresaError(
            err.message,
            err.message.includes('não encontrada') ? 404 : 400
          );
        });

      res.json({
        success: true,
        data: empresa
      });
    } catch (error) {
      EmpresaErrorHandler.handle(error, res);
    }
  }

  async atualizar(req, res) {
    console.log('[EmpresaController] Requisição recebida com body:', req.body);
    try {
      if (!req.params.cnpj) {
        throw new EmpresaError('CNPJ é obrigatório', 400);
      }

      const empresa = await EmpresaService.atualizarEmpresa(
        req.params.cnpj,
        req.body
      ).catch(err => {
        throw new EmpresaError(
          err.message,
          err.message.includes('não encontrada') ? 404 : 400
        );
      });

      res.json({
        success: true,
        data: empresa,
        message: 'Empresa atualizada com sucesso'
      });
    } catch (error) {
      EmpresaErrorHandler.handle(error, res);
    }
  }

  async deletar(req, res) {
    try {
      if (!req.params.cnpj) {
        throw new EmpresaError('CNPJ é obrigatório', 400);
      }

      await EmpresaService.deletarEmpresa(req.params.cnpj)
        .catch(err => {
          throw new EmpresaError(
            err.message,
            err.message.includes('não encontrada') ? 404 : 400
          );
        });

      res.status(204).json({
        success: true,
        message: 'Empresa deletada com sucesso'
      });
    } catch (error) {
      EmpresaErrorHandler.handle(error, res);
    }
  }

  async listar(req, res) {
    try {
      const empresas = await EmpresaService.listarEmpresas()
        .catch(err => {
          throw new EmpresaError(
            `Falha ao listar empresas: ${err.message}`,
            500
          );
        });

      res.json({
        success: true,
        count: empresas.length,
        data: empresas
      });
    } catch (error) {
      EmpresaErrorHandler.handle(error, res);
    }
  }
}

module.exports = new EmpresaController();