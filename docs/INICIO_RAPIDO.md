# 🚀 Guia de Inicialização Rápida

Siga este guia para começar o projeto em menos de 15 minutos.

---

## ✅ Pré-requisitos (Instale Primeiro)

```bash
# Verificar versões instaladas
flutter --version
python --version
git --version
```

Se algo estiver faltando:
- [Flutter](https://flutter.dev/docs/get-started/install)
- [Python 3.8+](https://www.python.org/downloads/)
- [Git](https://git-scm.com/)

---

## 📋 Etapa 1: Clonar e Explorar (2 min)

```bash
# Clonar o repositório
git clone https://seu-repositorio.git eventos-app
cd eventos-app

# Explorar estrutura
ls -la
```

---

## 🐍 Etapa 2: Configurar Backend Python (3 min)

```bash
cd backend

# Criar ambiente virtual
python -m venv venv

# Ativar ambiente virtual
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Instalar dependências
pip install -r requirements.txt

# Copiar arquivo .env
cp .env.example .env
```

### ⚠️ IMPORTANTE: Configurar .env

Abra `backend/.env` e altere:
```env
GOOGLE_SERVICE_ACCOUNT_FILE=service-account.json
GOOGLE_DRIVE_FOLDER_ID=COLOQUE_AQUI_O_ID_DA_PASTA
```

> **Não tem ID da pasta?** Veja `docs/CONFIGURACAO_GOOGLE_DRIVE.md`

---

## 🎨 Etapa 3: Configurar Frontend Flutter (3 min)

```bash
cd ../frontend

# Instalar dependências Flutter
flutter pub get

# Criar build web (se não existir)
flutter create --platforms web .

# (Opcional) Preparar web
flutter config --enable-web
```

---

## 🔑 Etapa 4: Copiar Service Account JSON (2 min)

1. Vá para `backend/`
2. Coloque o arquivo `service-account.json` que baixou do Google Cloud
3. Verifique se o arquivo existe:
   ```bash
   ls backend/service-account.json
   ```

---

## 🚀 Etapa 5: Executar Aplicação (2 min)

### Terminal 1: Backend
```bash
cd backend
# (Se não estiver ativado) source venv/bin/activate  # macOS/Linux
# (Se não estiver ativado) venv\Scripts\activate      # Windows
python main.py
```

✅ Você verá:
```
INFO: Uvicorn running on http://0.0.0.0:8000
```

### Terminal 2: Frontend
```bash
cd frontend
flutter run -d chrome
```

✅ Você verá:
```
Chrome will be started as soon as a connection is established
Waiting for connection from debug service on Chrome...
```

---

## 🎮 Etapa 6: Testar (2 min)

### Teste 1: Abrir em Browser
1. Abra: `http://localhost:3000/?session=teste123`
2. Você deve ver a interface do Flutter

### Teste 2: Capturar e Enviar Foto
1. Clique "Capturar Foto"
2. Escolha uma imagem
3. Clique "Enviar Foto"
4. Aguarde confirmação

### Teste 3: Verificar Google Drive
1. Acesse https://drive.google.com/
2. Abra a pasta configurada
3. Procure por arquivo: `foto_teste123_*.jpg`

---

## 📊 Verificar Status

### Backend rodando?
```bash
curl http://localhost:8000/health
# Esperado: {"status":"ok","timestamp":"..."}
```

### Frontend rodando?
```bash
# Abra no navegador:
http://localhost:3000/?session=teste
```

### Google Drive funcionando?
```bash
curl -X POST http://localhost:8000/upload-foto \
  -F "imagem=@/caminho/foto.jpg" \
  -F "session=teste123"
```

---

## 🔧 Configuração Avançada

### Alterar Porta do Backend
Em `backend/main.py`, altere a última linha:
```python
uvicorn.run(app, host="0.0.0.0", port=8000)  # Mude 8000 para sua porta
```

### Alterar URL do Backend (Frontend)
Em `frontend/lib/main.dart`, procure por:
```dart
const String urlBackend = 'http://localhost:8000/upload-foto';
```

### Adicionar Domínios CORS
Em `backend/main.py`, altere `ALLOWED_ORIGINS`:
```python
ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "https://seu-dominio.com",  # Adicione aqui
]
```

---

## 🆘 Problemas Comuns

### "command not found: flutter"
```bash
# Adicione Flutter ao PATH
# Windows: Editee variáveis de ambiente do sistema
# macOS/Linux: echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

### "Permission denied" no Google Drive
- Verifique se compartilhou a pasta com o email da conta de serviço
- Email formato: `conta@seu-projeto.iam.gserviceaccount.com`

### "CORS blocked"
- Adicione o domínio em `ALLOWED_ORIGINS` no backend
- Reinicie o backend

### "Module not found: google"
```bash
# Ative o ambiente virtual
cd backend
source venv/bin/activate  # macOS/Linux
venv\Scripts\activate     # Windows
pip install -r requirements.txt
```

### "Connection refused" ao enviar foto
- Verifique se backend está rodando
- Verifique se port 8000 não está em uso
- Verifique URL em `main.dart`

---

## 📚 Próximos Passos

Após confirmar que tudo funciona:

1. **Deploy Backend:**
   - Google Cloud Run
   - Heroku
   - Seu próprio servidor

2. **Deploy Frontend:**
   - Firebase Hosting
   - Netlify
   - Vercel

3. **Configuração de Produção:**
   - Usar HTTPS (não HTTP)
   - Ativar logging avançado
   - Configurar alertas de erro
   - Monitorar performance

---

## 📖 Documentação Completa

- [README.md](../README.md) - Visão geral do projeto
- [CONFIGURACAO_GOOGLE_DRIVE.md](CONFIGURACAO_GOOGLE_DRIVE.md) - Setup Google Drive
- [main.py](../backend/main.py) - Código backend comentado
- [main.dart](../frontend/lib/main.dart) - Código frontend comentado

---

## ✨ Checklist de Setup

- [ ] Flutter instalado (`flutter --version`)
- [ ] Python 3.8+ instalado (`python --version`)
- [ ] Git instalado (`git --version`)
- [ ] Repositório clonado
- [ ] Ambiente virtual Python criado e ativado
- [ ] `requirements.txt` instalado (`pip list`)
- [ ] `pubspec.yaml` atualizado (`flutter pub get`)
- [ ] `.env` configurado com ID da pasta
- [ ] `service-account.json` copiadoe colocado
- [ ] Backend rodando em `localhost:8000`
- [ ] Frontend rodando em `localhost:3000`
- [ ] Foto enviada com sucesso
- [ ] Foto aparece no Google Drive

---

**Se tudo foi checado ✅ você está pronto para usar!**

Tempo total esperado: **15 minutos**

---

Para dúvidas, veja `CONFIGURACAO_GOOGLE_DRIVE.md` ou abra uma issue.

**Bom desenvolvimento! 🎉**
