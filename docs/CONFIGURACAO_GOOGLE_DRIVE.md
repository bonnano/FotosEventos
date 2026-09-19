# 📋 Guia Completo: Configuração do Google Drive com Service Account

Este guia passo a passo ensina como configurar a autenticação com Google Drive usando uma Conta de Serviço (Service Account) para upload automático de fotos.

---

## 📌 Pré-requisitos

- Conta Google ativa
- Acesso ao Google Cloud Console (https://console.cloud.google.com/)
- Conhecimento básico de Google Drive
- Pasta no Google Drive onde as fotos serão salvas

---

## 🔑 PASSO 1: Criar um Projeto no Google Cloud Console

### 1.1 Acesse o Google Cloud Console
1. Vá para https://console.cloud.google.com/
2. Faça login com sua conta Google
3. Clique em **"Selecionar um projeto"** (topo esquerdo)

### 1.2 Criar um Novo Projeto
1. Clique em **"NOVO PROJETO"**
2. Digite um nome para o projeto (ex: `Captura-Fotos-Eventos`)
3. Deixe a organização em branco ou selecione a sua (se tiver)
4. Clique em **"CRIAR"**
5. Aguarde a criação (pode levar alguns segundos)

### 1.3 Selecionar o Projeto
1. Depois que o projeto for criado, clique em **"Selecionar um projeto"** novamente
2. Localize seu novo projeto na lista
3. Clique nele para ativá-lo

---

## 🔌 PASSO 2: Habilitar a Google Drive API

### 2.1 Acessar a Biblioteca de APIs
1. No painel esquerdo do Cloud Console, vá para **"APIs e Serviços"**
2. Clique em **"Biblioteca"**

### 2.2 Buscar e Habilitar a Drive API
1. Na barra de busca, digite **"Google Drive API"**
2. Clique no resultado **"Google Drive API"**
3. Clique em **"ATIVAR"**
4. Aguarde a ativação (pode levar alguns segundos)

> ✅ Você verá uma mensagem confirmando que a API foi ativada

---

## 👤 PASSO 3: Criar uma Conta de Serviço

### 3.1 Acessar Contas de Serviço
1. No painel esquerdo, vá para **"APIs e Serviços"**
2. Clique em **"Contas de Serviço"**

### 3.2 Criar Nova Conta de Serviço
1. Clique em **"+ CRIAR CONTA DE SERVIÇO"** (topo)
2. **Preencha os campos:**
   - **ID da Conta de Serviço:** `captura-fotos-eventos` (usar hífens, sem espaços)
   - **Nome de exibição:** `Conta de Serviço - Captura de Fotos`
   - **Descrição:** `Conta usada para upload automático de fotos no Google Drive`
3. Clique em **"CRIAR E CONTINUAR"**

### 3.3 Conceder Funções
1. Na tela "Conceder acesso a este conta de serviço":
   - Em **"Selecione um papel"**, escolha **"Editor"** (permite leitura e escrita)
   - Clique em **"CONTINUAR"**

> ⚠️ **Nota:** Em produção, considere usar um papel mais restritivo se possível.

### 3.4 Criar Chave JSON
1. Na tela "Conceder aos usuários o acesso a esta conta de serviço", você pode deixar em branco
2. Clique em **"CONCLUÍDO"**
3. Você voltará à lista de contas de serviço
4. Localize a conta que acabou de criar na lista
5. Clique no **email** da conta (ex: `captura-fotos-eventos@...`)

### 3.5 Criar Chave Privada
1. Vá para a aba **"Chaves"**
2. Clique em **"Adicionar chave"** e depois **"Criar nova chave"**
3. Escolha **"JSON"** como tipo de chave
4. Clique em **"CRIAR"**
5. Um arquivo `*.json` será automaticamente baixado para seu computador

> 📥 **IMPORTANTE:** Guarde este arquivo com segurança. Ele contém a chave privada!

---

## 📁 PASSO 4: Configurar acesso à pasta

### 4.1 Criar ou Selecionar uma Pasta
1. Acesse https://drive.google.com/
2. Crie uma pasta chamada **"Fotos-Eventos"** (ou escolha uma existente)
3. Clique com botão direito na pasta
4. Selecione **"Compartilhar"**

### 4.2 Extrair o ID da Pasta
1. Na URL da pasta, copie o ID (está entre `/folders/` e o final da URL)
   - Exemplo URL: `https://drive.google.com/drive/folders/1A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P7`
   - ID da pasta: `1A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P7`

> 💾 Você usará este ID na configuração do backend

### 4.3 Acesso conforme o modo escolhido

No modo OAuth (`GOOGLE_DRIVE_AUTH_MODE=oauth`), não é necessário compartilhar a
pasta com a Conta de Serviço: a pasta já pertence à conta Google autorizada no
navegador. Confirme que o login do primeiro uso será feito com
`rbonnano@gmail.com`.

No modo `service_account`, compartilhe a pasta com o email da Conta de Serviço.
Esse modo só deve ser usado com uma **Unidade Compartilhada**, pois uma pasta
comum do Meu Drive não fornece cota para a Conta de Serviço.

1. Na janela de compartilhamento, clique em **"Alterar"** (ao lado de "Restrito")
2. Na barra de busca, **cole o email da conta de serviço** que criou
   - Formato: `captura-fotos-eventos@seu-projeto-id.iam.gserviceaccount.com`
3. Clique em **"Compartilhar"**

> ✅ A conta de serviço agora tem acesso à pasta!

---

## ⚙️ PASSO 5: Configurar o Backend Python

### 5.1 Copiar o Arquivo JSON
1. Localize o arquivo JSON que foi baixado (geralmente em Downloads)
2. Copie-o para a pasta `backend/` do seu projeto
3. Renomeie para **`service-account.json`** (ou use o nome que preferir)

### 5.2 Configurar Variáveis de Ambiente
1. Na pasta `backend/`, crie um arquivo **`.env`** baseado em `.env.example`
2. Abra o arquivo `.env` e configure:

```env
# Para pasta do Meu Drive, use OAuth da conta proprietária.
GOOGLE_DRIVE_AUTH_MODE=oauth
GOOGLE_OAUTH_CLIENT_FILE=oauth-client.json
GOOGLE_OAUTH_TOKEN_FILE=oauth-token.json

# Usado apenas quando GOOGLE_DRIVE_AUTH_MODE=service_account
GOOGLE_SERVICE_ACCOUNT_FILE=service-account.json

# ID da pasta no Google Drive onde salvar as fotos
GOOGLE_DRIVE_FOLDER_ID=1A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P7

# Outras configurações
API_HOST=0.0.0.0
API_PORT=8000
```

> ⚠️ **Importante:** uma Conta de Serviço não possui cota no Meu Drive. Compartilhar uma pasta comum com ela não transfere a cota para o proprietário. Para essa pasta, use OAuth com a conta `rbonnano@gmail.com`.

### 5.2.1 Configurar OAuth do usuário

1. No Google Cloud Console, configure a tela de consentimento OAuth e habilite a Google Drive API.
2. Crie uma credencial OAuth do tipo **Aplicativo para computador**.
3. Baixe o JSON, renomeie para `oauth-client.json` e coloque-o em `backend/`.
4. Execute `python main.py` no terminal do backend e faça login com `rbonnano@gmail.com` quando o navegador abrir.
5. O arquivo `oauth-token.json` será criado automaticamente. Ele permite que os próximos uploads usem a mesma conta sem novo login.

> ⚠️ **Segurança:** nunca versione `oauth-client.json`, `oauth-token.json` ou `service-account.json`.

### 5.3 Instalar Dependências
Execute no terminal da pasta `backend/`:

```bash
pip install -r requirements.txt
```

### 5.4 Executar o Backend
```bash
python main.py
```

> ✅ Se tudo correr bem, você verá: `INFO: Application startup complete`

---

## 🌐 PASSO 6: Configurar o Frontend Flutter Web

### 6.1 Ajustar URL do Backend
No arquivo `lib/main.dart`, localize a linha com a URL do backend:

```dart
const String urlBackend = 'http://localhost:8000/upload-foto';
```

Altere conforme necessário:
- **Desenvolvimento local:** `http://localhost:8000/upload-foto`
- **Produção:** `https://api.seudominio.com/upload-foto`

### 6.2 Configurar CORS no Backend
Abra `backend/main.py` e localize a seção `ALLOWED_ORIGINS`:

```python
ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://localhost:5000",
    "https://meuapp.com",
    # Adicione seus domínios aqui
]
```

### 6.3 Instalar Dependências e Executar
Na pasta `frontend/`, execute:

```bash
flutter pub get
flutter run -d chrome   # Para Chrome (ou seu navegador)
```

---

## 🧪 PASSO 7: Testar a Solução

### 7.1 Via Flutter Web Dev
1. Abra o navegador em: `http://localhost:3000/?session=teste123`
2. Clique em "Capturar Foto"
3. Tire uma foto usando a câmera do dispositivo
4. Clique em "Enviar Foto"
5. Verifique se a foto aparece na pasta do Google Drive

### 7.2 Verificar no Google Drive
1. Acesse https://drive.google.com/
2. Abra a pasta configurada
3. Você deve ver a foto com nome: `foto_teste123_YYYYMMDD_HHMMSS.jpg`

### 7.3 Verificar Logs do Backend
Observe os logs do terminal onde `main.py` está rodando para confirmar:
```
INFO: Autenticação Google Drive realizada com sucesso
INFO: Arquivo salvo no Google Drive: file_id_123456
```

---

## 🛡️ Segurança - Checklist Importante

- [ ] **Não comite** `service-account.json` no Git
- [ ] Adicione `service-account.json` ao `.gitignore`
- [ ] Use variáveis de ambiente para valores sensíveis
- [ ] Em produção, use HTTPS (não HTTP)
- [ ] Configure CORS apenas para domínios confiáveis
- [ ] Implemente autenticação adicional se necessário
- [ ] Rotacione chaves de serviço periodicamente
- [ ] Monitore os logs para atividades suspeitas

---

## 🐛 Troubleshooting

### Erro: "Arquivo de Service Account não encontrado"
- Verifique se o arquivo JSON está na pasta `backend/`
- Verifique o caminho em `GOOGLE_SERVICE_ACCOUNT_FILE`

### Erro: "Permission denied" no Google Drive
- Verifique se a pasta foi compartilhada com o email da conta de serviço
- Verifique o ID da pasta em `GOOGLE_DRIVE_FOLDER_ID`

### Erro: CORS bloqueado
- Verifique se o domínio do frontend está em `ALLOWED_ORIGINS` no `main.py`
- Reinicie o backend após alterar CORS

### Erro: "Unauthorized (401)"
- Verifique se a Google Drive API está habilitada no Cloud Console
- Recrie a chave JSON se necessário

### Erro: Upload lento ou timeout
- Aumente o timeout em `lib/main.dart` (padrão: 30 segundos)
- Reduza a qualidade da imagem (padrão: 85%)

---

## 📞 Suporte e Referências

- [Google Cloud Console](https://console.cloud.google.com/)
- [Documentação Google Drive API](https://developers.google.com/drive/api/guides/about-sdk)
- [Service Accounts](https://cloud.google.com/docs/authentication/service-accounts)
- [Flutter Image Picker](https://pub.dev/packages/image_picker)
- [FastAPI Docs](https://fastapi.tiangolo.com/)

---

## 📝 Resumo da Configuração

| Componente | Arquivo | Informação |
|-----------|---------|-----------|
| Google Cloud Project | Console | `seu-projeto-id` |
| Service Account Email | JSON | `conta@seu-projeto.iam.gserviceaccount.com` |
| Chave Privada | JSON | `service-account.json` |
| ID da Pasta Drive | `.env` | `GOOGLE_DRIVE_FOLDER_ID` |
| URL Backend | `main.dart` | `http://localhost:8000/upload-foto` |

---

**Criado em:** Junho de 2026
**Versão:** 1.0.0
