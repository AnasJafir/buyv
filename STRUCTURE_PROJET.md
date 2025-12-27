# 📁 Structure du Projet BuyV

## 🌳 Arborescence Complète

```
E-commerce-master -new-full 2/
│
├── 📄 Documentation & Configuration
│   ├── LICENSE                            # Licence du projet│
├── 🔧 Configuration Projet
│   ├── build.gradle.kts                   # Configuration Gradle racine
│   ├── settings.gradle.kts                # Settings Gradle
│   ├── gradle.properties                  # Propriétés Gradle
│   ├── gradlew / gradlew.bat              # Wrapper Gradle
│   ├── gradle/wrapper/                    # Gradle wrapper
│   ├── local.properties                   # Propriétés locales
│   └── package-lock.json                  # Lock npm
│
├── 🐍 buyv_backend/                       # Backend FastAPI (Python)
│   ├── app/                               # Code source backend
│   │   ├── __pycache__/                  # Cache Python
│   │   ├── main.py                       # Point d'entrée FastAPI
│   │   ├── config.py                      # Configuration (env vars)
│   │   ├── database.py                   # Configuration SQLAlchemy
│   │   ├── models.py                     # Modèles SQLAlchemy (DB)
│   │   ├── schemas.py                    # Schémas Pydantic (API)
│   │   ├── auth.py                       # Authentification JWT
│   │   ├── users.py                      # Endpoints utilisateurs
│   │   ├── posts.py                       # Endpoints posts/reels
│   │   ├── comments.py                   # Endpoints commentaires
│   │   ├── orders.py                      # Endpoints commandes
│   │   ├── payments.py                    # Endpoints Stripe
│   │   ├── commissions.py                 # Endpoints commissions
│   │   ├── follows.py                     # Endpoints follow/unfollow
│   │   └── notifications.py              # Endpoints notifications
│   ├── buyv.db                           # Base de données SQLite (dev)
│   ├── requirements.txt                  # Dépendances Python
│   ├── Dockerfile                        # Docker pour déploiement
│   └── run_backend.bat                   # Script démarrage Windows
│
├── 📱 buyv_flutter_app/                   # Application Flutter (Frontend principal)
│   │
│   ├── 📄 Configuration
│   │   ├── pubspec.yaml                  # Dépendances Flutter
│   │   ├── pubspec.lock                  # Lock des dépendances
│   │   ├── analysis_options.yaml         # Options d'analyse Dart
│   │   ├── devtools_options.yaml         # Options DevTools
│   │   ├── package.json / package-lock.json # npm (pour proxy CORS)
│   │   └── README.md                     # Documentation Flutter
│   │
│   ├── 📂 lib/                           # Code source Dart
│   │   ├── main.dart                     # Point d'entrée application
│   │   │
│   │   ├── constants/                    # Constantes
│   │   │   └── app_constants.dart        # Constantes de l'app
│   │   │
│   │   ├── core/                         # Configuration core
│   │   │   ├── config/
│   │   │   │   └── environment_config.dart # Config environnement
│   │   │   ├── localization/
│   │   │   │   └── app_localizations.dart   # Localisation
│   │   │   └── theme/
│   │   │       └── app_theme.dart           # Thème Material3
│   │   │
│   │   ├── domain/                       # Modèles métier (Clean Architecture)
│   │   │   └── models/
│   │   │       ├── cart_model.dart
│   │   │       ├── cj_product_model.dart
│   │   │       ├── comment_model.dart
│   │   │       ├── order_model.dart
│   │   │       ├── product_model.dart
│   │   │       ├── reel_model.dart
│   │   │       ├── user_model.dart
│   │   │       └── user_profile_model.dart
│   │   │
│   │   ├── data/                         # Couche données
│   │   │   ├── models/                   # Modèles de données
│   │   │   │   ├── commission_model.dart
│   │   │   │   ├── notification_model.dart
│   │   │   │   ├── order_model.dart
│   │   │   │   └── post_model.dart
│   │   │   ├── providers/               # Providers (state management)
│   │   │   │   ├── product_provider.dart
│   │   │   │   ├── theme_provider.dart
│   │   │   │   └── user_provider.dart
│   │   │   ├── repositories/            # Repositories
│   │   │   │   └── auth_repository_fastapi.dart
│   │   │   └── services/                # Services de données
│   │   │       ├── commission_service.dart
│   │   │       └── order_service.dart
│   │   │
│   │   ├── presentation/                # Couche présentation (UI)
│   │   │   ├── providers/               # Providers UI
│   │   │   │   ├── auth_provider.dart
│   │   │   │   ├── cart_provider.dart
│   │   │   │   └── locale_provider.dart
│   │   │   ├── screens/                 # Écrans de l'application
│   │   │   │   ├── auth/                # Authentification
│   │   │   │   │   ├── login_screen.dart
│   │   │   │   │   ├── register_screen.dart
│   │   │   │   │   └── signup_screen.dart
│   │   │   │   ├── cart/                # Panier
│   │   │   │   │   └── cart_screen.dart
│   │   │   │   ├── earnings/            # Gains/Commissions
│   │   │   │   │   └── earnings_screen.dart
│   │   │   │   ├── feed_screen.dart     # Feed principal
│   │   │   │   ├── help/                # Aide
│   │   │   │   │   └── help_screen.dart
│   │   │   │   ├── home/                # Accueil
│   │   │   │   │   └── home_screen.dart
│   │   │   │   ├── notifications/      # Notifications
│   │   │   │   │   └── notifications_screen.dart
│   │   │   │   ├── onboarding/          # Onboarding
│   │   │   │   │   └── onboarding_screen.dart
│   │   │   │   ├── orders/              # Commandes
│   │   │   │   │   ├── orders_history_screen.dart
│   │   │   │   │   └── orders_track_screen.dart
│   │   │   │   ├── payment/             # Paiements
│   │   │   │   │   ├── payment_methods_screen.dart
│   │   │   │   │   └── payment_screen.dart
│   │   │   │   ├── products/           # Produits
│   │   │   │   │   ├── product_detail_screen.dart
│   │   │   │   │   └── recently_viewed_screen.dart
│   │   │   │   ├── profile/            # Profil utilisateur
│   │   │   │   │   ├── add_post_screen.dart
│   │   │   │   │   ├── edit_profile_screen.dart
│   │   │   │   │   ├── follow_list_screen.dart
│   │   │   │   │   ├── other_user_profile_screen.dart
│   │   │   │   │   ├── profile_screen.dart
│   │   │   │   │   ├── settings_screen.dart
│   │   │   │   │   └── share_profile_screen.dart
│   │   │   │   ├── reels/              # Reels (TikTok-style)
│   │   │   │   │   ├── reels_screen.dart
│   │   │   │   │   └── search_reels_screen.dart
│   │   │   │   ├── search/            # Recherche
│   │   │   │   │   └── search_screen.dart
│   │   │   │   ├── settings/          # Paramètres
│   │   │   │   │   ├── change_password_screen.dart
│   │   │   │   │   ├── language_settings_screen.dart
│   │   │   │   │   ├── location_settings_screen.dart
│   │   │   │   │   └── settings_screen.dart
│   │   │   │   ├── shop/             # Boutique
│   │   │   │   │   ├── cj_products_grid.dart
│   │   │   │   │   ├── product_promotion_screen.dart
│   │   │   │   │   └── shop_screen.dart
│   │   │   │   └── splash/           # Splash screen
│   │   │   │       └── splash_screen.dart
│   │   │   └── widgets/              # Widgets réutilisables
│   │   │       ├── buy_bottom_sheet.dart
│   │   │       ├── custom_button.dart
│   │   │       ├── custom_text_field.dart
│   │   │       ├── post_card_widget.dart
│   │   │       ├── reel_interactions.dart
│   │   │       ├── reel_video_player.dart
│   │   │       ├── require_login_prompt.dart
│   │   │       ├── social_login_button.dart
│   │   │       └── video_player_widget.dart
│   │   │
│   │   └── services/                 # Services métier
│   │       ├── api/                  # Services API
│   │       │   ├── comment_api_service.dart
│   │       │   ├── commission_api_service.dart
│   │       │   ├── notification_api_service.dart
│   │       │   └── order_api_service.dart
│   │       ├── security/            # Services sécurité
│   │       │   ├── api_security_service.dart
│   │       │   ├── cj_token_manager.dart
│   │       │   ├── data_encryption_service.dart
│   │       │   └── secure_token_manager.dart
│   │       ├── auth_api_service.dart
│   │       ├── cj_dropshipping_service.dart
│   │       ├── cloudinary_service.dart
│   │       ├── follow_api_service.dart
│   │       ├── follow_service.dart
│   │       ├── notification_service.dart
│   │       ├── post_api_service.dart
│   │       ├── post_service.dart
│   │       ├── secure_storage_service.dart
│   │       ├── security_audit_service.dart
│   │       ├── stripe_service.dart
│   │       └── user_service.dart
│   │
│   ├── 📂 assets/                    # Ressources statiques
│   │   ├── icons/                    # Icônes (39 fichiers PNG)
│   │   ├── images/                   # Images (103 fichiers)
│   │   └── videos/                   # Vidéos
│   │
│   ├── 📂 android/                   # Configuration Android
│   │   ├── app/
│   │   │   ├── build.gradle.kts      # Build config app
│   │   │   └── src/
│   │   │       └── main/
│   │   │           ├── AndroidManifest.xml
│   │   │           └── kotlin/       # Code Kotlin natif
│   │   ├── build.gradle.kts          # Build config racine
│   │   ├── settings.gradle.kts       # Settings Gradle
│   │   ├── gradle.properties         # Propriétés Gradle
│   │   ├── gradlew / gradlew.bat     # Gradle wrapper
│   │   └── gradle/wrapper/           # Gradle wrapper files
│   │
│   ├── 📂 ios/                       # Configuration iOS
│   │   ├── Flutter/                  # Config Flutter iOS
│   │   ├── Runner/                   # App iOS
│   │   │   ├── AppDelegate.swift
│   │   │   ├── Info.plist            # Deep linking config
│   │   │   └── Assets.xcassets/
│   │   └── Runner.xcodeproj/         # Projet Xcode
│   │
│   ├── 📂 web/                       # Configuration Web
│   │   ├── index.html
│   │   ├── manifest.json
│   │   └── icons/
│   │
│   ├── 📂 windows/                   # Configuration Windows
│   ├── 📂 linux/                     # Configuration Linux
│   ├── 📂 macos/                     # Configuration macOS
│   │
│   ├── 📂 test/                      # Tests unitaires
│   │
│   └── 🔧 Fichiers utilitaires
│       ├── cors_proxy_server.*       # Serveur proxy CORS (dart/js/py)
│       ├── start_proxy.bat           # Script démarrage proxy
│       └── test_*.dart               # Fichiers de test API
│
├── 📱 e-commerceAndroidApp/          # App Android native (Kotlin)
│   ├── build.gradle.kts             # Build config
│   ├── google-services.json          # Firebase config
│   └── src/
│       └── main/
│           ├── AndroidManifest.xml
│           ├── java/com/...          # Code Kotlin (153 fichiers)
│           └── res/                  # Ressources Android
│               ├── drawable/         # Images (100 fichiers)
│               ├── mipmap-*/         # Icônes launcher
│               └── values/           # Strings, colors, etc.
│
├── 📱 e-commerceiosApp/              # App iOS native (Swift)
│   └── e-commerceiosApp/
│       ├── iOSApp.swift
│       ├── ContentView.swift
│       └── Info.plist
│
└── 🔗 shared/                        # Code partagé KMM (Kotlin Multiplatform)
    ├── build.gradle.kts
    └── src/
        ├── commonMain/               # Code commun
        ├── androidMain/              # Code Android
        └── iosMain/                   # Code iOS
```

