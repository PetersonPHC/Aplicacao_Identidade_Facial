const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();
class ColaboradorRepository {
  constructor() {
    this.prisma = require('../config/prisma'); // ou sua inicialização do Prisma
  }

  
    async findByMatriculaAndCNPJ(cnpj, matricula) {
      console.log('Dados CHEGARAM AQ:', cnpj, matricula);
      try {
        
        return await this.prisma.colaborador.findFirst({
          where: {
            CNPJ_EMPRESA: cnpj,
            MATRICULA: matricula
           
          }
        });
      } catch (error) {
        console.error('Erro no repositório:', error);
        throw error;
      }
    }
  
  
  async create(colaborador) {
    console.log('→ repository:');
    return await prisma.colaborador.create({
      data: {
        MATRICULA: colaborador.MATRICULA,
        NOME: colaborador.NOME,
        CPF: colaborador.CPF,
        RG: colaborador.RG,
        DATA_NASCIMENTO: this.formatDate(colaborador.DATA_NASCIMENTO), // Formatando para apenas data
        DATA_ADMISSAO: this.formatDate(colaborador.DATA_ADMISSAO),     // Formatando para apenas data
        CTPS: colaborador.CTPS,
        NIS: colaborador.NIS,
        CARGA_HORARIA: this.formatarCargaHoraria(colaborador.CARGA_HORARIA),
        CARGO: colaborador.CARGO,
        IMAGEM: colaborador.IMAGEM,
        EMPRESA: {
          connect: {
            CNPJ: colaborador.CNPJ_EMPRESA
          }
        }


      }
          });
  }

  // Método para formatar a data (removendo a parte de tempo)
  formatDate(date) {
    if (!date) return null;
    const d = new Date(date);
    return new Date(d.getFullYear(), d.getMonth(), d.getDate());
  }
  formatarCargaHoraria(cargaHoraria) {
    // Se já for um objeto Date válido
    if (cargaHoraria instanceof Date) {
      return cargaHoraria;
    }
  
    // Se for string no formato HH:MM:SS
    if (typeof cargaHoraria === 'string' && /^([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$/.test(cargaHoraria)) {
      const [hours, minutes, seconds] = cargaHoraria.split(':');
      return new Date(1970, 0, 1, hours, minutes, seconds);
    }
  
    // Se for apenas um número (como '8')
    const apenasNumeros = cargaHoraria.toString().replace(/\D/g, '');
    const horas = apenasNumeros.slice(0, 2).padStart(2, '0');
    
    return new Date(1970, 0, 1, horas, 0, 0);
  }

    async findByMatricula(matricula) {
      return await this.prisma.colaborador.findFirst({
        where: { MATRICULA: matricula }
       
      });
    }
    

    async update(matricula, colaboradorData) {
      console.log('[ColaboradorRepo] Dados recebidos para atualização:', colaboradorData);
      
      // Validação adicional para CARGA_HORARIA
      if (colaboradorData.CARGA_HORARIA && isNaN(colaboradorData.CARGA_HORARIA.getTime())) {
        throw new Error('CARGA_HORARIA inválida - não é um objeto Date válido');
      }
    
      try {
        const resultado = await this.prisma.colaborador.update({
          where: { MATRICULA: matricula },
          data: colaboradorData
        });
        
        console.log('[ColaboradorRepo] Atualização bem-sucedida:', resultado);
        return resultado;
      } catch (error) {
        console.error('[ColaboradorRepo] Erro detalhado:', error);
        throw error;
      }
    }
  //Alteração -> CNPJ Removido
  async delete(matricula) {
    
    console.log('→ REPOSITORY:');
    console.log('→ MATRICULA:', matricula);
    
    const colaborador = await this.prisma.colaborador.delete({
      where: {
        //MATRICULA_CNPJ_EMPRESA: {
          MATRICULA: matricula,
          //CNPJ_EMPRESA: cnpjEmpresa
        //}
      }
    });
    console.log(colaborador);
    return colaborador;
  }

  async findAllByEmpresa(cnpjEmpresa) {


    try {
      
      
      return await this.prisma.colaborador.findMany({
        where: { CNPJ_EMPRESA: cnpjEmpresa },
        include: {
          USUARIO_COLABORADOR : true
        }
      
      });
    } catch (error) {
      console.error('Erro no repositório:', error);
      throw error;
    }

  }
}

module.exports = new ColaboradorRepository();