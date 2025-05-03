const prisma = require('../config/prisma');

class UsuarioRepository {
  constructor() {
    this.prisma = prisma;
  }

  async create(usuarioData) {
    return await this.prisma.usuario.create({
      data: {
        MATRICULA_COLABORADOR: usuarioData.MATRICULA_COLABORADOR,
        CNPJ_EMPRESA: usuarioData.CNPJ_EMPRESA,
        SENHA: usuarioData.SENHA,
        ADMIN: usuarioData.ADMIN
      },
      include: {
        colaborador: true
      }
    });
  }

  async findByMatricula(matricula) {
    console.log('Dados normalizados para criação:', matricula);
    return await this.prisma.uSUARIO_COLABORADOR.findFirst({
      where: { USUARIO_ID : matricula },
      include: {
        colaborador: true}
    
     
    });
  }

  // Busca empresa APENAS por CNPJ (para login de empresa)
  async findByCnpj(cnpj) {
    return await this.prisma.usuario.findFirst({
      where: {
        CNPJ_EMPRESA: cnpj,
      },
      include: {
        empresa: true // Inclui dados relacionados da empresa se necessário
      }
    });
  }

  // Mantenha este método se ainda for necessário em outros contextos
  async findByMatriculaAndCnpj(matricula, cnpj) {
    return await this.prisma.usuario.findUnique({
      where: {
        MATRICULA_COLABORADOR_CNPJ_EMPRESA: {
          MATRICULA_COLABORADOR: matricula,
          CNPJ_EMPRESA: cnpj
        }
      }
    });
  }

  //Alteração -> CNPJ Removido
  async update(matricula, usuarioData) {
    return await this.prisma.uSUARIO_COLABORADOR.update({
      where: {
         USUARIO_ID: matricula
      },
      data: usuarioData,
    });
  }

  async delete(matricula, cnpjEmpresa) {
    return await this.prisma.usuario.delete({
      where: {
        MATRICULA_COLABORADOR_CNPJ_EMPRESA: {
          MATRICULA_COLABORADOR: matricula,
          CNPJ_EMPRESA: cnpjEmpresa
        }
      }
    });
  }

  async findAllByEmpresa(cnpjEmpresa) {
    return await this.prisma.usuario.findMany({
      where: { CNPJ_EMPRESA: cnpjEmpresa },
      include: {
        empresa: true,
        colaborador: true
      }
    });
  }
}

module.exports = new UsuarioRepository();