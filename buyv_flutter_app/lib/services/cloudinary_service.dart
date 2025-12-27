import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

/// Exception personnalisée pour les erreurs d'upload Cloudinary
class CloudinaryUploadException implements Exception {
  final String message;
  final String? details;
  final int? statusCode;

  CloudinaryUploadException(this.message, {this.details, this.statusCode});

  @override
  String toString() {
    if (details != null) {
      return 'CloudinaryUploadException: $message\nDetails: $details';
    }
    return 'CloudinaryUploadException: $message';
  }
}

/// Service réutilisable pour l'upload d'images et vidéos vers Cloudinary
/// Utilise uniquement des uploads non signés (unsigned uploads) - aucun secret API requis
class CloudinaryService {
  static CloudinaryService? _instance;

  CloudinaryService._internal();

  static CloudinaryService get instance {
    _instance ??= CloudinaryService._internal();
    return _instance!;
  }

  /// Obtient l'instance Cloudinary configurée
  CloudinaryPublic _getCloudinary() {
    final cloudName = AppConstants.cloudinaryCloudName;
    final uploadPreset = AppConstants.cloudinaryUploadPreset;

    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      throw CloudinaryUploadException(
        'Cloudinary credentials are not configured',
        details: 'Cloud Name: $cloudName, Upload Preset: $uploadPreset',
      );
    }

