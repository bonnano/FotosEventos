# 🧪 Guia de Testes da API

Exemplos de como testar a API Backend usando cURL, Postman, ou outras ferramentas.

---

## 📍 Base URL

- **Desenvolvimento:** `http://localhost:8000`
- **Produção:** `https://api.seudominio.com` (alterar conforme deploy)

---

## ✅ Endpoints Disponíveis

### 1. Health Check

**Descrição:** Verifica se a API está online

**Requisição:**
```bash
curl http://localhost:8000/health
```

**Resposta (200):**
```json
{
  "status": "ok",
  "timestamp": "2026-06-03T10:30:45.123456"
}
```

---

### 2. Raiz da API

**Descrição:** Informações sobre a API

**Requisição:**
```bash
curl http://localhost:8000/
```

**Resposta (200):**
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

---

### 3. Upload de Foto ⭐ (Principal)

**Descrição:** Envia uma foto para Google Drive

**Requisição - cURL (com arquivo real):**
```bash
curl -X POST http://localhost:8000/upload-foto \
  -F "imagem=@/caminho/para/sua/foto.jpg" \
  -F "session=SESSION_ID_123"
```

**Requisição - cURL (criando imagem de teste):**
```bash
# Criar imagem de teste (1x1 pixel JPEG)
curl -s "https://images.unsplash.com/photo-1606986628025-35d57e735ae0?w=100&h=100" \
  -o test.jpg

# Enviar para API
curl -X POST http://localhost:8000/upload-foto \
  -F "imagem=@test.jpg" \
  -F "session=teste123"
```

**Requisição - Postman:**
1. Método: `POST`
2. URL: `http://localhost:8000/upload-foto`
3. Aba "Body":
   - Tipo: `form-data`
   - Campo 1: `imagem` (tipo: File) → Selecione seu arquivo
   - Campo 2: `session` (tipo: Text) → `seu-id-sessao`
4. Clique "Send"

**Requisição - Python:**
```python
import requests

url = "http://localhost:8000/upload-foto"
files = {'imagem': open('foto.jpg', 'rb')}
data = {'session': 'teste123'}

response = requests.post(url, files=files, data=data)
print(response.json())
```

**Resposta de Sucesso (200):**
```json
{
  "status": "sucesso",
  "mensagem": "Foto salva com sucesso no Google Drive",
  "arquivo_id": "1A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P7",
  "arquivo_nome": "foto_teste123_20260603_103045.jpg",
  "timestamp": "2026-06-03T10:30:45.123456",
  "session": "teste123"
}
```

**Resposta de Erro - Sem Session (400):**
```json
{
  "status": "erro",
  "mensagem": "Session ID é obrigatório"
}
```

**Resposta de Erro - Tipo Inválido (400):**
```json
{
  "status": "erro",
  "mensagem": "Tipo de arquivo não permitido. Permitidos: image/jpeg, image/jpg, image/png, image/webp"
}
```

**Resposta de Erro - Arquivo Vazio (400):**
```json
{
  "status": "erro",
  "mensagem": "Imagem está vazia"
}
```

**Resposta de Erro - Falha no Google Drive (500):**
```json
{
  "status": "erro",
  "mensagem": "Erro ao salvar arquivo no Google Drive"
}
```

---

### 4. Listar Fotos

**Descrição:** Lista as últimas fotos enviadas

**Requisição - cURL:**
```bash
curl http://localhost:8000/listar-fotos

# Com limite customizado
curl "http://localhost:8000/listar-fotos?limite=20"
```

**Requisição - Postman:**
1. Método: `GET`
2. URL: `http://localhost:8000/listar-fotos?limite=10`
3. Clique "Send"

**Requisição - Python:**
```python
import requests

url = "http://localhost:8000/listar-fotos"
params = {'limite': 10}

response = requests.get(url, params=params)
fotos = response.json()['arquivos']

for foto in fotos:
    print(f"Nome: {foto['nome']}")
    print(f"ID: {foto['id']}")
    print(f"Link: {foto['link']}")
    print("---")
```

