import 'package:buyv_flutter_app/core/config/environment_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Constantes globales de l'application
class AppConstants {
  // ═══════════════════════════════════════════════════════════════════
  // 📱 INFORMATIONS DE L'APPLICATION
  // ═══════════════════════════════════════════════════════════════════
  
  static const String appName = 'BuyV';
  static const String appVersion = '1.0.0';

  // ═══════════════════════════════════════════════════════════════════
  // 🔥 COLLECTIONS FIREBASE (si vous utilisez Firebase)
  // ═══════════════════════════════════════════════════════════════════
  
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String reelsCollection = 'reels';
  static const String ordersCollection = 'orders';
  static const String categoriesCollection = 'categories';
  static const String notificationsCollection = 'notifications';
  static const String commentsCollection = 'comments';
  static const String likesCollection = 'likes';
  static const String followsCollection = 'follows';

  // ═══════════════════════════════════════════════════════════════════
  // ☁️ CONFIGURATION CLOUDINARY (Upload d'images/vidéos)
  // ═══════════════════════════════════════════════════════════════════
  
  /// Nom du cloud Cloudinary
  /// Trouvez-le sur : https://console.cloudinary.com/console/
  static String cloudinaryCloudName =
      dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? 'dhzllfeno';
  
  /// Preset d'upload non signé
  /// Créez-en un sur : Settings > Upload > Upload presets
  static String cloudinaryUploadPreset =
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'Ecommerce_BuyV';
  
  // Note : Pas besoin de clés API pour les uploads non signés

  // ═══════════════════════════════════════════════════════════════════
  // 💾 CLÉS SHARED PREFERENCES (Stockage local)
  // ═══════════════════════════════════════════════════════════════════
  
  static const String userIdKey = 'user_id';
  static const String userTokenKey = 'user_token';
  static const String isLoggedInKey = 'is_logged_in';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  // ═══════════════════════════════════════════════════════════════════
  // 🌐 ENDPOINTS API
  // ═══════════════════════════════════════════════════════════════════
  
  /// URL de base de l'API (legacy - à supprimer si non utilisé)
  @Deprecated('Utilisez fastApiBaseUrl à la place')
  static const String baseUrl = 'https://api.buyv.com';
  
  /// URL du backend FastAPI (dynamique selon environnement)
  static String get fastApiBaseUrl => EnvironmentConfig.fastApiBaseUrl;

  // ═══════════════════════════════════════════════════════════════════
  // 🛒 CONFIGURATION CJ DROPSHIPPING
  // ═══════════════════════════════════════════════════════════════════
  
  /// URL de base pour l'API CJ (via proxy CORS)
  static String get cjBaseUrl => EnvironmentConfig.cjBaseUrl;
  
  /// Clé API CJ Dropshipping
  /// Obtenez-la sur : https://cj-market.cjdropshipping.com/
  /// Login > Settings > API > Generate API Key
  static String cjApiKey = dotenv.env['CJ_API_KEY'] ?? '';
  
  /// ID du compte CJ (alternative à l'email)
  static String cjAccount = dotenv.env['CJ_ACCOUNT_ID'] ?? '';
  
  /// Email du compte CJ
  static String cjEmail = dotenv.env['CJ_EMAIL'] ?? '';

  // ═══════════════════════════════════════════════════════════════════
  // 📄 PAGINATION
  // ═══════════════════════════════════════════════════════════════════
  
  static const int pageSize = 20;
  static const int reelsPageSize = 10;

  // ═══════════════════════════════════════════════════════════════════
  // 🎥 PARAMÈTRES VIDÉO
  // ═══════════════════════════════════════════════════════════════════
  
  /// Durée maximale d'une vidéo (en secondes)
  static const int maxVideoLength = 60;
  
  /// Taille maximale d'une vidéo (en MB)
  static const int maxVideoSize = 50;

  // ═══════════════════════════════════════════════════════════════════
  // 🖼️ PARAMÈTRES IMAGE
  // ═══════════════════════════════════════════════════════════════════
  
  /// Taille maximale d'une image (en MB)
  static const int maxImageSize = 10;
  
  /// Formats d'image autorisés
  static const List<String> allowedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  // ═══════════════════════════════════════════════════════════════════
  // 👥 FONCTIONNALITÉS SOCIALES
  // ═══════════════════════════════════════════════════════════════════
  
  /// Longueur maximale d'un commentaire
  static const int maxCommentLength = 500;
  
  /// Longueur maximale de la bio utilisateur
  static const int maxBioLength = 150;
  
  /// Longueur maximale du nom d'utilisateur
  static const int maxUsernameLength = 30;

  // ═══════════════════════════════════════════════════════════════════
  // 🛍️ E-COMMERCE
  // ═══════════════════════════════════════════════════════════════════
  
  /// Montant minimum d'une commande
  static const double minOrderAmount = 10.0;
  
  /// Montant maximum d'une commande
  static const double maxOrderAmount = 10000.0;
  
  /// Nombre maximum d'articles dans le panier
  static const int maxCartItems = 50;

  // ═══════════════════════════════════════════════════════════════════
  // 🔔 TYPES DE NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════════════
  
  static const String orderNotification = 'order';
  static const String socialNotification = 'social';
  static const String promotionNotification = 'promotion';
  static const String securityNotification = 'security';
  static const String appUpdateNotification = 'app_update';
  static const String generalNotification = 'general';
  
  // ═══════════════════════════════════════════════════════════════════
  // 🔍 HELPERS DE DEBUG
  // ═══════════════════════════════════════════════════════════════════
  
  /// Affiche les constantes principales
  static void printConstants() {
    if (EnvironmentConfig.isDebugMode) {
      print('════════════════════════════════════════');
      print('📱 CONSTANTES APPLICATION');
      print('════════════════════════════════════════');
      print('App : $appName v$appVersion');
      print('FastAPI : $fastApiBaseUrl');
      print('CJ API : $cjBaseUrl');
      print('Cloudinary : $cloudinaryCloudName');
      print('CJ API Key : ${cjApiKey.isNotEmpty ? "✅ Configurée" : "❌ Manquante"}');
      print('════════════════════════════════════════');
    }
  }
}
