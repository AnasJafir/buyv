import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'data/repositories/auth_repository_fastapi.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/cart_provider.dart';
import 'data/providers/product_provider.dart';
import 'data/providers/user_provider.dart';
import 'data/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'services/secure_storage_service.dart';
import 'services/security_audit_service.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load Environment Variables
    await dotenv.load(fileName: ".env");
    debugPrint('✅ Environment variables loaded');

    // Initialize Stripe
    final stripeKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
    if (stripeKey != null && stripeKey.isNotEmpty) {
      Stripe.publishableKey = stripeKey;
      Stripe.merchantIdentifier = 'BuyV';
      await Stripe.instance.applySettings();
      debugPrint('✅ Stripe initialized');
    } else {
      debugPrint('⚠️ Stripe key not found, skipping Stripe initialization');
    }
  } catch (e) {
    debugPrint('❌ Error during initialization: $e');
  }

  // تهيئة Hive للتخزين المحلي
  await Hive.initFlutter();

  // تهيئة الخدمات الأمنية
  try {
    await SecureStorageService.initialize();

    // تشغيل مراجعة أمنية أولية
    final auditReport = await SecurityAuditService.performSecurityAudit();
    if (auditReport.overallScore < 70) {
      debugPrint(
        '⚠️ Security audit warning: Score ${auditReport.overallScore}/100',
      );
      debugPrint('Risk level: ${auditReport.riskLevel}');
    } else {
      debugPrint(
        '✅ Security audit passed: Score ${auditReport.overallScore}/100',
      );
    }
  } catch (e) {
    debugPrint('❌ Security services initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final authRepo = AuthRepositoryFastApi();
            return AuthProvider(authRepo);
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final provider = CartProvider();
            provider.loadCart();
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter.getRouter(context);
          
          return MaterialApp.router(
            title: 'BuyV E-commerce',
            theme: AppTheme.lightTheme,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
