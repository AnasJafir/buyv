# 🚀 Guide Complet : Deep Linking & Go Router

## Date d'Implémentation : 26 Décembre 2025

---

## 📋 Table des Matières

1. [Vue d'Ensemble](#vue-densemble)
2. [Configuration](#configuration)
3. [Routes Disponibles](#routes-disponibles)
4. [Deep Links Supportés](#deep-links-supportés)
5. [Utilisation dans le Code](#utilisation-dans-le-code)
6. [Tests](#tests)
7. [Troubleshooting](#troubleshooting)

---

## 🎯 Vue d'Ensemble

L'application BuyV utilise maintenant **go_router** pour une navigation moderne avec support complet du deep linking. Cela permet :

- ✅ Navigation déclarative avec URLs
- ✅ Deep linking depuis l'extérieur (SMS, emails, réseaux sociaux)
- ✅ Partage de contenu via liens directs
- ✅ Gestion automatique de l'authentification
- ✅ Back button handling natif
- ✅ Navigation typée et sécurisée

---

## ⚙️ Configuration

### 1. AndroidManifest.xml
```xml
<!-- Déjà configuré dans android/app/src/main/AndroidManifest.xml -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="buyv"/>
</intent-filter>
```

### 2. Info.plist (iOS)
```xml
<!-- Déjà configuré dans ios/Runner/Info.plist -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>buyv</string>
        </array>
    </dict>
</array>
```

### 3. Dependencies
```yaml
# pubspec.yaml
dependencies:
  go_router: ^16.2.4  # ✅ Déjà installé
```

---

## 🗺️ Routes Disponibles

### Routes Principales

| Route | Description | Authentification |
|-------|-------------|------------------|
| `/` | Splash Screen | Non |
| `/onboarding` | Onboarding | Non |
| `/login` | Login | Non |
| `/signup` | Sign Up | Non |
| `/register` | Register | Non |
| `/home` | Home Feed | Oui |
| `/reels` | Reels Screen | Oui |
| `/shop` | Shop | Oui |
| `/cart` | Shopping Cart | Oui |
| `/profile` | Mon Profil | Oui |
| `/edit-profile` | Éditer Profil | Oui |
| `/add-post` | Ajouter Post | Oui |
| `/search` | Recherche | Oui |
| `/notifications` | Notifications | Oui |
| `/settings` | Paramètres | Oui |
| `/orders-history` | Historique Commandes | Oui |
| `/payment` | Paiement | Oui |

### Routes Dynamiques (Deep Links)

| Route Pattern | Exemple | Description |
|--------------|---------|-------------|
| `/post/:uid` | `/post/abc123` | Afficher un post |
| `/user/:uid` | `/user/user123` | Afficher profil utilisateur |
| `/product/:id` | `/product/prod456?name=Shirt&price=29.99` | Afficher produit |

---

## 🔗 Deep Links Supportés

### 1. **Post Deep Link**

**URL:** `buyv://post/{postId}`

**Exemple:**
```
buyv://post/p_1234567890
```

**Résultat:** Ouvre l'écran de détail du post avec ID `p_1234567890`

**Code pour créer le lien:**
```dart
import 'package:buyv_flutter_app/services/deep_link_handler.dart';

final link = DeepLinkHandler.createPostDeepLink('p_1234567890');
// Résultat: "buyv://post/p_1234567890"
```

---

### 2. **User Profile Deep Link**

**URL:** `buyv://user/{userId}`

**Exemple:**
```
buyv://user/johndoe
```

**Résultat:** Ouvre le profil de l'utilisateur `johndoe`

**Code pour créer le lien:**
```dart
final link = DeepLinkHandler.createUserDeepLink('johndoe');
// Résultat: "buyv://user/johndoe"
```

---

### 3. **Product Deep Link**

**URL:** `buyv://product/{productId}?name=...&price=...&image=...&category=...`

**Exemple:**
```
buyv://product/prod_789?name=T-Shirt&price=29.99&category=Clothing
```

**Résultat:** Ouvre la page produit avec détails

**Code pour créer le lien:**
```dart
final link = DeepLinkHandler.createProductDeepLink(
  'prod_789',
  name: 'T-Shirt',
  price: 29.99,
  category: 'Clothing',
  image: 'https://example.com/image.jpg',
);
// Résultat: "buyv://product/prod_789?name=T-Shirt&price=29.99&category=Clothing&image=..."
```

---

### 4. **Navigation Screens**

| Deep Link | Action |
|-----------|--------|
| `buyv://home` | Aller à l'accueil |
| `buyv://profile` | Aller au profil |
| `buyv://shop` | Aller à la boutique |
| `buyv://cart` | Aller au panier |
| `buyv://reels` | Aller aux reels |
| `buyv://search` | Aller à la recherche |
| `buyv://notifications` | Aller aux notifications |
| `buyv://orders-history` | Aller à l'historique |
| `buyv://settings` | Aller aux paramètres |

---

## 💻 Utilisation dans le Code

### Navigation Programmatique

#### Méthode 1 : GoRouter (Recommandé)
```dart
import 'package:go_router/go_router.dart';

// Navigation simple
context.go('/home');

// Navigation avec paramètres
context.go('/post/abc123');

// Navigation avec query params
context.go('/product/prod123?name=Shirt&price=29.99');

// Navigation push (garde historique)
context.push('/user/johndoe');

// Navigation avec remplacement
context.replace('/login');

// Retour arrière
context.pop();
```

#### Méthode 2 : Named Routes
```dart
import 'package:go_router/go_router.dart';

context.goNamed('home');
context.goNamed('post-detail', pathParameters: {'uid': 'abc123'});
context.pushNamed('user-detail', pathParameters: {'uid': 'johndoe'});
```

### Partager un Deep Link

```dart
import 'package:share_plus/share_plus.dart';
import 'package:buyv_flutter_app/services/deep_link_handler.dart';

// Partager un post
void sharePost(String postId) {
  final deepLink = DeepLinkHandler.createPostDeepLink(postId);
  Share.share('Check out this post: $deepLink');
}

// Partager un profil utilisateur
void shareUserProfile(String userId) {
  final deepLink = DeepLinkHandler.createUserDeepLink(userId);
  Share.share('Follow @$userId on BuyV: $deepLink');
}

// Partager un produit
void shareProduct(String productId, String productName, double price) {
  final deepLink = DeepLinkHandler.createProductDeepLink(
    productId,
    name: productName,
    price: price,
  );
  Share.share('Check out $productName for \$$price: $deepLink');
}
```

### Gérer un Deep Link Manuellement

```dart
import 'package:buyv_flutter_app/services/deep_link_handler.dart';

// Dans un widget ou service
void handleIncomingLink(String url) {
  final uri = Uri.parse(url);
  
  if (DeepLinkHandler.isValidDeepLink(uri)) {
    DeepLinkHandler.handleDeepLink(context, uri);
  } else {
    print('Invalid deep link: $url');
  }
}
```

---

## 🧪 Tests

### Test 1 : Navigation Interne

```dart
// Dans votre code
ElevatedButton(
  onPressed: () => context.go('/post/test123'),
  child: const Text('Go to Post'),
)
```

### Test 2 : Deep Link depuis Terminal (Android)

```bash
# Ouvrir un post
adb shell am start -W -a android.intent.action.VIEW -d "buyv://post/abc123" com.buyv.app

# Ouvrir un profil utilisateur
adb shell am start -W -a android.intent.action.VIEW -d "buyv://user/johndoe" com.buyv.app

# Ouvrir un produit
adb shell am start -W -a android.intent.action.VIEW -d "buyv://product/prod123?name=Shirt&price=29.99" com.buyv.app

# Ouvrir l'accueil
adb shell am start -W -a android.intent.action.VIEW -d "buyv://home" com.buyv.app
```

### Test 3 : Deep Link depuis Terminal (iOS Simulator)

```bash
# Ouvrir un post
xcrun simctl openurl booted "buyv://post/abc123"

# Ouvrir un profil
xcrun simctl openurl booted "buyv://user/johndoe"

# Ouvrir un produit
xcrun simctl openurl booted "buyv://product/prod123"
```

### Test 4 : QR Code

1. Générer un QR code avec le lien : `buyv://post/test123`
2. Scanner le QR code avec votre téléphone
3. L'app devrait s'ouvrir sur le post

**Générateur de QR Code:** https://www.qr-code-generator.com/

---

## 🔍 Debugging

### Activer les Logs

Les logs de navigation sont déjà activés dans `app_router.dart` :

```dart
GoRouter(
  debugLogDiagnostics: true,  // ✅ Activé
  // ...
)
```

### Logs Deep Link

```dart
// Dans deep_link_handler.dart
debugPrint('🔗 Deep Link received: ${uri.toString()}');
debugPrint('✅ Navigated to post: $postId');
debugPrint('⚠️ Unhandled deep link path: $path');
debugPrint('❌ Error handling deep link: $e');
```

### Vérifier l'État de la Navigation

```dart
import 'package:go_router/go_router.dart';

// Dans un widget
final currentRoute = GoRouterState.of(context).matchedLocation;
print('Current route: $currentRoute');
```

---

## ⚠️ Troubleshooting

### Problème 1 : Deep Link ne fonctionne pas

**Solution:**
1. Vérifier AndroidManifest.xml et Info.plist
2. Réinstaller l'app : `flutter clean && flutter run`
3. Vérifier les logs : `flutter logs`

### Problème 2 : Navigation ne fonctionne pas

**Solution:**
```dart
// Utiliser BuildContext correct
Builder(
  builder: (context) {
    return ElevatedButton(
      onPressed: () => context.go('/home'),
      child: const Text('Home'),
    );
  },
)
```

### Problème 3 : Erreur "Page not found"

**Solution:**
Vérifier que la route existe dans `app_router.dart` et que le path est correct.

### Problème 4 : Authentification bloque la navigation

**Solution:**
Les routes nécessitant authentification redirigent vers `/login`. Vérifier `AuthProvider.isAuthenticated`.

---

## 🎨 Bonnes Pratiques

### 1. Toujours Utiliser context.go() ou context.push()

```dart
// ✅ BON
context.go('/home');

// ❌ MAUVAIS (ancien système)
Navigator.pushNamed(context, '/home');
```

### 2. Utiliser RouteNames pour éviter les typos

```dart
import 'package:buyv_flutter_app/core/router/route_names.dart';

// ✅ BON
context.go(RouteNames.home);

// ❌ RISQUÉ
context.go('/home');  // Typo possible
```

### 3. Vérifier l'Authentification

```dart
// Le router gère déjà la redirection automatique
// Pas besoin de vérifier manuellement dans chaque écran
```

### 4. Partager avec Deep Links

```dart
// Toujours utiliser DeepLinkHandler pour créer des liens
final link = DeepLinkHandler.createPostDeepLink(postId);
Share.share(link);
```

---

## 🚀 Prochaines Étapes

- [ ] Ajouter des analytics pour tracker les deep links
- [ ] Implémenter Universal Links (https://buyv.app/...)
- [ ] Ajouter des deep links pour les orders et commissions
- [ ] Créer un dashboard admin pour voir les stats de deep links
- [ ] Implémenter le deferred deep linking

---

## 📚 Ressources

- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Flutter Deep Linking](https://docs.flutter.dev/development/ui/navigation/deep-linking)
- [Android App Links](https://developer.android.com/training/app-links)
- [iOS Universal Links](https://developer.apple.com/ios/universal-links/)

---

**Status:** ✅ Production Ready  
**Version:** 1.0.0  
**Date:** 26 Décembre 2025
