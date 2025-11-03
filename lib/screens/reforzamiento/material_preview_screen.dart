import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/material_reforzamiento_model.dart';

class MaterialPreviewScreen extends StatefulWidget {
  final MaterialReforzamiento material;

  const MaterialPreviewScreen({super.key, required this.material});

  @override
  State<MaterialPreviewScreen> createState() => _MaterialPreviewScreenState();
}

class _MaterialPreviewScreenState extends State<MaterialPreviewScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.material.titulo),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (widget.material.tipoContenido) {
      case 'texto':
        return _buildTextoContent();
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
                    });
                  }
                  debugPrint('Error al cargar el video: ${error.description}');
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

