# 🎨 Frontend - Flutter Web

Interface web responsiva para captura e envio de fotos.

---

## 📋 Estrutura

```
frontend/
├── lib/
│   └── main.dart              # Aplicação principal
├── web/
│   ├── index.html             # Página HTML
│   └── manifest.json          # PWA Manifest
├── pubspec.yaml               # Dependências Flutter
└── README.md                  # Este arquivo
```

---

## 🚀 Quick Start

```bash
cd frontend

# Instalar dependências
flutter pub get

# Executar em Chrome
flutter run -d chrome

# Acessar
# http://localhost:3000/?session=seu-id-sessao
```

---

## 📦 Dependências

| Pacote | Versão | Propósito |
|--------|--------|----------|
| `image_picker` | ^1.0.0 | Captura de câmera |
| `http` | ^1.1.0 | Requisições HTTP |
| `provider` | ^6.0.0 | State management |
| `logger` | ^2.0.0 | Logging |

---

## 🎮 Funcionalidades

### Captura de Foto
- ✅ Abre câmera nativa do dispositivo
- ✅ Captura foto com qualidade 85%
- ✅ Exibe preview da foto

### Envio de Foto
- ✅ Upload via Multipart Form Data
- ✅ Envia com ID de sessão
- ✅ Feedback visual durante upload
- ✅ Timeout de 30 segundos

### Interface
- ✅ 100% responsiva (mobile-first)
- ✅ Material Design 3
- ✅ Estados visuais claros
- ✅ Mensagens de erro/sucesso

---

## 🔧 Configuração

### URL do Backend

O frontend usa a variável de compilação `BACKEND_URL`. O padrão já está configurado
para o backend publicado:

```dart
https://eventos-backend-32ds.onrender.com/upload-foto
```

**Exemplos:**
- Desenvolvimento: `http://localhost:8000/upload-foto`
- Produção: `https://eventos-backend-32ds.onrender.com/upload-foto`

Para sobrescrever a URL durante a execução ou o build:

```bash
flutter run -d chrome --dart-define=BACKEND_URL=http://localhost:8000
flutter build web --release --dart-define=BACKEND_URL=https://eventos-backend-32ds.onrender.com
```

O domínio publicado do frontend também precisa estar cadastrado na variável
`ALLOWED_ORIGINS` do serviço do backend no Render. Informe apenas a origem, sem
`/upload-foto`, por exemplo: `https://seu-frontend.onrender.com`.

### Permissões

As permissões de câmera são solicitadas automaticamente:

```dart
final XFile? foto = await _picker.pickImage(
  source: ImageSource.camera,
  imageQuality: 85,
);
```

---

## 📲 Como Usar

### 1. Com URL local
```bash
http://localhost:3000/?session=teste123
```

### 2. Com URL de produção
```
https://meuapp.com/?session=ABC123XYZ
```

### 3. Via QR Code
Gere um QR Code apontando para a URL com session ID

---

## 🛠️ Desenvolvimento

### Estrutura do Código

```dart
// main.dart
├── main()                     // Entrada
├── MyApp                      // App principal
├── CapturaFotosPage          // Página principal
│   ├── _extrairSessaoUrl()   // Extrai session da URL
│   ├── _capturarFoto()       // Abre câmera
│   ├── _enviarFoto()         // Upload para backend
│   ├── _descartarFoto()      // Limpa preview
│   ├── _mostrarMensagem()    // Exibe feedback
│   └── build()               // Constrói UI
└── MensagemTipo enum         // Tipos de mensagem
```

### Estados Visuais

```dart
enum MensagemTipo {
  sucesso,  // ✅ Verde
  erro,     // ❌ Vermelho
  info,     // ℹ️ Azul
}
```

---

## 📱 Interface

### Tela Inicial (sem foto)

```
┌─────────────────────────────┐
│   Captura de Fotos          │
├─────────────────────────────┤
│                             │
│  ID de Sessão: teste123    │
│                             │
│        📷                   │
│                             │
│  Clique em "Capturar Foto" │
│                             │
│   [Capturar Foto]          │
│                             │
└─────────────────────────────┘
```

### Tela de Preview (com foto)

```
┌─────────────────────────────┐
│   Captura de Fotos          │
├─────────────────────────────┤
│                             │
│  ID de Sessão: teste123    │
│                             │
│    ┌────────────────┐       │
│    │                │       │
│    │   [FOTO]       │       │
│    │                │       │
│    └────────────────┘       │
│                             │
│   [Enviar Foto]            │
│   [Descartar Foto]         │
│                             │
└─────────────────────────────┘
```

---

## 🧪 Testes

### Teste Manual

1. Abra em navegador: `http://localhost:3000/?session=teste123`
2. Clique "Capturar Foto"
3. Escolha/tire uma imagem
4. Clique "Enviar Foto"
5. Verifique confirmação

### Teste de Responsividade

```bash
# Abrir Flutter DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Testar diferentes tamanhos de tela
flutter run -d chrome --web-browser-flag "--start-maximized"
```

---

## 🐛 Troubleshooting

### "Câmera não disponível"
- Ative permissões de câmera no navegador
- Tente em outro navegador (Chrome recomendado)

### "Connection refused"
- Verifique se backend está rodando em `localhost:8000`
- Altere URL em `main.dart` se necessário

### Upload lento
- Reduza qualidade em `imageQuality: 85`
- Verifique conexão de internet
- Arquivo muito grande? Reduza dimensões

---

## 📊 Logging

Ative logs para debug:

```dart
// Em main.dart
final Logger logger = Logger();

// Usar em qualquer lugar
logger.i('Informação');
logger.w('Aviso');
logger.e('Erro: $erro');
logger.d('Debug: $detalhes');
```

---

## 🚀 Build para Produção

### Web Release Build

```bash
flutter build web --release --dart-define=BACKEND_URL=https://sua-api.com
```

### Arquivos de output

```
frontend/build/web/
├── index.html
├── main.dart.js
├── assets/
│   ├── packages/
│   └── fonts/
└── ...
```

---

## 📋 Código Comentado

Veja [main.dart](lib/main.dart) para documentação completa do código com comentários detalhados.

---

## 🔗 Referências

- [Flutter Documentation](https://flutter.dev/docs)
- [Image Picker Plugin](https://pub.dev/packages/image_picker)
- [HTTP Package](https://pub.dev/packages/http)
- [Material Design 3](https://m3.material.io/)

---

**Criado:** Junho de 2026  
**Versão:** 1.0.0
