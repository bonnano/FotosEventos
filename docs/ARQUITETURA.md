# 🏗️ Arquitetura do Sistema

Visão completa da arquitetura da solução de captura e upload de fotos.

---

## 📊 Diagrama de Fluxo Completo

```
┌─────────────────────────────────────────────────────────────────┐
│                      USUÁRIO FINAL                              │
│                   (Smartphone/Tablet)                           │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ 1. Lê QR Code
                         │    https://meuapp.com/?session=ABC123
                         ▼
        ┌─────────────────────────────────┐
        │   QR Code Scanner App (Nativo)  │
        │   (Câmera do SO)                │
        └────────┬────────────────────────┘
                 │
                 │ 2. Abre em navegador
                 ▼
    ┌──────────────────────────────────────┐
    │        Flutter Web (No Chrome)       │
    │  ┌────────────────────────────────┐  │
    │  │  URL Parser (extract session)  │  │
    │  │  - session=ABC123             │  │
    │  └────────────────────────────────┘  │
    │                                       │
    │  ┌────────────────────────────────┐  │
    │  │   Image Picker Plugin          │  │
    │  │   (acessa câmera nativa)       │  │
    │  └────────────────────────────────┘  │
    │                                       │
    │  ┌────────────────────────────────┐  │
    │  │   UI com Preview da Foto       │  │
    │  │   - Capturada: [Imagem]        │  │
    │  │   - [Enviar] [Descartar]       │  │
    │  └────────────────────────────────┘  │
    │                                       │
    │  ┌────────────────────────────────┐  │
    │  │   HTTP Client (dart:io)        │  │
    │  │   POST multipart/form-data     │  │
    │  └────────────────────────────────┘  │
    └──────────────┬───────────────────────┘
                   │
                   │ 3. POST /upload-foto
                   │    - imagem (bytes)
                   │    - session (ABC123)
                   │    Headers: multipart/form-data
                   │    CORS: Origin verificado
                   ▼
    ┌──────────────────────────────────────┐
    │      Backend Python FastAPI          │
    │  ┌────────────────────────────────┐  │
    │  │   CORS Middleware              │  │
    │  │   - Valida origem               │  │
    │  │   - Método OPTIONS              │  │
    │  └────────────────────────────────┘  │
    │                                       │
    │  ┌────────────────────────────────┐  │
    │  │   POST /upload-foto            │  │
    │  │   - Recebe multipart           │  │
    │  │   - Valida tipo (jpeg/png)     │  │
    │  │   - Valida tamanho             │  │
    │  │   - Valida session ID          │  │
    │  └────────────────────────────────┘  │
    │                                       │
    │  ┌────────────────────────────────┐  │
    │  │   Google Auth Manager          │  │
    │  │   - Carrega service-account.json│ │
    │  │   - Refresh credentials        │  │
    │  │   - Build cliente Drive        │  │
    │  └────────────────────────────────┘  │
    │                                       │
    │  ┌────────────────────────────────┐  │
    │  │   Google Drive Upload          │  │
    │  │   - Salva arquivo temporário   │  │
    │  │   - Upload para pasta          │  │
    │  │   - Nome: foto_{session}_{ts}  │  │
    │  │   - Retorna arquivo_id         │  │
    │  │   - Remove temporário          │  │
    │  └────────────────────────────────┘  │
    │                                       │
    │  ┌────────────────────────────────┐  │
    │  │   Logging & Response           │  │
    │  │   - Registra sucesso/erro      │  │
    │  │   - Retorna JSON com ID        │  │
    │  └────────────────────────────────┘  │
    └──────────────┬───────────────────────┘
                   │
                   │ 4. Response JSON
                   │    {
                   │      "status": "sucesso",
                   │      "arquivo_id": "...",
                   │      "arquivo_nome": "...",
                   │      "timestamp": "..."
                   │    }
                   ▼
    ┌──────────────────────────────────────┐
    │       Flutter Web (Response Handler) │
    │       - Parse JSON                   │
    │       - Mostrar mensagem sucesso     │
    │       - Limpar preview               │
    │       - Pronto para próxima foto     │
    └──────────────┬───────────────────────┘
                   │
                   │ 5. Sinalização Visual
                   │    ✅ Foto enviada com sucesso!
                   ▼
    ┌──────────────────────────────────────┐
    │     Google Drive Pasta Compartilhada │
    │     /Fotos-Eventos/                  │
    │     ├── foto_ABC123_20260603_103045  │
    │     ├── foto_DEF456_20260603_103100  │
    │     └── foto_GHI789_20260603_103115  │
    └──────────────────────────────────────┘
```

---

## 🏛️ Arquitetura em Camadas

