const UsuarioRepository = require('../repositories/ColaboradorRepository');
const RegistroPontoRepository = require('../repositories/RegistroPontoRepository');
const ColaboradorService = require('./ColaboradorService');
const axios = require('axios');

class RegistroPontoService {
  
  async criarRegistro(registroData) {
    // Importa FormData no início da função
    const FormData = require('form-data');
    
    try {
      if (!registroData.IMAGEM) {
        throw new Error('Imagem não fornecida para verificação facial');
      }
  
      // 1. Verificação facial usando FormData
      const form = new FormData();
      form.append('imagem', registroData.IMAGEM, 'imagem_capturada.jpg');
  
      const verificarFaceResponse = await axios.post(
        'http://127.0.0.1:8000/verificar-face/',
        form,
        {
          headers: {
            ...form.getHeaders(),
            'Accept': 'application/json'
          }
        }
      );
  
      if (verificarFaceResponse.status !== 200) {
        throw new Error('Falha na verificação facial: ' + verificarFaceResponse.data.message);
      }
  
      // 2. Buscar colaborador
      const colaboradorExistente = await UsuarioRepository.findByMatriculaAndCNPJ(
        registroData.CNPJ_EMPRESA, registroData.MATRICULA
      );
  
      if (!colaboradorExistente) {
        throw new Error('Colaborador não encontrado');
      }
  
      if (!colaboradorExistente.IMAGEM) {
        throw new Error('Imagem do colaborador não cadastrada');
      }
  
      // 3. Comparação de faces
      const comparisonForm = new FormData();
  
      // Processa as imagens garantindo que são Buffers
      const processImage = (image) => {
        if (!image) throw new Error('Imagem não fornecida');
        if (typeof image === 'string') {
          return Buffer.from(image, 'base64');
        }
        return Buffer.isBuffer(image) ? image : Buffer.from(image);
      };
  
      // Adiciona as imagens com os nomes EXATOS que o FastAPI espera
      comparisonForm.append('imagem_cadastrada', processImage(colaboradorExistente.IMAGEM), {
        filename: 'cadastrada.jpg',
        contentType: 'image/jpeg'
      });
      
      comparisonForm.append('imagem_registro_ponto', processImage(registroData.IMAGEM), {
        filename: 'registro.jpg',
        contentType: 'image/jpeg'
      });
  
      // Envio para a API
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
  
      // Verificação da resposta
      if (!compararFacesResponse.data || 
          typeof compararFacesResponse.data.face_detectada === 'undefined' ||
          typeof compararFacesResponse.data.faces_iguais === 'undefined') {
        throw new Error('Resposta inválida da API de comparação facial');
      }
  
      if (!compararFacesResponse.data.face_detectada) {
        throw new Error('Nenhuma face detectada na imagem de registro');
      }
  
      if (!compararFacesResponse.data.faces_iguais) {
        throw new Error('Faces não correspondem');
      }
  
      // 4. Criar registro
      return await RegistroPontoRepository.create(registroData);
    } catch (error) {
      console.error('Erro detalhado:', {
        message: error.message,
        responseData: error.response?.data,
        requestConfig: {
          url: error.config?.url,
          headers: error.config?.headers,
          data: error.config?.data
        }
      });
      
      // Corrigido: usando throw new Error em vez de throw error(...)
      throw new Error(`Erro na comparação facial: ${error.message}`);
    }
  }


  async buscar(cnpj, matricula, data) {
    console.log('[ColaboradorService] Buscando colaborador com:');
    console.log('→ MATRICULA:', matricula, 'Tipo:', typeof matricula);
    console.log('→ CNPJ:', cnpj, 'Tipo:', typeof cnpj);
    console.log('→ DATA:', data, 'Tipo:', typeof data);
    
    const Registro = await RegistroPontoRepository.find(cnpj, matricula, data);
    if (!Registro) throw new Error('Colaborador não encontrado');
    
  
      return Registro;
    
    
  }


  

  async buscarTodosRegistros(cnpj, matricula) {
    console.log('[ColaboradorService] Buscando colaborador com:');
    console.log('→ MATRICULA:', matricula, 'Tipo:', typeof matricula);
    console.log('→ CNPJ:', cnpj, 'Tipo:', typeof cnpj);
    
    const Registro = await RegistroPontoRepository.findAll(cnpj, matricula);
    if (!Registro) throw new Error('Colaborador não encontrado');
    
  
      return Registro;
    
    
  }


  async buscarEmpresaPorCNPJ(cnpj) {
    const empresa = await EmpresaRepository.findByCNPJ(cnpj);
    if (!empresa) throw new Error('Empresa não encontrada');
    return empresa;
  }


  
  //Alteração -> CNPJ Removido
  async deletarRegistro(matricula, data) {
    await this.buscarRegistro(matricula, data); // Verifica se existe
    return await RegistroPontoRepository.delete(
      matricula, 
      new Date(data)
    );
  }

  //Alteração -> CNPJ Removido
  async listarRegistrosPorColaborador(matricula) {
    await ColaboradorService.buscarColaborador(matricula);
    return await RegistroPontoRepository.findAllByColaborador(matricula);
  }
}

// Exporta uma instância Singleton (recomendado para serviços stateless)
module.exports = new RegistroPontoService();