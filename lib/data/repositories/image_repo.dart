import 'dart:io';
import 'package:raising_india/error/exceptions.dart';
import '../../../data/rest_client.dart';
import '../../../services/service_locator.dart';

class ImageRepository with RepoErrorHandler {
  final RestClient _client = getIt<RestClient>();

  Future<String> uploadImage(File file) async {
    try {
      final response = await _client.uploadImage(file);
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      await _client.deleteImage(imageUrl);
    } catch (e) {
      throw handleError(e);
    }
  }
}