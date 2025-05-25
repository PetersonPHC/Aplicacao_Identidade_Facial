const EmpresaRepository = require('../repositories/EmpresaRepository');
const ColaboradorRepository = require('../repositories/ColaboradorRepository');
const axios = require('axios');
const FormData = require('form-data');
const sharp = require('sharp');

class ColaboradorService {
async criarColaborador(dadosColaborador) {
  if (!dadosColaborador) {
    throw new Error('Dados do colaborador não fornecidos');
  }
  
  const cnpj = dadosColaborador.CNPJ_EMPRESA;
  if (!cnpj) {
    throw new Error('CNPJ não fornecido');
  }

  const colaboradorExistente = await ColaboradorRepository.findByMatricula(
    dadosColaborador.MATRICULA,
    cnpj
  );
  
  if (colaboradorExistente) {
    throw new Error('Colaborador já cadastrado');
  }

  let imagemProcessada = null;

  if (dadosColaborador.IMAGEM) {
    try {
      
      // Processa a imagem (converte se necessário)
      const { buffer: imagemBuffer, nomeArquivo, converted } = await this.converterImagemJPG(
        dadosColaborador.IMAGEM,
        'imagem_colaborador.jpg'
      );


      // Armazena a imagem processada para salvar no banco depois
      imagemProcessada = imagemBuffer;

      // Envia para verificação facial
      const form = new FormData();
      form.append('imagem', imagemBuffer, nomeArquivo);

      const verificarFaceResponse = await axios.post(
        'http://127.0.0.1:8000/verificar-face/',
        form,
        {
          headers: {
            ...form.getHeaders(),
            'Accept': 'application/json'
          },
          timeout: 30000
        }
      );

      if (verificarFaceResponse.status !== 200) {
        throw new Error('Falha na verificação facial: ' + (verificarFaceResponse.data.message || 'Resposta inválida da API'));
      }
      
    } catch (error) {
      
      if (error.response && error.response.data) {
        const pythonError = error.response.data;
        if (pythonError.includes('Unsupported image type')) {
          throw new Error('A API de reconhecimento facial só suporta imagens JPG/JPEG. Por favor, converta a imagem antes de enviar.');
        }
      }
      
      throw new Error('Erro na verificação facial: ' + error.message);
    }
  } 
  
  // Cria o objeto do colaborador com a imagem processada (se existir)
  const dadosParaSalvar = {
    ...dadosColaborador,
    CNPJ: cnpj
  };

  // Se a imagem foi processada, substitui pelo buffer convertido
  if (imagemProcessada) {
    dadosParaSalvar.IMAGEM = imagemProcessada;
  }

  return await ColaboradorRepository.create(dadosParaSalvar);
}

async converterImagemJPG(imagemBuffer, nomeArquivo) {
  
  // Verifica se o buffer começa com assinatura PNG (independente do nome do arquivo)
  const isPNG = imagemBuffer.slice(0, 8).toString('hex') === '89504e470d0a1a0a';

  if (isPNG) {
    try {
      
      // Converte PNG para JPG
      const jpgBuffer = await sharp(imagemBuffer)
        .jpeg({ 
          quality: 90,
          mozjpeg: true
        })
        .toBuffer();
      
      // Garante que o nome do arquivo termine com .jpg
      const newFilename = nomeArquivo.replace(/\.[^/.]+$/, '') + '.jpg';
      
      return {
        buffer: jpgBuffer,
        nomeArquivo: newFilename,
        converted: true
      };
    } catch (error) {
      throw new Error('Falha ao converter imagem PNG para JPG: ' + error.message);
    }
  }
  
  return {
    buffer: imagemBuffer,
    nomeArquivo: nomeArquivo,
    converted: false
  };
}


  async buscarColaboradorMatricula( matricula) {
  
    
    const colaborador = await ColaboradorRepository.findByMatricula( matricula);
    if (!colaborador) throw new Error('Colaborador não encontrado');
    
    return {
      ...colaborador,
      CARGA_HORARIA: colaborador.CARGA_HORARIA?.toTimeString().substring(0, 8) || null,
      BANCO_DE_HORAS: colaborador.BANCO_DE_HORAS?.toTimeString().substring(0, 8) || null
    };
  }



