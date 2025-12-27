# 📱 Guide: Tester l'application sur Émulateur Android

## 🎯 Objectif
Lancer l'application BuyV sur un émulateur Android pour tester toutes les fonctionnalités avant de construire un APK.

---

## 📋 Prérequis

### 1. Vérifier les outils installés
```bash
# Vérifier Flutter
flutter doctor

# Vérifier que le SDK Android est installé
# Le SDK Android est généralement dans: %LOCALAPPDATA%\Android\Sdk (Windows)
# ou ~/Android/Sdk (Linux/Mac)

# Vérifier que les outils sont dans le PATH
adb version
emulator -version
```

### 2. Installer le SDK Android (si nécessaire)

**Option A: Via Flutter (recommandé)**
```bash
# Flutter installe automatiquement le SDK Android
flutter doctor --android-licenses
# Accepter toutes les licences en tapant 'y'
```

**Option B: Télécharger le SDK Command Line Tools**
1. Télécharger depuis: https://developer.android.com/studio#command-tools
2. Extraire dans un dossier (ex: `C:\Android\Sdk`)
3. Ajouter au PATH:
   - Windows: `C:\Android\Sdk\platform-tools` et `C:\Android\Sdk\emulator`
   - Linux/Mac: `~/Android/Sdk/platform-tools` et `~/Android/Sdk/emulator`

### 3. Vérifier les émulateurs disponibles
```bash
# Lister les émulateurs disponibles
flutter emulators

# OU directement avec l'outil emulator
emulator -list-avds
```

---

## 🚀 Étape 1: Préparer l'émulateur Android (Terminal uniquement)

### Option A: Créer un nouvel émulateur (si nécessaire)

**1. Installer un système d'image Android:**
```bash
# Lister les images système disponibles
sdkmanager --list | grep "system-images"

# Installer une image système (ex: Android 13 API 33)
sdkmanager "system-images;android-33;google_apis;x86_64"

# OU via Flutter (plus simple)
flutter emulators --create
# Suivre les instructions interactives
```

**2. Créer l'AVD (Android Virtual Device):**
```bash
# Lister les cibles disponibles
avdmanager list targets

# Créer un nouvel AVD
avdmanager create avd -n Pixel_5_API_33 -k "system-images;android-33;google_apis;x86_64" -d "pixel_5"

# Paramètres:
# -n: Nom de l'AVD (vous pouvez choisir)
# -k: Clé du système d'image (format: system-images;android-VERSION;TYPE;ARCH)
# -d: Device profile (pixel_5, pixel_6, etc.)
```

**3. Vérifier que l'AVD est créé:**
```bash
# Lister tous les AVD disponibles
avdmanager list avd

# OU
emulator -list-avds
```

### Option B: Utiliser un émulateur existant

**1. Lister les émulateurs disponibles:**
```bash
emulator -list-avds
# OU
flutter emulators
```

**2. Démarrer l'émulateur:**
```bash
# Démarrer en arrière-plan (recommandé)
emulator -avd Pixel_5_API_33 &

# OU démarrer dans un terminal séparé
emulator -avd Pixel_5_API_33

# Options utiles:
# -no-snapshot-load: Démarrer sans charger de snapshot (plus lent mais plus stable)
# -wipe-data: Effacer les données de l'émulateur
# -netdelay 200: Simuler une connexion lente (pour tests)
```

**3. Vérifier que l'émulateur est démarré:**
```bash
# Attendre que l'émulateur démarre (peut prendre 30-60 secondes)
# Puis vérifier:
adb devices

# Devrait afficher quelque chose comme:
# List of devices attached
# emulator-5554   device
```

**4. Attendre que l'émulateur soit prêt:**
```bash
# L'émulateur est prêt quand vous voyez l'écran d'accueil Android
# Vous pouvez aussi vérifier avec:
adb wait-for-device
adb shell getprop sys.boot_completed
# Devrait retourner: 1
```

---

## 🔧 Étape 2: Configurer le Backend

### 1. Démarrer le backend FastAPI

**Terminal 1 - Backend:**
```bash
cd buyv_backend

# Vérifier que le fichier .env existe
# Si non, créer .env avec:
# DATABASE_URL=sqlite:///./buyv.db
# SECRET_KEY=your-secret-key
# STRIPE_SECRET_KEY=sk_test_...

# Démarrer le serveur
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# OU utiliser le script Windows
run_backend.bat
```

**✅ Vérifier que le backend fonctionne:**
```bash
# Dans un autre terminal
curl http://localhost:8000/health

# Devrait retourner: {"status":"ok"}
```

### 2. Important: Configuration pour émulateur