**Resposta (200):**
```json
{
  "status": "sucesso",
  "total": 3,
  "arquivos": [
    {
      "id": "1ABC123DEF456GHI789JKL012MNO345P",
      "nome": "foto_sessao123_20260603_103045.jpg",
      "criado_em": "2026-06-03T10:30:45.123456Z",
      "link": "https://drive.google.com/file/d/1ABC123DEF456GHI789JKL012MNO345P/view"
    },
    {
      "id": "2XYZ789ABC456DEF123GHI456JKL789M",
      "nome": "foto_sessao456_20260603_102030.jpg",
      "criado_em": "2026-06-03T10:20:30.654321Z",
      "link": "https://drive.google.com/file/d/2XYZ789ABC456DEF123GHI456JKL789M/view"
    },
    {
      "id": "3QWE123RTY456UIO789PAS456DFG789H",
      "nome": "foto_sessao789_20260603_101015.jpg",
      "criado_em": "2026-06-03T10:10:15.987654Z",
      "link": "https://drive.google.com/file/d/3QWE123RTY456UIO789PAS456DFG789H/view"
    }
  ]
}
```

---

## 🔗 Tipos de Requisição

### Multipart Upload (Upload de Arquivo)

```bash
# Formato:
curl -X POST http://localhost:8000/upload-foto \
  -F "campo1=@arquivo.extensao" \
  -F "campo2=valor"
```

### Form Data (Dados de Formulário)

```bash
curl -X POST http://localhost:8000/endpoint \
  -d "session=teste123"
```

### JSON (Dados Estruturados)

```bash
curl -X POST http://localhost:8000/endpoint \
  -H "Content-Type: application/json" \
  -d '{"session":"teste123"}'
```

---

## 📋 Testes Automáticos com cURL

### Script Bash - Teste Completo

```bash
#!/bin/bash

echo "🧪 Teste de API - Captura de Fotos"
echo "===================================="

# 1. Health Check
echo "1️⃣ Verificando saúde da API..."
curl -s http://localhost:8000/health | json_pp
echo -e "\n"

# 2. Informações da API
echo "2️⃣ Obtendo informações da API..."
curl -s http://localhost:8000/ | json_pp
echo -e "\n"

# 3. Listar fotos existentes
echo "3️⃣ Listando fotos..."
curl -s http://localhost:8000/listar-fotos | json_pp
echo -e "\n"

# 4. Enviar nova foto
echo "4️⃣ Enviando nova foto..."

# Criar imagem de teste
convert -size 100x100 xc:blue test_image.jpg

# Upload
curl -X POST http://localhost:8000/upload-foto \
  -F "imagem=@test_image.jpg" \
  -F "session=test_$(date +%s)" | json_pp

echo -e "\n✅ Testes concluídos!"

# Limpeza
rm -f test_image.jpg
```

### Script Python - Teste Interativo

