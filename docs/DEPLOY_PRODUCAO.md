# 🚀 Guia de Deploy em Produção

Instruções para implantar a aplicação em produção (cloud ou servidor próprio).

---

## 📋 Checklist Pré-Deploy

- [ ] Todas as variáveis de ambiente configuradas
- [ ] `service-account.json` está seguro (não versionado)
- [ ] Testes locais passando
- [ ] Build web otimizado
- [ ] CORS configurado corretamente
- [ ] HTTPS habilitado (para produção)
- [ ] Logging e monitoramento configurados
- [ ] Backup dos dados do Google Drive
- [ ] Plano de recuperação de falhas

---

## 🔐 Segurança em Produção

### Variáveis de Ambiente

**NUNCA commitar:**
- `service-account.json`
- `.env` (com valores reais)
- Chaves privadas
- Tokens de API

**SEMPRE usar:**
- Variáveis de ambiente gerenciadas
- Secrets do provider cloud
- Criptografia para dados sensíveis

### CORS - Whitelist de Domínios

```python
# backend/main.py
ALLOWED_ORIGINS = [
    "https://meuapp.com",           # Domínio principal
    "https://www.meuapp.com",       # WWW
    "https://app.meuapp.com",       # Subdomínio app
    # NÃO incluir localhost em produção
]
```

### HTTPS Obrigatório

```python
# Redirecionar HTTP para HTTPS (se usando nginx)
# Usar certificados SSL válidos
# Considerar Let's Encrypt (gratuito)
```

---

## ☁️ Opção 1: Google Cloud Run

### 1.1 Pré-requisitos
```bash
# Instalar Google Cloud SDK
# https://cloud.google.com/sdk/docs/install

gcloud init
gcloud auth login
gcloud config set project seu-projeto-id
```

### 1.2 Criar Dockerfile para Backend

```dockerfile
# backend/Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Copiar requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código
COPY . .

# Criar diretório para uploads temporários
RUN mkdir -p temp_uploads

# Expor porta
EXPOSE 8000

# Comando de inicialização
CMD ["python", "main.py"]
```

### 1.3 Deploy Backend

```bash
cd backend

# Build imagem
gcloud builds submit --tag gcr.io/seu-projeto/captura-fotos

# Deploy no Cloud Run
gcloud run deploy captura-fotos \
  --image gcr.io/seu-projeto/captura-fotos \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars GOOGLE_DRIVE_FOLDER_ID=seu_folder_id,GOOGLE_SERVICE_ACCOUNT_FILE=/etc/secrets/service-account.json
```

### 1.4 Deploy Frontend (Firebase Hosting)

```bash
cd frontend

# Build web otimizado
flutter build web --release --dart-define=BACKEND_URL=https://seu-backend-url

# Instalar Firebase CLI
npm install -g firebase-tools
firebase login

# Inicializar Firebase
firebase init hosting

# Deploy
firebase deploy
```

---

## 🐋 Opção 2: Docker + Compose (Seu Servidor)

