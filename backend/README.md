# 🐍 Backend - Python FastAPI

API de upload de fotos com integração Google Drive.

---

## 📋 Estrutura

```
backend/
├── main.py                     # Servidor principal
├── requirements.txt            # Dependências Python
├── .env.example               # Template de variáveis
├── service-account.example.json # Template de credenciais
└── README.md                  # Este arquivo
```

---

## 🚀 Quick Start

```bash
cd backend

# Criar ambiente virtual
python3 -m venv venv
source venv/bin/activate  # macOS/Linux
# ou
venv\Scripts\activate     # Windows

# Instalar dependências
pip install -r requirements.txt

# Configurar variáveis
cp .env.example .env
# Editar .env com seus valores

# Executar
python main.py

# Acesso: http://localhost:8000
```

---

## 📦 Dependências

| Pacote | Versão | Propósito |
|--------|--------|----------|
| `fastapi` | ^0.104 | Framework web |
| `uvicorn` | ^0.24 | Servidor ASGI |
| `google-auth` | ^2.25 | Autenticação Google |
| `google-api-python-client` | ^1.12 | Google Drive API |
| `python-multipart` | ^0.0.6 | Upload de arquivos |
| `Pillow` | ^10.1 | Processamento de imagens |

---

## ⚙️ Configuração

### Variáveis de Ambiente (.env)

```env
# Google Drive
GOOGLE_SERVICE_ACCOUNT_FILE=service-account.json
GOOGLE_DRIVE_FOLDER_ID=seu_folder_id_aqui

# API
API_HOST=0.0.0.0
API_PORT=8000
API_DEBUG=false

# CORS
ALLOWED_ORIGINS=http://localhost:3000,https://meuapp.com
```

### Service Account JSON

1. Baixe do Google Cloud Console
2. Renomeie para `service-account.json`
3. Coloque na pasta `backend/`

Veja [CONFIGURACAO_GOOGLE_DRIVE.md](../docs/CONFIGURACAO_GOOGLE_DRIVE.md)

---

## 🔌 API Endpoints

### GET /

```bash
curl http://localhost:8000/
```

**Resposta:**
```json
{
  "nome": "API de Upload de Fotos",
  "versao": "1.0.0",
  "status": "online",
  "endpoints": {
    "upload": "/upload-foto",
    "listar": "/listar-fotos",
    "health": "/health"
  }
}
```

### GET /health

```bash
curl http://localhost:8000/health
```

**Resposta:** `{"status":"ok","timestamp":"..."}`

### POST /upload-foto

```bash
curl -X POST http://localhost:8000/upload-foto \
  -F "imagem=@foto.jpg" \
  -F "session=teste123"
```

**Resposta:**
```json
{
  "status": "sucesso",
  "arquivo_id": "1A2B3C...",
  "arquivo_nome": "foto_teste123_20260603_103045.jpg",
  "timestamp": "2026-06-03T10:30:45.123456"
}
```

### GET /listar-fotos

```bash
curl "http://localhost:8000/listar-fotos?limite=10"
```

---

## 🛠️ Desenvolvimento

### Estrutura do Código

```python
# main.py
├── Imports e configuração
├── Logging setup
├── FastAPI app initialization
├── CORS Middleware
├── GoogleDriveManager class
│   ├── _obter_service()       # Auth Google
│   ├── salvar_arquivo()       # Upload
│   └── listar_arquivos_pasta() # List
├── Endpoints
│   ├── GET /
│   ├── GET /health
│   ├── POST /upload-foto ⭐
│   ├── GET /listar-fotos
│   └── OPTIONS /*
└── if __name__ == "__main__"
```

---

## 🔐 Autenticação Google Drive

### Fluxo

```
1. Carregar credentials do JSON
   ↓
2. Refresh token se necessário
   ↓
3. Build cliente Drive autenticado
   ↓
4. Upload arquivo com MediaFileUpload
   ↓
5. Retornar ID do arquivo
```

### Classes Principais

