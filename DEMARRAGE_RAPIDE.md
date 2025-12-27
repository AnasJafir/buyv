# ⚡ Démarrage Rapide - Test sur Émulateur

## 🚀 En 5 minutes

### 1. Démarrer l'émulateur (30 secondes)
```bash
# Lister les émulateurs disponibles
emulator -list-avds
# OU
flutter emulators

# Démarrer l'émulateur (remplacer par le nom de votre AVD)
emulator -avd Pixel_5_API_33

# Attendre que l'émulateur démarre complètement (30-60 secondes)
# Vérifier avec:
adb devices
# Devrait afficher: emulator-5554   device
```

**💡 Astuce:** Si vous n'avez pas d'émulateur, créez-en un:
```bash
# Créer un émulateur via Flutter (plus simple)
flutter emulators --create

# OU manuellement
avdmanager create avd -n Pixel_5_API_33 -k "system-images;android-33;google_apis;x86_64"
```

### 2. Démarrer le backend (1 minute)
```bash
cd buyv_backend
run_backend.bat
# OU
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

**✅ Vérifier:** Ouvrir http://localhost:8000/health dans le navigateur

### 3. Lancer l'app Flutter (2 minutes)
```bash
cd buyv_flutter_app
flutter run
```

**✅ L'app devrait s'ouvrir automatiquement sur l'émulateur**

---

## 📋 Configuration Actuelle

### Backend URL
L'application utilise actuellement l'URL de production Railway:
- **URL:** `https://buyv-production.up.railway.app`
- **Avantage:** Pas besoin de démarrer le backend local
- **Inconvénient:** Dépend de la connexion internet

### Pour tester avec backend local

Si vous voulez tester avec votre backend local, modifiez temporairement:

**Fichier:** `buyv_flutter_app/lib/core/config/environment_config.dart`

```dart
static String get fastApiBaseUrl {
  // Pour tester en local sur émulateur
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8000';  // Émulateur Android
  }
  if (Platform.isIOS) {
    return 'http://localhost:8000';  // iOS Simulator
  }
  if (kIsWeb) {
    return 'http://localhost:8000';  // Web
  }
  // Production par défaut
  return _productionUrl;
}
```

**⚠️ Important:** Remettre l'URL de production avant de construire l'APK final.

---

## ✅ Tests Essentiels (10 minutes)

### Test 1: Authentification (2 min)
1. Créer un compte
2. Se connecter
3. Vérifier que la session persiste

### Test 2: Commentaires (2 min)
1. Aller dans Reels
2. Cliquer sur commentaire
3. Ajouter un commentaire
4. Vérifier qu'il apparaît immédiatement

### Test 3: Paiement Stripe (3 min)
1. Ajouter produit au panier
2. Checkout
3. Utiliser carte test: `4242 4242 4242 4242`
4. Vérifier que la commande est créée

### Test 4: Historique Commandes (2 min)
1. Profile > Orders History
2. Vérifier l'affichage
3. Tester les filtres
4. Vérifier les couleurs de statut

### Test 5: Cache Vidéo (1 min)
1. Aller dans Reels
2. Faire défiler quelques vidéos
3. Revenir en arrière
4. Vérifier chargement instantané

---

## 🐛 Problèmes Fréquents

### "Connection refused"
→ Vérifier que le backend tourne sur le port 8000

### "App ne se lance pas"
→ Vérifier que l'émulateur est démarré: `adb devices`

### "Hot reload ne fonctionne pas"
→ Appuyer sur `R` pour hot restart

### "Vidéos ne se chargent pas"
→ Vérifier la connexion internet de l'émulateur

---

## 📞 Commandes Utiles

```bash
# Voir les appareils
flutter devices

# Voir les logs
flutter logs

# Hot reload: appuyer sur 'r'
# Hot restart: appuyer sur 'R'
# Quitter: appuyer sur 'q'

# Tester backend
curl http://localhost:8000/health
```

---

**🎯 Objectif:** Tester toutes les fonctionnalités avant de construire l'APK

**📖 Guide complet:** Voir `GUIDE_TEST_EMULATEUR.md` pour plus de détails

