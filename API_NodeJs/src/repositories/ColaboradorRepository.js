const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();
class ColaboradorRepository {
  constructor() {
    this.prisma = require('../config/prisma'); // ou sua inicialização do Prisma
  }

  
    async findByMatriculaAndCNPJ(cnpj, matricula) {
      try {
        
        return await this.prisma.colaborador.findFirst({
          where: {
            CNPJ_EMPRESA: cnpj,
            MATRICULA: matricula
           
          }
        });
      } catch (error) {
      
        throw error;
      }
    }
  
  
  async create(colaborador) {

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
formatDate(date) {
  if (!date) return null;

  const d = new Date(date);

  // Corrigir: pegar os componentes de data, mas setar como UTC ZERO
  const year = d.getUTCFullYear();
  const month = d.getUTCMonth();
  const day = d.getUTCDate();

  // Criar Date no UTC com hora zero
  return new Date(Date.UTC(year, month, day, 0, 0, 0, 0));
}

formatarCargaHoraria(cargaHoraria) {
  if (!cargaHoraria) return null;

  if (cargaHoraria instanceof Date) {
    const h = cargaHoraria.getHours();
    const m = cargaHoraria.getMinutes();
    const s = cargaHoraria.getSeconds();
    return new Date(Date.UTC(1970, 0, 1, h, m, s));
  }

  if (typeof cargaHoraria === 'string' && /^([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$/.test(cargaHoraria)) {
    const [hours, minutes, seconds] = cargaHoraria.split(':').map(Number);
    return new Date(Date.UTC(1970, 0, 1, hours, minutes, seconds));
  }

  const apenasNumeros = cargaHoraria.toString().replace(/\D/g, '');
  const horas = parseInt(apenasNumeros.slice(0, 2).padStart(2, '0'), 10);
  return new Date(Date.UTC(1970, 0, 1, horas, 0, 0));
}


    async findByMatricula(matricula) {
      return await this.prisma.colaborador.findFirst({
        where: { MATRICULA: matricula }
       
      });
    }
    

    async update(matricula, colaboradorData) {
      console.log(`chegou ao repository`);
  
      // Validação adicional para CARGA_HORARIA
       colaboradorData.CARGA_HORARIA = this.formatarCargaHoraria(colaboradorData.CARGA_HORARIA);
      
      try {
        const resultado = await this.prisma.colaborador.update({
          where: { MATRICULA: matricula },
          data: colaboradorData
        });
        
        return resultado;
      } catch (error) {
        throw error;
      }
    }
  //Alteração -> CNPJ Removido
  async delete(matricula) {
    
    
    const colaborador = await this.prisma.colaborador.delete({
      where: {
          MATRICULA: matricula,
      }
    });
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
     
      throw error;
    }

  }
}

module.exports = new ColaboradorRepository();