```python
class GoogleDriveManager:
    SERVICE_ACCOUNT_FILE = 'service-account.json'
    FOLDER_ID = 'seu_folder_id'
    SCOPES = [...]
    
    @staticmethod
    def _obter_service() -> Resource
    
    @staticmethod
    def salvar_arquivo(arquivo_bytes: bytes, nome_arquivo: str) -> str
    
    @staticmethod
    def listar_arquivos_pasta(limite: int = 10) -> list
```

---

## 📤 Upload de Arquivo

### Processo

```python
# 1. Recebe multipart
arquivo_bytes = await imagem.read()

# 2. Valida
if arquivo.content_type not in tipos_permitidos:
    raise HTTPException(400, "Tipo inválido")

# 3. Salva temporário
with open(caminho_temp, 'wb') as f:
    f.write(arquivo_bytes)

# 4. Faz upload para Drive
arquivo_id = GoogleDriveManager.salvar_arquivo(
    arquivo_bytes,
    nome_arquivo
)

# 5. Remove temporário
caminho_temp.unlink()

# 6. Retorna JSON
return {"status": "sucesso", "arquivo_id": arquivo_id}
```

---

## 🧪 Testes

### Teste Health Check

```bash
curl http://localhost:8000/health
```

### Teste Upload Simples

```bash
# Criar imagem de teste
python3 -c "from PIL import Image; Image.new('RGB', (100, 100), color='blue').save('test.jpg')"

# Upload
curl -X POST http://localhost:8000/upload-foto \
  -F "imagem=@test.jpg" \
  -F "session=teste123"
```

### Teste Listar Fotos

```bash
curl http://localhost:8000/listar-fotos
```

---

## 📊 Logging

### Níveis

```python
logger.info('Informação importante')
logger.warning('Aviso de atenção')
logger.error('Erro encontrado')
logger.debug('Debug: detalhes técnicos')
```

### Arquivo de Log

Os logs são exibidos no console por padrão. Para salvar em arquivo:

```bash
python main.py > app.log 2>&1
```

---

## 🐛 Troubleshooting

### "Service Account not found"
```python
# Verificar caminho
import os
print(os.path.exists('service-account.json'))

# Usar caminho absoluto se necessário
GOOGLE_SERVICE_ACCOUNT_FILE = '/caminho/completo/service-account.json'
```

### "Permission denied" no Google Drive
- Compartilhe pasta com email da conta
- Email: `seu-service-account@seu-projeto.iam.gserviceaccount.com`

### "Connection refused"
- Verifique ALLOWED_ORIGINS
- Reinicie aplicação

### Slow uploads
- Aumente `workers` no Uvicorn
- Reduza qualidade no frontend
- Verifique conexão de rede

---

## 🚀 Produção

### Múltiplos Workers

```bash
gunicorn main:app \
  --workers 4 \
  --worker-class uvicorn.workers.UvicornWorker \
  --bind 0.0.0.0:8000
```

### Docker

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["python", "main.py"]
```

Para usar OAuth localmente, não copie os arquivos de credenciais para a imagem. Inicie o container montando-os em `/app` e carregando o arquivo `.env`:

```powershell
docker build -t eventos-backend:test .
docker run -d --name eventos-backend -p 8000:8000 `
  --env-file .env `
  -v "${PWD}/oauth-client.json:/app/oauth-client.json:ro" `
  -v "${PWD}/oauth-token.json:/app/oauth-token.json" `
  eventos-backend:test
```

O `oauth-token.json` deve conter um token OAuth já autorizado. Se ele não existir ou estiver expirado sem `refresh_token`, execute a primeira autorização fora do container ou disponibilize uma janela/URL de callback apropriada para o fluxo OAuth.

```bash
docker build -t captura-fotos .
docker run -p 8000:8000 -e GOOGLE_DRIVE_FOLDER_ID=seu_id captura-fotos
```

---

## 📖 Documentação do Código

Veja [main.py](main.py) para:
- Documentação completa de cada função
- Exemplos de uso
- Tratamento de erros
- Comentários detalhados

---

## 🔗 Referências

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Uvicorn](https://www.uvicorn.org/)
- [Google Drive API](https://developers.google.com/drive/api)
- [Google Auth Library](https://google-auth.readthedocs.io/)

---

**Criado:** Junho de 2026  
**Versão:** 1.0.0
