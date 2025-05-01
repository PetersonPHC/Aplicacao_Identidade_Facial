const ColaboradorService = require('../services/ColaboradorService');
const multer = require('multer');

class AppError extends Error {
  constructor(message, statusCode, details = null) {
    super(message);
    this.statusCode = statusCode;
    this.details = details;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}

class MulterConfig {
  constructor() {
    this.storage = multer.memoryStorage();
    this.upload = multer({
      storage: this.storage,
      preservePath: true,
      fileFilter: this.fileFilter,
      limits: {
        fileSize: 5 * 1024 * 1024 // 5MB
      }
    });
  }

  fileFilter(req, file, cb) {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Apenas imagens são permitidas!'), false);
    }
  }
}

class ErrorHandler {
  static handle(error, res) {
    console.error('Erro no controller:', {
      message: error.message,
      statusCode: error.statusCode || 500,
      stack: error.stack,
      isOperational: error.isOperational || false
    });

    const statusCode = error.statusCode || 500;
    const response = {
      status: 'error',
      message: error.message
    };

    if (process.env.NODE_ENV === 'development') {
      response.stack = error.stack;
      response.details = error.details;
    }

    res.status(statusCode).json(response);
  }
}


class ColaboradorController {
  constructor() {
    
    this.multerConfig = new MulterConfig();
    this.uploadMiddleware = this.multerConfig.upload.single('IMAGEM');
  }

  buscar = async (req, res) => {
    try {
      const { matricula, cnpj } = req.params;
      console.log('→ MATRICULA:', matricula);
      console.log('→ cnpj:', cnpj);
      const Colaborador = await ColaboradorService.buscarColaboradorMatriculaCnpj(cnpj, matricula);
      
      res.json({
        status: 'success',
        data: {
          ...Colaborador,
          IMAGEM: Colaborador.IMAGEM?.toString('base64')
        }
      });
    } catch (error) {
      ErrorHandler.handle(error, res);
    }
  };

  criar = async (req, res) => {
    try {
      console.log('Dados recebidos:', {
        body: req.body,
        file: req.file ? `Imagem (${req.file.size} bytes)` : null,
        headers: req.headers
      });
  
      // Corrigido: combina body e file corretamente
      const colaboradorData = {
        ...req.body,
        IMAGEM: req.file?.buffer
      };
      
      console.log('Dados normalizados para criação:', colaboradorData);
  
      const colaborador = await ColaboradorService.criarColaborador(colaboradorData);
      
      res.status(201).json({
        status: 'success',
        data: colaborador
      });
    } catch (error) {
      ErrorHandler.handle(error, res);
    }
  }

  atualizar = async (req, res) => {
    try {
      const { matricula } = req.params; // Extrai a matrícula dos parâmetros da URL
      const dadosAtualizacao = {
        ...req.body,
        IMAGEM: req.file?.buffer
      };
  
      const colaborador = await ColaboradorService.atualizarColaborador(
        matricula, // Passa a matrícula como primeiro parâmetro
        dadosAtualizacao // Passa os dados de atualização como segundo parâmetro
      );
  
      res.json({
        status: 'success',
        data: colaborador
      });
    } catch (error) {
      ErrorHandler.handle(error, res);
    }
  }
  

  deletar = async (req, res) => {
    try {
      const { cnpjEmpresa } = req.params;
      const { matricula } = req.params;
      console.log('→ MATRICULA:', matricula);
      console.log('→ cnpj:', cnpjEmpresa);
      const colaboradores = await ColaboradorService.deletarColaborador(cnpjEmpresa, matricula);
      res.status(204).end();
    } catch (error) {
      ErrorHandler.handle(error, res);
    }
  };

  listarPorEmpresa = async (req, res) => {
    try {
      const { cnpjEmpresa } = req.params;
      const colaboradores = await ColaboradorService.listarColaboradoresPorEmpresa(cnpjEmpresa);
      
      res.json({
        status: 'success',
        data: colaboradores.map(c => ({
          ...c,
          IMAGEM: c.IMAGEM?.toString('base64')
        }))
      });
    } catch (error) {
      ErrorHandler.handle(error, res);
    }
  };
}

module.exports = new ColaboradorController();