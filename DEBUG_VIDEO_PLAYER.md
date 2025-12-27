# 🎬 GUIDE DE DÉBOGAGE - VIDEO PLAYER

## 🔍 Changements Appliqués

### 1. **VideoPlayerWidget Enhanced** ✅
**Fichier**: `lib/presentation/widgets/video_player_widget.dart`

**Améliorations**:
- ✅ Logs détaillés avant/pendant/après l'initialisation
- ✅ Validation d'URL (vide, HTTP/HTTPS)
- ✅ Message d'erreur détaillé affiché à l'écran
- ✅ Bouton "Retry" pour recharger la vidéo
- ✅ État de chargement amélioré avec texte

**Logs ajoutés**:
```dart
debugPrint('🎥 VideoPlayerWidget: Initializing video player');
debugPrint('🎥 Video URL: ${widget.videoUrl}');
debugPrint('✅ Video initialized successfully!');
debugPrint('📺 Video dimensions: ${_controller!.value.size}');
debugPrint('⏱️ Video duration: ${_controller!.value.duration}');
```

### 2. **PostCardWidget Enhanced** ✅
**Fichier**: `lib/presentation/widgets/post_card_widget.dart`

**Améliorations**:
- ✅ Logs pour chaque vidéo rendue dans le feed
- ✅ Gestion explicite des URLs vides
- ✅ Message "No video available" pour URLs manquantes

**Logs ajoutés**:
```dart
debugPrint('🎬 PostCard: Rendering video for post ${widget.post.id}');
debugPrint('🎬 Video URL: ${widget.post.videoUrl}');
debugPrint('🎬 Post type: ${widget.post.type}');
```

### 3. **Profile Screen Navigation Fixed** ✅
**Fichier**: `lib/presentation/screens/profile/profile_screen.dart`

**Améliorations**:
- ✅ Navigation vers ReelsScreen implémentée
- ✅ Logs pour chaque vidéo dans la grille
- ✅ Clic sur vidéo maintenant fonctionnel

**Code ajouté**:
```dart
onTap: () {
  if (item.type == 'reel' || item.type == 'video') {
    context.push('/reels', extra: {'startPostId': item.id});
  }
}
```

### 4. **Script de Diagnostic DB** ✅
**Fichier**: `buyv_backend/scripts/check_video_urls.py`

**Fonctionnalité**:
- Vérifie toutes les URLs vidéo en base de données
- Affiche statistiques détaillées
- Identifie les URLs vides ou invalides

---

## 🧪 Comment Tester

### Étape 1: Vérifier la Base de Données
```bash
cd C:\Users\user\Desktop\Ecommercemasternewfull 2\Buyv\buyv_backend
python scripts/check_video_urls.py
```

**Ce que vous devriez voir**:
- Liste de tous les posts vidéo
- URLs Cloudinary complètes
- Identification des URLs vides

**Si URLs vides**:
- ❌ Problème avec l'upload Cloudinary
- Vérifiez les credentials dans `.env`

### Étape 2: Tester l'Upload d'une Nouvelle Vidéo

1. **Ouvrir l'app Flutter** (Android ou Desktop)
2. **Activer les logs dans VS Code**:
   - View → Output → Select "Debug Console"
3. **Créer un nouveau Reel**:
   - Profile → Button "+" → Select video
4. **Observer les logs**:

**Logs attendus lors de l'upload**:
```
🚀 [Cloudinary] Starting video upload...
📁 Folder: videos
📄 File name: video_20241227.mp4
📏 File size: 2458632 bytes
☁️ Cloud Name: [votre cloud name]
🔧 Upload Preset: [votre preset]
📖 Reading file bytes...
✅ File bytes read: 2458632 bytes
📤 Uploading to Cloudinary...
✅ [Cloudinary] Video uploaded successfully in 5243ms
🔗 Secure URL: https://res.cloudinary.com/...
```

**Si erreur**:
```
❌ [Cloudinary] Error uploading video (Dio): ...
❌ Status Code: 401
❌ Response Data: {"error": "Invalid credentials"}
```

### Étape 3: Tester la Lecture Vidéo

1. **Aller dans le Feed**
2. **Observer les logs VideoPlayerWidget**:

**Logs attendus**:
```
🎬 PostCard: Rendering video for post abc123
🎬 Video URL: https://res.cloudinary.com/.../video.mp4
🎥 VideoPlayerWidget: Initializing video player
🎥 Video URL: https://res.cloudinary.com/.../video.mp4
🎥 Creating VideoPlayerController...
🎥 Initializing controller...
✅ Video initialized successfully!
📺 Video dimensions: Size(1080.0, 1920.0)
⏱️ Video duration: 0:00:15.000000
```

**Si erreur**:
```
❌ Invalid video URL (not HTTP/HTTPS): [url]
ou
❌ Video URL is empty!
ou
❌ ERROR initializing video player: [exception]
```

