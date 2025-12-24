import 'dart:io';
import 'package:flutter/foundation.dart';

class EnvironmentConfig {
  // Production Railway URL
  static const String _productionUrl = 'https://buyv-production.up.railway.app';

  static String get fastApiBaseUrl {
    // Return production URL for all platforms
    return _productionUrl;
  }

  static String get cjBaseUrl {
    const String path = '/api/cj';
    if (kIsWeb) return 'http://127.0.0.1:3001$path';
    if (Platform.isAndroid) return 'http://10.0.2.2:3001$path';
    if (Platform.isIOS) return 'http://localhost:3001$path';
    return 'http://192.168.1.100:3001$path'; // Update as needed
  }
}
