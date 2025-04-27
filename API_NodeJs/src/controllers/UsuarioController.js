const UsuarioService = require('../services/UsuarioService');
module.exports = {
  criar: async (req, res) => {
    try {
      console.log('[UsuarioController] Requisição recebida com body:');
      console.log(req.body);
  
      const usuarioData = {
        MATRICULA_COLABORADOR: this.concatMatricula(req),
        //CNPJ_EMPRESA: req.body.CNPJ_EMPRESA,
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

  //Alteração -> CNPJ Removido
  buscar: async (req, res) => {
    try {
      const usuario = await UsuarioService.buscarUsuario(
        this.concatMatricula(req.params.matricula), 
        //req.params.cnpjEmpresa
      );
      res.json(usuario);
    } catch (error) {
      res.status(error.message === 'Usuário não encontrado' ? 404 : 500)
         .json({ error: error.message });
    }
  },

  //Alteração -> CNPJ Removido
  atualizar: async (req, res) => {
    try {
      const usuario = await UsuarioService.atualizarUsuario(
        this.concatMatricula(req.params.matricula), 
        //req.params.cnpjEmpresa, 
        req.body
      );
      res.json(usuario);
    } catch (error) {
      res.status(error.message === 'Usuário não encontrado' ? 404 : 500)
         .json({ error: error.message });
    }
  },

  //Alteração -> CNPJ Removido
  deletar: async (req, res) => {
    
    try {
      await UsuarioService.deletarUsuario(
        this.concatMatricula(req.params.matricula)
        //req.params.cnpjEmpresa
      );
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

  //Alteração -> Adição do Prefixo como um CONCAT
  loginColaborador: async (req, res) => {
    try {
      //const { matricula, senha } = req.body;
      const matricula = this.concatMatricula(req);
      const senha = req.body.SENHA;
      const colaborador = await UsuarioService.autenticarColaborador(matricula, senha);
      res.json(colaborador);
    } catch (error) {
      res.status(401).json({ error: error.message });
    }
  },

  concatMatricula(req){
    //return MATRICULA = String(req.body.CODIGO_EMPRESA).trim() + String(req.body.MATRICULA).trim();
    return MATRICULA = String(req.body.CODIGO_EMPRESA).trim().concat(String(req.body.MATRICULA).trim());
  }

};