"""
API de Upload de Fotos para Eventos
Backend construído com FastAPI e integração com Google Drive
"""

import os
import json
import logging
from datetime import datetime
from pathlib import Path
from typing import Optional

from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import uvicorn
from dotenv import load_dotenv

from google.auth.transport.requests import Request
from google_auth_oauthlib.flow import InstalledAppFlow
from google.oauth2.credentials import Credentials as OAuthCredentials
from google.oauth2.service_account import Credentials
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload
from googleapiclient.errors import HttpError

load_dotenv()

# ============================================================================
# Configuração de Logging
# ============================================================================

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# ============================================================================
# Inicialização da Aplicação FastAPI
# ============================================================================

app = FastAPI(
    title="API de Upload de Fotos",
    description="Backend para captura e upload automático de fotos com integração Google Drive",
    version="1.0.0"
)

# ============================================================================
# Configuração de CORS
# ============================================================================

# IMPORTANTE: Configurar os domínios permitidos conforme seu ambiente
ALLOWED_ORIGINS = [
    "http://localhost:3000",          # Frontend local (Flutter Web dev)
    "http://localhost:5000",          # Alternativa
    "http://localhost:8080",          # Flutter Web dev server
    "http://127.0.0.1:3000",          # Localhost
    "http://127.0.0.1:5000",          # Localhost
    "http://127.0.0.1:8080",          # Localhost
    "https://bonnano.github.io",      # Frontend publicado no GitHub Pages
    "https://meuapp.com",             # Domínio de produção (ALTERAR)
    "https://www.meuapp.com",         # WWW (ALTERAR)
    "http://localhost:port",          # Substitua 'port' pelo número da porta se necessário
    # Adicione outros domínios conforme necessário
]

origins_configuradas = os.getenv('ALLOWED_ORIGINS', '')
if origins_configuradas:
    ALLOWED_ORIGINS = [
        origem.strip()
        for origem in origins_configuradas.split(',')
        if origem.strip()
    ]

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_origin_regex=r"^https?://(localhost|127\.0\.0\.1)(:\d+)?$",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============================================================================
# Configuração do Google Drive
# ============================================================================

