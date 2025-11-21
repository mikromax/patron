import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class FilePickerHelper {
  // Dosya veya Resim seçtiren fonksiyon
  // source: 0 = Galeri/Dosya, 1 = Kamera
  static Future<File?> pickFile({required int source}) async {
    
    // WINDOWS: Sadece dosya gezgini açılır
    if (Platform.isWindows) {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } 
    
    // MOBİL (Android/iOS)
    else {
      final ImagePicker picker = ImagePicker();
      XFile? pickedFile;

      if (source == 1) {
        // Kamera
        pickedFile = await picker.pickImage(source: ImageSource.camera);
      } else {
        // Galeri (Veya FilePicker ile doküman da seçtirilebilir)
        // Şimdilik basitlik adına ImagePicker kullanıyoruz, 
        // isterseniz buraya FilePicker mantığı da eklenebilir.
        pickedFile = await picker.pickImage(source: ImageSource.gallery);
      }

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    }
  }

  // Seçim Menüsünü Gösteren Fonksiyon
  static Future<void> showSelectionSheet(BuildContext context, Function(File) onFileSelected) async {
    // Windows ise direkt dosya seçici aç ve BİTMESİNİ BEKLE (await)
    if (Platform.isWindows) {
      final file = await pickFile(source: 0);
      if (file != null) onFileSelected(file);
      return;
    }

    // Mobil ise alttan menü aç
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeriden Seç'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await pickFile(source: 0);
                  if (file != null) onFileSelected(file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Fotoğraf Çek'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await pickFile(source: 1);
                  if (file != null) onFileSelected(file);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}