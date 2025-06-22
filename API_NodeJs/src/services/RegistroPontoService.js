const UsuarioRepository = require('../repositories/ColaboradorRepository');
const RegistroPontoRepository = require('../repositories/RegistroPontoRepository');
const ColaboradorService = require('./ColaboradorService');
const axios = require('axios');
const sharp = require('sharp');

class RegistroPontoService {
  
async criarRegistro(registroData) {
    const FormData = require('form-data');
    
    try {
     

      if (!registroData.IMAGEM) {
        throw new Error('Imagem não fornecida para verificação facial');
      }


      const colaboradorExistente = await UsuarioRepository.findByMatriculaAndCNPJ(
        registroData.CNPJ_EMPRESA, registroData.MATRICULA
      );

      if (!colaboradorExistente) {
        throw new Error('Colaborador não encontrado');
      }

      if (!colaboradorExistente.IMAGEM) {
        throw new Error('Imagem do colaborador não cadastrada');
      }

      
      const comparisonForm = new FormData();

      const processImage = (image, nome) => {
        if (!image) throw new Error('Imagem não fornecida: ' + nome);
        
      

        if (typeof image === 'string') {
          return Buffer.from(image, 'base64');
        }
        return Buffer.isBuffer(image) ? image : Buffer.from(image);
      };

    const imagemCadastrada = await this.prepareImage(processImage(colaboradorExistente.IMAGEM, 'cadastrada'));
    const imagemRegistro = await this.prepareImage(processImage(registroData.IMAGEM, 'registro'));
 

      comparisonForm.append('imagem_cadastrada', imagemCadastrada, {
        filename: 'cadastrada.jpg',
        contentType: 'image/jpeg'
      });
      
      comparisonForm.append('imagem_registro_ponto', imagemRegistro, {
        filename: 'registro.jpg',
        contentType: 'image/jpeg'
      });


      const compararFacesResponse = await axios.post(
        'http://127.0.0.1:8000/comparar-faces/',
        comparisonForm,
        {
          headers: {
            ...comparisonForm.getHeaders(),
            'Accept': 'application/json'
          },
          maxContentLength: Infinity,
          maxBodyLength: Infinity
        }
      );

     
      console.log(compararFacesResponse.data);
      if (!compararFacesResponse.data || 
          typeof compararFacesResponse.data.face_detectada === 'undefined') {
        throw new Error('Resposta inválida da API de comparação facial');
      }

      if (!compararFacesResponse.data.face_detectada) {
       
        throw new Error('Nenhuma face detectada na imagem de registro');
      }

      if (!compararFacesResponse.data.faces_iguais) {
        throw new Error('Faces não correspondem');
      }

      return await RegistroPontoRepository.create(registroData);
    } catch (error) {
      
      throw new Error(`Erro na comparação facial: ${error.message}`);
    }
  }

  async prepareImage(imageBuffer) {
  try {
    const metadata = await sharp(imageBuffer).metadata();
    

    const processed = await sharp(imageBuffer)
  .rotate() 
  .resize({ width: 800, height: 800, fit: 'cover', position: 'centre' })
  .normalise()
  .jpeg({ quality: 70, progressive: true, force: true })
  .toBuffer();

   
   
    
    return processed;
  } catch (error) {
    
    throw new Error('Falha no processamento da imagem');
  }
}
  async incluir(cnpj, matricula, data) {

    
    const Registro = await RegistroPontoRepository.include(cnpj, matricula, data);
    if (!Registro) throw new Error('Colaborador não encontrado');
    
  
      return Registro;
    
    
  }

  async buscar(cnpj, matricula, data) {
   
    
    const Registro = await RegistroPontoRepository.find(cnpj, matricula, data);
    if (!Registro) throw new Error('Colaborador não encontrado');
    
  
      return Registro;
    
    
  }


  

  async buscarTodosRegistros(cnpj, matricula) {
  
    
    const Registro = await RegistroPontoRepository.findAll(cnpj, matricula);
    if (!Registro) throw new Error('Colaborador não encontrado');
    
  
      return Registro;
    
    
  }


