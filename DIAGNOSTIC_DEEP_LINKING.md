# 🔗 DIAGNOSTIC DEEP LINKING - 27 DEC 2024

## ✅ ÉTAT ACTUEL

### 1. AndroidManifest.xml Configuration
**Statut**: ✅ **CONFIGURÉ CORRECTEMENT**

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="buyv"/>
</intent-filter>
```

**✅ Points positifs**:
- Schéma `buyv://` configuré
- `autoVerify="true"` pour App Links
- `android:launchMode="singleTop"` (évite duplication d'activité)
- Categories DEFAULT et BROWSABLE présentes

---

### 2. DeepLinkHandler Service
**Statut**: ✅ **SERVICE CRÉÉ**

Fichier: `lib/services/deep_link_handler.dart`

**✅ Fonctionnalités implémentées**:
- ✅ Parsing des deep links
- ✅ Navigation avec GoRouter
- ✅ Support des routes:
  - `/post/{id}` - Posts/Reels
  - `/user/{id}` - Profils utilisateurs
  - `/product/{id}` - Produits avec params (name, price, image, category)
  - `/home`, `/profile`, `/shop`, `/cart`, `/reels`, `/search`, `/notifications`, `/orders-history`, `/settings`

**✅ Méthodes utilitaires**:
- `createPostDeepLink(postId)` - Génère: `buyv://post/abc123`
- `createUserDeepLink(userId)` - Génère: `buyv://user/user123`
- `createProductDeepLink(productId, ...)` - Génère: `buyv://product/prod123?name=Shirt&price=29.99`
- `isValidDeepLink(uri)` - Valide le schéma
- `extractRoute(uri)` - Extrait le path

---

### 3. Router Configuration (GoRouter)
**Statut**: ✅ **ROUTES DÉFINIES**

Fichier: `lib/core/router/app_router.dart`

**✅ Routes avec deep linking support**:
```dart
GoRoute(path: RouteNames.post, name: 'post')
  // Accepte /post/:postId

GoRoute(path: RouteNames.userProfile, name: 'user_profile')
  // Accepte /user/:userId

GoRoute(path: RouteNames.product, name: 'product')
  // Accepte /product/:productId avec query params
```

---

## ⚠️ PROBLÈMES DÉTECTÉS

### ❌ **PROBLÈME #1: Package `uni_links` NON INSTALLÉ**

**Description**: Le package pour écouter les deep links entrants n'est pas installé.

**Impact**: L'app ne peut pas recevoir et traiter les deep links quand elle est:
- Fermée (cold start)
- En arrière-plan (warm start)

**Solution requise**:
```yaml
# pubspec.yaml
dependencies:
  uni_links: ^0.5.1  # OU app_links: ^6.3.2 (plus moderne)
```

---

### ❌ **PROBLÈME #2: Listener NON INITIALISÉ dans main.dart**

**Description**: Aucun code dans `main.dart` pour écouter les deep links.

**Impact**: Les deep links ouverts depuis:
- Navigateur mobile
- Messages/Email
- Autres apps
...ne sont PAS interceptés.

**Solution requise**: Ajouter un listener dans `main.dart` qui:
1. Écoute les deep links quand l'app démarre (initial link)
2. Écoute les deep links quand l'app est déjà ouverte (link stream)
3. Appelle `DeepLinkHandler.handleDeepLink()` avec le contexte GoRouter

---

### ⚠️ **PROBLÈME #3: Pas de gestion dans MainActivity.kt**

**Description**: Le fichier `MainActivity.kt` ne traite pas explicitement les Intent data.

**État**: Android devrait gérer automatiquement avec l'intent-filter, mais pour une robustesse maximale, on peut ajouter du code Kotlin.

**Impact**: Mineur (fonctionne probablement déjà), mais peut causer des edge cases.

---

## 🔧 PLAN DE CORRECTION

### **ÉTAPE 1**: Installer le package uni_links ou app_links

**Option A - uni_links** (simple, stable):
```bash
flutter pub add uni_links
```

**Option B - app_links** (moderne, recommandé pour Android 12+):
```bash
flutter pub add app_links
```

### **ÉTAPE 2**: Modifier main.dart

**Avec `uni_links`**:
```dart
import 'package:uni_links/uni_links.dart';
import 'dart:async';

// Dans MyApp ou une StatefulWidget wrapper
StreamSubscription? _linkSubscription;

@override
void initState() {
  super.initState();
  _handleIncomingLinks();
  _handleInitialUri();
}

// Handle links while app is running
void _handleIncomingLinks() {
  _linkSubscription = uriLinkStream.listen((Uri? uri) {
    if (uri != null && mounted) {
      DeepLinkHandler.handleDeepLink(context, uri);
    }
  }, onError: (err) {
    debugPrint('Error handling deep link: $err');
  });
}

// Handle initial link when app starts
Future<void> _handleInitialUri() async {
  try {
    final uri = await getInitialUri();
    if (uri != null && mounted) {
      DeepLinkHandler.handleDeepLink(context, uri);
    }
  } catch (e) {
    debugPrint('Error getting initial URI: $e');
  }
}

@override
void dispose() {
  _linkSubscription?.cancel();
  super.dispose();
}
```

**Avec `app_links`** (plus moderne):
```dart
import 'package:app_links/app_links.dart';

final _appLinks = AppLinks();
StreamSubscription? _linkSubscription;

@override
void initState() {
  super.initState();
  _initDeepLinks();
}

Future<void> _initDeepLinks() async {
  // Handle initial link when app starts
  final initialUri = await _appLinks.getInitialLink();
  if (initialUri != null && mounted) {
    DeepLinkHandler.handleDeepLink(context, initialUri);
  }

  // Handle links while app is running
  _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
    if (mounted) {
      DeepLinkHandler.handleDeepLink(context, uri);
    }
  });
}
```

### **ÉTAPE 3**: Tester avec ADB

**Test 1 - Post/Reel**:
```bash
adb shell am start -W -a android.intent.action.VIEW -d "buyv://post/762136ed-468b-4315-ba58-16b1d41a1bdb" com.buyv.flutter_app
```

**Test 2 - User Profile**:
```bash
adb shell am start -W -a android.intent.action.VIEW -d "buyv://user/359b21e7-03d4-41de-984a-b693ef6c03f7" com.buyv.flutter_app
```

**Test 3 - Product**:
```bash
adb shell am start -W -a android.intent.action.VIEW -d "buyv://product/12345?name=T-Shirt&price=29.99" com.buyv.flutter_app
```

**Test 4 - Home**:
```bash
adb shell am start -W -a android.intent.action.VIEW -d "buyv://home" com.buyv.flutter_app
```

---

## 📊 CHECKLIST AVANT TEST

### Configuration Android
- [x] AndroidManifest.xml a intent-filter avec `buyv://`
- [x] Activity a `launchMode="singleTop"`
- [x] Schéma deep link défini correctement

### Code Flutter
- [x] DeepLinkHandler service créé
- [x] Méthodes de parsing des routes
- [ ] **Package uni_links/app_links installé** ⚠️
- [ ] **Listener initialisé dans main.dart** ⚠️
- [x] GoRouter routes configurées

### Intégration
- [x] Routes correspondent entre DeepLinkHandler et GoRouter
- [x] Gestion des paramètres de requête (query params)
- [x] Fallback vers home en cas d'erreur

---

## 🎯 RÉSUMÉ

**État actuel**: 70% prêt
- ✅ Configuration Android OK
- ✅ Service DeepLinkHandler OK
- ✅ Routes GoRouter OK
- ❌ Package listener MANQUANT
- ❌ Initialisation listener MANQUANTE

**Actions requises**:
1. Installer `app_links` (recommandé) ou `uni_links`
2. Ajouter listener dans `main.dart`
3. Tester avec commandes ADB

**Temps estimé**: 10-15 minutes

**Après correction**, vous pourrez:
- Partager des posts avec `buyv://post/{id}`
- Partager des profils avec `buyv://user/{id}`
- Partager des produits avec `buyv://product/{id}?name=...&price=...`
- Ouvrir l'app depuis un navigateur/email/message

---

## 📝 NOTES IMPORTANTES

1. **Android 12+**: Nécessite App Links verification pour https:// (pas urgent pour buyv://)
2. **iOS**: Nécessite configuration dans `Info.plist` (pas fait actuellement)
3. **Testing**: Toujours tester sur device réel, pas émulateur (deep links ne marchent pas bien sur émulateur)
4. **Package choice**: `app_links` est plus moderne et mieux maintenu que `uni_links`

---

**Date**: 27 Décembre 2024
**Checkpoint**: Après VIDEO PLAYER FIX
**Prochaine étape**: Installation package + Listener setup
