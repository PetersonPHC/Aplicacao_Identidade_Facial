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
}

module.exports = new RegistroPontoService();