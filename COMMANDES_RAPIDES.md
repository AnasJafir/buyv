# ⚡ Commandes Rapides - Référence

## 🚀 Démarrage

### Démarrer l'émulateur (Terminal uniquement)
```bash
# Lister les émulateurs disponibles
emulator -list-avds
# OU
flutter emulators

# Démarrer l'émulateur
emulator -avd NOM_EMULATEUR

# Démarrer en arrière-plan (recommandé)
emulator -avd NOM_EMULATEUR &

# Options utiles:
emulator -avd NOM_EMULATEUR -no-snapshot-load  # Démarrer proprement
emulator -avd NOM_EMULATEUR -wipe-data         # Effacer les données
```

### Créer un nouvel émulateur
```bash
# Via Flutter (recommandé - plus simple)
flutter emulators --create

# OU manuellement
# 1. Installer une image système
sdkmanager "system-images;android-33;google_apis;x86_64"

# 2. Créer l'AVD
avdmanager create avd -n Pixel_5_API_33 -k "system-images;android-33;google_apis;x86_64" -d "pixel_5"
```

### Démarrer le backend
```bash
cd buyv_backend
run_backend.bat
# OU
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

### Lancer l'app Flutter
```bash
cd buyv_flutter_app
flutter run
```

---

## 🔍 Vérifications

### Vérifier les appareils connectés
```bash
flutter devices
adb devices
```

### Vérifier que le backend fonctionne
```bash
curl http://localhost:8000/health
# Devrait retourner: {"status":"ok"}
```

### Voir les logs Flutter
```bash
flutter logs
```

### Voir les logs Android (logcat)
```bash
adb logcat | grep "buyv"
```

---

## 🛠️ Commandes Flutter (pendant l'exécution)

Quand `flutter run` est actif:
- `r` - Hot reload (recharger les changements)
- `R` - Hot restart (redémarrer complètement)
- `q` - Quitter l'application
- `p` - Afficher les performances
- `o` - Basculer entre Android/iOS
- `h` - Afficher l'aide

---

## 🧪 Tests

### Tester l'API Commentaires
```bash
# Récupérer un token d'abord (via login)
TOKEN="votre-jwt-token"

# GET comments
curl -X GET "http://localhost:8000/comments/POST_UID?limit=20&offset=0" \
  -H "Authorization: Bearer $TOKEN"

# POST comment
curl -X POST "http://localhost:8000/comments/POST_UID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": "Test comment"}'
```

### Tester l'API Commandes
```bash
# GET orders
curl -X GET "http://localhost:8000/orders/me" \
  -H "Authorization: Bearer $TOKEN"
```

### Tester Deep Link
```bash
# Android
adb shell am start -a android.intent.action.VIEW -d "buyv://product/123"

# iOS (si sur Mac)
xcrun simctl openurl booted "buyv://product/123"
```

---

## 🧹 Nettoyage

### Nettoyer le projet Flutter
```bash
cd buyv_flutter_app
flutter clean
flutter pub get
```

### Nettoyer le cache Gradle
```bash
cd buyv_flutter_app/android
./gradlew clean
```

### Nettoyer le cache pub
```bash
flutter pub cache clean
```

---

## 🔧 Debug

### Mode debug avec logs détaillés
```bash
flutter run --debug --verbose
```

### Build debug APK (sans installer)
```bash
flutter build apk --debug
```

### Voir les erreurs de build
```bash
flutter build apk --debug 2>&1 | tee build_log.txt
```

---

## 📱 Émulateur (Terminal uniquement)

### Lister les émulateurs
```bash
flutter emulators
emulator -list-avds
avdmanager list avd
```

### Démarrer un émulateur spécifique
```bash
# Démarrer normalement
emulator -avd Pixel_5_API_33

# Démarrer en arrière-plan
emulator -avd Pixel_5_API_33 &

# Démarrer sans snapshot (plus lent mais plus stable)
emulator -avd Pixel_5_API_33 -no-snapshot-load

# Démarrer et effacer les données
emulator -avd Pixel_5_API_33 -wipe-data
```

### Vérifier que l'émulateur est prêt
```bash
# Vérifier les appareils connectés
adb devices

# Attendre que l'émulateur soit prêt
adb wait-for-device
adb shell getprop sys.boot_completed
# Devrait retourner: 1
```

### Arrêter l'émulateur
```bash
# Trouver le PID de l'émulateur
adb emu kill

# OU fermer la fenêtre de l'émulateur
# OU tuer le processus
# Windows:
taskkill /F /IM qemu-system-x86_64.exe
# Linux/Mac:
pkill -f emulator
```

### Redémarrer l'émulateur
```bash
adb reboot
```

### Gérer les émulateurs
```bash
# Supprimer un AVD
avdmanager delete avd -n NOM_AVD

# Lister les images système installées
sdkmanager --list_installed | grep system-images

# Installer une nouvelle image système
sdkmanager "system-images;android-33;google_apis;x86_64"
```

### Prendre une capture d'écran
```bash
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png
```

---

## 🌐 Réseau

### Vérifier la connexion de l'émulateur
```bash
adb shell ping -c 3 8.8.8.8
```

### Vérifier l'accès au backend depuis l'émulateur
```bash
adb shell curl http://10.0.2.2:8000/health
```

### Trouver l'IP locale (pour device réel)
```bash
# Windows
ipconfig | findstr IPv4

# Linux/Mac
ifconfig | grep inet
```

---

## 📊 Performance

### Voir les performances en temps réel
```bash
# Pendant flutter run, appuyer sur 'p'
```

### Profiler l'application
```bash
flutter run --profile
```

### Analyser la taille de l'APK
```bash
flutter build apk --debug
# Le fichier sera dans: build/app/outputs/flutter-apk/app-debug.apk
```

---

## 🔐 Sécurité

### Vérifier les variables d'environnement
```bash
# Backend
cd buyv_backend
cat .env

# Flutter
cd buyv_flutter_app
cat .env
```

### Tester l'authentification
```bash
# Register
curl -X POST "http://localhost:8000/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123","username":"testuser","displayName":"Test User"}'

# Login
curl -X POST "http://localhost:8000/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'
```

---

## 📝 Notes

- **Backend local:** Utilise `http://10.0.2.2:8000` pour l'émulateur
- **Backend production:** Utilise `https://buyv-production.up.railway.app`
- **Hot reload:** Fonctionne pour les changements UI uniquement
- **Hot restart:** Nécessaire pour les changements de logique

---

**💡 Astuce:** Gardez ce fichier ouvert pendant vos tests pour référence rapide!

