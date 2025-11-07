import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../models/reporte_notas_model.dart';
import '../../services/notas_service.dart';
import '../../services/enrollment_api_service.dart';
import '../../services/user_service.dart';

class ReporteNotasScreen extends StatefulWidget {
  final int? estudianteId;
  final int? anioAcademico; // Opcional

  const ReporteNotasScreen({
    super.key,
    this.estudianteId,
    this.anioAcademico,
  });

  @override
  State<ReporteNotasScreen> createState() => _ReporteNotasScreenState();
}

class _ReporteNotasScreenState extends State<ReporteNotasScreen> {
  final NotasService _notasService = NotasService();
  final EnrollmentApiService _enrollmentService = EnrollmentApiService();
  ReporteNotasModel? _reporte;
  bool _isLoading = true;
  String? _errorMessage;
  int? _currentEstudianteId;

  @override
  void initState() {
    super.initState();
    _loadReporte();
  }

  Future<void> _loadReporte() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      int? estudianteId = widget.estudianteId;

      // Si no se proporciona estudianteId, obtenerlo del usuario actual
      if (estudianteId == null) {
        final user = await UserService.getCurrentUser();
        if (user == null || user.rol.toLowerCase() != 'estudiante') {
          setState(() {
            _isLoading = false;
            _errorMessage = 'No se pudo obtener la información del estudiante';
          });
          return;
        }

        estudianteId = await _enrollmentService.getStudentIdByUserId(user.id!);
        if (estudianteId == null) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'No se encontró el ID del estudiante';
          });
          return;
        }
      }

      _currentEstudianteId = estudianteId;

      debugPrint('📊 DEBUG ReporteNotasScreen: Obteniendo reporte para estudiante_id: $estudianteId, año: ${widget.anioAcademico}');

      final resultado = await _notasService.obtenerReporteNotas(
        estudianteId: estudianteId,
        anioAcademico: widget.anioAcademico,
      );

      debugPrint('📊 DEBUG ReporteNotasScreen: Resultado recibido - success: ${resultado.success}, message: ${resultado.message}');
      debugPrint('📊 DEBUG ReporteNotasScreen: Data: ${resultado.data != null ? "Disponible" : "NULL"}');

      setState(() {
        _isLoading = false;
        if (resultado.success && resultado.data != null) {
          _reporte = resultado;
          debugPrint('📊 DEBUG ReporteNotasScreen: Reporte cargado exitosamente');
        } else {
          _errorMessage = resultado.message.isNotEmpty
              ? resultado.message
              : 'No hay reportes disponibles para este estudiante. El año académico puede no estar finalizado.';
          debugPrint('⚠️ WARNING ReporteNotasScreen: ${_errorMessage}');
        }
      });
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR ReporteNotasScreen._loadReporte: $e');
      debugPrint('   Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar el reporte: $e';
      });
    }
  }

  Future<void> _exportarPDF() async {
    if (_reporte?.data == null || _currentEstudianteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay datos para exportar'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      debugPrint('📄 DEBUG: Generando PDF...');
      final pdf = await _generatePDF(_reporte!.data!);
      debugPrint('📄 DEBUG: PDF generado exitosamente');
      
      // Intentar usar Printing.layoutPdf primero
      try {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async {
            debugPrint('📄 DEBUG: Generando PDF con formato: ${format.width}x${format.height}');
            return pdf.save();
          },
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF generado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (printingError) {
        // Si Printing.layoutPdf falla, intentar guardar el archivo directamente
        debugPrint('⚠️ WARNING: Printing.layoutPdf falló, intentando guardar archivo directamente: $printingError');
        
        try {
          // Guardar PDF en el sistema de archivos
          final directory = await getApplicationDocumentsDirectory();
          final fileName = 'reporte_notas_${_currentEstudianteId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
          final filePath = '${directory.path}/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(await pdf.save());
          
          debugPrint('📄 DEBUG: PDF guardado en: $filePath');
          
          // Intentar abrir el archivo
          final result = await OpenFilex.open(filePath);
          
          if (mounted) {
            if (result.type == ResultType.done) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('PDF guardado exitosamente en: $fileName'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('PDF guardado. Ubicación: $filePath'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          }
        } catch (fileError) {
          debugPrint('❌ ERROR al guardar archivo: $fileError');
          // Re-lanzar el error original si ambos métodos fallan
          throw printingError;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR al generar PDF: $e');
      debugPrint('   Stack trace: $stackTrace');
      
      if (mounted) {
        String errorMessage = 'Error al generar PDF';
        
        // Mensajes de error más específicos
        if (e.toString().contains('MissingPluginException')) {
          errorMessage = 'Error: El plugin de impresión no está disponible. Por favor, reinstala la aplicación.';
        } else if (e.toString().contains('PlatformException')) {
          errorMessage = 'Error: No se pudo acceder a la funcionalidad de impresión. Verifica los permisos.';
        } else {
          errorMessage = 'Error al generar PDF: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<pw.Document> _generatePDF(ReporteNotasData data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Encabezado
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Reporte de Notas',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Año Académico: ${data.anioAcademico}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // Información del estudiante
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Estudiante',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    children: [
                      pw.Text('Nombre: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(data.estudiante.nombreCompleto),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    children: [
                      pw.Text('Grado: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(data.estudiante.grado),
                      pw.SizedBox(width: 20),
                      pw.Text('Sección: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(data.estudiante.seccion),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Estadísticas
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                border: pw.Border.all(color: PdfColors.blue300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    children: [
                      pw.Text(
                        data.estadisticas.promedioGeneral?.toStringAsFixed(2) ?? 'N/A',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text('Promedio General', style: pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text(
                        data.estadisticas.totalMaterias.toString(),
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green900,
                        ),
                      ),
                      pw.Text('Total Materias', style: pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text(
                        data.estadisticas.materiasAprobadas.toString(),
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green900,
                        ),
                      ),
                      pw.Text('Aprobadas', style: pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text(
                        data.estadisticas.materiasReprobadas.toString(),
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red900,
                        ),
                      ),
                      pw.Text('Reprobadas', style: pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // Tabla de materias
            pw.Text(
              'Detalle de Materias',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1),
                4: const pw.FlexColumnWidth(1),
                5: const pw.FlexColumnWidth(1),
                6: const pw.FlexColumnWidth(1),
              },
              children: [
                // Encabezado de la tabla
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Materia',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Nota 1',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Nota 2',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Nota 3',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Nota 4',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Promedio',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Estado',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
                // Filas de datos
                ...data.notas.map((nota) {
                  final colorEstado = nota.estaAprobado
                      ? PdfColors.green900
                      : PdfColors.red900;
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(nota.nombreMateria),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          nota.nota1?.toStringAsFixed(2) ?? 'N/A',
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          nota.nota2?.toStringAsFixed(2) ?? 'N/A',
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          nota.nota3?.toStringAsFixed(2) ?? 'N/A',
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          nota.nota4?.toStringAsFixed(2) ?? 'N/A',
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          nota.promedio?.toStringAsFixed(2) ?? 'N/A',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          nota.estadoMateria,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            color: colorEstado,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 20),
            
            // Pie de página
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text(
              'Reporte generado el ${DateTime.now().toString().split(' ')[0]}',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Notas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Opción para seleccionar año (solo si no hay reporte cargado)
          if (_reporte?.data == null && _errorMessage != null)
            PopupMenuButton<int>(
              icon: const Icon(Icons.calendar_today),
              tooltip: 'Seleccionar año académico',
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 2024,
                  child: Text('Año 2024'),
                ),
                const PopupMenuItem(
                  value: 2025,
                  child: Text('Año 2025'),
                ),
              ],
              onSelected: (anio) async {
                debugPrint('📊 Seleccionado año: $anio');
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                try {
                  final resultado = await _notasService.obtenerReporteNotas(
                    estudianteId: _currentEstudianteId!,
                    anioAcademico: anio,
                  );
                  setState(() {
                    _isLoading = false;
                    if (resultado.success && resultado.data != null) {
                      _reporte = resultado;
                    } else {
                      _errorMessage = resultado.message.isNotEmpty
                          ? resultado.message
                          : 'No hay reportes disponibles para el año $anio';
                    }
                  });
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                    _errorMessage = 'Error al cargar el reporte: $e';
                  });
                }
              },
            ),
          if (_reporte?.data != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _exportarPDF,
              tooltip: 'Exportar a PDF',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReporte,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _reporte?.data != null
                  ? _buildReporteView()
                  : _buildEmptyView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Error desconocido',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadReporte,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay reportes disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Los reportes solo están disponibles para años académicos finalizados.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadReporte,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReporteView() {
    final data = _reporte!.data!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información del estudiante
          _buildEstudianteCard(data.estudiante, data.anioAcademico),

          const SizedBox(height: 16),

          // Estadísticas
          _buildEstadisticasCard(data.estadisticas),

          const SizedBox(height: 16),

          // Lista de notas por materia
          Text(
            'Materias',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          ...data.notas.map((nota) => _buildMateriaCard(nota)),
        ],
      ),
    );
  }

  Widget _buildEstudianteCard(EstudianteInfo estudiante, String anioAcademico) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        estudiante.nombreCompleto,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${estudiante.grado} Sección ${estudiante.seccion}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Año Académico:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  anioAcademico,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticasCard(EstadisticasNotas estadisticas) {
    return Card(
      elevation: 2,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Promedio General',
                  estadisticas.promedioGeneral?.toStringAsFixed(2) ?? 'N/A',
                  Icons.trending_up,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Total Materias',
                  estadisticas.totalMaterias.toString(),
                  Icons.book,
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Aprobadas',
                  estadisticas.materiasAprobadas.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatItem(
                  'Reprobadas',
                  estadisticas.materiasReprobadas.toString(),
                  Icons.cancel,
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMateriaCard(NotaMateria nota) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: nota.estaAprobado ? Colors.green[50] : Colors.red[50],
      child: ExpansionTile(
        leading: Icon(
          nota.estaAprobado ? Icons.check_circle : Icons.cancel,
          color: nota.estaAprobado ? Colors.green : Colors.red,
        ),
        title: Text(
          nota.nombreMateria,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (nota.nombreProfesor != null)
              Text('Profesor: ${nota.nombreProfesor}'),
            Text(
              'Promedio: ${nota.promedio?.toStringAsFixed(2) ?? "N/A"}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: nota.estaAprobado ? Colors.green[700] : Colors.red[700],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNotaItem('Nota 1', nota.nota1),
                    _buildNotaItem('Nota 2', nota.nota2),
                    _buildNotaItem('Nota 3', nota.nota3),
                    _buildNotaItem('Nota 4', nota.nota4),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: nota.estaAprobado ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    nota.estadoMateria,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotaItem(String label, double? nota) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          nota?.toStringAsFixed(2) ?? 'N/A',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