```python
#!/usr/bin/env python3
import requests
import json
from pathlib import Path
from datetime import datetime

BASE_URL = "http://localhost:8000"

def health_check():
    """Testa se a API está online"""
    print("🔍 Verificando saúde da API...")
    response = requests.get(f"{BASE_URL}/health")
    print(f"Status: {response.status_code}")
    print(f"Resposta: {response.json()}\n")

def get_info():
    """Obtém informações da API"""
    print("ℹ️ Obtendo informações da API...")
    response = requests.get(BASE_URL)
    print(f"Status: {response.status_code}")
    print(json.dumps(response.json(), indent=2))
    print()

def list_photos(limit=10):
    """Lista fotos recentes"""
    print(f"📸 Listando últimas {limit} fotos...")
    response = requests.get(f"{BASE_URL}/listar-fotos", params={'limite': limit})
    print(f"Status: {response.status_code}")
    data = response.json()
    print(f"Total de fotos: {data['total']}")
    for foto in data['arquivos']:
        print(f"  - {foto['nome']} ({foto['criado_em']})")
    print()

def upload_photo(file_path, session_id):
    """Envia uma foto"""
    print(f"⬆️ Enviando foto: {file_path}")
    
    if not Path(file_path).exists():
        print(f"❌ Arquivo não encontrado: {file_path}\n")
        return
    
    with open(file_path, 'rb') as f:
        files = {'imagem': f}
        data = {'session': session_id}
        response = requests.post(
            f"{BASE_URL}/upload-foto",
            files=files,
            data=data
        )
    
    print(f"Status: {response.status_code}")
    print(json.dumps(response.json(), indent=2))
    print()

if __name__ == "__main__":
    print("🚀 Sistema de Testes - API Captura de Fotos\n")
    
    try:
        # Testes
        health_check()
        get_info()
        list_photos()
        
        # Upload (se arquivo existir)
        if Path("test_photo.jpg").exists():
            session = f"teste_{datetime.now().timestamp()}"
            upload_photo("test_photo.jpg", session)
        else:
            print("⚠️ Coloque um arquivo 'test_photo.jpg' para testar upload\n")
        
        print("✅ Todos os testes concluídos!")
        
    except requests.exceptions.ConnectionError:
        print("❌ ERRO: Não conseguiu conectar à API")
        print("   Verifique se o backend está rodando em http://localhost:8000")
    except Exception as e:
        print(f"❌ ERRO: {e}")
```

---

## 🔒 Testes com Autenticação (Futuro)

Se adicionar autenticação depois:

```bash
# Com Bearer Token
curl -X POST http://localhost:8000/upload-foto \
  -H "Authorization: Bearer seu-token-aqui" \
  -F "imagem=@foto.jpg" \
  -F "session=teste123"

# Com API Key
curl -X POST http://localhost:8000/upload-foto \
  -H "X-API-Key: sua-chave-api" \
  -F "imagem=@foto.jpg" \
  -F "session=teste123"
```

---

## 📊 Métricas de Performance

### Teste de Carga Simples

```bash
# Enviar 10 fotos sequencialmente
for i in {1..10}; do
  echo "Enviando foto $i..."
  curl -X POST http://localhost:8000/upload-foto \
    -F "imagem=@test.jpg" \
    -F "session=teste_$i" \
    -w "Status: %{http_code} | Tempo: %{time_total}s\n"
  sleep 1
done
```

---

## 🐛 Debugando Requisições

### Ver Headers Completos

```bash
curl -v http://localhost:8000/health
```

### Ver Apenas Headers de Resposta

```bash
curl -i http://localhost:8000/health
```

### Ver Request e Response Completos

```bash
curl -v -F "imagem=@foto.jpg" -F "session=teste123" \
  http://localhost:8000/upload-foto
```

### Salvar Resposta em Arquivo

```bash
curl http://localhost:8000/listar-fotos > resposta.json
cat resposta.json | json_pp
```

---

## 📱 Testando Direto do Flutter

No `main.dart`, adicione um botão de teste:

```dart
ElevatedButton(
  onPressed: () async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/upload-foto'),
      body: {
        'session': 'teste-flutter',
      },
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
  },
  child: const Text('Teste Backend'),
)
```

---

## ✨ Checklist de Testes

- [ ] Health check retorna 200
- [ ] Informações da API disponíveis
- [ ] Listar fotos (mesmo sem fotos) retorna 200
- [ ] Upload com arquivo válido retorna 200
- [ ] Upload sem arquivo retorna 400
- [ ] Upload sem session retorna 400
- [ ] Tipo de arquivo inválido retorna 400
- [ ] Foto aparece no Google Drive
- [ ] Arquivo é nomeado com session ID
- [ ] Timestamp está correto

---

**Dica:** Salve este arquivo e execute os testes regularmente para garantir que a API está funcionando corretamente!

---

Criado: Junho de 2026  
Versão: 1.0.0
