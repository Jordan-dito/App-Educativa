import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
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
          final estudiantes =
              data.map((e) => EstudianteReprobado.fromJson(e)).toList();

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
      debugPrint(
          '❌ ERROR ReforzamientoApiService.obtenerEstudiantesReprobados: $e');
      rethrow;
    }
  }

  // Subir material de reforzamiento
  // Solo soporta texto y link (sin archivos)
  Future<bool> subirMaterial({
    required int materiaId,
    int? estudianteId,
    required int profesorId,
    required String titulo,
    String? descripcion,
    required String tipoContenido,
    String? contenido,
    dynamic
        archivo, // Deprecated - ya no se usa, pero se mantiene por compatibilidad
    String? urlExterna,
    DateTime? fechaVencimiento,
  }) async {
    try {
      debugPrint('📤 DEBUG ReforzamientoApiService: Subiendo material...');
      debugPrint('   Tipo: $tipoContenido');

      final url = Uri.parse('$_baseUrl/reforzamiento.php?action=subir');

      // Usar http.post en lugar de MultipartRequest ya que no enviamos archivos
      final Map<String, String> body = {
        'materia_id': materiaId.toString(),
        if (estudianteId != null) 'estudiante_id': estudianteId.toString(),
        'profesor_id': profesorId.toString(),
        'año_academico': DateTime.now().year.toString(),
        'titulo': titulo,
        if (descripcion != null) 'descripcion': descripcion,
        'tipo_contenido': tipoContenido,
        if (contenido != null) 'contenido': contenido,
        if (urlExterna != null) 'url_externa': urlExterna,
        if (fechaVencimiento != null)
          'fecha_vencimiento': fechaVencimiento.toIso8601String(),
      };

      // Debug: mostrar todos los campos que se están enviando
      debugPrint('📤 DEBUG ReforzamientoApiService: Campos del request:');
      body.forEach((key, value) {
        debugPrint('   $key: $value');
      });

      final response = await http.post(
        url,
        headers: {
          ..._headers,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      debugPrint(
          '📤 DEBUG ReforzamientoApiService: Status Code: ${response.statusCode}');
      debugPrint(
          '📤 DEBUG ReforzamientoApiService: Response Body: ${response.body}');

      // Validar que la respuesta no esté vacía
      if (response.body.isEmpty) {
        debugPrint('❌ ERROR: Respuesta vacía del servidor');
        throw Exception(
            'El servidor no respondió. Verifica tu conexión a internet.');
      }

      // Intentar decodificar JSON
      Map<String, dynamic> data;
      try {
        data = json.decode(response.body);
      } catch (jsonError) {
        debugPrint(
            '❌ ERROR: No se pudo decodificar la respuesta JSON: $jsonError');
        debugPrint('   Respuesta recibida: ${response.body}');
        throw Exception(
            'Error en la respuesta del servidor. Por favor, intenta nuevamente.');
      }

      // Verificar código de estado HTTP
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Verificar que la respuesta tenga el formato esperado
        if (data.containsKey('success')) {
          final success = data['success'] == true ||
              data['success'] == 'true' ||
              data['success'] == 1;
          if (success) {
            debugPrint('✅ Material subido exitosamente');
            return true;
          } else {
            final errorMessage = data['message'] ??
                data['error'] ??
                'Error desconocido al subir material';
            debugPrint('❌ ERROR: El servidor reportó fallo: $errorMessage');
            throw Exception(errorMessage);
          }
        } else {
          debugPrint('❌ ERROR: La respuesta no contiene el campo "success"');
          debugPrint('   Respuesta: $data');
          throw Exception('Formato de respuesta inválido del servidor');
        }
      } else {
        // Código de estado HTTP indica error
        final errorMessage = data['message'] ??
            data['error'] ??
            'Error HTTP ${response.statusCode} al subir material';
        debugPrint('❌ ERROR HTTP ${response.statusCode}: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR ReforzamientoApiService.subirMaterial: $e');
      debugPrint('   Stack trace: $stackTrace');
      // Si ya es una Exception con mensaje, re-lanzarla
      if (e is Exception) {
        rethrow;
      }
      // Si es otro tipo de error, convertirlo en Exception con mensaje claro
      throw Exception('Error al subir material: $e');
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
          return data.map((e) => MaterialReforzamiento.fromJson(e)).toList();
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
  // Este método debe retornar:
  // 1. Material específico del estudiante (estudiante_id = estudianteId)
  // 2. Material general para todos los reprobados (estudiante_id IS NULL)
  Future<List<MaterialReforzamiento>> obtenerMaterialEstudiante({
    required int estudianteId,
    int? materiaId,
    int? anioAcademico,
  }) async {
    try {
      final anioActual = anioAcademico ?? DateTime.now().year;
      debugPrint(
          '📚 DEBUG ReforzamientoApiService: Obteniendo material estudiante');
      debugPrint('   estudiante_id: $estudianteId');
      debugPrint('   materia_id: $materiaId');
      debugPrint('   año_academico: $anioActual');

      final queryParams = {
        'action': 'obtener_estudiante',
        'estudiante_id': estudianteId.toString(),
        'año_academico': anioActual.toString(),
      };

      if (materiaId != null) {
        queryParams['materia_id'] = materiaId.toString();
      }

      final url = Uri.parse('$_baseUrl/reforzamiento.php')
          .replace(queryParameters: queryParams);

      debugPrint('📚 DEBUG ReforzamientoApiService: URL completa: $url');

      final response = await http.get(url, headers: _headers);

      debugPrint(
          '📚 DEBUG ReforzamientoApiService: Status Code: ${response.statusCode}');

      // Validar que la respuesta no esté vacía
      if (response.body.isEmpty) {
        debugPrint('⚠️ WARNING: Respuesta vacía del servidor');
        return [];
      }

      debugPrint(
          '📚 DEBUG ReforzamientoApiService: Response Body (primeros 500 chars): ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> jsonResponse;
        try {
          jsonResponse = json.decode(response.body);
        } catch (jsonError) {
          debugPrint('❌ ERROR: No se pudo decodificar JSON: $jsonError');
          debugPrint('   Respuesta completa: ${response.body}');
          throw Exception('Error al procesar respuesta del servidor');
        }

        if (jsonResponse['success'] == true ||
            jsonResponse['success'] == 'true' ||
            jsonResponse['success'] == 1) {
          final data = jsonResponse['data'];

          debugPrint(
              '📚 DEBUG ReforzamientoApiService: Data type: ${data.runtimeType}');
          debugPrint(
              '📚 DEBUG ReforzamientoApiService: Data es null: ${data == null}');

          // Manejar diferentes formatos de respuesta
          List<dynamic> materialesList;
          if (data == null) {
            debugPrint('⚠️ WARNING: Data es null en la respuesta');
            materialesList = [];
          } else if (data is List) {
            materialesList = data;
            debugPrint(
                '📚 Data es una Lista con ${materialesList.length} elementos');
          } else if (data is Map) {
            if (data['materiales'] != null) {
              materialesList = data['materiales'] as List;
              debugPrint(
                  '📚 Data es un Map con clave "materiales" con ${materialesList.length} elementos');
            } else if (data['material'] != null) {
              materialesList = [data['material']];
              debugPrint('📚 Data es un Map con clave "material" (1 elemento)');
            } else {
              // Intentar tratar el Map como si fuera un único material
              materialesList = [data];
              debugPrint(
                  '📚 Data es un Map sin claves conocidas, tratando como material único');
            }
          } else {
            debugPrint(
                '⚠️ WARNING: Formato de respuesta inesperado: ${data.runtimeType}');
            materialesList = [];
          }

          debugPrint(
              '📚 DEBUG ReforzamientoApiService: ${materialesList.length} materiales encontrados en respuesta');

          // Filtrar materiales activos y validar que correspondan al estudiante o sean generales
          final materialesFiltrados = <dynamic>[];
          for (var item in materialesList) {
            if (item is Map<String, dynamic>) {
              // Verificar que el material esté activo
              final estado =
                  item['estado']?.toString().toLowerCase() ?? 'activo';
              if (estado != 'activo') {
                debugPrint(
                    '   ⏭️ Material ID ${item['id']} está inactivo, omitiendo');
                continue;
              }

              // Verificar que corresponda al estudiante (específico o general)
              // El backend ya filtró con (estudiante_id = ? OR estudiante_id IS NULL),
              // pero verificamos aquí por seguridad
              final matEstudianteIdValue = item['estudiante_id'];
              // Si estudiante_id es null, 'null', 'NULL', o string vacío, es material general (válido para todos)
              final isMaterialGeneral = matEstudianteIdValue == null ||
                  matEstudianteIdValue.toString().toLowerCase() == 'null' ||
                  matEstudianteIdValue.toString() == '';

              if (!isMaterialGeneral) {
                // Es material específico, verificar que coincida con el estudiante
                final matEstudianteId =
                    int.tryParse(matEstudianteIdValue.toString());
                if (matEstudianteId != null &&
                    matEstudianteId != estudianteId) {
                  debugPrint(
                      '   ⏭️ Material ID ${item['id']} es para otro estudiante (${matEstudianteId}), omitiendo');
                  continue;
                }
              }
              // Si es material general (NULL) o coincide con el estudiante, es válido

              // Verificar materia_id si se proporciona
              // Nota: Si el backend no retorna materia_id, confiamos que el filtro del backend fue correcto
              if (materiaId != null && item.containsKey('materia_id')) {
                final matMateriaId =
                    int.tryParse(item['materia_id']?.toString() ?? '');
                if (matMateriaId != null && matMateriaId != materiaId) {
                  debugPrint(
                      '   ⏭️ Material ID ${item['id']} es para otra materia (${matMateriaId}), omitiendo');
                  continue;
                }
              }

              materialesFiltrados.add(item);
              final estudianteIdStr = isMaterialGeneral
                  ? "NULL (general)"
                  : matEstudianteIdValue?.toString() ?? "NULL (general)";
              debugPrint(
                  '   ✅ Material ID ${item['id']} válido - Título: ${item['titulo']}, EstudianteID: $estudianteIdStr');
            } else {
              debugPrint('   ⚠️ Item no es un Map, tipo: ${item.runtimeType}');
            }
          }

          debugPrint(
              '📚 DEBUG ReforzamientoApiService: ${materialesFiltrados.length} materiales después de filtrado');

          // Parsear materiales
          final materiales = materialesFiltrados
              .map((e) {
                try {
                  // Agregar campos faltantes si no están en el JSON
                  // (el backend puede no incluirlos si hace JOINs o simplifica la respuesta)
                  final materialData =
                      Map<String, dynamic>.from(e as Map<String, dynamic>);

                  // Si no tiene materia_id pero tenemos materiaId del parámetro, usarlo
                  if (!materialData.containsKey('materia_id') &&
                      materiaId != null) {
                    materialData['materia_id'] = materiaId;
                    debugPrint(
                        '   🔧 Agregando materia_id=$materiaId al material (no estaba en respuesta)');
                  }

                  // Si no tiene profesor_id, usar 0 como fallback (el modelo lo requiere)
                  if (!materialData.containsKey('profesor_id')) {
                    materialData['profesor_id'] = 0;
                    debugPrint(
                        '   🔧 Agregando profesor_id=0 al material (no estaba en respuesta)');
                  }

                  // Si no tiene estudiante_id, puede ser NULL (material general)
                  // El modelo ya maneja estudianteId como nullable, así que está bien dejarlo sin el campo
                  // Pero para consistencia, agregarlo explícitamente si sabemos que debería ser NULL
                  if (!materialData.containsKey('estudiante_id')) {
                    // No agregamos nada, el modelo manejará null correctamente
                    debugPrint(
                        '   ℹ️ Material sin estudiante_id explícito (será NULL = material general)');
                  }

                  final parsed = MaterialReforzamiento.fromJson(materialData);
                  debugPrint(
                      '   ✅ Material parseado: ID=${parsed.id}, Título=${parsed.titulo}, MateriaID=${parsed.materiaId}, EstudianteID=${parsed.estudianteId ?? "NULL"}');
                  return parsed;
                } catch (parseError) {
                  debugPrint('❌ ERROR: Error parseando material: $parseError');
                  debugPrint('   Datos del material: $e');
                  return null;
                }
              })
              .whereType<MaterialReforzamiento>()
              .toList();

          debugPrint(
              '📚 DEBUG ReforzamientoApiService: ${materiales.length} materiales parseados exitosamente');

          if (materiales.isEmpty && materialesList.isNotEmpty) {
            debugPrint(
                '❌ ERROR: Hubo ${materialesList.length} materiales pero ninguno pasó el filtrado o parseo');
          }

          return materiales;
        } else {
          final errorMessage = jsonResponse['message'] ??
              jsonResponse['error'] ??
              'Error al obtener material';
          debugPrint('❌ ERROR: El servidor reportó fallo: $errorMessage');
          throw Exception(errorMessage);
        }
      } else {
        debugPrint('❌ ERROR HTTP: ${response.statusCode}');
        debugPrint('   Respuesta: ${response.body}');
        throw Exception(
            'Error HTTP ${response.statusCode}: No se pudo obtener el material');
      }
    } catch (e, stackTrace) {
      debugPrint(
          '❌ ERROR ReforzamientoApiService.obtenerMaterialEstudiante: $e');
      debugPrint('   Stack trace: $stackTrace');
      // Re-lanzar como Exception para manejo consistente
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error al obtener material del estudiante: $e');
    }
  }

  // Eliminar material
  Future<bool> eliminarMaterial(int materialId) async {
    try {
      debugPrint(
          '🗑️ DEBUG ReforzamientoApiService: Eliminando material - id: $materialId');

      final url =
          Uri.parse('$_baseUrl/reforzamiento.php').replace(queryParameters: {
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
