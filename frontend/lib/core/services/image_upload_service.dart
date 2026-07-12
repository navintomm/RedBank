import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  return ImageUploadService();
});

class ImageUploadService {
  final Dio _dio = Dio();
  
  // TODO: Replace with your actual Cloudinary Cloud Name and Upload Preset
  static const String _cloudName = 'your_cloud_name_here';
  static const String _uploadPreset = 'your_unsigned_preset_here';
  static const String _cloudinaryUrl = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  Future<String> uploadImage({
    required File imageFile,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      final fileName = imageFile.path.split('/').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path, filename: fileName),
        'upload_preset': _uploadPreset,
      });

      final response = await _dio.post(
        _cloudinaryUrl,
        data: formData,
        onSendProgress: onProgress,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Cloudinary returns the secure_url upon successful upload
        return response.data['secure_url'] as String;
      } else {
        throw Exception('Failed to upload image. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error during upload: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during upload: $e');
    }
  }
}
