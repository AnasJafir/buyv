# Configuration Cloudinary - Guide d'utilisation

## 📋 Vue d'ensemble

Le service Cloudinary a été configuré pour permettre l'upload d'images et de vidéos vers Cloudinary en utilisant uniquement des **uploads non signés** (unsigned uploads). Aucun secret API n'est requis côté client.

## 🔑 Credentials configurées

- **Cloud Name**: `dhzllfeno`
- **Upload Preset**: `Ecommerce_BuyV`

Ces credentials sont définies dans `lib/constants/app_constants.dart` et peuvent être surchargées via des variables d'environnement dans le fichier `.env` :

```env
CLOUDINARY_CLOUD_NAME=dhzllfeno
CLOUDINARY_UPLOAD_PRESET=Ecommerce_BuyV
```

## 📦 Dépendances

Toutes les dépendances nécessaires sont déjà présentes dans `pubspec.yaml` :

- ✅ `dio: ^5.7.0` - Pour les requêtes HTTP
- ✅ `image_picker: ^1.1.2` - Pour sélectionner des images/vidéos
- ✅ `cloudinary_public: ^0.23.1` - SDK Cloudinary pour Flutter

## 🚀 Utilisation de base

### Upload d'une image

```dart
import 'package:image_picker/image_picker.dart';
import 'package:buyv_flutter_app/services/cloudinary_service.dart';

// 1. Sélectionner une image
final ImagePicker picker = ImagePicker();
final XFile? image = await picker.pickImage(source: ImageSource.gallery);

if (image != null) {
  try {
    // 2. Uploader vers Cloudinary
    final String imageUrl = await CloudinaryService.uploadImage(
      image,
      folder: 'images', // Optionnel
    );
    
    // 3. Utiliser l'URL retournée
    print('Image uploadée: $imageUrl');
  } on CloudinaryUploadException catch (e) {
    // Gérer les erreurs spécifiques à Cloudinary
    print('Erreur d\'upload: ${e.message}');
  }
}
```

### Upload d'une vidéo

```dart
final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

if (video != null) {
  try {
    final String videoUrl = await CloudinaryService.uploadVideo(
      video,
      folder: 'videos', // Optionnel
    );
    
    print('Vidéo uploadée: $videoUrl');
  } on CloudinaryUploadException catch (e) {
    print('Erreur d\'upload: ${e.message}');
  }
}
```

### Upload d'une image de profil

```dart
try {
  final String profileImageUrl = await CloudinaryService.uploadProfileImage(
    imagePath, // Chemin du fichier local
  );
  
  // Mettre à jour le profil utilisateur avec l'URL
} on CloudinaryUploadException catch (e) {
  print('Erreur: ${e.message}');
}
```

### Upload d'une vidéo de reel

```dart
try {
  final String reelUrl = await CloudinaryService.uploadReelVideo(videoFile);
  
  // Créer le post avec l'URL
} on CloudinaryUploadException catch (e) {
  print('Erreur: ${e.message}');
}
```

## 📝 Méthodes disponibles

### `uploadImage(XFile imageFile, {String? folder, String? publicId})`
Upload une image vers Cloudinary.

**Paramètres:**
- `imageFile`: Fichier image à uploader (XFile depuis image_picker)
- `folder`: Dossier de destination (optionnel, défaut: 'images')
- `publicId`: ID public personnalisé (optionnel, généré automatiquement)

**Retourne:** `Future<String>` - URL sécurisée de l'image

**Lance:** `CloudinaryUploadException` en cas d'erreur

### `uploadVideo(XFile videoFile, {String? folder, String? publicId})`
Upload une vidéo vers Cloudinary.

**Paramètres:**
- `videoFile`: Fichier vidéo à uploader (XFile depuis image_picker)
- `folder`: Dossier de destination (optionnel, défaut: 'videos')
- `publicId`: ID public personnalisé (optionnel, généré automatiquement)

**Retourne:** `Future<String>` - URL sécurisée de la vidéo

**Lance:** `CloudinaryUploadException` en cas d'erreur

### `uploadProfileImage(String imagePath)`
Upload une image de profil avec transformations spécifiques.

**Paramètres:**
- `imagePath`: Chemin du fichier image local

**Retourne:** `Future<String>` - URL sécurisée de l'image

**Lance:** `CloudinaryUploadException` en cas d'erreur

