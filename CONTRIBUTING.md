# 🤝 Contribuindo e Desenvolvendo

Guia para contribuir e estender a solução de Captura de Fotos.

---

## 👨‍💻 Antes de Começar

1. Leia [README.md](../README.md)
2. Leia [ARQUITETURA.md](ARQUITETURA.md)
3. Execute tudo localmente com sucesso
4. Entenda o fluxo completo

---

## 🔄 Workflow de Desenvolvimento

### 1. Setup Local

```bash
# Clone o repositório
git clone https://seu-repo.git
cd Eventos

# Configure backend
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Configure .env e service-account.json

# Configure frontend
cd ../frontend
flutter pub get

# Volte à raiz
cd ..
```

### 2. Crie uma Branch

```bash
git checkout -b feature/sua-feature
# ou
git checkout -b fix/bug-description
# ou
git checkout -b docs/doc-update
```

### 3. Faça suas Mudanças

- Código comentado
- Siga style guide
- Adicione testes se possível

### 4. Teste Localmente

```bash
# Terminal 1: Backend
cd backend
python main.py

# Terminal 2: Frontend
cd frontend
flutter run -d chrome

# Terminal 3: Testes
cd docs
bash run-tests.sh  # (criado em futuro)
```

### 5. Commit e Push

```bash
git add .
git commit -m "feat: descrição da mudança"
git push origin feature/sua-feature
```

### 6. Abra um Pull Request

- Título descritivo
- Descrição detalhada
- Link para issues relacionadas

---

## 📝 Convenções de Código

### Flutter (Dart)

```dart
// ✅ BOM
class MinhaClasse {
  final String descricao;
  
  const MinhaClasse({required this.descricao});
  
  /// Função bem documentada
  void meuMetodo() {
    // Fazer algo
  }
}

// ❌ RUIM
class MINHACLASSE {
  String desc;
  
  void m() {
    // fazer
  }
}
```

