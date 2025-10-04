import 'dart:io';
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  // URL base que se selecciona automáticamente según el entorno
  static Future<String> getBaseUrl() async {
    // 🖥️ Si se ejecuta en Web o Desktop (tu PC)
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return "http://127.0.0.1:8000";
    }

    // 📱 Si se ejecuta en Android o iOS (físico o emulador)
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      // Si es un emulador Android (usa la IP especial 10.0.2.2)
      if (androidInfo.isPhysicalDevice == false) {
        return "http://10.0.2.2:8000";
      } else {
        // ⚠️ Si es un teléfono físico, usa tu IP local real
        return "http://192.168.100.5:8000";
      }
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      if (iosInfo.isPhysicalDevice == false) {
        return "http://127.0.0.1:8000";
      } else {
        return "http://192.168.100.5:8000";
      }
    }

    // Por defecto (fallback)
    return "http://127.0.0.1:8000";
  }

  // Función para mandar las imágenes al backend
  static Future<Map<String, dynamic>?> gradeExam(
    File teacherImg,
    File studentImg,
  ) async {
    final baseUrl = await getBaseUrl();
    final uri = Uri.parse('$baseUrl/grade');

    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('teacher', teacherImg.path))
      ..files.add(
        await http.MultipartFile.fromPath('student', studentImg.path),
      );

    final response = await request.send();
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      return jsonDecode(body);
    } else {
      print("Error: ${response.statusCode}");
      return null;
    }
  }
}