class GoogleDriveManager:
    """
    Gerenciador para autenticação e interações com Google Drive
    usando OAuth do usuário ou Service Account
    """

    AUTH_MODE = os.getenv('GOOGLE_DRIVE_AUTH_MODE', 'oauth').lower()
    
    # Caminho para o arquivo JSON da Service Account
    SERVICE_ACCOUNT_FILE = os.getenv(
        'GOOGLE_SERVICE_ACCOUNT_FILE',
        'service-account.json'
    )
    
    # ID da pasta no Google Drive onde salvar as fotos
    FOLDER_ID = os.getenv(
        'GOOGLE_DRIVE_FOLDER_ID',
        '1lbNk8NROiwIDrHDKX6oX1al3FG599Duq'  # ALTERAR COM O ID DA PASTA
    )
    
    # Escopos necessários para acesso
    SCOPES = [
        'https://www.googleapis.com/auth/drive.file',
        'https://www.googleapis.com/auth/drive'
    ]

    OAUTH_CLIENT_FILE = os.getenv(
        'GOOGLE_OAUTH_CLIENT_FILE',
        'oauth-client.json'
    )
    OAUTH_TOKEN_FILE = os.getenv(
        'GOOGLE_OAUTH_TOKEN_FILE',
        'oauth-token.json'
    )

    @staticmethod
    def _resolver_arquivo(arquivo: str) -> str:
        """Resolve arquivos locais ou Secret Files montados pelo Render."""
        caminho = Path(arquivo)
        if caminho.exists():
            return str(caminho)

        caminho_secreto = Path('/etc/secrets') / caminho.name
        if caminho_secreto.exists():
            return str(caminho_secreto)

        return str(caminho)

    @staticmethod
    def _obter_credenciais_oauth():
        """Carrega ou cria as credenciais OAuth da conta Google do proprietário."""
        credenciais = None
        caminho_token = GoogleDriveManager._resolver_arquivo(
            GoogleDriveManager.OAUTH_TOKEN_FILE
        )
        caminho_cliente = GoogleDriveManager._resolver_arquivo(
            GoogleDriveManager.OAUTH_CLIENT_FILE
        )

        if os.path.exists(caminho_token):
            credenciais = OAuthCredentials.from_authorized_user_file(
                caminho_token,
                GoogleDriveManager.SCOPES
            )

        if credenciais and credenciais.valid:
            return credenciais

        if credenciais and credenciais.expired and credenciais.refresh_token:
            credenciais.refresh(Request())
        else:
            if not os.path.exists(caminho_cliente):
                erro = (
                    'Arquivo OAuth não encontrado: '
                    f'{GoogleDriveManager.OAUTH_CLIENT_FILE} ou '
                    f'/etc/secrets/{Path(GoogleDriveManager.OAUTH_CLIENT_FILE).name}. '
                    'Baixe um cliente OAuth do tipo aplicativo para computador '
                    'e configure GOOGLE_OAUTH_CLIENT_FILE.'
                )
                logger.error(erro)
                raise FileNotFoundError(erro)

            fluxo = InstalledAppFlow.from_client_secrets_file(
                caminho_cliente,
                GoogleDriveManager.SCOPES
            )
            credenciais = fluxo.run_local_server(port=0)

        with open(GoogleDriveManager.OAUTH_TOKEN_FILE, 'w', encoding='utf-8') as arquivo:
            arquivo.write(credenciais.to_json())

        return credenciais

    @staticmethod
    def _obter_service():
        """
        Cria e retorna um cliente do Google Drive autenticado
        
        Returns:
            googleapiclient.discovery.Resource: Cliente do Google Drive
            
        Raises:
            FileNotFoundError: Se o arquivo de credenciais não existir
            Exception: Se houver erro na autenticação
        """
        try:
            if GoogleDriveManager.AUTH_MODE == 'oauth':
                credenciais = GoogleDriveManager._obter_credenciais_oauth()
                logger.info("Autenticação OAuth do usuário realizada com sucesso")
            else:
                caminho_service_account = GoogleDriveManager._resolver_arquivo(
                    GoogleDriveManager.SERVICE_ACCOUNT_FILE
                )
                if not os.path.exists(caminho_service_account):
                    erro = (
                        'Arquivo de Service Account não encontrado: '
                        f'{GoogleDriveManager.SERVICE_ACCOUNT_FILE} ou '
                        f'/etc/secrets/{Path(GoogleDriveManager.SERVICE_ACCOUNT_FILE).name}'
                    )
                    logger.error(erro)
                    raise FileNotFoundError(erro)

                credenciais = Credentials.from_service_account_file(
                    caminho_service_account,
                    scopes=GoogleDriveManager.SCOPES
                )
                credenciais.refresh(Request())
                logger.info("Autenticação da Service Account realizada com sucesso")

            # Constrói o cliente do Google Drive
            servico = build('drive', 'v3', credentials=credenciais)
            
            return servico

        except FileNotFoundError as e:
            logger.error(f"Erro: {e}")
            raise
        except Exception as e:
            logger.error(f"Erro ao autenticar com Google Drive: {e}")
            raise

    @staticmethod
    def salvar_arquivo(
        arquivo_bytes: bytes,
        nome_arquivo: str,
        mime_type: str = 'image/jpeg'
    ) -> Optional[str]:
        """
        Salva um arquivo no Google Drive
        
        Args:
            arquivo_bytes (bytes): Conteúdo do arquivo em bytes
            nome_arquivo (str): Nome do arquivo a ser salvo
            
        Returns:
            Optional[str]: ID do arquivo no Google Drive, ou None se falhar
        """
        caminho_temp = None
        upload = None

        try:
            if not arquivo_bytes:
                logger.error("Arquivo vazio recebido")
                return None

            # Cria pasta temporária para armazenar o arquivo
            temp_dir = Path("temp_uploads")
            temp_dir.mkdir(exist_ok=True)
            
            caminho_temp = temp_dir / nome_arquivo
            
            # Escreve o arquivo temporariamente
            with open(caminho_temp, 'wb') as f:
                f.write(arquivo_bytes)
            
            logger.info(f"Arquivo temporário criado: {caminho_temp}")

            # Obtém o cliente autenticado
            servico = GoogleDriveManager._obter_service()

            # Prepara os metadados do arquivo
            metadados = {
                'name': nome_arquivo,
                'parents': [GoogleDriveManager.FOLDER_ID]  # Salva na pasta especificada
            }

            # Faz upload do arquivo
            upload = MediaFileUpload(
                str(caminho_temp),
                mimetype=mime_type,
                resumable=True
            )

            arquivo = servico.files().create(
                body=metadados,
                media_body=upload,
                fields='id, webViewLink',
                supportsAllDrives=True
            ).execute()

            arquivo_id = arquivo.get('id')
            link_arquivo = arquivo.get('webViewLink')

            logger.info(f"Arquivo salvo no Google Drive: {arquivo_id}")
            logger.info(f"Link: {link_arquivo}")

            return arquivo_id

        except HttpError as erro:
            logger.error(f"Erro HTTP ao salvar no Google Drive: {erro}")
            return None
        except Exception as erro:
            logger.error(f"Erro inesperado ao salvar arquivo: {erro}")
            return None
        finally:
            # No Windows, o descritor aberto pelo MediaFileUpload precisa ser fechado antes do unlink.
            if upload is not None:
                descritor = getattr(upload, '_fd', None)
                if descritor is not None and not descritor.closed:
                    descritor.close()

            if caminho_temp is not None and caminho_temp.exists():
                try:
                    caminho_temp.unlink()
                    logger.info("Arquivo temporário deletado")
                except OSError as erro:
                    logger.warning(f"Não foi possível remover o arquivo temporário: {erro}")

    @staticmethod
    def listar_arquivos_pasta(limite: int = 10):
        """
        Lista arquivos em uma pasta do Google Drive
        
        Args:
            limite (int): Número máximo de arquivos a listar
            
        Returns:
            list: Lista de arquivos (ou lista vazia se falhar)
        """
        try:
            servico = GoogleDriveManager._obter_service()
            
            resultados = servico.files().list(
                q=f"'{GoogleDriveManager.FOLDER_ID}' in parents",
                spaces='drive',
                fields='files(id, name, createdTime, webViewLink)',
                pageSize=limite,
                orderBy='createdTime desc'
            ).execute()

            arquivos = resultados.get('files', [])
            logger.info(f"Total de arquivos na pasta: {len(arquivos)}")
            
            return arquivos

        except Exception as e:
            logger.error(f"Erro ao listar arquivos: {e}")
            return []

