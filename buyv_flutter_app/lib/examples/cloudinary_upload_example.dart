import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';

/// Exemple d'utilisation du service Cloudinary pour uploader des images
/// 
/// Cet exemple montre comment :
/// 1. Sélectionner une image depuis la galerie ou la caméra
/// 2. Uploader l'image vers Cloudinary
/// 3. Gérer les erreurs
/// 4. Afficher le résultat
class CloudinaryUploadExample extends StatefulWidget {
  const CloudinaryUploadExample({super.key});

  @override
  State<CloudinaryUploadExample> createState() => _CloudinaryUploadExampleState();
}

class _CloudinaryUploadExampleState extends State<CloudinaryUploadExample> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploading = false;
  String? _errorMessage;

  /// Sélectionne une image depuis la galerie
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Compression optionnelle (0-100)
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _uploadedImageUrl = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la sélection de l\'image: $e';
      });
    }
  }

  /// Sélectionne une image depuis la caméra
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _uploadedImageUrl = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la prise de photo: $e';
      });
    }
  }

  /// Upload l'image sélectionnée vers Cloudinary
  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      setState(() {
        _errorMessage = 'Veuillez d\'abord sélectionner une image';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
      _uploadedImageUrl = null;
    });

    try {
      // Upload vers Cloudinary
      // Le service lance une CloudinaryUploadException en cas d'erreur
      final imageUrl = await CloudinaryService.uploadImage(
        _selectedImage!,
        folder: 'examples', // Dossier optionnel dans Cloudinary
      );

      setState(() {
        _uploadedImageUrl = imageUrl;
        _isUploading = false;
      });

      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploadée avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on CloudinaryUploadException catch (e) {
      // Gérer les erreurs spécifiques à Cloudinary
      setState(() {
        _errorMessage = e.message;
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'upload: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Gérer les autres erreurs
      setState(() {
        _errorMessage = 'Erreur inattendue: $e';
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemple Upload Cloudinary'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Comment utiliser:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Sélectionnez une image depuis la galerie ou la caméra'),
                    const Text('2. Cliquez sur "Uploader vers Cloudinary"'),
                    const Text('3. L\'URL de l\'image uploadée s\'affichera ci-dessous'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Boutons de sélection
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _pickImageFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galerie'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _pickImageFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Caméra'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Image sélectionnée
            if (_selectedImage != null)
              Card(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Image sélectionnée:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Image.network(
                      _selectedImage!.path,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Pour les fichiers locaux, utiliser Image.file
                        return Image.asset(
                          'assets/images/placeholder.png',
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox(
                              height: 200,
                              child: Center(
                                child: Icon(Icons.image, size: 64),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Nom: ${_selectedImage!.name}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Bouton d'upload
            ElevatedButton(
              onPressed: _isUploading || _selectedImage == null
                  ? null
                  : _uploadImage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: _isUploading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Upload en cours...'),
                      ],
                    )
                  : const Text(
                      'Uploader vers Cloudinary',
                      style: TextStyle(fontSize: 16),
                    ),
            ),

            const SizedBox(height: 24),

            // Message d'erreur
            if (_errorMessage != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.error, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Erreur',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),

            // URL uploadée
            if (_uploadedImageUrl != null)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Upload réussi!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'URL de l\'image:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        _uploadedImageUrl!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Image.network(
                        _uploadedImageUrl!,
                        height: 200,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox(
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                            height: 200,
                            child: Center(
                              child: Icon(Icons.error, size: 64, color: Colors.red),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

