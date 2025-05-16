const prisma = require('../config/prisma');

class EmpresaRepository {


  async create(empresa) {
    try {
      return await prisma.eMPRESA.create({
        data: {
          ...empresa
         
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

    return await prisma.eMPRESA.findUnique({
      where: {
        CNPJ: cnpj 
      }
    });
  }

  async update(cnpj, empresaData) {
    return await prisma.eMPRESA.update({
      where: { CNPJ: cnpj },
      data: empresaData
    });
  }

  async delete(cnpj) {
    return await this.prisma.eMPRESA.delete({ where: { CNPJ: cnpj } });
  }

  async findAll() {
    return await this.prisma.eMPRESA.findMany({
      include: {
        COLABORADORES: true,
        USUARIOS: true
      }
    });
  }
}

module.exports = new EmpresaRepository();