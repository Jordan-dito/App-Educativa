import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';

class DownloadService {
  static const String baseUrl = 'https://hermanosfrios.alwaysdata.net';

  /// Descargar y abrir un archivo
  static Future<void> downloadAndOpenFile({
    required String filePath,
    required String fileName,
    required BuildContext context,
  }) async {
    try {
      // Mostrar indicador de carga
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Solicitar permisos de almacenamiento
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        if (context.mounted) {
          Navigator.pop(context); // Cerrar loading
          _showError(context, 'Se necesitan permisos de almacenamiento para descargar archivos');
        }
        return;
      }

      // Construir URL completa del archivo
      final url = filePath.startsWith('http')
          ? filePath
          : '$baseUrl${filePath.startsWith('/') ? filePath : '/$filePath'}';

      debugPrint('📥 DownloadService: Descargando desde: $url');

      // Descargar el archivo
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode != 200) {
        Navigator.pop(context); // Cerrar loading
        _showError(context, 'Error al descargar el archivo: ${response.statusCode}');
        return;
      }

      // Obtener directorio de descargas
      final directory = await _getDownloadDirectory();
      final file = File('${directory.path}/$fileName');

      // Guardar el archivo
      await file.writeAsBytes(response.bodyBytes);

      debugPrint('✅ DownloadService: Archivo guardado en: ${file.path}');

      Navigator.pop(context); // Cerrar loading

      // Abrir el archivo
      final result = await OpenFilex.open(file.path);

      if (result.type != ResultType.done) {
        _showError(context, 'Error al abrir el archivo: ${result.message}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Archivo descargado: $fileName'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ ERROR DownloadService.downloadAndOpenFile: $e');
      if (context.mounted) {
        Navigator.pop(context); // Cerrar loading si aún está abierto
        _showError(context, 'Error al descargar: $e');
      }
    }
  }

  /// Solicitar permisos de almacenamiento
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      try {
        // Verificar si ya tiene permisos
        if (await Permission.storage.isGranted ||
            await Permission.manageExternalStorage.isGranted) {
          return true;
        }

        // Para Android 11+ (API 30+), necesitamos manageExternalStorage para escribir en Downloads
        // Pero es más fácil usar el directorio externo de la app que no requiere permisos especiales
        // Intentamos solicitar storage, pero si falla, usamos el directorio de la app
        final status = await Permission.storage.request();
        
        // Si no se concedió, no es crítico porque usaremos el directorio de la app
        return status.isGranted || status.isLimited;
      } catch (e) {
        debugPrint('⚠️ Error solicitando permisos: $e');
        // Continuar sin permisos, usaremos directorio de la app
        return false;
      }
    }
    
    // Para iOS y otros sistemas
    return true;
  }

  /// Obtener el directorio de descargas
  /// Prioriza el directorio externo de la app que no requiere permisos especiales
  static Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // Primero intentar usar el directorio externo de la app (no requiere permisos especiales)
      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          final downloadDir = Directory('${externalDir.path}/Downloads');
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
          debugPrint('✅ Usando directorio externo de la app: ${downloadDir.path}');
          return downloadDir;
        }
      } catch (e) {
        debugPrint('⚠️ No se pudo obtener external storage: $e');
      }

      // Si falla, intentar el directorio público (solo si tenemos permisos)
      try {
        final hasPermission = await Permission.storage.isGranted;
        if (hasPermission) {
          final directory = Directory('/storage/emulated/0/Download');
          // Verificar que podemos escribir ahí
          try {
            final testFile = File('${directory.path}/.test_write');
            await testFile.writeAsString('test');
            await testFile.delete();
            debugPrint('✅ Usando directorio público de descargas: ${directory.path}');
            return directory;
          } catch (e) {
            debugPrint('⚠️ No se puede escribir en /storage/emulated/0/Download: $e');
          }
        }
      } catch (e) {
        debugPrint('⚠️ Error accediendo a directorio público: $e');
      }
    }

    // Para iOS y otros, usar el directorio de documentos de la aplicación
    try {
      final directory = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${directory.path}/Downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      debugPrint('✅ Usando directorio de documentos: ${downloadDir.path}');
      return downloadDir;
    } catch (e) {
      debugPrint('❌ Error obteniendo directorio de documentos: $e');
      // Último recurso: usar directorio temporal
      final tempDir = Directory.systemTemp;
      debugPrint('⚠️ Usando directorio temporal: ${tempDir.path}');
      return tempDir;
    }
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

