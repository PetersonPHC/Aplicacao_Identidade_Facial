const prisma = require('../config/prisma')
class ColaboradorRepository {
  

  async create(colaborador) {
    return await prisma.colaborador.create({
      data: {
        MATRICULA: colaborador.MATRICULA,
        CNPJ: colaborador.CNPJ,
        NOME: colaborador.NOME,
        CPF: colaborador.CPF,
        RG: colaborador.RG,
        DATA_NASCIMENTO: this.formatDate(colaborador.DATA_NASCIMENTO), // Formatando para apenas data
        DATA_ADMISSAO: this.formatDate(colaborador.DATA_ADMISSAO),     // Formatando para apenas data
        CTPS: colaborador.CTPS,
        NIS: colaborador.NIS,
        CARGA_HORARIA: colaborador.CARGA_HORARIA,
        CARGO: colaborador.CARGO,
        IMAGEM: colaborador.IMAGEM
      },
      include: {
        empresa: true,
        usuario: true
      }
    });
  }

  // Método para formatar a data (removendo a parte de tempo)
  formatDate(date) {
    if (!date) return null;
    const d = new Date(date);
    return new Date(d.getFullYear(), d.getMonth(), d.getDate());
  }

  async findByMatriculaAndCNPJ(matricula, cnpj) {
    return await this.prisma.colaborador.findFirst({
      where: {
        MATRICULA: matricula,
        CNPJ_EMPRESA: cnpj
      }
    });
  }

  async findByMatricula(matricula, cnpjEmpresa) {
    return await this.prisma.colaborador.findUnique({
      where: {
        MATRICULA_CNPJ_EMPRESA: {
          MATRICULA: matricula,
          CNPJ_EMPRESA: cnpjEmpresa
        }
      }
    });
  }

  async update(matricula, cnpjEmpresa, colaboradorData) {
    return await this.prisma.colaborador.update({
      where: {
        MATRICULA_CNPJ_EMPRESA: {
          MATRICULA: matricula,
          CNPJ_EMPRESA: cnpjEmpresa
        }
      },
      data: colaboradorData,
      include: {
        usuario: true,
        registro_ponto: true
      }
    });
  }

  async delete(matricula, cnpjEmpresa) {
    const colaborador = await this.prisma.colaborador.delete({
      where: {
        MATRICULA_CNPJ_EMPRESA: {
          MATRICULA: matricula,
          CNPJ_EMPRESA: cnpjEmpresa
        }
      }
    });
    console.log(colaborador);
    return colaborador;
  }

  async findAllByEmpresa(cnpjEmpresa) {
    return await this.prisma.colaborador.findMany({
      where: { CNPJ_EMPRESA: cnpjEmpresa },
      include: {
        empresa: true,
        usuario: true,
      }
    });
  }
}

module.exports = new ColaboradorRepository();