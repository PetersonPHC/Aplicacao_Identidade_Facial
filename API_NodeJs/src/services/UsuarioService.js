const UsuarioRepository = require('../repositories/UsuarioRepository');
const ColaboradorService = require('./ColaboradorService');

class UsuarioService {
 

  async criarUsuario(usuarioData) {
    try {
      await ColaboradorService.buscarColaborador(
        usuarioData.MATRICULA_COLABORADOR, 
        usuarioData.CNPJ_EMPRESA
      );
      
      const usuarioExistente = await UsuarioRepository.findByMatriculaAndCnpj(
        usuarioData.MATRICULA_COLABORADOR,
        usuarioData.CNPJ_EMPRESA
      );
      
      if (usuarioExistente) {
        throw new Error('Já existe um usuário cadastrado para este colaborador');
      }
      
      return await UsuarioRepository.create(usuarioData);
    } catch (error) {
      console.error('[UsuarioService] Erro ao criar usuário:', error);
      throw error;
    }
  }

 async buscarUsuario(matricula, cnpj) {
    const usuario = await UsuarioRepository.findByMatriculaAndCnpj(matricula, cnpj);
    if (!usuario) throw new Error(' usuario não encontrado');
    return usuario;
  }

  //Alteração -> CNPJ Removido
  async atualizarUsuario( matricula, usuarioData) {
    const usuarioExistente = await UsuarioRepository.findByMatricula(matricula);
    if (!usuarioExistente) {
      throw new Error('Usuário não encontrado');
    }
    return await UsuarioRepository.update(matricula, usuarioData); 
  
  }

  async deletarUsuario(matricula, cnpjEmpresa) {
    await UsuarioRepository.findByMatriculaAndCnpj(matricula, cnpjEmpresa);
    return await UsuarioRepository.delete(matricula, cnpjEmpresa);
  }

  async listarUsuariosPorEmpresa(cnpjEmpresa) {
    return await UsuarioRepository.findAllByEmpresa(cnpjEmpresa);
  }

  async autenticarEmpresa(cnpj, senha) {
    const empresa = await UsuarioRepository.findByCnpj(cnpj);
    if (!empresa) {
      throw new Error('Empresa não encontrada');
    }
    if (empresa.SENHA !== senha) {
      throw new Error('Senha incorreta');
    }
    return empresa;
  }


  async autenticarColaborador(USUARIO_ID, senha) {
    const colaborador = await UsuarioRepository.findByMatricula(USUARIO_ID);
    if (!colaborador) {
      throw new Error('colaborador não encontrado');
    }
    if (colaborador.SENHA !== senha) {
      throw new Error('Senha incorreta');
    }
    return colaborador;
  }
}

// Exporta uma instância do Service (Singleton)
module.exports = new UsuarioService();