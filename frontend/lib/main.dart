import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open House do Luiz',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF061322),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD99A2B),
          brightness: Brightness.dark,
        ),
      ),
      home: const CapturaFotosPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CapturaFotosPage extends StatefulWidget {
  const CapturaFotosPage({Key? key}) : super(key: key);

  @override
  State<CapturaFotosPage> createState() => _CapturaFotosPageState();
}

class _CapturaFotosPageState extends State<CapturaFotosPage> {
  final Logger logger = Logger();
  final ImagePicker _picker = ImagePicker();
  
  Uint8List? _imagemCapturada;
  String _sessaoId = '';
  bool _fazendoUpload = false;
  String _mensagem = '';
  MensagemTipo _tipoMensagem = MensagemTipo.info;

  @override
  void initState() {
    super.initState();
    _extrairSessaoUrl();
  }

  /// Extrai o parâmetro 'session' da URL do navegador
  void _extrairSessaoUrl() {
    try {
      final uri = Uri.base;
      _sessaoId = uri.queryParameters['session'] ?? 'Luiz-Party';
      
      logger.i('Sessão ID extraída: $_sessaoId');
      
      if (_sessaoId.isEmpty) {
        _mostrarMensagem(
          'ID de sessão não encontrado na URL',
          MensagemTipo.erro,
        );
      }
    } catch (e) {
      logger.e('Erro ao extrair sessão da URL: $e');
      _mostrarMensagem(
        'Erro ao processar URL',
        MensagemTipo.erro,
      );
    }
  }

