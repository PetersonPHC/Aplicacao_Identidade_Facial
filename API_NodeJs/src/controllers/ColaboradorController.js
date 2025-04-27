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

class ColaboradorController {
  constructor() {
    // Configuração do Multer movida para dentro do construtor
    const storage = multer.memoryStorage();
    this.upload = multer({
      storage: storage,
      preservePath: true,
      fileFilter: (req, file, cb) => {
        if (file.mimetype.startsWith('image/')) {
          cb(null, true);
        } else {
          cb(new Error('Apenas imagens são permitidas!'), false);
        }
      },
      limits: {
        fileSize: 5 * 1024 * 1024 // 5MB
      }
    });
    
    // Cria o middleware de upload
    this.uploadMiddleware = this.upload.single('IMAGEM');
  }

  handleError(error, res) {
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

  criar = async (req, res) => {
    try {
      console.log('Dados recebidos:', {
        body: req.body,
        file: req.file ? `Imagem (${req.file.size} bytes)` : null,
        headers: req.headers
      });
  
      // Verifica se os campos obrigatórios existem
      if (!req.body.MATRICULA || !req.body.CNPJ) {
        throw new AppError('Matrícula e CNPJ são obrigatórios', 400);
      }
  
      const colaboradorData = {
        MATRICULA: this.concatMatricula(req),
        CNPJ: String(req.body.CNPJ).trim(),
        NOME: String(req.body.NOME || '').trim(),
        CPF: String(req.body.CPF || '').replace(/\D/g, ''),
        RG: String(req.body.RG || '').replace(/\D/g, ''),
        DATA_NASCIMENTO: req.body.DATA_NASCIMENTO,
        DATA_ADMISSAO: req.body.DATA_ADMISSAO,
        CTPS: String(req.body.CTPS || ''),
        NIS: String(req.body.NIS || ''),
        CARGA_HORARIA: parseInt(req.body.CARGA_HORARIA) || 0,
        CARGO: String(req.body.CARGO || '').trim(),
        IMAGEM: req.file?.buffer
      };
      // Validações adicionais
      if (!colaboradorData.NOME) throw new AppError('Nome é obrigatório', 400);
      if (!colaboradorData.CPF || colaboradorData.CPF.length !== 11) throw new AppError('CPF inválido', 400);
  
      console.log('Dados normalizados para criação:', colaboradorData);
  
      const colaborador = await ColaboradorService.criarColaborador(colaboradorData);
      
      res.status(201).json({
        status: 'success',
        data: colaborador
      });
    } catch (error) {
      console.error('Erro no controller:', error);
      this.handleError(error, res);
    }
  }

  buscar = async (req, res) => {
    try {
      //Alteração: Removido CNPJ
      //const { matricula, codigo_empresa } = req.params;
      const colaborador = await ColaboradorService.buscarColaborador(this.concatMatricula(req));
      
      res.json({
        status: 'success',
        data: {
          ...colaborador,
          IMAGEM: colaborador.IMAGEM?.toString('base64')
        }
      });
    } catch (error) {
      this.handleError(error, res);
    }
  };

  //Alteração -> Remoção do CNPJ como parâmetro
  atualizar = [
    (req, res, next) => {
      this.uploadMiddleware(req, res, (err) => {
        if (err) {
          return this.handleError(err, res);
        }
        next();
      });
    },
    async (req, res) => {
      try {
        //const { matricula, codigo_empresa } = req.params;
        const dadosAtualizacao = {
          ...req.body,
          IMAGEM: req.file?.buffer
        };

        const colaborador = await ColaboradorService.atualizarColaborador(
          this.concatMatricula(req), 
          dadosAtualizacao
        );

        res.json({
          status: 'success',
          data: colaborador
        });
      } catch (error) {
        this.handleError(error, res);
      }
    }
  ];

  //Alteração -> CNPJ Removido
  deletar = async (req, res) => {
    try {
      //const { matricula, codigo_empresa } = req.params;
      await ColaboradorService.deletarColaborador(this.concatMatricula(req));
      res.status(204).end();
    } catch (error) {
      this.handleError(error, res);
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
      this.handleError(error, res);
    }
  };

concatMatricula(req){
  //return MATRICULA = String(req.body.CODIGO_EMPRESA).trim() + String(req.body.MATRICULA).trim();
  return MATRICULA = String(req.body.CODIGO_EMPRESA).trim().concat(String(req.body.MATRICULA).trim());
}

}

module.exports = new ColaboradorController();