  async buscarEmpresaPorCNPJ(cnpj) {
    const empresa = await EmpresaRepository.findByCNPJ(cnpj);
    if (!empresa) throw new Error('Empresa não encontrada');
    return empresa;
  }


  async deletarRegistro(cnpj, matricula, data) {

    return await RegistroPontoRepository.delete(cnpj,matricula,data);
   };
  

  //Alteração -> CNPJ Removido
  async listarRegistrosPorColaborador(matricula) {
    await ColaboradorService.buscarColaborador(matricula);
    return await RegistroPontoRepository.findAllByColaborador(matricula);
  }

  /**
   * Calcula o banco de horas mensal de um colaborador
   * @param {string} cnpj
   * @param {string} matricula
   * @param {string|Date} data - Data de referência (qualquer dia do mês desejado)
   * @returns {Promise<number>} - Saldo de horas em milissegundos
   */
  async calcularBancoDeHorasMensal(cnpj, matricula, data) {
    // Buscar colaborador para obter carga horária
    const colaborador = await UsuarioRepository.findByMatriculaAndCNPJ(cnpj, matricula);
    if (!colaborador) throw new Error('Colaborador não encontrado');
    if (!colaborador.CARGA_HORARIA) throw new Error('Carga horária não cadastrada');

    // Extrair carga horária diária em milissegundos
    let cargaHoraria;
    if (typeof colaborador.CARGA_HORARIA === 'string') {
      // Espera-se formato HH:mm:ss
      const [h, m, s] = colaborador.CARGA_HORARIA.split(':').map(Number);
      cargaHoraria = ((h || 0) * 3600 + (m || 0) * 60 + (s || 0)) * 1000;
    } else if (colaborador.CARGA_HORARIA instanceof Date) {
      cargaHoraria = (colaborador.CARGA_HORARIA.getHours() * 3600 + colaborador.CARGA_HORARIA.getMinutes() * 60 + colaborador.CARGA_HORARIA.getSeconds()) * 1000;
    } else {
      throw new Error('Formato de carga horária inválido');
    }

    // Extrair mês e ano da data
    const refDate = new Date(data);
    const year = refDate.getUTCFullYear();
    const month = refDate.getUTCMonth() + 1; // 1-12
    const today = new Date();
    
    // Verifica se é o Mês atual, caso seja, será retornado o calculo até o dia de ontem
    const isCurrentMonth = (refDate.getUTCFullYear() === today.getUTCFullYear() && refDate.getUTCMonth() === today.getUTCMonth());
    const lastDay = isCurrentMonth ? today.getUTCDate() - 1 : new Date(Date.UTC(year, month, 0)).getUTCDate();

    // Buscar todos os registros do mês
    const registros = await RegistroPontoRepository.findAllByMonth(cnpj, matricula, year, month);

    // Agrupar registros por dia //TODO: Pegar Apenas dias úteis
    const registrosPorDia = {};
    for (const reg of registros) {
      const d = new Date(reg.DATA_PONTO);
      const dia = d.getUTCDate();
      if (!registrosPorDia[dia]) registrosPorDia[dia] = [];
      registrosPorDia[dia].push(d);
    }

    let bancoDeHoras = 0;
    for (let dia = 1; dia <= lastDay; dia++) {
      const pontos = (registrosPorDia[dia] || []).sort((a, b) => a - b);
      if (pontos.length >= 2) {
        // Considera o primeiro como entrada e o último como saída
        const entrada = pontos[0];
        const saida = pontos[pontos.length - 1];
        const trabalhado = saida - entrada;
        bancoDeHoras += (trabalhado - cargaHoraria);
      } else if (pontos.length === 1) {
        // Só um ponto: considera falta total
        bancoDeHoras -= cargaHoraria;
      } else {
        // Nenhum ponto: considera falta total
        bancoDeHoras -= cargaHoraria;
      }
    }
    return bancoDeHoras;
  }
}

module.exports = new RegistroPontoService();