L'émulateur Android utilise `10.0.2.2` pour accéder à `localhost` de la machine hôte.

**Vérifier `buyv_flutter_app/lib/core/config/environment_config.dart`:**
```dart
static String get fastApiBaseUrl {
  // Pour émulateur Android, devrait utiliser 10.0.2.2
  if (Platform.isAndroid) {
    // Vérifier si on est sur émulateur ou device réel
    return 'http://10.0.2.2:8000';  // Pour émulateur
    // OU
    // return 'https://buyv-production.up.railway.app';  // Pour production
  }
  // ...
}
```

**Note:** Si vous utilisez déjà l'URL de production (Railway), vous n'avez pas besoin de changer. Sinon, pour tester en local, utilisez `10.0.2.2:8000`.

---

## 📱 Étape 3: Lancer l'application Flutter

### Méthode 1: Via Android Studio (Recommandé)

1. **Ouvrir le projet Flutter dans Android Studio:**
   - File > Open > Sélectionner le dossier `buyv_flutter_app`

2. **Sélectionner l'émulateur:**
   - En haut de l'écran, dans la barre d'outils
   - Cliquer sur le menu déroulant des appareils
   - Sélectionner votre émulateur (ex: `Pixel 5 API 33`)

3. **Lancer l'application:**
   - Cliquer sur le bouton **▶️ Run** (ou `Shift + F10`)
   - OU: `Run > Run 'main.dart'`

4. **Attendre le build et le lancement:**
   - Le build peut prendre 2-5 minutes la première fois
   - L'app devrait s'ouvrir automatiquement sur l'émulateur

### Méthode 2: Via Terminal/Commande

**Terminal 2 - Flutter:**
```bash
cd buyv_flutter_app

# Lister les appareils disponibles
flutter devices

# Lancer sur l'émulateur
flutter run

# OU spécifier l'émulateur explicitement
flutter run -d emulator-5554

# Mode debug avec hot reload (recommandé)
flutter run --debug
```

**Commandes utiles pendant l'exécution:**
- `r` - Hot reload (recharger les changements)
- `R` - Hot restart (redémarrer complètement)
- `q` - Quitter
- `p` - Afficher les performances

---

## ✅ Étape 4: Checklist de Test des Fonctionnalités

### 🔐 1. Authentification

- [ ] **Créer un compte:**
  - Aller dans "Sign Up" ou "Register"
  - Remplir le formulaire (email, username, password)
  - Vérifier que l'inscription fonctionne
  - Vérifier les messages d'erreur si champs invalides

- [ ] **Se connecter:**
  - Utiliser les identifiants créés
  - Vérifier que la connexion fonctionne
  - Vérifier que le token est sauvegardé

- [ ] **Vérifier la session:**
  - Fermer et rouvrir l'app
  - Vérifier que l'utilisateur reste connecté

**🔍 Vérification Backend:**
```bash
# Vérifier les logs du backend
# Devrait voir: POST /auth/register ou POST /auth/login
```

---

### 💬 2. Système de Commentaires

- [ ] **Afficher les commentaires:**
  - Aller dans l'onglet "Reels"
  - Cliquer sur l'icône commentaire d'un reel
  - Vérifier que les commentaires existants s'affichent
  - Vérifier le format "time-ago" (ex: "2m", "1h", "3d")

- [ ] **Ajouter un commentaire:**
  - Taper un commentaire dans le champ texte
  - Cliquer sur "Send"
  - Vérifier que le commentaire apparaît immédiatement en haut
  - Vérifier que le compteur de commentaires s'incrémente

- [ ] **Pagination:**
  - Si beaucoup de commentaires, faire défiler
  - Vérifier que la pagination fonctionne

**🔍 Vérification Backend:**
```bash
# Vérifier les logs
# Devrait voir: GET /comments/{post_uid}?limit=20&offset=0
# Devrait voir: POST /comments/{post_uid}
```

**Test API direct:**
```bash
# Récupérer un token d'authentification d'abord
TOKEN="your-jwt-token"

# Tester GET comments
curl -X GET "http://localhost:8000/comments/POST_UID?limit=20&offset=0" \
  -H "Authorization: Bearer $TOKEN"

# Tester POST comment
curl -X POST "http://localhost:8000/comments/POST_UID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": "Test comment from emulator"}'
```

---

### 🛒 3. Paiements Stripe

- [ ] **Ajouter au panier:**
  - Aller dans "Shop" ou "Products"
  - Ajouter des produits au panier
  - Vérifier que le panier se met à jour

- [ ] **Checkout:**
  - Aller dans "Cart"
  - Cliquer sur "Checkout" ou "Pay Now"
  - Vérifier que le Payment Sheet Stripe s'ouvre