### Étape 4: Tester Navigation Profile → Vidéo

1. **Aller dans Profile**
2. **Cliquer sur l'onglet "Videos"**
3. **Cliquer sur une vidéo**

**Logs attendus**:
```
📹 Profile Grid: Rendering item post_123
📹 Video URL: https://res.cloudinary.com/.../video.mp4
🎯 Profile Grid: Item tapped - post_123
🎯 Navigating to reels screen with post post_123
```

---

## 🔧 Problèmes Courants et Solutions

### Problème 1: URLs Vides en Base de Données
**Symptôme**: Script Python montre "❌ URLs VIDES"

**Causes possibles**:
1. Cloudinary credentials incorrectes
2. Upload preset mal configuré
3. Erreur réseau lors de l'upload

**Solution**:
```bash
# Vérifier .env
cd buyv_backend
cat .env | grep CLOUDINARY

# Devrait montrer:
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_UPLOAD_PRESET=your_preset
```

### Problème 2: "Invalid video URL (not HTTP/HTTPS)"
**Symptôme**: VideoPlayerWidget affiche cette erreur

**Causes possibles**:
1. URL relative au lieu d'absolue
2. URL locale (file://)
3. URL mal formée

**Solution**:
- Vérifier que Cloudinary retourne URL complète
- Vérifier logs CloudinaryService lors de l'upload

### Problème 3: "ERROR initializing video player"
**Symptôme**: Exception lors de l'initialisation

**Causes possibles**:
1. Format vidéo non supporté (pas MP4)
2. CORS issues (Cloudinary)
3. Réseau inaccessible

**Solution**:
```dart
// Tester avec URL hardcodée dans VideoPlayerWidget
final testUrl = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
// Si ça marche, le problème est avec vos URLs Cloudinary
```

### Problème 4: Vidéos ne s'affichent pas dans Profile
**Symptôme**: Grille vide ou pas de navigation

**Causes possibles**:
1. Aucun post de type 'reel' en DB
2. getUserReels() ne retourne rien

**Solution**:
```python
# Vérifier avec script Python
python scripts/check_video_urls.py
# Si 0 posts, créer un reel depuis l'app
```

---

## 📋 Checklist de Vérification

### Backend
- [ ] Python script `check_video_urls.py` exécuté
- [ ] Au moins 1 post vidéo en DB avec URL valide
- [ ] URL Cloudinary au format HTTPS complet
- [ ] Backend démarre sans erreur (port 8000)

### Cloudinary
- [ ] `.env` contient CLOUDINARY_CLOUD_NAME
- [ ] `.env` contient CLOUDINARY_UPLOAD_PRESET
- [ ] Upload preset configuré en "unsigned" sur Cloudinary
- [ ] Upload preset accepte les vidéos (resource_type: video)

### Flutter App
- [ ] Logs activés (Debug Console)
- [ ] CloudinaryService logs apparaissent lors de l'upload
- [ ] VideoPlayerWidget logs apparaissent lors du rendu
- [ ] PostCardWidget logs apparaissent dans le feed
- [ ] Profile navigation fonctionne (tap sur vidéo)

---

## 🎯 Tests de Validation Finale

### Test 1: Upload + Lecture Immédiate
1. Créer nouveau reel avec vidéo
2. Observer logs Cloudinary (upload successful)
3. Retourner au feed
4. Vérifier que la vidéo s'affiche (pas d'erreur rouge)

### Test 2: Profile Grid Navigation
1. Aller dans Profile → Videos tab
2. Vérifier présence de vidéos
3. Cliquer sur une vidéo
4. Vérifier navigation vers ReelsScreen

### Test 3: Feed Scroll Multiple Videos
1. Créer 3-5 reels
2. Scroller le feed
3. Vérifier que chaque vidéo charge correctement
4. Aucune erreur rouge

---

## 📞 Prochaines Étapes Si Problème Persiste

1. **Partager les logs**:
   - Copier sortie de `check_video_urls.py`
   - Copier logs Debug Console Flutter
   - Copier logs backend (uvicorn)

2. **Tester URL vidéo manuellement**:
   ```dart
   // Dans VideoPlayerWidget, ligne 32, remplacer temporairement:
   final testUrl = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
   _controller = VideoPlayerController.networkUrl(Uri.parse(testUrl));
   ```

3. **Vérifier réseau**:
   - Tester sur Android (real device)
   - Tester sur WiFi vs mobile data
   - Vérifier firewall/antivirus

4. **Cloudinary Dashboard**:
   - Vérifier que les vidéos apparaissent
   - Tester l'URL directement dans navigateur
   - Vérifier les transformations automatiques

---

**Date**: 27 Décembre 2024  
**Version**: 1.0  
**État**: Debugging tools déployés, prêt pour tests
