import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/reporte_notas_model.dart';

class NotasService {
  static const String baseUrl = 'https://hermanosfrios.alwaysdata.net/api/notas.php';

  /// Obtener reporte de notas finales del estudiante
  ///
  /// [estudianteId] - ID del estudiante (requerido)
  /// [anioAcademico] - Año académico (opcional, si es null obtiene el último año finalizado)
  Future<ReporteNotasModel> obtenerReporteNotas({
    required int estudianteId,
    int? anioAcademico,
  }) async {
    try {
      debugPrint(
          '📊 DEBUG NotasService: Obteniendo reporte de notas - estudiante_id: $estudianteId, anio_academico: $anioAcademico');

      // Construir URL con parámetros
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          'action': 'reporte_final',
          'estudiante_id': estudianteId.toString(),
          if (anioAcademico != null) 'año_academico': anioAcademico.toString(),
        },
      );

      debugPrint('📊 DEBUG NotasService: URL: $uri');

      // Realizar petición GET
      final response = await http.get(uri);

      debugPrint('📊 DEBUG NotasService: Status Code: ${response.statusCode}');
      debugPrint('📊 DEBUG NotasService: Response Body: ${response.body}');

      // Verificar código de respuesta
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ReporteNotasModel.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        // No hay reportes disponibles o año no finalizado
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ReporteNotasModel.fromJson(jsonData);
      } else {
        // Error del servidor
        debugPrint('❌ ERROR NotasService: Error HTTP ${response.statusCode}');
        return ReporteNotasModel(
          success: false,
          message: 'Error al obtener reporte: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Error de conexión
      debugPrint('❌ ERROR NotasService: $e');
      return ReporteNotasModel(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }
}