- [ ] **Test paiement:**
  - Utiliser la carte de test Stripe:
    - Numéro: `4242 4242 4242 4242`
    - Date: N'importe quelle date future (ex: 12/25)
    - CVC: N'importe quel 3 chiffres (ex: 123)
    - Code postal: N'importe quel code postal
  - Confirmer le paiement
  - Vérifier que la commande est créée

**🔍 Vérification Backend:**
```bash
# Vérifier les logs
# Devrait voir: POST /payments/create-payment-intent
# Devrait voir: POST /orders
```

**⚠️ Important:** Vérifier que `STRIPE_SECRET_KEY` est dans `buyv_backend/.env`

---

### 📦 4. Historique des Commandes

- [ ] **Afficher l'historique:**
  - Aller dans "Profile" > "Orders History"
  - Vérifier que les commandes s'affichent (pas de mock data)
  - Vérifier que les données viennent du serveur

- [ ] **Filtres:**
  - Tester le filtre "All"
  - Tester le filtre "Delivered" (devrait être vert)
  - Tester le filtre "Processing" (devrait être orange)
  - Tester le filtre "Shipped" (devrait être bleu)
  - Tester le filtre "Cancelled" (devrait être rouge)

- [ ] **Détails de commande:**
  - Cliquer sur une commande
  - Vérifier que les détails s'affichent correctement
  - Vérifier les items, prix, adresse, etc.

**🔍 Vérification Backend:**
```bash
# Vérifier les logs
# Devrait voir: GET /orders/me
# Devrait voir: GET /orders/me/by_status?status=...
```

---

### 🎬 5. Cache Vidéo (Performance)

- [ ] **Premier chargement:**
  - Aller dans "Reels"
  - Faire défiler quelques vidéos
  - Noter le temps de chargement initial

- [ ] **Test du cache:**
  - Faire défiler vers le haut pour revenir aux vidéos précédentes
  - Vérifier qu'elles se chargent **instantanément** (cache)
  - Fermer complètement l'app (swipe up dans le multitâche)
  - Rouvrir l'app et retourner dans Reels
  - Vérifier que les vidéos récemment vues se chargent rapidement

**✅ Critère de succès:** Les vidéos doivent se charger en < 1 seconde après le premier chargement.

---

### 🔗 6. Deep Linking

- [ ] **Test depuis terminal:**
```bash
# Depuis votre machine (pas dans l'émulateur)
adb shell am start -a android.intent.action.VIEW -d "buyv://product/123"
```

- [ ] **Vérifier:**
  - L'app s'ouvre automatiquement
  - L'app navigue vers le produit avec l'ID 123
  - L'écran de détail produit s'affiche

- [ ] **Test depuis navigateur (optionnel):**
  - Créer un fichier HTML simple avec un lien:
  ```html
  <a href="buyv://product/123">Ouvrir produit 123</a>
  ```
  - Ouvrir dans le navigateur de l'émulateur
  - Cliquer sur le lien
  - Vérifier que l'app s'ouvre

**🔍 Vérification:**
- Vérifier les logs Flutter pour voir si le deep link est reçu
- Vérifier que le routing fonctionne correctement

---

## 🐛 Résolution de Problèmes Courants

### Problème: L'app ne se connecte pas au backend

**Symptômes:**
- Erreurs "Connection refused" ou "Failed to connect"
- Les requêtes API échouent

**Solutions:**
1. **Vérifier que le backend tourne:**
   ```bash
   curl http://localhost:8000/health
   ```

2. **Vérifier l'URL dans Flutter:**
   - Pour émulateur: `http://10.0.2.2:8000`
   - Pour device réel: `http://VOTRE_IP_LOCALE:8000` (ex: `192.168.1.100:8000`)

3. **Vérifier le firewall Windows:**
   - Autoriser Python/uvicorn sur le port 8000

4. **Vérifier les logs Flutter:**
   ```bash
   # Dans le terminal où vous avez lancé flutter run
   # Regarder les erreurs réseau
   ```

### Problème: L'émulateur est lent

**Solutions:**
1. **Augmenter la RAM de l'émulateur:**
   ```bash
   # Démarrer avec plus de RAM
   emulator -avd Pixel_5_API_33 -memory 4096
   
   # OU modifier l'AVD existant
   # Éditer le fichier: ~/.android/avd/Pixel_5_API_33.avd/config.ini
   # Changer: hw.ramSize = 4096
   ```

2. **Activer l'accélération matérielle:**
   - Vérifier que HAXM ou Hyper-V est activé
   - `flutter doctor` devrait le confirmer
   - Windows: Hyper-V devrait être activé automatiquement
   - Linux: Installer KVM
   - Mac: HAXM devrait être installé automatiquement