---

## 📊 Statistiques du Projet

### Backend (Python FastAPI)
- **Fichiers Python:** 13 fichiers principaux
- **Base de données:** SQLite (dev) / MySQL (prod)
- **Endpoints:** 9 modules (auth, users, posts, comments, orders, payments, etc.)

### Frontend Flutter
- **Fichiers Dart:** ~100+ fichiers
- **Écrans:** 34 écrans
- **Widgets:** 9 widgets réutilisables
- **Services:** 20+ services
- **Modèles:** 15+ modèles

### Android Native (Kotlin)
- **Fichiers Kotlin:** 153 fichiers
- **Architecture:** Clean Architecture + MVVM
- **UI:** Jetpack Compose

### iOS Native (Swift)
- **Fichiers Swift:** 2 fichiers principaux
- **Structure:** Prête pour développement

---

## 🎯 Points Clés de l'Architecture

### Backend
- **Framework:** FastAPI
- **ORM:** SQLAlchemy
- **Base de données:** SQLite (dev) / MySQL (prod)
- **Authentification:** JWT (python-jose)
- **Paiements:** Stripe
- **Médias:** Cloudinary

### Frontend Flutter (Principal)
- **Architecture:** Clean Architecture
- **State Management:** Provider
- **Navigation:** Go Router
- **Video:** cached_video_player
- **Paiements:** flutter_stripe
- **Stockage:** flutter_secure_storage