```
┌─────────────────────────────────────────────────────────────┐
│                    CAMADA DE APRESENTAÇÃO                   │
│         (Flutter Web - Interface do Usuário)                │
├─────────────────────────────────────────────────────────────┤
│ • Pages (CapturaFotosPage)                                  │
│ • Widgets (UI components)                                   │
│ • State Management (Provider)                               │
│ • Image Picker (Integração com câmera)                      │
└────────────────────┬────────────────────────────────────────┘
                     │ HTTP REST API
                     │ (JSON + Multipart)
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              CAMADA DE APLICAÇÃO (Backend)                  │
│         (FastAPI - Lógica de Negócio)                       │
├─────────────────────────────────────────────────────────────┤
│ • Router endpoints (/upload-foto, /listar-fotos)           │
│ • Validation (file type, size, session)                     │
│ • File handling (saving, cleanup)                           │
│ • Error handling & logging                                  │
│ • CORS middleware                                           │
└────────────────────┬────────────────────────────────────────┘
                     │ Google API
                     │ (OAuth2 Service Account)
                     ▼
┌─────────────────────────────────────────────────────────────┐
│           CAMADA DE INTEGRAÇÃO (Google Drive)               │
│         (Google Drive API - Armazenamento)                  │
├─────────────────────────────────────────────────────────────┤
│ • GoogleDriveManager class                                  │
│ • Authentication (Service Account credentials)              │
│ • File upload (MediaFileUpload)                             │
│ • Folder management (FOLDER_ID)                             │
│ • List operations                                           │
└────────────────────┬────────────────────────────────────────┘
                     │ Cloud API
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              CAMADA DE DADOS (Google Cloud)                 │
│         (Google Drive - Persistência)                       │
├─────────────────────────────────────────────────────────────┤
│ • Google Drive Storage                                      │
│ • Service Account permissions                               │
│ • Shared folder: /Fotos-Eventos/                           │
│ • File metadata (ID, name, timestamp)                       │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔗 Componentes e Dependências

### Frontend (Flutter Web)

```
lib/main.dart
├── MyApp (MaterialApp)
└── CapturaFotosPage (StatefulWidget)
    ├── ImagePicker (image_picker plugin)
    ├── HttpClient (http package)
    ├── Logger (logging)
    ├── UI Components
    │   ├── AppBar
    │   ├── Camera Area
    │   ├── Preview Area
    │   ├── Action Buttons
    │   └── Message Dialogs
    └── State Management
        ├── _imagemCapturada (Uint8List)
        ├── _sessaoId (String)
        ├── _fazendoUpload (bool)
        └── _mensagem (String)
