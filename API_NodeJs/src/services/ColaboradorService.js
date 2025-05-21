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

  console.log(`[ColaboradorService] Verificando colaborador matrícula ${dadosColaborador.MATRICULA} na empresa ${cnpj}`);
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
      console.log('[ColaboradorService] Processando imagem do colaborador...');
      
      // Processa a imagem (converte se necessário)
      const { buffer: imagemBuffer, nomeArquivo, converted } = await this.converterImagemJPG(
        dadosColaborador.IMAGEM,
        'imagem_colaborador.jpg'
      );

      console.log(`[ColaboradorService] Imagem preparada para envio: ${nomeArquivo} (${converted ? 'Convertida de PNG' : 'Formato original'})`);

      // Armazena a imagem processada para salvar no banco depois
      imagemProcessada = imagemBuffer;

      // Envia para verificação facial
      const form = new FormData();
      form.append('imagem', imagemBuffer, nomeArquivo);

      console.log('[ColaboradorService] Enviando imagem para verificação facial...');
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
        console.error('[ColaboradorService] Falha na verificação facial:', verificarFaceResponse.data);
        throw new Error('Falha na verificação facial: ' + (verificarFaceResponse.data.message || 'Resposta inválida da API'));
      }
      
      console.log('[ColaboradorService] Verificação facial realizada com sucesso');
    } catch (error) {
      console.error('[ColaboradorService] Erro no processo de verificação facial:', error);
      
      if (error.response && error.response.data) {
        const pythonError = error.response.data;
        if (pythonError.includes('Unsupported image type')) {
          throw new Error('A API de reconhecimento facial só suporta imagens JPG/JPEG. Por favor, converta a imagem antes de enviar.');
        }
      }
      
      throw new Error('Erro na verificação facial: ' + error.message);
    }
  } else {
    console.log('[ColaboradorService] Nenhuma imagem fornecida para verificação facial');
  }
  
  console.log('[ColaboradorService] Criando novo colaborador no banco de dados');
  
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
  console.log(`[ColaboradorService] Verificando necessidade de conversão para: ${nomeArquivo}`);
  
  // Verifica se o buffer começa com assinatura PNG (independente do nome do arquivo)
  const isPNG = imagemBuffer.slice(0, 8).toString('hex') === '89504e470d0a1a0a';
  console.log(`[ColaboradorService] Conteúdo da imagem é PNG? ${isPNG}`);

  if (isPNG) {
    try {
      console.log('[ColaboradorService] Iniciando conversão de PNG para JPG...');
      
      // Converte PNG para JPG
      const jpgBuffer = await sharp(imagemBuffer)
        .jpeg({ 
          quality: 90,
          mozjpeg: true
        })
        .toBuffer();
      
      // Garante que o nome do arquivo termine com .jpg
      const newFilename = nomeArquivo.replace(/\.[^/.]+$/, '') + '.jpg';
      console.log(`[ColaboradorService] Conversão concluída: ${nomeArquivo} -> ${newFilename}`);
      
      return {
        buffer: jpgBuffer,
        nomeArquivo: newFilename,
        converted: true
      };
    } catch (error) {
      console.error('[ColaboradorService] Erro na conversão de imagem:', error);
      throw new Error('Falha ao converter imagem PNG para JPG: ' + error.message);
    }
  }
  
  console.log('[ColaboradorService] Nenhuma conversão necessária - mantendo formato original');
  return {
    buffer: imagemBuffer,
    nomeArquivo: nomeArquivo,
    converted: false
  };
}


  async buscarColaboradorMatricula( matricula) {
    console.log('[ColaboradorService] Buscando colaborador com metodo de matricula:');
    console.log('→ MATRICULA:', matricula);
  
    
    const colaborador = await ColaboradorRepository.findByMatricula( matricula);
    if (!colaborador) throw new Error('Colaborador não encontrado');
    
    return {
      ...colaborador,
      CARGA_HORARIA: colaborador.CARGA_HORARIA?.toTimeString().substring(0, 8) || null,
      BANCO_DE_HORAS: colaborador.BANCO_DE_HORAS?.toTimeString().substring(0, 8) || null
    };
  }



  async buscarColaboradorMatriculaCnpj(cnpj, matricula) {
    console.log('[ColaboradorService] Buscando colaborador com:');
    console.log('→ MATRICULA:', matricula);
    console.log('→ cnpj:', cnpj);
    
    const colaborador = await ColaboradorRepository.findByMatriculaAndCNPJ(cnpj, matricula);
    if (!colaborador) throw new Error('Colaborador não encontrado');
    
    return {
      ...colaborador,
      CARGA_HORARIA: colaborador.CARGA_HORARIA?.toTimeString().substring(0, 8) || null
    };
  }
  async atualizarColaborador(matricula, colaboradorData) {
    console.log('[ColaboradorService] Iniciando atualização', {
      matricula,
      colaboradorData: { ...colaboradorData, IMAGEM: colaboradorData.IMAGEM ? 'Buffer presente' : 'Nenhuma imagem' }
    });
  
    await this.buscarColaboradorMatricula(matricula);
    console.log('[ColaboradorService] Colaborador encontrado, prosseguindo com atualização');
  
    if (colaboradorData.DATA_NASCIMENTO) {
      colaboradorData.DATA_NASCIMENTO = new Date(colaboradorData.DATA_NASCIMENTO + 'T00:00:00.000Z');
    }
    
    if (colaboradorData.DATA_ADMISSAO) {
      colaboradorData.DATA_ADMISSAO = new Date(colaboradorData.DATA_ADMISSAO + 'T00:00:00.000Z');
    }
  
    if (colaboradorData.CARGA_HORARIA) {
      console.log('[ColaboradorService] Formatando CARGA_HORARIA:', colaboradorData.CARGA_HORARIA);
      
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
        console.log('[ColaboradorService] Processando imagem do colaborador...');
        
        const { buffer: imagemBuffer, nomeArquivo, converted } = await this.converterImagemSeNecessario(
          colaboradorData.IMAGEM,
          'imagem_colaborador.jpg'
        );

        console.log(`[ColaboradorService] Imagem preparada para envio: ${nomeArquivo} (${converted ? 'Convertida de PNG' : 'Formato original'})`);

        // Armazena a imagem processada para atualização
        imagemProcessada = imagemBuffer;

        const form = new FormData();
        form.append('imagem', imagemBuffer, nomeArquivo);

        console.log('[ColaboradorService] Enviando imagem para verificação facial...');
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
          console.error('[ColaboradorService] Falha na verificação facial:', verificarFaceResponse.data);
          throw new Error('Falha na verificação facial: ' + (verificarFaceResponse.data.message || 'Resposta inválida da API'));
        }
        
        console.log('[ColaboradorService] Verificação facial realizada com sucesso');
      } catch (error) {
        console.error('[ColaboradorService] Erro no processo de verificação facial:', error);
        
        if (error.response && error.response.data) {
          const pythonError = error.response.data;
          if (pythonError.includes('Unsupported image type')) {
            throw new Error('A API de reconhecimento facial só suporta imagens JPG/JPEG. Por favor, converta a imagem antes de enviar.');
          }
        }
        
        throw new Error('Erro na verificação facial: ' + error.message);
      }
    } else {
      console.log('[ColaboradorService] Nenhuma imagem fornecida para verificação facial');
    }
  
    // Filtra campos permitidos
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
  
    console.log('[ColaboradorService] Dados filtrados para atualização:', { 
      ...dadosParaAtualizar, 
      IMAGEM: dadosParaAtualizar.IMAGEM ? 'Buffer presente' : 'Nenhuma imagem' 
    });
  
    const resultado = await ColaboradorRepository.update(matricula, dadosParaAtualizar);
    console.log('[ColaboradorService] Atualização no repositório concluída:', resultado);
  
    return resultado;
  }
  
  //Alteração -> CNPJ Removido
  async deletarColaborador( cnpj, matricula) {

    try {
      
      console.log('SERVICE');
      console.log('→ MATRICULA:', matricula);
      console.log('→ cnpj:', cnpj);
      await this.buscarColaboradorMatriculaCnpj(cnpj, matricula);
      return await ColaboradorRepository.delete(matricula);
    } catch (error) {
      console.error('[ColaboradorService] Erro ao deletar:', {
        message: error.message,
        stack: error.stack,
        meta: error.meta || null
      });
      
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