Siga: [Effective Dart](https://dart.dev/guides/language/effective-dart)

### Python (FastAPI)

```python
# ✅ BOM
class GoogleDriveManager:
    """Gerenciador de Google Drive com docstring"""
    
    @staticmethod
    def salvar_arquivo(
        arquivo_bytes: bytes,
        nome_arquivo: str
    ) -> Optional[str]:
        """
        Salva arquivo no Google Drive.
        
        Args:
            arquivo_bytes: Conteúdo do arquivo
            nome_arquivo: Nome do arquivo
            
        Returns:
            ID do arquivo ou None se falhar
        """
        # Implementação

# ❌ RUIM
def save(data, name):
    # save to drive
    pass
```

Siga: [PEP 8](https://pep8.org/) e [PEP 257](https://pep257.dev/)

---

## 🧪 Testes

### Frontend (Flutter)

```bash
cd frontend

# Testes unitários
flutter test

# Testes de widget
flutter test --verbose

# Cobertura
flutter test --coverage
```

### Backend (Python)

```bash
cd backend

# Instalar pytest
pip install pytest pytest-cov

# Rodar testes
pytest

# Com cobertura
pytest --cov=. --cov-report=html
```

---

## 🐛 Bug Reports

### Template de Issue

```markdown
## Descrição do Bug
Descrição clara do problema

## Passos para Reproduzir
1. Faça X
2. Clique em Y
3. Observe Z

## Comportamento Esperado
Descrição do que deveria acontecer

## Comportamento Atual
Descrição do que está acontecendo

## Screenshots/Logs
[Adicionar se relevante]

## Ambiente
- OS: [Windows/macOS/Linux]
- Flutter: [versão]
- Python: [versão]
- Browser: [Chrome/Firefox/Safari]

## Contexto Adicional
[Qualquer informação extra]
```

---

## ✨ Feature Requests

### Template de Feature

```markdown
## Descrição
Descrição clara da feature

## Benefícios
Por que isso seria útil?

## Implementação Proposta
Como você implementaria?

## Exemplos de Uso
Exemplos práticos

## Alternativas Consideradas
Outras formas de resolver
```

---

## 📦 Versionamento

Usamos [Semantic Versioning](https://semver.org/):

- **MAJOR.MINOR.PATCH** (e.g., 1.0.0)
- `MAJOR`: Mudanças incompatíveis
- `MINOR`: Novas features compatíveis
- `PATCH`: Bug fixes

---

## 🔍 Code Review Checklist

Ao revisar código, verificar:

- [ ] Código segue style guide
- [ ] Nomes de variáveis descritivos
- [ ] Funções têm docstrings
- [ ] Testes inclusos
- [ ] Sem código comentado inútil
- [ ] Sem secrets hardcoded
- [ ] Sem console.log/print debug
- [ ] Performance aceitável
- [ ] Sem warning/errors

---

## 🚀 Melhorias Sugeridas

### Frontend

```dart
// TODO: Implementar cache local
class CapturaFotosPage extends StatefulWidget {
  // ...
  
  // TODO: Adicionar filtros de imagem
  Future<void> _capturarFoto() async {
    // ...
  }
}
```

### Backend

```python
# TODO: Implementar rate limiting
@app.post("/upload-foto")
async def upload_foto(...):
    """
    TODO: Adicionar autenticação de usuário
    TODO: Implementar retry automático
    """
    # ...
```

---

## 📚 Recursos para Contribuidores

### Flutter
- [Flutter Documentation](https://flutter.dev/docs)
- [Pub.dev Packages](https://pub.dev)
- [Flutter Community](https://flutter.dev/community)

### Python/FastAPI
- [FastAPI Tutorial](https://fastapi.tiangolo.com/tutorial/)
- [Google Drive API](https://developers.google.com/drive/api)
- [Python Docs](https://docs.python.org/3/)

### DevOps/Deploy
- [Google Cloud Run](https://cloud.google.com/run/docs)
- [Docker Documentation](https://docs.docker.com/)
- [GitHub Actions](https://docs.github.com/en/actions)

---

## 🔐 Segurança

### Reportar Vulnerabilidades

⚠️ **NÃO abra issue pública para vulnerabilidades!**

Envie email para: `security@seu-email.com`

Inclua:
- Descrição da vulnerabilidade
- Passos para reproduzir
- Impacto potencial
- Sugestões de fix (se tiver)

---

## 📋 Checklist Pré-Commit

Antes de fazer commit:

```bash
# Frontend
cd frontend
flutter format lib/
flutter analyze

# Backend
cd ../backend
black .
isort .
flake8 .

# Geral
git diff --check  # Whitespace issues
```

---

## 🎓 Arquitetura e Padrões

### Padrões Utilizados

**Frontend:**
- Pattern Provider (State Management)
- Builder Pattern (UI Components)
- Factory Pattern (HTTP Client)

**Backend:**
- Repository Pattern (Google Drive Manager)
- Middleware Pattern (CORS, Auth)
- Singleton Pattern (Google Service Client)

### Princípios SOLID

- **S**ingle Responsibility: Cada classe tem uma responsabilidade
- **O**pen/Closed: Aberto para extensão, fechado para modificação
- **L**iskov Substitution: Subclasses podem substituir suas classes base
- **I**nterface Segregation: Interfaces específicas, não genéricas
- **D**ependency Inversion: Depender de abstrações, não implementações

---

## 📊 Métricas de Qualidade

Almejamos:
- ✅ Cobertura de testes: > 80%
- ✅ Performance: < 2s por operação
- ✅ Uptime: > 99.9%
- ✅ Error rate: < 0.1%

---

## 🚢 Release Checklist

Antes de fazer release:

- [ ] Todos os testes passam
- [ ] Documentação atualizada
- [ ] CHANGELOG atualizado
- [ ] Versão atualizada (semver)
- [ ] Tag criada: `v1.0.0`
- [ ] Build web otimizado criado
- [ ] Backend testado em produção
- [ ] Backup dos dados existentes
- [ ] Comunicado aos stakeholders

---

## 🎯 Roadmap

### Q3 2026
- [ ] Autenticação de usuário
- [ ] Histórico de uploads
- [ ] Busca e filtros
- [ ] Notificações

### Q4 2026
- [ ] PWA installável
- [ ] Edição de imagens
- [ ] Compartilhamento
- [ ] Relatórios

### 2027
- [ ] Database próprio
- [ ] API pública
- [ ] App mobile nativo
- [ ] Análise de imagens (ML)

---

## 💡 Ideias de Contribuição

**Fáceis (Good First Issues):**
- [ ] Adicionar comentários ao código
- [ ] Melhorar mensagens de erro
- [ ] Atualizar documentação
- [ ] Corrigir typos

**Médias:**
- [ ] Implementar testes
- [ ] Adicionar validações
- [ ] Otimizar performance
- [ ] Refatorar código legado

**Difíceis:**
- [ ] Novas features
- [ ] Integração com novos serviços
- [ ] Refatoração arquitetural
- [ ] Implementação de IA/ML

---

## 🤔 FAQ do Desenvolvedor

### Qual linguagem de programação usar para comentários?
Português (preferência do projeto)

### Quantos workers no backend?
Recomendado: CPU cores × 2 (e.g., 4 cores → 8 workers)

### Preciso de tests para contribuir?
Para bug fixes: não obrigatório. Para features: sim.

### Como reportar um problema de segurança?
Veja seção "Segurança" acima.

### Posso usar biblioteca X?
Abra uma issue para discutir antes.

---

## 🎉 Boas Práticas

### ✅ Faça

- Writes testes
- Use type hints (Python) e tipos (Dart)
- Commits descritivos
- Documente mudanças
- Revise seu próprio código primeiro

### ❌ Não Faça

- Commits massivos sem descrição
- Código comentado inteiro (delete!)
- Secrets no código
- Modificações de .gitignore
- Conflitos de merge sem resolver

---

## 🙏 Agradecimentos

Obrigado por contribuir! Cada linha de código, linha de documentação e bug report ajuda a melhorar o projeto.

---

**Versão:** 1.0.0  
**Última atualização:** Junho de 2026  
**Mantido por:** Senior Software Architect
