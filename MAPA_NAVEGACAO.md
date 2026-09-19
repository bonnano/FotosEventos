# 🗺️ Mapa de Navegação - Onde Encontrar Tudo

Guia rápido para encontrar exatamente o que você precisa.

---

## 🎯 Estou Começando Agora

### Não tenho ideia por onde começar
👉 **Leia:** [RESUMO_EXECUTIVO.md](RESUMO_EXECUTIVO.md) (5 min)
- Visão rápida do que foi entregue
- Próximos passos
- Checklist inicial

### Preciso de visão geral do projeto
👉 **Leia:** [README.md](README.md) (10 min)
- Arquitetura completa
- Requisitos
- Instalação detalhada
- Troubleshooting

### Quero começar em 15 minutos
👉 **Leia:** [docs/INICIO_RAPIDO.md](docs/INICIO_RAPIDO.md)
- Setup passo a passo
- Comandos prontos para copiar
- Verificação rápida

---

## 🐍 Trabalhando com Python/Backend

### Quero entender o backend
👉 **Leia:** [backend/README.md](backend/README.md)
- Estrutura do código
- Endpoints disponíveis
- Configuração

### Preciso configurar o Google Drive
👉 **Leia:** [docs/CONFIGURACAO_GOOGLE_DRIVE.md](docs/CONFIGURACAO_GOOGLE_DRIVE.md) ⭐ IMPORTANTE
- Passo a passo completo
- Google Cloud Console
- Service Account
- Compartilhamento de pasta

### Vou modificar o código backend
👉 **Consulte:** [backend/main.py](backend/main.py)
- 500+ linhas comentadas
- Estrutura modular
- Exemplos de implementação

### Como testar a API?
👉 **Leia:** [docs/TESTES_API.md](docs/TESTES_API.md)
- Exemplos cURL
- Exemplos Postman
- Exemplos Python
- Testes automáticos

### Preciso fazer deploy
👉 **Leia:** [docs/DEPLOY_PRODUCAO.md](docs/DEPLOY_PRODUCAO.md)
- Google Cloud Run
- Docker Compose
- Heroku
- CI/CD GitHub Actions

---

## 🎨 Trabalhando com Flutter/Frontend

### Quero entender o frontend
👉 **Leia:** [frontend/README.md](frontend/README.md)
- Estrutura Flutter
- Dependências
- Interface
- Configuração

### Vou modificar o código Flutter
👉 **Consulte:** [frontend/lib/main.dart](frontend/lib/main.dart)
- 600+ linhas comentadas
- Componentes UI
- State management
- HTTP requests

### Como testar o frontend?
👉 **Execute:**
```bash
cd frontend
flutter run -d chrome
# Abra: http://localhost:3000/?session=teste123
```

### Preciso customizar a interface
👉 **Modifique:**
- `frontend/lib/main.dart` - UI components
- `frontend/web/index.html` - HTML
- `frontend/pubspec.yaml` - Dependências

### Como gerar build para produção?
👉 **Execute:**
```bash
flutter build web --release
# Arquivos em: frontend/build/web/
```

---

## 🏗️ Entendendo a Arquitetura

### Diagrama geral
👉 **Leia:** [docs/ARQUITETURA.md](docs/ARQUITETURA.md)
- Fluxo completo
- Componentes
- Integração Google Drive
- Performance

