const UsuarioService = require('../services/UsuarioService');
module.exports = {
  criar: async (req, res) => {
    try {
      console.log('[UsuarioController] Requisição recebida com body:');
      console.log(req.body);
  
      const usuarioData = {
        MATRICULA_COLABORADOR: req.body.MATRICULA,
        CNPJ_EMPRESA: req.body.CNPJ_EMPRESA,
        SENHA: req.body.SENHA,
        ADMIN: req.body.ADMIN || false
      };
  
      const usuario = await UsuarioService.criarUsuario(usuarioData);
      
      // Remove a senha do objeto de resposta por segurança
      const usuarioResponse = { ...usuario };
      delete usuarioResponse.SENHA;
      
      res.status(201).json(usuarioResponse);
    } catch (error) {
      console.error('[UsuarioController] Erro ao criar usuário:', error);
      res.status(400).json({ 
        error: error.message,
        details: process.env.NODE_ENV === 'development' ? error.stack : undefined
      });
    }
  },
  buscar: async (req, res) => {
    try {
      const usuario = await UsuarioService.buscarUsuario(
        req.params.matricula, 
        req.params.cnpjEmpresa
      );
      res.json(usuario);
    } catch (error) {
      res.status(error.message === 'Usuário não encontrado' ? 404 : 500)
         .json({ error: error.message });
    }
  },

  atualizar : async (req, res) => {
  
    const { matricula } = req.params;
    try {
      const usuario = await UsuarioService.atualizarUsuario( matricula, req.body);
      res.json((usuario));
    } catch (error) {
      res.status(error.message === 'Usuário não encontrado' ? 404 : 500)
         .json({ error: error.message });
    }
  },

  

  deletar : async (req, res) => {
    try {
    const usuarios =  await UsuarioService.deletarUsuario(req.params.cnpjEmpresa, req.params.MATRICULA);
      res.json({ message: 'Usuário deletado com sucesso' });
    } catch (error) {
      res.status(error.message === 'Usuário não encontrado' ? 404 : 500)
         .json({ error: error.message });
    }
  },

  listarPorEmpresa: async (req, res) => {
    try {
      const usuarios = await UsuarioService.listarUsuariosPorEmpresa(
        req.params.cnpjEmpresa
      );
      res.json(usuarios);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },



  loginEmpresa: async (req, res) => {
    try {
      const { cnpj, senha } = req.body;
      const empresa = await UsuarioService.autenticarEmpresa(cnpj, senha);
      res.json(empresa);
    } catch (error) {
      res.status(401).json({ error: error.message });
    }
  },

  loginColaborador: async (req, res) => {
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
      res.status(401).json({ error: error.message });
    }
  }
};