const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();
class RegistroPontoRepository {
  constructor() {
    this.prisma = require('../config/prisma');
  } 
  
  
  async create(registroData) {
    try {
      // Converter DATA_HORA string para Date, ou usar a data atual se não for fornecida
      const dataPonto = registroData.DATA_HORA
        ? new Date(registroData.DATA_HORA.replace(' ', 'T') + 'Z')
        : new Date();

      return await prisma.rEGISTRO_PONTO.create({
        data: {
          MATRICULA: registroData.MATRICULA,
          CNPJ_EMPRESA: registroData.CNPJ_EMPRESA,
          DATA_PONTO: dataPonto
        }
      });
    } catch (error) {
      console.error('Erro detalhado ao criar registro:', {
        message: error.message,
        stack: error.stack,
        dataRecebida: registroData
      });
      throw new Error(`Falha ao criar registro: ${error.message}`);
    }
  }
  
  
  async find(cnpj, matricula, dataInicio) {
    // Cria a data inicial (início do dia)
    const startDate = new Date(dataInicio);
    startDate.setUTCHours(0, 0, 0, 0); // Define para início do dia em UTC
    
    // Cria a data final (fim do dia)
    const endDate = new Date(dataInicio);
    endDate.setUTCHours(23, 59, 59, 999); // Define para fim do dia em UTC

    return await prisma.rEGISTRO_PONTO.findMany({
      where: {
        MATRICULA: matricula,
        CNPJ_EMPRESA: cnpj,
        DATA_PONTO: {
          gte: startDate, // maior ou igual ao início do dia
          lte: endDate    // menor ou igual ao fim do dia
        }
      }
    });
}


async findAll(cnpj, matricula) {
  // Cria a data inicial (início do dia)
  
  return await prisma.rEGISTRO_PONTO.findMany({
    where: {
      MATRICULA: matricula,
      CNPJ_EMPRESA: cnpj,
      
    }
  });
}


  async delete(matricula, data) {
    return await this.prisma.rEGISTRO_PONTO.delete({
      where: {
        //MATRICULA_COLABORADOR_CNPJ_EMPRESA_DATA: {
        MATRICULA_COLABORADOR_DATA: {
          MATRICULA_COLABORADOR: matricula,
          //CNPJ_EMPRESA: cnpjEmpresa,
          DATA: data
        }
      }
    });
  }

  async findAllByColaborador(matricula) {
    return await this.prisma.rEGISTRO_PONTO.findMany({
      where: {
        MATRICULA_COLABORADOR: matricula,
        //CNPJ_EMPRESA: cnpjEmpresa
      },
      include: {
        colaborador: true
      }
    });
  }
}

module.exports = new RegistroPontoRepository();