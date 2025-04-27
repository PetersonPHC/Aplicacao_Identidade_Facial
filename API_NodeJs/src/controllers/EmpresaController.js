const EmpresaService = require('../services/EmpresaService');

// Classe de erro personalizado
class EmpresaError extends Error {
  constructor(message, statusCode, details = {}) {
    super(message);
    this.name = this.constructor.name;
    this.statusCode = statusCode;
    this.details = details;
    Error.captureStackTrace(this, this.constructor);
  }
}

class EmpresaController {
  constructor() {
    // Centraliza o tratamento de erros
    this._handleError = this._handleError.bind(this);
  }

  // Método privado para tratamento de erros
  _handleError(error, res) {
    console.error(`[EmpresaController] ${error.name}:`, error.message);

    const statusCode = error.statusCode || 500;
    const response = {
      success: false,
      message: error.message,
    };

    if (process.env.NODE_ENV === 'development') {
      response.details = {
        stack: error.stack,
        ...error.details
      };
    }

    res.status(statusCode).json(response);
  }

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
    try {
      // Validação e formatação da data
      const dataCriacao = this._processarDataCriacao(req.body.DATACRIACAO);

      const dadosEmpresa = {
        ...req.body,
        DATACRIACAO: dataCriacao
      };

      const empresa = await EmpresaService.criarEmpresa(dadosEmpresa)
        .catch(err => {
          throw new EmpresaError(
            `Falha ao criar empresa: ${err.message}`,
            400,
            { originalError: err.message }
          );
        });

      res.status(201).json({
        success: true,
        data: empresa,
        message: 'Empresa criada com sucesso'
      });
    } catch (error) {
      this._handleError(error, res);
    }
  }

  async buscarPorCNPJ(req, res) {
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
      this._handleError(error, res);
    }
  }

  async atualizar(req, res) {
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
      this._handleError(error, res);
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
      this._handleError(error, res);
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
      this._handleError(error, res);
    }
  }
}

module.exports = new EmpresaController();