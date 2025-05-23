const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();
class UsuarioRepository {
  constructor() {
    this.prisma = require('../config/prisma'); // ou sua inicialização do Prisma
  }


  async create(usuarioData) {
    return await prisma.uSUARIO_COLABORADOR.create({
      data: {
        USUARIO_ID: usuarioData.USUARIO_ID,
        
        SENHA: usuarioData.SENHA,
        ADM : usuarioData.ADM
      },
      include: {
        colaborador: true
      }
    });
  }

  

  async createEmpresa(usuarioData) {
    return await prisma.uSUARIO_EMPRESA.create({
      data: {
        USUARIO_ID: usuarioData.USUARIO_ID,
        SENHA: usuarioData.SENHA,
        ADM : usuarioData.ADM
      },
      include: {
        empresa : true
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
  async findByCnpj(id) {
    return await this.prisma.uSUARIO_EMPRESA.findFirst({
      where: {
        USUARIO_ID: id,
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

  //Alteração -> CNPJ Removido
  async delete(matricula) {
    return await this.prisma.usuario.delete({
      where: {
        //MATRICULA_COLABORADOR_CNPJ_EMPRESA: {
          MATRICULA_COLABORADOR: matricula,
          //CNPJ_EMPRESA: cnpjEmpresa
        //}
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