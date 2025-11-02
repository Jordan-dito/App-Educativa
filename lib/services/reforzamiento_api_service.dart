import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/estudiante_reprobado_model.dart';
import '../models/material_reforzamiento_model.dart';

class ReforzamientoApiService {
  static const String _baseUrl = 'https://hermanosfrios.alwaysdata.net/api';

  // Headers para las peticiones
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Obtener estudiantes reprobados
  Future<List<EstudianteReprobado>> obtenerEstudiantesReprobados({
    required int materiaId,
    required int profesorId,
    int? anioAcademico,
  }) async {
    try {
      debugPrint(
          '📚 DEBUG ReforzamientoApiService: Obteniendo estudiantes reprobados - materia_id: $materiaId, profesor_id: $profesorId');

      final queryParams = {
        'action': 'estudiantes_reprobados',
        'materia_id': materiaId.toString(),
        'profesor_id': profesorId.toString(),
      };

      if (anioAcademico != null) {
        queryParams['año_academico'] = anioAcademico.toString();
      } else {
        queryParams['año_academico'] = DateTime.now().year.toString();
      }

      final url = Uri.parse('$_baseUrl/reforzamiento.php')
          .replace(queryParameters: queryParams);

      debugPrint('📚 DEBUG ReforzamientoApiService: URL: $url');

      final response = await http.get(url, headers: _headers);

      debugPrint(
          '📚 DEBUG ReforzamientoApiService: Status Code: ${response.statusCode}');
      debugPrint(
          '📚 DEBUG ReforzamientoApiService: Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'] ?? [];
          final estudiantes = data
              .map((e) => EstudianteReprobado.fromJson(e))
              .toList();

          debugPrint(
              '📚 DEBUG ReforzamientoApiService: ${estudiantes.length} estudiantes reprobados encontrados');
          return estudiantes;
        } else {
          throw Exception(jsonResponse['message'] ??
              'Error al obtener estudiantes reprobados');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ ERROR ReforzamientoApiService.obtenerEstudiantesReprobados: $e');
      rethrow;
    }
  }