```

### Backend (Python FastAPI)

```
main.py
├── FastAPI app
├── CORS Middleware
├── GoogleDriveManager class
│   ├── _obter_service() → Google Drive client
│   ├── salvar_arquivo() → Upload file
│   └── listar_arquivos_pasta() → List files
├── Endpoints
│   ├── GET / (root info)
│   ├── GET /health (health check)
│   ├── POST /upload-foto (upload endpoint)
│   ├── GET /listar-fotos (list photos)
│   └── OPTIONS /* (CORS preflight)
└── Error Handlers
    ├── HTTPException
    ├── FileNotFoundError
    └── Google API errors
```

---

## 📡 Fluxo de Dados

### Upload de Foto

```
1. Frontend Prepara:
   ├── Captura bytes da imagem
   ├── Extrai session da URL
   ├── Cria requisição multipart
   └── Headers: Content-Type: multipart/form-data

2. Network:
   ├── HTTP POST
   ├── Endpoint: /upload-foto
   ├── Body: [imagem bytes] + [session_id]
   └── Timeout: 30 segundos

3. Backend Processa:
   ├── Recebe multipart request
   ├── Valida tipo de arquivo
   ├── Valida tamanho
   ├── Salva temporariamente
   ├── Autentica com Google
   └── Faz upload para Drive

4. Google Drive:
   ├── Recebe arquivo
   ├── Armazena em pasta
   ├── Retorna arquivo_id
   └── Backend limpa temp

5. Response ao Frontend:
   ├── Status: 200 OK
   ├── JSON: {arquivo_id, timestamp}
   └── Frontend exibe: ✅ Sucesso!
```

### Listar Fotos

```
1. Frontend:
   ├── GET /listar-fotos?limite=10
   └── Sem body

2. Backend:
   ├── Autentica com Google
   ├── Query pasta no Drive
   ├── Limita resultados
   └── Ordena por data (DESC)

3. Google Drive:
   ├── Busca files na pasta
   ├── Retorna metadata
   └── [id, name, createdTime, webViewLink]

4. Response:
   ├── Status: 200 OK
   ├── JSON: {total, arquivos[]}
   └── Frontend exibe lista
```

---

## 🔐 Fluxo de Autenticação (Google Drive)

```
┌──────────────────────────┐
│  Service Account JSON    │
│  ├── project_id          │
│  ├── private_key         │
│  ├── client_email        │
│  └── ...                 │
└────────┬─────────────────┘
         │
         │ Load
         ▼
┌──────────────────────────────────┐
│  Google Auth Library             │
│  Credentials.from_service_account│
│  _file()                         │
└────────┬─────────────────────────┘
         │
         │ Sign JWT
         ▼
┌──────────────────────────────────┐
│  Google OAuth 2.0 Token Endpoint │
│  https://oauth2.googleapis.com   │
│  /token                          │
└────────┬─────────────────────────┘
         │
         │ Return Access Token
         ▼
┌──────────────────────────────────┐
│  Google Drive API                │
│  Authorization: Bearer {token}   │
└────────┬─────────────────────────┘
         │
         │ Request authenticated
         ▼
┌──────────────────────────────────┐
│  Upload/List Photos              │
│  (com permissões de escrita)     │
└──────────────────────────────────┘
```

---

## 📊 Modelo de Dados

### Requisição Upload

```json
{
  "method": "POST",
  "endpoint": "/upload-foto",
  "headers": {
    "Content-Type": "multipart/form-data; boundary=---..."
  },
  "body": {
    "imagem": "bytes_da_imagem.jpg",
    "session": "ABC123XYZ"
  }
}
```

### Resposta Sucesso (200)

```json
{
  "status": "sucesso",
  "mensagem": "Foto salva com sucesso no Google Drive",
  "arquivo_id": "1ABC123...XYZ789",
  "arquivo_nome": "foto_ABC123XYZ_20260603_103045.jpg",
  "timestamp": "2026-06-03T10:30:45.123456",
  "session": "ABC123XYZ"
}
```

### Resposta Erro (400/500)

```json
{
  "status": "erro",
  "mensagem": "Descrição do erro",
  "detalhe": "Detalhes técnicos (se disponível)"
}
```

### Resposta Listar Fotos

```json
{
  "status": "sucesso",
  "total": 5,
  "arquivos": [
    {
      "id": "1ABC123...XYZ789",
      "nome": "foto_ABC123_20260603_103045.jpg",
      "criado_em": "2026-06-03T10:30:45.123456Z",
      "link": "https://drive.google.com/file/d/..."
    }
  ]
}
```

---

## 🚀 Performance e Escalabilidade

### Otimizações Implementadas

```
Frontend:
├── Image compression (qualidade 85%)
├── Timeout 30s
├── Error handling robusto
└── Cache do navegador

Backend:
├── Validação rápida
├── Arquivo temporário (cleanup automático)
├── Logging eficiente
├── Suporte a múltiplos workers
└── Rate limiting (futuro)

Google Drive:
├── Upload resumível
├── Pasta compartilhada (sem duplicação)
├── Índices por session_id
└── Metadata otimizada
```

### Limitações Conhecidas

```
Frontend:
├── Tamanho máximo upload: ~100MB (navegador)
├── Timeout de 30s (conexões lentas)
└── Dependência de câmera nativa

Backend:
├── Upload simultâneos: limitado por workers
├── Temp storage: precisa espaço em disco
└── Rate limit: 1000 req/dia (Google Drive)

Google Drive:
├── Armazenamento: limite da conta Google
├── Rate limit: 100 MB/segundo por arquivo
└── Latência: depende da conexão
```

---

## 📈 Escalabilidade Futura

```
Se crescer demais:
├── Frontend
│   ├── Adicionar progressive web app (PWA)
│   ├── Service workers para offline
│   └── Cache local de fotos
├── Backend
│   ├── Adicionar fila (Celery + Redis)
│   ├── Implementar rate limiting
│   ├── Cache de metadados
│   └── Database local (SQLite/PostgreSQL)
└── Storage
    ├── Trocar Google Drive por S3/Cloud Storage
    ├── Implementar versionamento
    ├── Adicionar backup automático
    └── Análise de uso com BigQuery
```

---

## 🔍 Monitoramento e Observabilidade

```
Logs:
├── Frontend: console.log + logger package
├── Backend: Python logging
└── Google Drive: Activity logs

Métricas:
├── Taxa de sucesso de upload
├── Tempo médio de upload
├── Tamanho médio de arquivo
├── Taxa de erro por tipo
└── Latência de resposta

Alertas:
├── Taxa de erro > 5%
├── Tempo de resposta > 5s
├── Falha de autenticação Google
├── Espaço em disco < 10%
└── Taxa de limite (quota) excedida
```

---

## 📝 Roadmap de Melhorias

```
MVP (Atual):
✅ Captura de foto
✅ Upload para Google Drive
✅ Interface básica
✅ Documentação

v1.1 (Próximas semanas):
- [ ] Autenticação de usuário
- [ ] Histórico de uploads
- [ ] Busca de fotos
- [ ] Temas escuro/claro

v1.2 (Próximos meses):
- [ ] PWA (installável)
- [ ] Filtros de imagem
- [ ] Edição antes de upload
- [ ] Compartilhamento de fotos

v2.0 (Futuro):
- [ ] Database próprio
- [ ] Galeria integrada
- [ ] API pública
- [ ] App mobile nativo
```

---

**Criado:** Junho de 2026  
**Versão:** 1.0.0  
**Arquiteto:** Senior Software Architect - Flutter & Python Expert