  async buscarColaboradorMatriculaCnpj(cnpj, matricula) {
    
    const colaborador = await ColaboradorRepository.findByMatriculaAndCNPJ(cnpj, matricula);
    if (!colaborador) throw new Error('Colaborador não encontrado');
    
    return {
      ...colaborador,
      CARGA_HORARIA: colaborador.CARGA_HORARIA?.toTimeString().substring(0, 8) || null
    };
  }
  async atualizarColaborador(matricula, colaboradorData) {

  
    await this.buscarColaboradorMatricula(matricula);
  
    if (colaboradorData.DATA_NASCIMENTO) {
      colaboradorData.DATA_NASCIMENTO = new Date(colaboradorData.DATA_NASCIMENTO + 'T00:00:00.000Z');
    }
    
    if (colaboradorData.DATA_ADMISSAO) {
      colaboradorData.DATA_ADMISSAO = new Date(colaboradorData.DATA_ADMISSAO + 'T00:00:00.000Z');
    }
  
    if (colaboradorData.CARGA_HORARIA) {
      
      const timeParts = colaboradorData.CARGA_HORARIA.split(':');
      if (timeParts.length < 2 || timeParts.length > 3) {
        throw new Error('Formato de CARGA_HORARIA inválido. Use HH:mm ou HH:mm:ss');
      }
      
      const formattedTime = timeParts.length === 2 
        ? `${colaboradorData.CARGA_HORARIA}:00` 
        : colaboradorData.CARGA_HORARIA;
      
      const dateObj = new Date(`1970-01-01T${formattedTime}`);
      
      if (isNaN(dateObj.getTime())) {
        throw new Error(`Falha ao converter CARGA_HORARIA: ${colaboradorData.CARGA_HORARIA}`);
      }
      
      colaboradorData.CARGA_HORARIA = dateObj;
    }

    // Verificação facial (se imagem foi fornecida)
    let imagemProcessada = null;
    if (colaboradorData.IMAGEM) {
      try {
        
        const { buffer: imagemBuffer, nomeArquivo, converted } = await this.converterImagemJPG(
          colaboradorData.IMAGEM,
          'imagem_colaborador.jpg'
        );


        // Armazena a imagem processada para atualização
        imagemProcessada = imagemBuffer;

        const form = new FormData();
        form.append('imagem', imagemBuffer, nomeArquivo);

        const verificarFaceResponse = await axios.post(
          'http://127.0.0.1:8000/verificar-face/',
          form,
          {
            headers: {
              ...form.getHeaders(),
              'Accept': 'application/json'
            },
            timeout: 30000
          }
        );

        if (verificarFaceResponse.status !== 200) {
          throw new Error('Falha na verificação facial: ' + (verificarFaceResponse.data.message || 'Resposta inválida da API'));
        }
        
      } catch (error) {
        
        if (error.response && error.response.data) {
          const pythonError = error.response.data;
          if (pythonError.includes('Unsupported image type')) {
            throw new Error('A API de reconhecimento facial só suporta imagens JPG/JPEG. Por favor, converta a imagem antes de enviar.');
          }
        }
        
        throw new Error('Erro na verificação facial: ' + error.message);
      }
    } else {
    }
  
    const camposPermitidos = [
      'NOME', 'CPF', 'RG', 'DATA_NASCIMENTO', 'DATA_ADMISSAO',
      'NIS', 'CTPS', 'CARGA_HORARIA', 'CARGO', 'BANCO_DE_HORAS', 'IMAGEM'
    ];
    
    const dadosParaAtualizar = {};
    for (const campo of camposPermitidos) {
      if (colaboradorData[campo] !== undefined) {
        dadosParaAtualizar[campo] = colaboradorData[campo];
      }
    }

    // Se a imagem foi processada, substitui pelo buffer convertido
    if (imagemProcessada) {
      dadosParaAtualizar.IMAGEM = imagemProcessada;
    }
    const resultado = await ColaboradorRepository.update(matricula, dadosParaAtualizar);
  
    return resultado;
  }
  
  //Alteração -> CNPJ Removido
  async deletarColaborador( cnpj, matricula) {

    try {
      
      await this.buscarColaboradorMatriculaCnpj(cnpj, matricula);
      return await ColaboradorRepository.delete(matricula);
    } catch (error) {
      
      
      if (error.message.includes('Foreign key constraint')) {
        throw new Error('Não foi possível deletar: existem registros vinculados');
      }
      throw error;
    }
  }

  async listarColaboradoresPorEmpresa(cnpjEmpresa) {
    await EmpresaRepository.findByCNPJ(cnpjEmpresa); // Verifica se a empresa existe
    
    const colaboradores = await ColaboradorRepository.findAllByEmpresa(cnpjEmpresa);
    
    return colaboradores.map(colab => ({
      ...colab,
      CARGA_HORARIA: colab.CARGA_HORARIA.toTimeString().substring(0, 8)
    }));
  }
}


// Exporta uma instância Singleton
module.exports = new ColaboradorService();