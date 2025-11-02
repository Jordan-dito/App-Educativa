import 'package:flutter/material.dart';
import '../../models/material_reforzamiento_model.dart';
import 'material_preview_screen.dart';

class StudentMaterialDetailScreen extends StatelessWidget {
  final MaterialReforzamiento material;

  const StudentMaterialDetailScreen({super.key, required this.material});

  @override
  Widget build(BuildContext context) {
    // Usar la pantalla de preview para mostrar el contenido directamente
    return MaterialPreviewScreen(material: material);
  }
}

