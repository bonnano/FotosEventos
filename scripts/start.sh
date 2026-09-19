#!/bin/bash

# 🚀 Script de Inicialização Automática - Captura de Fotos
# Este script configura e inicia automaticamente frontend e backend

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════╗"
echo "║     🚀 Sistema de Captura de Fotos - Eventos     ║"
echo "║           Inicialização Automática                ║"
echo "╚═══════════════════════════════════════════════════╝"
echo -e "${NC}"

# Função para exibir mensagens
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Função para aguardar input
wait_for_input() {
    read -p "$(echo -e ${YELLOW})Pressione ENTER para continuar...$(echo -e ${NC})" dummy
}

# Verificar pré-requisitos
check_prerequisites() {
    print_info "Verificando pré-requisitos..."
    
    local missing=0
    
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter não encontrado. Instale em: https://flutter.dev/docs/get-started/install"
        missing=1
    else
        print_success "Flutter encontrado: $(flutter --version | head -n1)"
    fi
    
    if ! command -v python3 &> /dev/null; then
        print_error "Python não encontrado. Instale em: https://www.python.org/downloads/"
        missing=1
    else
        print_success "Python encontrado: $(python3 --version)"
    fi
    
    if ! command -v git &> /dev/null; then
        print_error "Git não encontrado. Instale em: https://git-scm.com/"
        missing=1
    else
        print_success "Git encontrado: $(git --version)"
    fi
    
    if [ $missing -eq 1 ]; then
        print_error "Por favor, instale os pré-requisitos faltantes"
        exit 1
    fi
    
    print_success "Todos os pré-requisitos verificados!"
    echo
}

# Configurar Backend
setup_backend() {
    print_info "Configurando Backend Python..."
    
    cd backend
    
    # Criar ambiente virtual
    if [ ! -d "venv" ]; then
        print_info "Criando ambiente virtual..."
        python3 -m venv venv
        print_success "Ambiente virtual criado"
    else
        print_success "Ambiente virtual já existe"
    fi
    
    # Ativar ambiente virtual
    if [ -f "venv/bin/activate" ]; then
        source venv/bin/activate
    elif [ -f "venv/Scripts/activate" ]; then
        source venv/Scripts/activate
    fi
    
    # Instalar dependências
    print_info "Instalando dependências Python..."
    pip install -q -r requirements.txt
    print_success "Dependências Python instaladas"
    
    # Copiar .env se não existir
    if [ ! -f ".env" ]; then
        cp .env.example .env
        print_warning ".env criado - CONFIGURE COM SEUS VALORES!"
        cat .env
        wait_for_input
    fi
    
    # Verificar service-account.json
    if [ ! -f "service-account.json" ]; then
        print_warning "⚠️  IMPORTANTE: service-account.json não encontrado!"
        print_info "Para usar o Google Drive, você precisa:"
        print_info "1. Ir para: https://console.cloud.google.com/"
        print_info "2. Criar um projeto"
        print_info "3. Habilitar Google Drive API"
        print_info "4. Criar uma Service Account"
        print_info "5. Baixar a chave JSON"
        print_info "6. Copiar para: backend/service-account.json"
        print_info ""
        print_info "Veja 'docs/CONFIGURACAO_GOOGLE_DRIVE.md' para instruções completas"
    else
        print_success "service-account.json encontrado"
    fi
    
    cd ..
    echo
}

# Configurar Frontend
setup_frontend() {
    print_info "Configurando Frontend Flutter..."
    
    cd frontend
    
    # Instalar dependências Flutter
    print_info "Instalando dependências Flutter..."
    flutter pub get -q
    print_success "Dependências Flutter instaladas"
    
    # Verificar se web está habilitado
    if [ ! -d "web" ]; then
        print_info "Criando suporte web..."
        flutter create --platforms web . --quiet
        print_success "Suporte web criado"
    fi
    
    cd ..
    echo
}

# Menu de inicialização
show_menu() {
    echo
    print_info "Selecione o que deseja fazer:"
    echo "1) Iniciar Backend (Python)"
    echo "2) Iniciar Frontend (Flutter Web)"
    echo "3) Iniciar Ambos (em abas diferentes)"
    echo "4) Apenas Configurar (sem iniciar)"
    echo "5) Sair"
    echo
    read -p "$(echo -e ${YELLOW})Escolha uma opção [1-5]: $(echo -e ${NC})" option
}

# Iniciar Backend
start_backend() {
    print_info "Iniciando Backend em http://localhost:8000"
    echo
    
    cd backend
    
    # Ativar ambiente virtual
    if [ -f "venv/bin/activate" ]; then
        source venv/bin/activate
    fi
    
    python3 main.py
    
    cd ..
}

# Iniciar Frontend
start_frontend() {
    print_info "Iniciando Frontend em http://localhost:3000"
    echo
    
    cd frontend
    flutter run -d chrome
    cd ..
}

# Iniciar Ambos
start_both() {
    print_info "Iniciando ambos os serviços em abas de terminal"
    echo
    
    # Verificar se está em macOS ou Linux
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        print_info "Abrindo Terminal para Backend..."
        osascript -e 'tell app "Terminal" to do script "cd '"$(pwd)"'/backend && source venv/bin/activate && python3 main.py"'
        
        sleep 2
        
        print_info "Abrindo Terminal para Frontend..."
        osascript -e 'tell app "Terminal" to do script "cd '"$(pwd)"'/frontend && flutter run -d chrome"'
    else
        # Linux/WSL
        print_info "Abrindo terminal para Backend..."
        x-terminal-emulator -e bash -c "cd $(pwd)/backend && source venv/bin/activate && python3 main.py; bash" &
        
        sleep 2
        
        print_info "Abrindo terminal para Frontend..."
        x-terminal-emulator -e bash -c "cd $(pwd)/frontend && flutter run -d chrome; bash" &
    fi
    
    echo
    print_success "Serviços iniciados!"
    print_info "Backend: http://localhost:8000"
    print_info "Frontend: http://localhost:3000/?session=teste123"
}

# Função principal
main() {
    # Verificar pré-requisitos
    check_prerequisites
    
    # Configurar
    setup_backend
    setup_frontend
    
    # Loop de menu
    while true; do
        show_menu
        
        case $option in
            1)
                start_backend
                ;;
            2)
                start_frontend
                ;;
            3)
                start_both
                break
                ;;
            4)
                print_success "Configuração concluída!"
                print_info "Para iniciar manualmente:"
                print_info "Backend:  cd backend && python3 main.py"
                print_info "Frontend: cd frontend && flutter run -d chrome"
                break
                ;;
            5)
                print_info "Até logo!"
                exit 0
                ;;
            *)
                print_error "Opção inválida"
                ;;
        esac
    done
}

# Executar
main
