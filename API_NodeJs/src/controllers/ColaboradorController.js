const ColaboradorService = require('../services/ColaboradorService');
const multer = require('multer');



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
  
      // Corrigido: combina body e file corretamente
      const colaboradorData = {
        ...req.body,
        IMAGEM: req.file?.buffer
      };
      
  
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
      const { matricula } = req.params;
      const dadosAtualizacao = {
        ...req.body, // Campos do form-data
        IMAGEM: req.file?.buffer // Arquivo se existir
      };
 ;
      const colaborador = await ColaboradorService.atualizarColaborador(
        matricula,
        dadosAtualizacao
      );
  
      res.json(colaborador);
    } catch (error) {
      ErrorHandler.handle(error, res);
    }
  }
  deletar = async (req, res) => {
    try {
      const { cnpjEmpresa } = req.params;
      const { matricula } = req.params;
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