### Android Native (Alternative)
- **Langage:** Kotlin
- **UI:** Jetpack Compose
- **Architecture:** MVVM + Clean Architecture
- **DI:** Koin
- **Backend:** Firebase (Auth, Firestore, FCM)

---

## 📁 Dossiers Importants

### Configuration
- `buyv_backend/.env` - Variables d'environnement backend
- `buyv_flutter_app/.env` - Variables d'environnement Flutter
- `buyv_flutter_app/pubspec.yaml` - Dépendances Flutter

### Documentation
- `README.md` - Documentation principale
- `DIAGNOSTIC_PRE_DEMO.md` - Diagnostic complet
- `GUIDE_TEST_EMULATEUR.md` - Guide de test

### Base de données
- `buyv_backend/buyv.db` - Base SQLite (développement)

---

## 🔄 Flux de Données

```
Flutter App (buyv_flutter_app)
    ↓ HTTP/REST
FastAPI Backend (buyv_backend)
    ↓ SQLAlchemy
SQLite/MySQL Database
```

**Alternative:**
```
Android Native App (e-commerceAndroidApp)
    ↓ Firebase SDK
Firebase (Auth, Firestore, FCM)
```

---

**📝 Note:** Cette structure montre un projet multi-plateforme avec:
- **Backend unique:** FastAPI (Python)
- **Frontend principal:** Flutter (cross-platform)
- **Frontend alternatif:** Android native (Kotlin) + iOS native (Swift)