### 2.1 Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: captura-fotos-backend
    ports:
      - "8000:8000"
    environment:
      - GOOGLE_DRIVE_FOLDER_ID=${GOOGLE_DRIVE_FOLDER_ID}
      - GOOGLE_SERVICE_ACCOUNT_FILE=/app/service-account.json
    volumes:
      - ./backend/service-account.json:/app/service-account.json:ro
      - ./uploads:/app/temp_uploads
    restart: unless-stopped
    networks:
      - app-network

  nginx:
    image: nginx:alpine
    container_name: captura-fotos-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./frontend/build/web:/usr/share/nginx/html:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - backend
    restart: unless-stopped
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  uploads:
```

### 2.2 Nginx Config

```nginx
# nginx.conf
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server backend:8000;
    }

    # Redirecionar HTTP para HTTPS
    server {
        listen 80;
        server_name meuapp.com www.meuapp.com;
        return 301 https://$server_name$request_uri;
    }

    # HTTPS
    server {
        listen 443 ssl http2;
        server_name meuapp.com www.meuapp.com;

        # Certificados SSL
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;

        # Segurança SSL
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;

        # Frontend
        location / {
            root /usr/share/nginx/html;
            try_files $uri $uri/ /index.html;
            add_header Cache-Control "public, max-age=3600";
        }

        # Backend API
        location /api/ {
            proxy_pass http://backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

### 2.3 Deploy com Docker Compose

```bash
# Criar certificados SSL (Let's Encrypt)
sudo certbot certonly --standalone -d meuapp.com -d www.meuapp.com

# Copiar certificados
sudo cp /etc/letsencrypt/live/meuapp.com/fullchain.pem ./ssl/cert.pem
sudo cp /etc/letsencrypt/live/meuapp.com/privkey.pem ./ssl/key.pem

# Iniciar containers
docker-compose up -d

# Verificar status
docker-compose ps

# Ver logs
docker-compose logs -f backend
```

---

## 🌐 Opção 3: Render (Web Service gratuito)

O Render é adequado para este backend porque ele executa uma aplicação FastAPI como
um Web Service. O plano Free é suficiente para testes e uso ocasional, mas o serviço
entra em suspensão após 15 minutos sem tráfego e pode levar cerca de um minuto para
voltar. O sistema de arquivos é temporário; neste projeto isso não perde fotos, pois
os arquivos são removidos após o upload para o Google Drive.

### 3.1 Preparar o repositório

Publique o projeto em um repositório GitHub, GitLab ou Bitbucket. No Render, crie
`New > Web Service` e selecione esse repositório.

No formulário do serviço, configure:

| Campo             | Valor                             |
|-------------------|-----------------------------------|
| Root Directory    | `backend`                         |
| Runtime           | `Python 3`                        |
| Build Command     | `pip install -r requirements.txt` |
| Start Command     | `python main.py`                  |
| Instance Type     | `Free`                            |
| Health Check Path | `/health`                         |

O `main.py` usa automaticamente a variável `PORT` fornecida pelo Render e escuta
em `0.0.0.0`.

### 3.2 Configurar o Google Drive

No serviço do Render, abra `Environment` e adicione:

```text
GOOGLE_DRIVE_AUTH_MODE=service_account
GOOGLE_SERVICE_ACCOUNT_FILE=/etc/secrets/service-account.json
GOOGLE_DRIVE_FOLDER_ID=ID_REAL_DA_PASTA
ALLOWED_ORIGINS=https://SEU-FRONTEND.onrender.com
```

Depois, em `Secret Files`, crie o arquivo `service-account.json` e cole o conteúdo
do JSON da conta de serviço. Não faça upload desse arquivo no repositório. Compartilhe
a pasta do Google Drive com o e-mail da conta de serviço e conceda permissão de
`Editor`.

> Não use `GOOGLE_DRIVE_AUTH_MODE=oauth` no Render: `InstalledAppFlow` exige uma
> interação com navegador e não funciona como inicialização automática do serviço.

### 3.3 Criar e testar o serviço

1. Clique em `Create Web Service` e aguarde o build.
2. Teste `https://SEU-SERVICO.onrender.com/health` e confirme `{"status":"ok"}`.
3. Consulte os logs do serviço se o deploy falhar.

O endereço público do backend será usado no build do Flutter:

```bash
cd frontend
flutter build web --release \
  --dart-define=BACKEND_URL=https://SEU-SERVICO.onrender.com
```

Publique o conteúdo de `frontend/build/web` em um Static Site do Render, Firebase
Hosting ou outro provedor. Se o frontend estiver no Render, configure em `ALLOWED_ORIGINS`
exatamente a URL dele, sem barra final. Após cada novo deploy do frontend, gere o
build novamente com a URL correta.

### 3.4 Limitações importantes do plano Free

- O serviço dorme após 15 minutos sem requisições e o primeiro acesso pode ser lento.
- O sistema de arquivos é efêmero; não armazene fotos, banco SQLite ou credenciais nele.
- Há limite mensal de 750 horas de instância por workspace.
- O Render pode reiniciar o serviço a qualquer momento.

---

## 🌐 Opção 4: Heroku (Mais Simples)

### 3.1 Criar Heroku App

```bash
# Instalar Heroku CLI
brew tap heroku/brew && brew install heroku

# Login
heroku login

# Criar app
heroku create meu-app-captura-fotos

# Adicionar buildpack para Python
heroku buildpacks:add heroku/python -a meu-app-captura-fotos
```

### 3.2 Procfile

```
# backend/Procfile
web: uvicorn main:app --host 0.0.0.0 --port $PORT
```

### 3.3 Configurar Variáveis de Ambiente

```bash
# Via CLI
heroku config:set GOOGLE_DRIVE_FOLDER_ID=seu_id -a meu-app-captura-fotos

# Ou via dashboard Heroku
# Settings → Config Vars
```

### 3.4 Deploy

```bash
cd backend

# Deploy
git push heroku main

# Ver logs
heroku logs --tail -a meu-app-captura-fotos

# URL da app
heroku open -a meu-app-captura-fotos
```

---

## 📊 Monitoramento em Produção

### Logs

```bash
# Backend (Google Cloud Run)
gcloud run logs read captura-fotos --limit 50

# Backend (Docker)
docker-compose logs -f backend

# Heroku
heroku logs --tail
```

### Alertas

Configurar alertas para:
- Taxa de erro > 5%
- Tempo de resposta > 5 segundos
- Falha de conexão com Google Drive
- Falta de espaço em disco

### Health Checks

```bash
# Adicionar monitoramento periódico
# Exemplo com cron:
*/5 * * * * curl -f http://meuapp.com/health || alert
```

---

## 🔄 CI/CD Pipeline (GitHub Actions)

### GitHub Actions Workflow

```yaml
# .github/workflows/deploy.yml
name: Deploy para Produção

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Instalar dependências
        run: |
          cd backend
          pip install -r requirements.txt
      
      - name: Executar testes
        run: |
          cd backend
          # pytest tests/
      
      - name: Build Flutter Web
        uses: subosito/flutter-action@v2
        with:
          flutter-version: 'latest'
      - run: cd frontend && flutter build web --release

  deploy:
    needs: test
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy no Google Cloud Run
        uses: google-github-actions/deploy-cloudrun@v0
        with:
          service: captura-fotos
          image: gcr.io/seu-projeto/captura-fotos
          credentials: ${{ secrets.GCP_SA_KEY }}
```

---

## 📈 Performance em Produção

### Otimizações

1. **Frontend:**
   - Minificar e agrupar CSS/JS
   - Comprimir imagens
   - Cache do navegador (maxAge)
   - CDN para assets estáticos

2. **Backend:**
   - Usar Gunicorn com múltiplos workers
   - Implementar rate limiting
   - Cache de respostas frequentes
   - Otimizar queries ao Google Drive

3. **Banco de Dados:**
   - Índices no Google Drive (via API)
   - Paginação de resultados
   - Limpeza periódica de uploads temporários

### Exemplo de Múltiplos Workers

```bash
# Ao invés de:
python main.py

# Use:
gunicorn main:app \
  --workers 4 \
  --worker-class uvicorn.workers.UvicornWorker \
  --bind 0.0.0.0:8000 \
  --access-logfile - \
  --error-logfile -
```

---

## 🔄 Rollback e Recuperação

### Rollback no Google Cloud Run

```bash
# Ver revisões anteriores
gcloud run revisions list --service captura-fotos

# Voltar para revisão anterior
gcloud run services update-traffic captura-fotos --to-revisions REVISION_ID=100
```

### Rollback no Docker

```bash
# Manter backup da imagem anterior
docker tag captura-fotos:v1.0.1 captura-fotos:v1.0.0-backup

# Restaurar se necessário
docker-compose down
docker tag captura-fotos:v1.0.0-backup captura-fotos:latest
docker-compose up -d
```

---

## 📞 Suporte e Troubleshooting

### Erro: Conexão recusada ao Google Drive
- Verifique se a Service Account tem permissões
- Recrie a chave JSON se necessário
- Verifique se a Google Drive API está habilitada

### Erro: CORS bloqueado em produção
- Adicione domínio em `ALLOWED_ORIGINS`
- Use HTTPS (não HTTP)
- Reinicie a aplicação

### Erro: Upload lento
- Aumente limite de upload
- Reduza qualidade de imagem
- Verifique conexão com Google Drive

---

## ✅ Checklist Pós-Deploy

- [ ] Aplicação acessível via HTTPS
- [ ] Testes manuais bem-sucedidos
- [ ] Logs sendo coletados
- [ ] Alertas configurados
- [ ] Backup automático ativado
- [ ] DNS apontando corretamente
- [ ] Email de suporte funcional
- [ ] Documentação atualizada
- [ ] Notificar stakeholders

---

**Tempo estimado para deploy:** 1-4 horas (dependendo da plataforma)

---

Criado: Junho de 2026  
Versão: 1.0.0