# ============================================================================
# Endpoints da API
# ============================================================================

@app.get("/")
async def raiz():
    """
    Endpoint raiz da API
    
    Returns:
        dict: Informações sobre a API
    """
    return {
        "nome": "API de Upload de Fotos",
        "versao": "1.0.0",
        "status": "online",
        "endpoints": {
            "upload": "/upload-foto",
            "listar": "/listar-fotos",
            "health": "/health"
        }
    }

@app.get("/health")
async def health_check():
    """
    Verificação de saúde da API
    
    Returns:
        dict: Status da API
    """
    return {
        "status": "ok",
        "timestamp": datetime.now().isoformat()
    }

@app.post("/upload-foto")
async def upload_foto(
    imagem: UploadFile = File(...),
    session: str = Form(...)
) -> JSONResponse:
    """
    Endpoint para upload de foto
    
    Recebe uma imagem multipart e salva no Google Drive
    
    Args:
        imagem (UploadFile): Arquivo de imagem
        session (str): ID da sessão para nomeação do arquivo
        
    Returns:
        JSONResponse: Resultado do upload
        
    Raises:
        HTTPException: Se ocorrer algum erro no processamento
    """
    try:
        logger.info(f"Recebido upload - Sessão: {session}")

        # Validação básica
        if not session or session.strip() == "":
            logger.warning("Session ID vazio recebido")
            raise HTTPException(
                status_code=400,
                detail="Session ID é obrigatório"
            )

        if not imagem.filename:
            logger.warning("Arquivo sem nome recebido")
            raise HTTPException(
                status_code=400,
                detail="Arquivo não possui nome válido"
            )

        # Lê o conteúdo da imagem
        conteudo_imagem = await imagem.read()
        
        if len(conteudo_imagem) == 0:
            logger.warning("Imagem vazia recebida")
            raise HTTPException(
                status_code=400,
                detail="Imagem está vazia"
            )

        # O MIME informado pelo navegador pode ser application/octet-stream.
        # Identifica o formato pelo conteúdo antes de aceitar o upload.
        assinaturas_imagem = {
            b'\xff\xd8\xff': ('image/jpeg', '.jpg'),
            b'\x89PNG\r\n\x1a\n': ('image/png', '.png'),
        }
        mime_type = None
        extensao_detectada = None

        for assinatura, (mime_candidato, extensao_candidata) in assinaturas_imagem.items():
            if conteudo_imagem.startswith(assinatura):
                mime_type = mime_candidato
                extensao_detectada = extensao_candidata
                break

        if conteudo_imagem.startswith(b'RIFF') and conteudo_imagem[8:12] == b'WEBP':
            mime_type = 'image/webp'
            extensao_detectada = '.webp'

        if mime_type is None:
            logger.warning(
                f"Tipo de arquivo não permitido: informado={imagem.content_type}, "
                f"nome={imagem.filename}"
            )
            raise HTTPException(
                status_code=400,
                detail="O arquivo enviado não é uma imagem JPEG, PNG ou WebP válida"
            )

        logger.info(
            f"Tamanho da imagem: {len(conteudo_imagem)} bytes, formato detectado: {mime_type}"
        )

        # Gera nome do arquivo com timestamp e session ID
        extensao = extensao_detectada or Path(imagem.filename).suffix or '.jpg'
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        nome_arquivo = f"foto_{session}_{timestamp}{extensao}"

        logger.info(f"Nome do arquivo: {nome_arquivo}")

        # Salva no Google Drive
        arquivo_id = GoogleDriveManager.salvar_arquivo(
            conteudo_imagem,
            nome_arquivo,
            mime_type
        )

        if not arquivo_id:
            logger.error("Falha ao salvar arquivo no Google Drive")
            raise HTTPException(
                status_code=500,
                detail="Erro ao salvar arquivo no Google Drive"
            )

        logger.info(f"Upload concluído com sucesso - ID: {arquivo_id}")

        return JSONResponse(
            status_code=200,
            content={
                "status": "sucesso",
                "mensagem": "Foto salva com sucesso no Google Drive",
                "arquivo_id": arquivo_id,
                "arquivo_nome": nome_arquivo,
                "timestamp": datetime.now().isoformat(),
                "session": session
            }
        )

    except HTTPException as e:
        logger.error(f"Erro HTTP: {e.detail}")
        return JSONResponse(
            status_code=e.status_code,
            content={"status": "erro", "mensagem": e.detail}
        )
    except Exception as e:
        logger.error(f"Erro inesperado: {e}")
        return JSONResponse(
            status_code=500,
            content={
                "status": "erro",
                "mensagem": "Erro interno do servidor",
                "detalhe": str(e)
            }
        )

