import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class OmrScreen extends StatefulWidget {
  const OmrScreen({super.key});

  @override
  State<OmrScreen> createState() => _OmrScreenState();
}

class _OmrScreenState extends State<OmrScreen> {
  final ImagePicker _picker = ImagePicker();
  File? teacherImg;
  File? studentImg;
  Map<String, dynamic>? result;

  // --- FUNCIONES PARA TOMAR O ELEGIR FOTO ---
  Future<void> _pickFromCamera(bool isTeacher) async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        if (isTeacher) {
          teacherImg = File(picked.path);
        } else {
          studentImg = File(picked.path);
        }
      });
    }
  }

  Future<void> _pickFromGallery(bool isTeacher) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isTeacher) {
          teacherImg = File(picked.path);
        } else {
          studentImg = File(picked.path);
        }
      });
    }
  }

  // --- ENVIAR LAS IMÁGENES AL BACKEND ---
  Future<void> _calificar() async {
    if (teacherImg == null || studentImg == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Faltan imágenes')));
      return;
    }

    final res = await ApiService.gradeExam(teacherImg!, studentImg!);
    setState(() => result = res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evaluar examen OMR')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------------- PROFESOR ----------------
            const Text(
              'Plantilla del Profesor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _imagePreview(teacherImg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickFromCamera(true),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Cámara'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickFromGallery(true),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería'),
                ),
              ],
            ),

            const Divider(height: 40),

            // ---------------- ALUMNO ----------------
            const Text(
              'Examen del Alumno',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _imagePreview(studentImg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickFromCamera(false),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Cámara'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickFromGallery(false),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería'),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ---------------- BOTÓN CALIFICAR ----------------
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              onPressed: _calificar,
              icon: const Icon(Icons.fact_check),
              label: const Text('Calificar', style: TextStyle(fontSize: 18)),
            ),

            const SizedBox(height: 20),
            if (result != null) _buildResults(),
          ],
        ),
      ),
    );
  }

  // --- WIDGET PARA MOSTRAR IMAGEN ---
  Widget _imagePreview(File? file) {
    return Container(
      height: 180,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: file != null
          ? Image.file(file, fit: BoxFit.cover)
          : const Center(child: Text('Sin imagen seleccionada')),
    );
  }

  // --- WIDGET RESULTADOS ---
  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Aciertos: ${result!['aciertos']} / ${result!['total']}  (${result!['porcentaje']}%)",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...((result!["detalle"] as List).map(
          (d) => ListTile(
            title: Text(
              "Pregunta ${d["pregunta"]}:  Alumno ${d["alumno"]}  |  Correcta ${d["correcta"]}",
            ),
            trailing: Icon(
              d["acierto"] ? Icons.check_circle : Icons.cancel,
              color: d["acierto"] ? Colors.green : Colors.red,
            ),
          ),
        )),
      ],
    );
  }
}
