const prisma = require('../config/prisma');

class EmpresaRepository {


  async create(empresa) {
    try {
      return await this.prisma.empresa.create({
        data: {
          ...empresa,
          DATACRIACAO: empresa.DATACRIACAO.toISOString() // Converte para string ISO
        }
      });
    } catch (error) {
      console.error('Erro no repository:', error);
      throw new Error(`Falha ao criar empresa: ${error.message}`);
    }
  }
  
  async findByCNPJ(cnpj) {
    if (!cnpj) {
      throw new Error('CNPJ não fornecido');
    }

    return await prisma.EMPRESA.findUnique({
      where: {
        CNPJ: cnpj 
      }
    });
  }

  async update(cnpj, empresaData) {
    return await this.prisma.empresa.update({
      where: { CNPJ: cnpj },
      data: empresaData
    });
  }

  async delete(cnpj) {
    return await this.prisma.empresa.delete({ where: { CNPJ: cnpj } });
  }

  async findAll() {
    return await this.prisma.empresa.findMany({
      include: {
        COLABORADORES: true,
        USUARIOS: true
      }
    });
  }
}

module.exports = new EmpresaRepository();