### Modelo de dados
👉 **Consulte:** [docs/ARQUITETURA.md#-modelo-de-dados](docs/ARQUITETURA.md)
- Requisições
- Respostas
- Estrutura JSON

---

## 🚀 Deploy e DevOps

### Vou fazer deploy
👉 **Leia:** [docs/DEPLOY_PRODUCAO.md](docs/DEPLOY_PRODUCAO.md)
- Google Cloud Run
- Docker
- Heroku
- Nginx

### Preciso de Docker
👉 **Veja:**
```dockerfile
# backend/Dockerfile (pronto para usar)
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["python", "main.py"]
```

### Vou usar Docker Compose
👉 **Veja:**
```yaml
# Configuração completa em docs/DEPLOY_PRODUCAO.md
version: '3.8'
services:
  backend:
    # ...
  nginx:
    # ...
```

### CI/CD com GitHub Actions
👉 **Veja exemplo em:** [docs/DEPLOY_PRODUCAO.md](docs/DEPLOY_PRODUCAO.md)
- Build automático
- Testes automáticos
- Deploy automático

---

## 📚 Documentação Detalhada

### Índice Completo
👉 **Leia:** [docs/INDICE_COMPLETO.md](docs/INDICE_COMPLETO.md)
- Lista de todos os documentos
- Tempo estimado de leitura
- O que aprender em cada um

### Sumário da Entrega
👉 **Leia:** [docs/ENTREGA_COMPLETA.md](docs/ENTREGA_COMPLETA.md)
- O que foi criado
- Linhas de código
- Funcionalidades

### Versões e Changelog
👉 **Leia:** [CHANGELOG.md](CHANGELOG.md)
- Versão atual (1.0.0)
- Roadmap futuro
- Known issues

---

## 🤝 Desenvolvendo e Contribuindo

### Quero contribuir
👉 **Leia:** [CONTRIBUTING.md](CONTRIBUTING.md)
- Workflow Git
- Convenções de código
- Testes
- Code review

### Setup para desenvolvimento
👉 **Siga:**
```bash
git clone repo
cd frontend && flutter pub get
cd backend && python -m venv venv && pip install -r requirements.txt
```

### Preciso de style guide
👉 **Consulte:** [CONTRIBUTING.md#-convenções-de-código](CONTRIBUTING.md)
- Dart/Flutter
- Python
- Commits

---

## 🐛 Problemas e Troubleshooting

### Algo não está funcionando
👉 **Verificar:**
1. [README.md - Troubleshooting](README.md#-troubleshooting)
2. [INICIO_RAPIDO.md - Problemas Comuns](docs/INICIO_RAPIDO.md)
3. [DEPLOY_PRODUCAO.md - Troubleshooting](docs/DEPLOY_PRODUCAO.md)

### Erro no frontend
👉 **Checklist:**
- Flutter instalado? `flutter --version`
- Web habilitado? `flutter config --enable-web`
- Dependências ok? `flutter pub get`
- URL do backend está correta em `main.dart`?

### Erro no backend
👉 **Checklist:**
- Python instalado? `python --version`
- Venv ativado? `source venv/bin/activate`
- Dependências ok? `pip list | grep fastapi`
- Google Drive configurado? `service-account.json` existe?
- `.env` configurado?

### Erro ao conectar Google Drive
👉 **Leia:** [docs/CONFIGURACAO_GOOGLE_DRIVE.md - Troubleshooting](docs/CONFIGURACAO_GOOGLE_DRIVE.md)
- Arquivo JSON não encontrado?
- Pasta não compartilhada?
- Service Account email incorreto?
- Folder ID incorreto?

---

## 📊 Testes

### Quero testar a API
👉 **Leia:** [docs/TESTES_API.md](docs/TESTES_API.md)
- Health check
- Upload teste
- Listar fotos
- Exemplos em cURL, Python, Postman

### Quero fazer teste automatizado
👉 **Consulte:**
- Backend: `pytest`
- Frontend: `flutter test`
- Veja exemplos em [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 💡 Dicas por Tecnologia

### Flutter Web
1. [Flutter Docs](https://flutter.dev/docs)
2. [frontend/README.md](frontend/README.md)
3. [frontend/lib/main.dart](frontend/lib/main.dart)

### FastAPI
1. [FastAPI Documentation](https://fastapi.tiangolo.com)
2. [backend/README.md](backend/README.md)
3. [backend/main.py](backend/main.py)

### Google Drive API
1. [Google Drive API Docs](https://developers.google.com/drive/api)
2. [docs/CONFIGURACAO_GOOGLE_DRIVE.md](docs/CONFIGURACAO_GOOGLE_DRIVE.md)
3. [backend/main.py - GoogleDriveManager](backend/main.py)

### Docker
1. [Docker Docs](https://docs.docker.com)
2. [docs/DEPLOY_PRODUCAO.md - Docker](docs/DEPLOY_PRODUCAO.md)

### CI/CD
1. [GitHub Actions](https://docs.github.com/en/actions)
2. [docs/DEPLOY_PRODUCAO.md - CI/CD](docs/DEPLOY_PRODUCAO.md)

---

## 🎯 Fluxo de Trabalho Típico

### Primeira Vez
```
1. RESUMO_EXECUTIVO.md (5 min) ← Você está aqui
   ↓
2. README.md (10 min)
   ↓
3. INICIO_RAPIDO.md (15 min)
   ↓
4. CONFIGURACAO_GOOGLE_DRIVE.md (20 min)
   ↓
5. Execute localmente
   ↓
6. TESTES_API.md (teste tudo)
```

### Para Modificar
```
1. Consulte o código comentado
   ↓
2. Entenda a arquitetura (ARQUITETURA.md)
   ↓
3. Modifique um arquivo
   ↓
4. Teste localmente
   ↓
5. Commit com mensagem descritiva
```

### Para Deploy
```
1. DEPLOY_PRODUCAO.md
   ↓
2. Escolha plataforma (Cloud Run/Docker/Heroku)
   ↓
3. Configure variáveis de ambiente
   ↓
4. Execute deploy
   ↓
5. Teste em produção
```

---

## 📁 Arquivos por Responsabilidade

### Código Frontend
- `frontend/lib/main.dart` - Aplicação principal

### Código Backend
- `backend/main.py` - Servidor e API

### Configuração
- `frontend/pubspec.yaml` - Dependências Flutter
- `backend/requirements.txt` - Dependências Python
- `backend/.env.example` - Template de variáveis
- `.gitignore` - Git ignore global

### Web
- `frontend/web/index.html` - HTML
- `frontend/web/manifest.json` - PWA config

### Documentação
- `README.md` - Visão geral
- `RESUMO_EXECUTIVO.md` - Resumo rápido
- `CONTRIBUTING.md` - Contribuir
- `CHANGELOG.md` - Versões
- `docs/` - Documentação detalhada (8 guias)

### Scripts
- `scripts/start.sh` - Inicialização automática

---

## ⏱️ Tempo de Leitura Estimado

| Documento | Tempo | Prioridade |
|-----------|-------|-----------|
| RESUMO_EXECUTIVO.md | 5 min | ⭐⭐⭐ |
| README.md | 10 min | ⭐⭐⭐ |
| INICIO_RAPIDO.md | 15 min | ⭐⭐⭐ |
| CONFIGURACAO_GOOGLE_DRIVE.md | 20 min | ⭐⭐⭐ |
| TESTES_API.md | 10 min | ⭐⭐ |
| ARQUITETURA.md | 15 min | ⭐⭐ |
| DEPLOY_PRODUCAO.md | 30 min | ⭐⭐ |
| CONTRIBUTING.md | 10 min | ⭐ |
| CHANGELOG.md | 5 min | ⭐ |

**Total: 120 minutos (2 horas) para ler tudo**

---

## 🚦 Comece Aqui Agora

```
┌─────────────────────────────────┐
│  1. Leia RESUMO_EXECUTIVO.md   │
│     (você está aqui)             │
└────────────┬────────────────────┘
             │
             ↓
┌─────────────────────────────────┐
│  2. Leia README.md              │
│     (compreenda o projeto)       │
└────────────┬────────────────────┘
             │
             ↓
┌─────────────────────────────────┐
│  3. Configure Google Drive      │
│  (docs/CONFIGURACAO_GOOGLE...md)│
└────────────┬────────────────────┘
             │
             ↓
┌─────────────────────────────────┐
│  4. Siga INICIO_RAPIDO.md       │
│     (execute localmente)         │
└────────────┬────────────────────┘
             │
             ↓
┌─────────────────────────────────┐
│  5. Teste com TESTES_API.md     │
│     (valide funcionamento)       │
└────────────┬────────────────────┘
             │
             ↓
      ✅ PRONTO PARA USAR!
```

---

## 🎁 Bonus: Atalhos Úteis

### Abrir documentação rapidamente
```bash
# No terminal, a partir da raiz do projeto
open README.md                          # macOS
xdg-open README.md                      # Linux
start README.md                         # Windows

# VS Code
code README.md
code docs/CONFIGURACAO_GOOGLE_DRIVE.md
```

### Navegar entre componentes
```bash
# Ver estrutura
tree -I 'node_modules|venv'

# Encontrar um arquivo
find . -name "*.md" -type f

# Procurar por texto
grep -r "session" --include="*.dart"
grep -r "Google" --include="*.py"
```

---

## 📞 Resumo Final

| Necessidade | Arquivo |
|-----------|---------|
| Começar | RESUMO_EXECUTIVO.md |
| Visão Geral | README.md |
| Setup Rápido | INICIO_RAPIDO.md |
| Google Drive | docs/CONFIGURACAO_GOOGLE_DRIVE.md ⭐ |
| Testar API | docs/TESTES_API.md |
| Entender Arquitetura | docs/ARQUITETURA.md |
| Deploy | docs/DEPLOY_PRODUCAO.md |
| Contribuir | CONTRIBUTING.md |
| Frontend | frontend/README.md |
| Backend | backend/README.md |

---

**Bem-vindo! 👋 Escolha um documento acima e comece! 🚀**

---

*Última atualização: 3 de Junho de 2026*