  // Subir material de reforzamiento
  Future<bool> subirMaterial({
    required int materiaId,
    int? estudianteId,
    required int profesorId,
    required String titulo,
    String? descripcion,
    required String tipoContenido,
    String? contenido,
    File? archivo,
    String? urlExterna,
    DateTime? fechaVencimiento,
  }) async {
    try {
      debugPrint('📤 DEBUG ReforzamientoApiService: Subiendo material...');

      final url = Uri.parse('$_baseUrl/reforzamiento.php?action=subir');

      var request = http.MultipartRequest('POST', url);

      // Campos del formulario
      request.fields['materia_id'] = materiaId.toString();
      if (estudianteId != null) {
        request.fields['estudiante_id'] = estudianteId.toString();
      }
      request.fields['profesor_id'] = profesorId.toString();
      request.fields['año_academico'] = DateTime.now().year.toString();
      request.fields['titulo'] = titulo;
      if (descripcion != null) request.fields['descripcion'] = descripcion;
      request.fields['tipo_contenido'] = tipoContenido;
      if (contenido != null) request.fields['contenido'] = contenido;
      if (urlExterna != null) request.fields['url_externa'] = urlExterna;
      if (fechaVencimiento != null) {
        request.fields['fecha_vencimiento'] =
            fechaVencimiento.toIso8601String();
      }

      // Archivo si existe
      if (archivo != null) {
        // Detectar tipo MIME basado en la extensión del archivo
        final extension = archivo.path.split('.').last.toLowerCase();
        String? contentType;
        String? filename;

        switch (extension) {
          case 'pdf':
            contentType = 'application/pdf';
            filename = archivo.path.split('/').last;
            break;
          case 'jpg':
          case 'jpeg':
            contentType = 'image/jpeg';
            filename = archivo.path.split('/').last;
            break;
          case 'png':
            contentType = 'image/png';
            filename = archivo.path.split('/').last;
            break;
          case 'gif':
            contentType = 'image/gif';
            filename = archivo.path.split('/').last;
            break;
          case 'mp4':
            contentType = 'video/mp4';
            filename = archivo.path.split('/').last;
            break;
          default:
            // Si no reconocemos el tipo, usar el tipo según tipoContenido
            if (tipoContenido == 'pdf') {
              contentType = 'application/pdf';
            } else if (tipoContenido == 'imagen') {
              contentType = 'image/jpeg'; // Default para imágenes
            } else if (tipoContenido == 'video') {
              contentType = 'video/mp4';
            }
            filename = archivo.path.split('/').last;
        }

        debugPrint('📤 DEBUG ReforzamientoApiService: Archivo - Extensión: $extension, Content-Type: $contentType, Nombre: $filename');

        request.files.add(await http.MultipartFile.fromPath(
          'archivo',
          archivo.path,
          filename: filename,
          contentType: contentType != null
              ? MediaType.parse(contentType)
              : null,
        ));
      }

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      final data = json.decode(responseBody);

      debugPrint(
          '📤 DEBUG ReforzamientoApiService: Response: ${responseBody}');

      if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
        return data['success'] == true;
      } else {
        throw Exception(data['message'] ?? 'Error al subir material');
      }
    } catch (e) {
      debugPrint('❌ ERROR ReforzamientoApiService.subirMaterial: $e');
      rethrow;
    }
  }

  // Obtener material por estudiante (para profesor)
  Future<List<MaterialReforzamiento>> obtenerMaterialPorEstudiante({
    required int estudianteId,
    required int materiaId,
    int? anioAcademico,
  }) async {
    try {
      debugPrint(
          '📚 DEBUG ReforzamientoApiService: Obteniendo material por estudiante - estudiante_id: $estudianteId, materia_id: $materiaId');

      final queryParams = {
        'action': 'material_por_estudiante',
        'estudiante_id': estudianteId.toString(),
        'materia_id': materiaId.toString(),
      };

      if (anioAcademico != null) {
        queryParams['año_academico'] = anioAcademico.toString();
      } else {
        queryParams['año_academico'] = DateTime.now().year.toString();
      }

      final url = Uri.parse('$_baseUrl/reforzamiento.php')
          .replace(queryParameters: queryParams);

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'] ?? [];
          return data
              .map((e) => MaterialReforzamiento.fromJson(e))
              .toList();
        } else {
          throw Exception(jsonResponse['message'] ??
              'Error al obtener material del estudiante');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint(
          '❌ ERROR ReforzamientoApiService.obtenerMaterialPorEstudiante: $e');
      rethrow;
    }
  }

  // Obtener material para estudiante
  Future<List<MaterialReforzamiento>> obtenerMaterialEstudiante({
    required int estudianteId,
    int? materiaId,
    int? anioAcademico,
  }) async {
    try {
      debugPrint(
          '📚 DEBUG ReforzamientoApiService: Obteniendo material estudiante - estudiante_id: $estudianteId');

      final queryParams = {
        'action': 'obtener_estudiante',
        'estudiante_id': estudianteId.toString(),
      };

      if (materiaId != null) {
        queryParams['materia_id'] = materiaId.toString();
      }

      if (anioAcademico != null) {
        queryParams['año_academico'] = anioAcademico.toString();
      } else {
        queryParams['año_academico'] = DateTime.now().year.toString();
      }

      final url = Uri.parse('$_baseUrl/reforzamiento.php')
          .replace(queryParameters: queryParams);

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'] ?? [];
          return data
              .map((e) => MaterialReforzamiento.fromJson(e))
              .toList();
        } else {
          throw Exception(
              jsonResponse['message'] ?? 'Error al obtener material');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint(
          '❌ ERROR ReforzamientoApiService.obtenerMaterialEstudiante: $e');
      rethrow;
    }
  }

  // Eliminar material
  Future<bool> eliminarMaterial(int materialId) async {
    try {
      debugPrint(
          '🗑️ DEBUG ReforzamientoApiService: Eliminando material - id: $materialId');

      final url = Uri.parse('$_baseUrl/reforzamiento.php')
          .replace(queryParameters: {
        'action': 'eliminar',
        'material_id': materialId.toString(),
      });

      final response = await http.delete(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['success'] == true;
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ ERROR ReforzamientoApiService.eliminarMaterial: $e');
      rethrow;
    }
  }
}