### `uploadReelVideo(XFile videoFile)`
Upload une vidéo de reel vers le dossier 'reels'.

**Paramètres:**
- `videoFile`: Fichier vidéo à uploader

**Retourne:** `Future<String>` - URL sécurisée de la vidéo

**Lance:** `CloudinaryUploadException` en cas d'erreur

### `uploadProductImages(List<String> imagePaths)`
Upload plusieurs images de produits en lot.

**Paramètres:**
- `imagePaths`: Liste des chemins des fichiers images

**Retourne:** `Future<List<String>>` - Liste des URLs uploadées (seulement les uploads réussis)

## 🔍 Gestion des erreurs

Le service lance une `CloudinaryUploadException` en cas d'erreur. Cette exception contient :

- `message`: Message d'erreur descriptif
- `details`: Détails supplémentaires (optionnel)
- `statusCode`: Code de statut HTTP (optionnel)

**Exemple de gestion d'erreur:**

```dart
try {
  final imageUrl = await CloudinaryService.uploadImage(imageFile);
} on CloudinaryUploadException catch (e) {
  // Erreur spécifique à Cloudinary
  print('Erreur Cloudinary: ${e.message}');
  if (e.statusCode != null) {
    print('Code de statut: ${e.statusCode}');
  }
  if (e.details != null) {
    print('Détails: ${e.details}');
  }
} catch (e) {
  // Autres erreurs
  print('Erreur inattendue: $e');
}
```

## 📊 Logging

Le service inclut un logging détaillé pour le processus d'upload :

- 🚀 Début de l'upload
- 📁 Dossier de destination
- 📄 Informations du fichier (nom, taille)
- ☁️ Credentials utilisées
- 📤 Progression de l'upload
- ✅ Succès avec URL retournée
- ❌ Erreurs avec détails

Les logs sont visibles dans la console de debug Flutter.

## 🔒 Sécurité

- ✅ **Aucun secret API exposé** : Utilisation uniquement d'uploads non signés
- ✅ **HTTPS uniquement** : Toutes les URLs retournées utilisent HTTPS
- ✅ **Validation des credentials** : Vérification que les credentials sont configurées avant l'upload

## 📱 Exemple complet

Un exemple complet d'utilisation est disponible dans :
`lib/examples/cloudinary_upload_example.dart`

Cet exemple montre :
- Sélection d'image depuis la galerie ou la caméra
- Upload vers Cloudinary avec gestion d'erreurs
- Affichage de l'image uploadée
- Interface utilisateur complète

## 🔄 Intégration dans le code existant

Le service est déjà intégré dans :

1. **`lib/services/post_service.dart`** : Upload de médias pour les posts/reels
2. **`lib/presentation/screens/profile/edit_profile_screen.dart`** : Upload d'images de profil

Ces fichiers ont été mis à jour pour gérer les nouvelles exceptions.

## ⚠️ Notes importantes

1. **Upload Preset** : Assurez-vous que le preset `Ecommerce_BuyV` est configuré comme "Unsigned" dans votre dashboard Cloudinary
2. **Permissions** : Pour utiliser `image_picker`, ajoutez les permissions nécessaires dans :
   - `android/app/src/main/AndroidManifest.xml`
   - `ios/Runner/Info.plist`
3. **Réseau** : L'upload nécessite une connexion Internet active
4. **Taille des fichiers** : Cloudinary a des limites de taille (généralement 10MB pour les images, 100MB pour les vidéos)

## 🐛 Dépannage

### Erreur : "Cloudinary credentials are not configured"
- Vérifiez que `cloudinaryCloudName` et `cloudinaryUploadPreset` sont définis dans `AppConstants`
- Vérifiez votre fichier `.env` si vous utilisez des variables d'environnement

### Erreur : "Upload succeeded but no URL was returned"
- Vérifiez que votre preset Cloudinary est bien configuré
- Vérifiez les logs Cloudinary dans votre dashboard

### Upload très lent
- Vérifiez votre connexion Internet
- Les vidéos peuvent prendre plus de temps à uploader selon leur taille

## 📚 Ressources

- [Documentation Cloudinary](https://cloudinary.com/documentation)
- [Cloudinary Flutter SDK](https://pub.dev/packages/cloudinary_public)
- [Image Picker Documentation](https://pub.dev/packages/image_picker)

