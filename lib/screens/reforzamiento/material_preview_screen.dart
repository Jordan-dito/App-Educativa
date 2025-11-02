import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/material_reforzamiento_model.dart';
import '../../services/download_service.dart';
class MaterialPreviewScreen extends StatefulWidget {
  final MaterialReforzamiento material;

  const MaterialPreviewScreen({super.key, required this.material});

  @override
  State<MaterialPreviewScreen> createState() => _MaterialPreviewScreenState();
}

class _MaterialPreviewScreenState extends State<MaterialPreviewScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  String get _fileUrl {
    if (widget.material.archivoRuta == null) return '';
    const baseUrl = 'https://hermanosfrios.alwaysdata.net';
    return widget.material.archivoRuta!.startsWith('http')
        ? widget.material.archivoRuta!
        : '$baseUrl${widget.material.archivoRuta!.startsWith('/') ? widget.material.archivoRuta! : '/${widget.material.archivoRuta!}'}';
  }

  @override
  void initState() {
    super.initState();
    // No inicializar WebView aquí, se creará en el build según el tipo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.material.titulo),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          if (widget.material.tipoContenido == 'pdf' ||
              widget.material.tipoContenido == 'imagen')
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Descargar',
              onPressed: () {
                if (widget.material.archivoRuta != null) {
                  DownloadService.downloadAndOpenFile(
                    filePath: widget.material.archivoRuta!,
                    fileName: widget.material.archivoNombre ??
                        'archivo.${widget.material.tipoContenido}',
                    context: context,
                  );
                }
              },
            ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (widget.material.tipoContenido) {
      case 'texto':
        return _buildTextoContent();
      case 'imagen':
        return _buildImagenContent();
      case 'pdf':
        return _buildPdfContent();
      case 'link':
        return _buildLinkContent();
      case 'video':
        return _buildVideoContent();
      default:
        return const Center(child: Text('Tipo de contenido no soportado'));
    }
  }

  Widget _buildTextoContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.material.titulo,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.material.descripcion != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.material.descripcion!,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.material.contenido ?? 'Sin contenido',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagenContent() {
    if (_fileUrl.isEmpty) {
      return const Center(child: Text('No hay imagen disponible'));
    }

    return Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: CachedNetworkImage(
          imageUrl: _fileUrl,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              const Text('Error al cargar la imagen'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  if (widget.material.archivoRuta != null) {
                    DownloadService.downloadAndOpenFile(
                      filePath: widget.material.archivoRuta!,
                      fileName: widget.material.archivoNombre ?? 'imagen.jpg',
                      context: context,
                    );
                  }
                },
                icon: const Icon(Icons.download),
                label: const Text('Descargar imagen'),
              ),
            ],
          ),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildPdfContent() {
    if (_fileUrl.isEmpty) {
      return const Center(child: Text('No hay PDF disponible'));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (widget.material.archivoRuta != null) {
                  DownloadService.downloadAndOpenFile(
                    filePath: widget.material.archivoRuta!,
                    fileName: widget.material.archivoNombre ?? 'documento.pdf',
                    context: context,
                  );
                }
              },
              icon: const Icon(Icons.download),
              label: const Text('Descargar PDF'),
            ),
          ],
        ),
      );
    }

    // Usar Google Docs Viewer para mostrar PDF
    final pdfViewerUrl = 'https://docs.google.com/viewer?url=${Uri.encodeComponent(_fileUrl)}&embedded=true';

    return Stack(
      children: [
        WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setNavigationDelegate(
              NavigationDelegate(
                onPageFinished: (String url) {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                onWebResourceError: (WebResourceError error) {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                      _errorMessage = 'Error al cargar el PDF: ${error.description}';
                    });
                  }
                },
              ),
            )
            ..loadRequest(Uri.parse(pdfViewerUrl)),
        ),
        if (_isLoading)
          Container(
            color: Colors.white,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando PDF...'),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLinkContent() {
    if (widget.material.urlExterna == null) {
      return const Center(child: Text('No hay URL disponible'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.material.titulo,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.material.descripcion != null) ...[
                    const SizedBox(height: 8),
                    Text(widget.material.descripcion!),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    widget.material.urlExterna!,
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              final uri = Uri.parse(widget.material.urlExterna!);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Abrir en navegador'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoContent() {
    if (widget.material.urlExterna == null) {
      return const Center(child: Text('No hay video disponible'));
    }

    // Para videos, usar WebView para mostrar el reproductor
    return Stack(
      children: [
        WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setNavigationDelegate(
              NavigationDelegate(
                onPageFinished: (String url) {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                onWebResourceError: (WebResourceError error) {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                      _errorMessage = 'Error al cargar el video';
                    });
                  }
                },
              ),
            )
            ..loadRequest(Uri.parse(widget.material.urlExterna!)),
        ),
        if (_isLoading)
          Container(
            color: Colors.white,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando video...'),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

