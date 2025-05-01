const UsuarioRepository = require('../repositories/UsuarioRepository');
const ColaboradorRepository = require('../repositories/ColaboradorRepository');


class UsuarioService {
 

  //Alteração -> CNPJ Removido
  async criarUsuario(usuarioData) {
    try {
         
      const usuarioExistente = await UsuarioRepository.findByMatricula(
        usuarioData.USUARIO_ID);
      
      if (usuarioExistente) {
        throw new Error('Já existe um usuário cadastrado para este colaborador');
      }
      
      return await UsuarioRepository.create(usuarioData);
    } catch (error) {
      console.error('[UsuarioService] Erro ao criar usuário:', error);
      throw error;
    }
  }



  async buscarUsuario(MATRICULA ,CNPJ) {
    const usuario = await UsuarioRepository.findByMatriculaAndCnpj(MATRICULA, CNPJ);
    if (!usuario) throw new Error(' usuario não encontrado');
    return usuario;
  }
  //Alteração -> CNPJ Removido
  async buscarEmpresa(CNPJ) {
    const usuario = await UsuarioRepository.findByCnpj(CNPJ);
    if (!usuario) throw new Error(' usuario não encontrado');
    return usuario;
  }

  //Alteração -> CNPJ Removido
  async atualizarUsuario(matricula, usuarioData) {
    await UsuarioRepository.findByMatricula(matricula);
    return await UsuarioRepository.update(matricula, usuarioData);
  }

  //Alteração -> CNPJ Removido
  async deletarUsuario(matricula, cnpj) {
    await UsuarioRepository.findByMatriculaAndCnpj(matricula, cnpj);
    return await UsuarioRepository.delete(matricula);
  }

  async listarUsuariosPorEmpresa(cnpjEmpresa) {
    return await UsuarioRepository.findAllByEmpresa(cnpjEmpresa);
  }

  async autenticarEmpresa(USUARIO_ID, senha) {
    const empresa = await UsuarioRepository.findByCnpj(USUARIO_ID);
    if (!empresa) {
      throw new Error('Empresa não encontrada');
    }
    if (empresa.SENHA !== senha) {
      throw new Error('Senha incorreta');
    }
    return empresa;
  }


  async autenticarColaborador(matricula, senha) {
    const colaborador = await UsuarioRepository.findByMatricula(matricula);
    if (!colaborador) {
      throw new Error('colaborador não encontrada');
    }
    if (colaborador.SENHA !== senha) {
      throw new Error('Senha incorreta');
    }
    return colaborador;
  }
}

// Exporta uma instância do Service (Singleton)
module.exports = new UsuarioService();