@app.get("/listar-fotos")
async def listar_fotos(limite: int = 10):
    """
    Lista as fotos enviadas (últimas primeiras)
    
    Args:
        limite (int): Número máximo de fotos a listar
        
    Returns:
        dict: Lista de fotos com metadados
    """
    try:
        logger.info(f"Listando últimas {limite} fotos")
        
        arquivos = GoogleDriveManager.listar_arquivos_pasta(limite)
        
        return {
            "status": "sucesso",
            "total": len(arquivos),
            "arquivos": [
                {
                    "id": arquivo.get('id'),
                    "nome": arquivo.get('name'),
                    "criado_em": arquivo.get('createdTime'),
                    "link": arquivo.get('webViewLink')
                }
                for arquivo in arquivos
            ]
        }
    except Exception as e:
        logger.error(f"Erro ao listar fotos: {e}")
        return JSONResponse(
            status_code=500,
            content={
                "status": "erro",
                "mensagem": "Erro ao listar fotos"
            }
        )

@app.options("/{full_path:path}")
async def preflight_handler(full_path: str):
    """
    Handler para requisições OPTIONS (CORS preflight)
    """
    return JSONResponse(
        status_code=200,
        content={"status": "ok"}
    )

# ============================================================================
# Inicialização do Servidor
# ============================================================================

if __name__ == "__main__":
    logger.info("Iniciando API de Upload de Fotos...")
    
    # Validação de configuração
    if GoogleDriveManager.FOLDER_ID == 'YOUR_FOLDER_ID_HERE':
        logger.warning(
            "⚠️  AVISO: GOOGLE_DRIVE_FOLDER_ID não configurado. "
            "Defina a variável de ambiente com o ID real da pasta."
        )
    
    if not os.path.exists(GoogleDriveManager.SERVICE_ACCOUNT_FILE):
        logger.warning(
            f"⚠️  AVISO: Arquivo de Service Account não encontrado em "
            f"{GoogleDriveManager.SERVICE_ACCOUNT_FILE}"
        )

    uvicorn.run(
        app,
        host="0.0.0.0",
        port=int(os.getenv('PORT', os.getenv('API_PORT', '8000'))),
        log_level="info"
    )