    return CloudinaryPublic(
      cloudName,
      uploadPreset,
      cache: false,
    );
  }

  /// Upload une image vers Cloudinary
  /// 
  /// [imageFile] : Le fichier image à uploader (XFile depuis image_picker)
  /// [folder] : Dossier de destination dans Cloudinary (optionnel, défaut: 'images')
  /// [publicId] : ID public personnalisé (optionnel, généré automatiquement si non fourni)
  /// 
  /// Retourne l'URL sécurisée de l'image uploadée
  /// 
  /// Lance [CloudinaryUploadException] en cas d'erreur
  static Future<String> uploadImage(
    XFile imageFile, {
    String? folder,
    String? publicId,
  }) async {
    try {
      debugPrint('🚀 [Cloudinary] Starting image upload...');
      debugPrint('📁 Folder: ${folder ?? 'images'}');
      debugPrint('📄 File path: ${imageFile.path}');
      debugPrint('📄 File name: ${imageFile.name}');
      debugPrint('📏 File size: ${await imageFile.length()} bytes');

      final cloudinary = CloudinaryService.instance._getCloudinary();

      debugPrint('☁️ Cloud Name: ${AppConstants.cloudinaryCloudName}');
      debugPrint('🔧 Upload Preset: ${AppConstants.cloudinaryUploadPreset}');

      // Lire les bytes du fichier
      debugPrint('📖 Reading file bytes...');
      final bytes = await imageFile.readAsBytes();
      debugPrint('✅ File bytes read: ${bytes.length} bytes');

      // Préparer le fichier Cloudinary
      final cloudinaryFile = CloudinaryFile.fromByteData(
        bytes.buffer.asByteData(),
        identifier: imageFile.name,
        folder: folder ?? 'images',
        publicId: publicId ?? 'img_${DateTime.now().millisecondsSinceEpoch}',
      );

      debugPrint('📤 Uploading to Cloudinary...');
      final startTime = DateTime.now();

      // Upload avec gestion de progression
      final response = await cloudinary.uploadFile(cloudinaryFile);

      final duration = DateTime.now().difference(startTime);
      debugPrint('✅ [Cloudinary] Image uploaded successfully in ${duration.inMilliseconds}ms');
      debugPrint('🔗 Secure URL: ${response.secureUrl}');
      debugPrint('📊 Public ID: ${response.publicId}');

      if (response.secureUrl.isEmpty) {
        throw CloudinaryUploadException(
          'Upload succeeded but no URL was returned',
          details: 'Response: ${response.toString()}',
        );
      }

      return response.secureUrl;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      debugPrint('❌ [Cloudinary] Error uploading image (Dio): $errorMessage');
      debugPrint('❌ Status Code: ${e.response?.statusCode}');
      debugPrint('❌ Response Data: ${e.response?.data}');
      debugPrint('❌ Request Path: ${e.requestOptions.path}');

      throw CloudinaryUploadException(
        'Failed to upload image: $errorMessage',
        details: e.response?.data?.toString(),
        statusCode: e.response?.statusCode,
      );
    } on CloudinaryUploadException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ [Cloudinary] Unexpected error uploading image: $e');
      debugPrint('❌ Stack trace: $stackTrace');

      throw CloudinaryUploadException(
        'Unexpected error during image upload: ${e.toString()}',
        details: stackTrace.toString(),
      );
    }
  }

  /// Upload une vidéo vers Cloudinary
  /// 
  /// [videoFile] : Le fichier vidéo à uploader (XFile depuis image_picker)
  /// [folder] : Dossier de destination dans Cloudinary (optionnel, défaut: 'videos')
  /// [publicId] : ID public personnalisé (optionnel, généré automatiquement si non fourni)
  /// 
  /// Retourne l'URL sécurisée de la vidéo uploadée
  /// 
  /// Lance [CloudinaryUploadException] en cas d'erreur
  static Future<String> uploadVideo(
    XFile videoFile, {
    String? folder,
    String? publicId,
  }) async {
    try {
      debugPrint('🚀 [Cloudinary] Starting video upload...');
      debugPrint('📁 Folder: ${folder ?? 'videos'}');
      debugPrint('📄 File path: ${videoFile.path}');
      debugPrint('📄 File name: ${videoFile.name}');
      debugPrint('📏 File size: ${await videoFile.length()} bytes');

      final cloudinary = CloudinaryService.instance._getCloudinary();

      debugPrint('☁️ Cloud Name: ${AppConstants.cloudinaryCloudName}');
      debugPrint('🔧 Upload Preset: ${AppConstants.cloudinaryUploadPreset}');

      // Lire les bytes du fichier
      debugPrint('📖 Reading file bytes...');
      final bytes = await videoFile.readAsBytes();
      debugPrint('✅ File bytes read: ${bytes.length} bytes');

      // Préparer le fichier Cloudinary
      final cloudinaryFile = CloudinaryFile.fromByteData(
        bytes.buffer.asByteData(),
        identifier: videoFile.name,
        folder: folder ?? 'videos',
        publicId: publicId ?? 'vid_${DateTime.now().millisecondsSinceEpoch}',
        resourceType: CloudinaryResourceType.Video,
      );

      debugPrint('📤 Uploading to Cloudinary...');
      final startTime = DateTime.now();

      // Upload avec gestion de progression
      final response = await cloudinary.uploadFile(cloudinaryFile);

      final duration = DateTime.now().difference(startTime);
      debugPrint('✅ [Cloudinary] Video uploaded successfully in ${duration.inMilliseconds}ms');
      debugPrint('🔗 Secure URL: ${response.secureUrl}');
      debugPrint('📊 Public ID: ${response.publicId}');

      if (response.secureUrl.isEmpty) {
        throw CloudinaryUploadException(
          'Upload succeeded but no URL was returned',
          details: 'Response: ${response.toString()}',
        );
      }

      return response.secureUrl;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      debugPrint('❌ [Cloudinary] Error uploading video (Dio): $errorMessage');
      debugPrint('❌ Status Code: ${e.response?.statusCode}');
      debugPrint('❌ Response Data: ${e.response?.data}');
      debugPrint('❌ Request Path: ${e.requestOptions.path}');

      throw CloudinaryUploadException(
        'Failed to upload video: $errorMessage',
        details: e.response?.data?.toString(),
        statusCode: e.response?.statusCode,
      );
    } on CloudinaryUploadException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ [Cloudinary] Unexpected error uploading video: $e');
      debugPrint('❌ Stack trace: $stackTrace');

      throw CloudinaryUploadException(
        'Unexpected error during video upload: ${e.toString()}',
        details: stackTrace.toString(),
      );
    }
  }

  /// Upload une image de profil avec transformations spécifiques
  /// 
  /// [imagePath] : Chemin du fichier image
  /// 
  /// Retourne l'URL sécurisée de l'image uploadée
  /// 
  /// Lance [CloudinaryUploadException] en cas d'erreur
  static Future<String> uploadProfileImage(String imagePath) async {
    try {
      debugPrint('🚀 [Cloudinary] Starting profile image upload...');
      debugPrint('📄 File path: $imagePath');

      final cloudinary = CloudinaryService.instance._getCloudinary();

      final cloudinaryFile = CloudinaryFile.fromFile(
        imagePath,
        folder: 'profiles',
        publicId: 'profile_${DateTime.now().millisecondsSinceEpoch}',
      );

      debugPrint('📤 Uploading to Cloudinary...');
      final startTime = DateTime.now();

      final response = await cloudinary.uploadFile(cloudinaryFile);

      final duration = DateTime.now().difference(startTime);
      debugPrint('✅ [Cloudinary] Profile image uploaded successfully in ${duration.inMilliseconds}ms');
      debugPrint('🔗 Secure URL: ${response.secureUrl}');

      if (response.secureUrl.isEmpty) {
        throw CloudinaryUploadException(
          'Upload succeeded but no URL was returned',
          details: 'Response: ${response.toString()}',
        );
      }

      return response.secureUrl;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      debugPrint('❌ [Cloudinary] Error uploading profile image: $errorMessage');

      throw CloudinaryUploadException(
        'Failed to upload profile image: $errorMessage',
        details: e.response?.data?.toString(),
        statusCode: e.response?.statusCode,
      );
    } on CloudinaryUploadException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ [Cloudinary] Unexpected error uploading profile image: $e');

      throw CloudinaryUploadException(
        'Unexpected error during profile image upload: ${e.toString()}',
        details: stackTrace.toString(),
      );
    }
  }

  /// Upload plusieurs images de produits
  /// 
  /// [imagePaths] : Liste des chemins des fichiers images
  /// 
  /// Retourne la liste des URLs uploadées (seulement les uploads réussis)
  static Future<List<String>> uploadProductImages(
    List<String> imagePaths,
  ) async {
    final List<String> uploadedUrls = [];
    final cloudinary = CloudinaryService.instance._getCloudinary();

    debugPrint('🚀 [Cloudinary] Starting batch upload of ${imagePaths.length} product images...');

    for (int i = 0; i < imagePaths.length; i++) {
      try {
        debugPrint('📤 [Cloudinary] Uploading product image ${i + 1}/${imagePaths.length}...');

        final cloudinaryFile = CloudinaryFile.fromFile(
          imagePaths[i],
          folder: 'products',
          publicId: 'product_${DateTime.now().millisecondsSinceEpoch}_$i',
        );

        final response = await cloudinary.uploadFile(cloudinaryFile);

        if (response.secureUrl.isNotEmpty) {
          uploadedUrls.add(response.secureUrl);
          debugPrint('✅ [Cloudinary] Product image ${i + 1} uploaded successfully');
        } else {
          debugPrint('⚠️ [Cloudinary] Product image ${i + 1} uploaded but no URL returned');
        }
      } catch (e) {
        debugPrint('❌ [Cloudinary] Error uploading product image ${i + 1}: $e');
        // Continue avec les autres images même si une échoue
      }
    }

    debugPrint('✅ [Cloudinary] Batch upload completed: ${uploadedUrls.length}/${imagePaths.length} successful');
    return uploadedUrls;
  }

  /// Upload une vidéo de reel
  /// 
  /// [videoFile] : Le fichier vidéo à uploader (XFile depuis image_picker)
  /// 
  /// Retourne l'URL sécurisée de la vidéo uploadée
  /// 
  /// Lance [CloudinaryUploadException] en cas d'erreur
  static Future<String> uploadReelVideo(XFile videoFile) async {
    return uploadVideo(videoFile, folder: 'reels');
  }

  /// Extrait un message d'erreur lisible depuis une DioException
  static String _extractErrorMessage(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map) {
        return data['error']?.toString() ?? 
               data['message']?.toString() ?? 
               e.message ?? 'Unknown error';
      }
      return data?.toString() ?? e.message ?? 'Unknown error';
    }
    return e.message ?? 'Network error';
  }
}
