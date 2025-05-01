const prisma = require('./config/prisma');
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const multer = require('multer');
const upload = multer();

const ColaboradorController = require('./controllers/ColaboradorController');
const EmpresaController = require('./controllers/EmpresaController');
const UsuarioController = require('./controllers/UsuarioController');
const RegistroPontoController = require('./controllers/RegistroPontoController');


const app = express();

// Middlewares - ORDEM CORRETA
app.use(bodyParser.urlencoded({ extended: true })); // Para form-data - DEVE VIR PRIMEIRO
app.use(express.json());
app.use(cors()); // Configuração simplificada do CORS

// Rotas de Empresa
app.post('/empresas', EmpresaController.criar);
app.get('/empresas/:cnpj', EmpresaController.buscarPorCNPJ);
app.put('/empresas/:cnpj', EmpresaController.atualizar);
app.delete('/empresas/:cnpj', EmpresaController.deletar);
app.get('/empresas', EmpresaController.listar);

// Rotas de Colaborador
app.post('/colaboradores', upload.single('IMAGEM'), ColaboradorController.criar);
app.get('/colaboradores/:cnpj/:matricula', ColaboradorController.buscar);
app.put('/colaboradores/:cnpjEmpresa/:matricula', ColaboradorController.atualizar);
app.delete('/colaboradores/:cnpjEmpresa/:matricula', ColaboradorController.deletar);
app.get('/colaboradores/:cnpjEmpresa', ColaboradorController.listarPorEmpresa);

// Rotas de Usuário
app.post('/usuarios', UsuarioController.criar);
app.get('/usuarios/:cnpjEmpresa/:matricula', UsuarioController.buscar);
app.put('/usuarios/:cnpjEmpresa/:matricula', UsuarioController.atualizar);
app.delete('/usuarios/:cnpjEmpresa/:matricula', UsuarioController.deletar);
app.get('/usuarios/:cnpjEmpresa', UsuarioController.listarPorEmpresa);
app.post('/loginEmpresa', UsuarioController.loginEmpresa);
app.post('/loginColaborador', UsuarioController.loginColaborador);

// Rotas de Registro de Ponto
app.post('/registros-ponto', RegistroPontoController.criar);
app.get('/registros-ponto/:cnpjEmpresa/:matricula/:data', RegistroPontoController.buscar);
app.delete('/registros-ponto', RegistroPontoController.deletar);
app.get('/registros-ponto/:cnpjEmpresa/:matricula', RegistroPontoController.listarPorColaborador);

// Tratamento de erros
app.use((err, req, res, next) => {
  console.error('Erro não tratado:', err.stack);
  res.status(500).json({ 
    error: 'Erro interno no servidor',
    message: err.message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});


// Iniciar servidor
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);

  // Adicione outras rotas conforme necessário
});