3. **Réduire la résolution:**
   - Créer un AVD avec résolution plus faible
   - Utiliser un device profile plus petit (ex: `pixel_2` au lieu de `pixel_5`)

4. **Utiliser un snapshot:**
   ```bash
   # Démarrer normalement (utilise le snapshot)
   emulator -avd Pixel_5_API_33
   # Le premier démarrage sera lent, les suivants seront rapides
   ```

### Problème: Hot reload ne fonctionne pas

**Solutions:**
1. **Vérifier que vous êtes en mode debug:**
   ```bash
   flutter run --debug
   ```

2. **Forcer un hot restart:**
   - Appuyer sur `R` dans le terminal

3. **Redémarrer complètement:**
   - Appuyer sur `q` pour quitter
   - Relancer avec `flutter run`

### Problème: Les vidéos ne se chargent pas

**Solutions:**
1. **Vérifier la connexion internet de l'émulateur:**
   - Ouvrir le navigateur dans l'émulateur
   - Essayer d'accéder à un site web

2. **Vérifier les permissions:**
   - Vérifier que `INTERNET` est dans `AndroidManifest.xml`

3. **Vérifier les URLs vidéo:**
   - Vérifier que les URLs dans les reels sont valides
   - Tester une URL dans le navigateur de l'émulateur

### Problème: Stripe Payment Sheet ne s'ouvre pas

**Solutions:**
1. **Vérifier les clés Stripe:**
   ```bash
   # Vérifier que STRIPE_SECRET_KEY est dans .env
   cat buyv_backend/.env | grep STRIPE
   ```

2. **Vérifier les logs backend:**
   - Regarder les erreurs Stripe dans les logs

3. **Tester l'endpoint directement:**
   ```bash
   curl -X POST "http://localhost:8000/payments/create-payment-intent" \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"amount": 1000, "currency": "usd"}'
   ```

---

## 📊 Logs et Debugging

### Voir les logs Flutter
```bash
# Dans le terminal où vous avez lancé flutter run
# Les logs apparaissent automatiquement

# OU filtrer les logs
flutter logs | grep "ERROR"
```

### Voir les logs Android (logcat)
```bash
# Filtrer les logs de l'app
adb logcat | grep "buyv"

# OU voir tous les logs
adb logcat
```

### Voir les logs Backend
```bash
# Les logs apparaissent dans le terminal où vous avez lancé uvicorn
# Format: INFO:     127.0.0.1:xxxxx - "GET /health HTTP/1.1" 200 OK
```

### Debug Network dans Flutter
```dart
// Ajouter dans votre code pour voir les requêtes HTTP
import 'package:dio/dio.dart';

// Dio interceptor pour logger les requêtes
final dio = Dio();
dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
));
```

---

## 🎯 Checklist Finale Avant Démo

- [ ] Émulateur fonctionne correctement
- [ ] Backend démarre sans erreur
- [ ] App se connecte au backend
- [ ] Authentification fonctionne (register/login)
- [ ] Commentaires: Ajout et affichage OK
- [ ] Paiements Stripe: Payment Sheet s'ouvre
- [ ] Historique commandes: Affichage avec statuts colorés
- [ ] Cache vidéo: Chargement rapide après premier load
- [ ] Deep linking: Navigation depuis lien externe
- [ ] Pas d'erreurs critiques dans les logs
- [ ] Performance acceptable (pas de lag)

---

## 🚀 Commandes Rapides de Référence

```bash
# Démarrer l'émulateur
emulator -avd Pixel_5_API_33

# Lister les appareils
flutter devices
adb devices

# Lancer l'app
flutter run

# Hot reload
# Appuyer sur 'r' dans le terminal

# Voir les logs
flutter logs
adb logcat

# Tester le backend
curl http://localhost:8000/health

# Tester deep link
adb shell am start -a android.intent.action.VIEW -d "buyv://product/123"
```

---

## 📝 Notes Importantes

1. **Premier lancement:** Le build peut prendre 5-10 minutes. Les lancements suivants seront plus rapides.

2. **Hot Reload:** Fonctionne pour les changements UI. Pour les changements de logique backend, redémarrer l'app.

3. **Performance:** L'émulateur peut être plus lent qu'un device réel. C'est normal.

4. **Réseau:** L'émulateur utilise `10.0.2.2` pour accéder à `localhost` de votre machine.

5. **Backend:** Gardez le terminal backend ouvert pour voir les logs en temps réel.

---

**Bon test ! 🎉**

Si vous rencontrez des problèmes, consultez la section "Résolution de Problèmes" ou vérifiez les logs.

