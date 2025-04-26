const { PrismaClient } = require('@prisma/client');

class RegistroPontoRepository {
  constructor() {
    this.prisma = new PrismaClient();
  }

  async create(registro) {
    return await this.prisma.rEGISTRO_PONTO.create({ 
      data: registro,
      include: {
        colaborador: true
      }
    });
  }

  async findByColaboradorAndDate(matricula, cnpjEmpresa, data) {
    return await this.prisma.rEGISTRO_PONTO.findUnique({
      where: {
        MATRICULA_COLABORADOR_CNPJ_EMPRESA_DATA: {
          MATRICULA_COLABORADOR: matricula,
          CNPJ_EMPRESA: cnpjEmpresa,
          DATA: data
        }
      },
      include: {
        colaborador: true
      }
    });
  }

  async delete(matricula, cnpjEmpresa, data) {
    return await this.prisma.rEGISTRO_PONTO.delete({
      where: {
        MATRICULA_COLABORADOR_CNPJ_EMPRESA_DATA: {
          MATRICULA_COLABORADOR: matricula,
          CNPJ_EMPRESA: cnpjEmpresa,
          DATA: data
        }
      }
    });
  }

  async findAllByColaborador(matricula, cnpjEmpresa) {
    return await this.prisma.rEGISTRO_PONTO.findMany({
      where: {
        MATRICULA_COLABORADOR: matricula,
        CNPJ_EMPRESA: cnpjEmpresa
      },
      include: {
        colaborador: true
      }
    });
  }
}

module.exports = new RegistroPontoRepository();