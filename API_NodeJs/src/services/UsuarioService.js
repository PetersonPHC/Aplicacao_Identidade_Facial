const UsuarioRepository = require('../repositories/UsuarioRepository');
const ColaboradorRepository = require('../repositories/ColaboradorRepository');
const EmpresaRepository = require('../repositories/EmpresaRepository');

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

  async criarEmpresa(empresaData) {
    try {
         
     
      return await UsuarioRepository.createEmpresa(empresaData);
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
  async atualizarUsuario( matricula, usuarioData) {
    const usuarioExistente = await UsuarioRepository.findByMatricula(matricula);
    if (!usuarioExistente) {
      throw new Error('Usuário não encontrado');
    }
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