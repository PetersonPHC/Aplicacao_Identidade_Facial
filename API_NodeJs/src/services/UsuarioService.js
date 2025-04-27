const UsuarioRepository = require('../repositories/UsuarioRepository');
const ColaboradorService = require('./ColaboradorService');

class UsuarioService {
 

  //Alteração -> CNPJ Removido
  async criarUsuario(usuarioData) {
    try {
      await ColaboradorService.buscarColaborador(
        usuarioData.MATRICULA_COLABORADOR, 
        //usuarioData.CNPJ_EMPRESA
      );
      
      const usuarioExistente = await UsuarioRepository.findByMatriculaAndCnpj(
        usuarioData.MATRICULA_COLABORADOR,
        //usuarioData.CNPJ_EMPRESA
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

  //Alteração -> CNPJ Removido
  async buscarUsuario(matricula) {
    const usuario = await UsuarioRepository.findByMatricula(matricula);
    if (!usuario) throw new Error(' usuario não encontrado');
    return usuario;
  }

  //Alteração -> CNPJ Removido
  async atualizarUsuario(matricula, usuarioData) {
    await UsuarioRepository.findByMatricula(matricula);
    return await UsuarioRepository.update(matricula, usuarioData);
  }

  //Alteração -> CNPJ Removido
  async deletarUsuario(matricula) {
    await UsuarioRepository.findByMatricula(matricula);
    return await UsuarioRepository.delete(matricula);
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