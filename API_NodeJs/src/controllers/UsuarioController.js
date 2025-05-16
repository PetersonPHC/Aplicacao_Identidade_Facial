const UsuarioService = require('../services/UsuarioService');

class UsuarioErrorHandler {
  static handle(error, res) {
    console.error('[UsuarioController] Erro:', error);
    
    const statusCode = error.message === 'Usuário não encontrado' ? 404 : 
                      error.message === 'Não autorizado' ? 401 : 
                      500;
    
    res.status(statusCode).json({ 
      error: error.message,
      ...(process.env.NODE_ENV === 'development' && { details: error.stack })
    });
  }
}




class UsuarioController {
  criarColaborador = async (req, res) => {
    try {
      console.log('[UsuarioController] Requisição recebida com body:', req.body);
      
      const usuario = await UsuarioService.criarUsuario(req.body);
      
      res.status(201).json(usuario);
    } catch (error) {
      UsuarioErrorHandler.handle(error, res);
    }
  }


  criarEmpresa = async (req, res) => {
    try {
      console.log('[UsuarioController] Requisição recebida com body:', req.body);
      
      const empresa = await UsuarioService.criarEmpresa(req.body);
      
      res.status(201).json(empresa);
    } catch (error) {
      UsuarioErrorHandler.handle(error, res);
    }
  }


  buscar = async (req, res) => {
    try {
      const usuario = await UsuarioService.buscarUsuario(
        (req.params)
      );
      res.json((usuario));
    } catch (error) {
      UsuarioErrorHandler.handle(error, res);
    }
  }

  atualizar = async (req, res) => {
  
    const { matricula } = req.params;
    try {
      const usuario = await UsuarioService.atualizarUsuario( matricula, req.body);
      res.json((usuario));
    } catch (error) {
      UsuarioErrorHandler.handle(error, res);
    }
  }

  deletar = async (req, res) => {
    try {
    const usuarios =  await UsuarioService.deletarUsuario(req.params.cnpjEmpresa, req.params.MATRICULA);
      res.json({ message: 'Usuário deletado com sucesso' });
    } catch (error) {
      UsuarioErrorHandler.handle(error, res);
    }
  }

  listarPorEmpresa = async (req, res) => {
    try {
      const usuarios = await UsuarioService.listarUsuariosPorEmpresa(
        req.params.cnpjEmpresa
      );
      res.json(usuarios);
    } catch (error) {
      UsuarioErrorHandler.handle(error, res);
    }
  }

  loginEmpresa = async (req, res) => {
    try {
      const { USUARIO_ID, SENHA } = req.body;
      console.log('→ pj:', USUARIO_ID);
      console.log('→ senha:', SENHA);
      const empresa = await UsuarioService.autenticarEmpresa(USUARIO_ID, SENHA);
      res.json(empresa);
    } catch (error) {
      UsuarioErrorHandler.handle(error, res);
    }
  }

  loginColaborador = async (req, res) => {
    try {
      const { USUARIO_ID, SENHA } = req.body;
      console.log('→ matricula:', USUARIO_ID);
      console.log('→ senha:', SENHA);
      const matricula = req.body.MATRICULA;
      const colaborador = await UsuarioService.autenticarColaborador(
            USUARIO_ID, 
        SENHA
      );
      res.json(colaborador);
    } catch (error) {
      UsuarioErrorHandler.handle(error, res);
    }
  }
}

module.exports = new UsuarioController();