  /// Abre a câmera e captura a foto
  Future<void> _capturarFoto() async {
    try {
      logger.i('Iniciando captura de foto');
      
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );

      if (foto != null) {
        final Uint8List bytes = await foto.readAsBytes();
        setState(() {
          _imagemCapturada = bytes;
          _mensagem = '';
        });
        logger.i('Foto capturada com sucesso: ${bytes.length} bytes');
      } else {
        logger.w('Captura de foto cancelada pelo usuário');
      }
    } catch (e) {
      logger.e('Erro ao capturar foto: $e');
      _mostrarMensagem(
        'Erro ao capturar foto. Verifique as permissões.',
        MensagemTipo.erro,
      );
    }
  }

  /// Envia a foto para o backend
  Future<void> _enviarFoto() async {
    if (_imagemCapturada == null) {
      _mostrarMensagem('Nenhuma foto capturada', MensagemTipo.erro);
      return;
    }

    if (_sessaoId.isEmpty) {
      _mostrarMensagem(
        'ID de sessão inválido',
        MensagemTipo.erro,
      );
      return;
    }

    setState(() {
      _fazendoUpload = true;
      _mensagem = 'Enviando foto...';
      _tipoMensagem = MensagemTipo.info;
    });

    try {
      logger.i('Enviando foto para backend - Sessão: $_sessaoId');
      
      const String backendUrl = String.fromEnvironment(
        'BACKEND_URL',
        defaultValue: 'http://localhost:8000',
      );
      final Uri urlBackend = Uri.parse('$backendUrl/upload-foto');
      
      final request = http.MultipartRequest('POST', urlBackend);
      
      // Adiciona a imagem como arquivo
      request.files.add(
        http.MultipartFile.fromBytes(
          'imagem',
          _imagemCapturada!,
          filename: 'foto_${_sessaoId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      
      // Adiciona o ID da sessão
      request.fields['session'] = _sessaoId;
      
      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Tempo limite de envio excedido');
        },
      );

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        logger.i('Upload bem-sucedido! Status: ${response.statusCode}');
        
        _mostrarMensagem(
          'Foto enviada com sucesso!',
          MensagemTipo.sucesso,
        );

        // Aguarda 2 segundos antes de limpar
        await Future.delayed(const Duration(seconds: 2));
        
        setState(() {
          _imagemCapturada = null;
        });
      } else {
        logger.e('Erro no upload. Status: ${response.statusCode}');
        _mostrarMensagem(
          'Erro no envio. Código: ${response.statusCode}',
          MensagemTipo.erro,
        );
      }

      logger.d('Response body: $responseBody');
    } catch (e) {
      logger.e('Erro ao enviar foto: $e');
      
      String mensagem = 'Erro ao enviar a foto';
      if (e is TimeoutException) {
        mensagem = 'Tempo limite de conexão excedido';
      } else if (e.toString().contains('Connection refused')) {
        mensagem = 'Não é possível conectar ao servidor. Verifique a URL.';
      }
      
      _mostrarMensagem(mensagem, MensagemTipo.erro);
    } finally {
      setState(() {
        _fazendoUpload = false;
      });
    }
  }

  /// Limpa a foto capturada
  void _descartarFoto() {
    setState(() {
      _imagemCapturada = null;
      _mensagem = '';
    });
  }

  /// Exibe mensagens de feedback
  void _mostrarMensagem(String texto, MensagemTipo tipo) {
    setState(() {
      _mensagem = texto;
      _tipoMensagem = tipo;
    });

    // Remove mensagem após 5 segundos se for sucesso
    if (tipo == MensagemTipo.sucesso) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _mensagem = '';
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool ehMobileSize = MediaQuery.of(context).size.width < 768;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF020914),
                      const Color(0xFF0B2138),
                      const Color(0xFF03101D),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -48,
              right: -22,
              child: _buildBalaoDecorativo(const Color(0xFFB97718), 118),
            ),
            Positioned(
              top: 74,
              right: 32,
              child: _buildBalaoDecorativo(const Color(0xFF174B76), 82),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  ehMobileSize ? 20 : 32,
                  26,
                  ehMobileSize ? 20 : 32,
                  40,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      children: [
                        const Text(
                          'OPEN HOUSE',
                          style: TextStyle(
                            color: Color(0xFFE8B34A),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'ANIVERSÁRIO',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFF5F1E8),
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'DO',
                          style: TextStyle(
                            color: Color(0xFFE3A12D),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                          ),
                        ),
                        const Text(
                          'LUIZ',
                          style: TextStyle(
                            color: Color(0xFFE2A334),
                            fontSize: 72,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 5,
                            height: .95,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: 150,
                          height: 2,
                          color: const Color(0xFFD99A2B),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _imagemCapturada == null
                              ? 'Venha celebrar este novo ciclo\ncom boa companhia e boas energias!'
                              : 'Essa lembrança já está quase pronta.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFF4F0E9),
                            fontSize: 19,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 30),
                        if (_imagemCapturada == null)
                          _buildCameraArea()
                        else
                          _buildPreviewArea(),
                        const SizedBox(height: 24),
                        if (_mensagem.isNotEmpty) _buildMensagem(),
                        if (_mensagem.isNotEmpty) const SizedBox(height: 18),
                        if (_imagemCapturada == null)
                          _buildBotaoCameraCaptura()
                        else
                          _buildBotoesPreview(),
                        const SizedBox(height: 28),
                        const Text(
                          'Registre o momento e compartilhe a alegria.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFCEAB68),
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalaoDecorativo(Color color, double size) {
    return Container(
      width: size,
      height: size * 1.18,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .8),
        borderRadius: BorderRadius.circular(size),
        border: Border.all(color: Colors.white.withValues(alpha: .35)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .35),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  /// Área de câmera (quando nenhuma foto foi capturada)
  Widget _buildCameraArea() {
    return Column(
      children: [
        Container(
          width: 156,
          height: 156,
          decoration: BoxDecoration(
            color: const Color(0xFF0C243A),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD99A2B), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD99A2B).withValues(alpha: .18),
                blurRadius: 22,
              ),
            ],
          ),
          child: Icon(
            Icons.camera_alt,
            size: 62,
            color: const Color(0xFFE3A12D),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Capture uma foto para guardar\nessa celebração para sempre',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFB7C2CC),
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  /// Área de preview (após captura)
  Widget _buildPreviewArea() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFD99A2B), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD99A2B).withValues(alpha: .2),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Image.memory(
              _imagemCapturada!,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Prévia da foto capturada',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFFCEAB68),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  /// Botão de captura (principal)
  Widget _buildBotaoCameraCaptura() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _capturarFoto,
        icon: const Icon(Icons.camera_alt, size: 24),
        label: const Text(
          'Capturar Foto',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color(0xFFD99A2B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  /// Botões de preview (Enviar e Descartar)
  Widget _buildBotoesPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botão Enviar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _fazendoUpload ? null : _enviarFoto,
            icon: _fazendoUpload
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Icon(Icons.check_circle, size: 24),
            label: Text(
              _fazendoUpload ? 'Enviando...' : 'Enviar Foto',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFFD99A2B),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF806328),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Botão Descartar
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _fazendoUpload ? null : _descartarFoto,
            icon: const Icon(Icons.close, size: 24),
            label: const Text(
              'Descartar Foto',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: const Color(0xFFE3A12D),
              side: const BorderSide(color: Color(0xFFD99A2B), width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Widget de mensagem de feedback
  Widget _buildMensagem() {
    Color corFundo;
    Color corTexto;
    IconData icone;

    switch (_tipoMensagem) {
      case MensagemTipo.sucesso:
        corFundo = const Color(0xFF173D31);
        corTexto = const Color(0xFF9FE0B0);
        icone = Icons.check_circle;
        break;
      case MensagemTipo.erro:
        corFundo = const Color(0xFF4B2023);
        corTexto = const Color(0xFFFFB1A9);
        icone = Icons.error;
        break;
      case MensagemTipo.info:
        corFundo = const Color(0xFF17334D);
        corTexto = const Color(0xFFA9D1F5);
        icone = Icons.info;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: corTexto.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icone, color: corTexto, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _mensagem,
              style: TextStyle(
                color: corTexto,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Enum para tipos de mensagem
enum MensagemTipo { sucesso, erro, info }
