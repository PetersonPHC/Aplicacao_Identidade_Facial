from fastapi import FastAPI, File, UploadFile # type: ignore
import face_recognition as fr # type: ignore
from PIL import Image # type: ignore
import io
import numpy as np # type: ignore

app = FastAPI()

@app.post("/verificar-face/")
async def verificar_face(imagem: UploadFile = File(...)):
    # Lê a imagem diretamente da requisição
    imagem_bytes = await imagem.read()
    
    # Converte os bytes em uma imagem PIL
    imagem_pil = Image.open(io.BytesIO(imagem_bytes))

    # Converte a imagem PIL para um array numpy
    imagem_array = np.array(imagem_pil)

    # Tenta reconhecer uma face
    rosto = fr.face_encodings(imagem_array)

    if len(rosto) > 0:
        return {"face_detectada": True}
    else:
        return {"face_detectada": False}

@app.post("/comparar-faces/")
async def comparar_faces(imagem_cadastrada: UploadFile = File(...), imagem_registro_ponto: UploadFile = File(...)):
    
    # Lê as imagens diretamente da requisição
    imagem_cadastrada_bytes = await imagem_cadastrada.read()
    imagem_registro_ponto_bytes = await imagem_registro_ponto.read()

    # Converte os bytes em imagens PIL
    imagem_cadastrada_pil = Image.open(io.BytesIO(imagem_cadastrada_bytes))
    imagem_registro_ponto_pil = Image.open(io.BytesIO(imagem_registro_ponto_bytes))

     # Converte as imagens PIL para arrays numpy
    imagem_cadastrada_array = np.array(imagem_cadastrada_pil)
    imagem_registro_ponto_array = np.array(imagem_registro_ponto_pil)

    # Tenta codificar as faces
    try:
        imagem_cadastrada_encode = fr.face_encodings(imagem_cadastrada_array)[0]
        imagem_registro_ponto_encode = fr.face_encodings(imagem_registro_ponto_array)[0]
    # Caso não seja possível codificar a face (ex: Face não humana)
    except Exception as e:
        return {
            "face_detectada": False,
            "faces_iguais": False
        }


    # Compara as faces
    resultado = fr.compare_faces([imagem_cadastrada_encode], imagem_registro_ponto_encode)

    # Converte o resultado de numpy.bool_ para bool nativo do Python
    if(bool(resultado[0]) == False):
        return {
            "face_detectada": True,
            "faces_iguais": False
        }
    else:
        return {
            "face_detectada": True,
            "faces_iguais": True
        }

