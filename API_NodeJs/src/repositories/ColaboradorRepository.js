const prisma = require('../config/prisma')
class ColaboradorRepository {
  

  
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