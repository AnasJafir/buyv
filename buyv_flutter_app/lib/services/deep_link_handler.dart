import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Service to handle deep links from different sources
/// Supports: buyv://, https://buyv.app, etc.
class DeepLinkHandler {
  /// Parse and navigate based on deep link URI
  static Future<void> handleDeepLink(BuildContext context, Uri uri) async {
    debugPrint('🔗 Deep Link received: ${uri.toString()}');

    // Extract path and parameters
    final path = uri.path;
    final queryParams = uri.queryParameters;

    try {
      // Handle different deep link patterns
      if (path.startsWith('/post/')) {
        // Deep link to post: buyv://post/abc123
        final postId = path.replaceFirst('/post/', '');
        if (postId.isNotEmpty) {
          context.go('/post/$postId');
          debugPrint('✅ Navigated to post: $postId');
        }
      } else if (path.startsWith('/user/')) {
        // Deep link to user: buyv://user/user123
        final userId = path.replaceFirst('/user/', '');
        if (userId.isNotEmpty) {
          context.go('/user/$userId');
          debugPrint('✅ Navigated to user: $userId');
        }
      } else if (path.startsWith('/product/')) {
        // Deep link to product: buyv://product/prod123?name=Shirt&price=29.99
        final productId = path.replaceFirst('/product/', '');
        if (productId.isNotEmpty) {
          final productName = queryParams['name'] ?? 'Product';
          final productImage = queryParams['image'] ?? '';
          final priceStr = queryParams['price'] ?? '0.0';
          final category = queryParams['category'] ?? 'General';
          final price = double.tryParse(priceStr) ?? 0.0;

          context.go(
            '/product/$productId?name=$productName&image=$productImage&price=$price&category=$category',
          );
          debugPrint('✅ Navigated to product: $productId');
        }
      } else if (path == '/home' || path == '/') {
        // Deep link to home
        context.go('/home');
        debugPrint('✅ Navigated to home');
      } else if (path == '/profile') {
        context.go('/profile');
        debugPrint('✅ Navigated to profile');
      } else if (path == '/shop') {
        context.go('/shop');
        debugPrint('✅ Navigated to shop');
      } else if (path == '/cart') {
        context.go('/cart');
        debugPrint('✅ Navigated to cart');
      } else if (path == '/reels') {
        context.go('/reels');
        debugPrint('✅ Navigated to reels');
      } else if (path == '/search') {
        context.go('/search');
        debugPrint('✅ Navigated to search');
      } else if (path == '/notifications') {
        context.go('/notifications');
        debugPrint('✅ Navigated to notifications');
      } else if (path == '/orders-history') {
        context.go('/orders-history');
        debugPrint('✅ Navigated to orders history');
      } else if (path == '/settings') {
        context.go('/settings');
        debugPrint('✅ Navigated to settings');
      } else {
        debugPrint('⚠️ Unhandled deep link path: $path');
        // Navigate to home as fallback
        context.go('/home');
      }
    } catch (e) {
      debugPrint('❌ Error handling deep link: $e');
      // Navigate to home on error
      context.go('/home');
    }
  }

  /// Convert internal route to deep link URL
  static String createDeepLink(String route, {Map<String, String>? params}) {
    final baseUrl = 'buyv:/';
    
    if (params != null && params.isNotEmpty) {
      final queryString = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      return '$baseUrl$route?$queryString';
    }
    
    return '$baseUrl$route';
  }

  /// Create shareable deep link for a post
  static String createPostDeepLink(String postId) {
    return createDeepLink('/post/$postId');
  }

  /// Create shareable deep link for a user
  static String createUserDeepLink(String userId) {
    return createDeepLink('/user/$userId');
  }

  /// Create shareable deep link for a product
  static String createProductDeepLink(
    String productId, {
    String? name,
    String? image,
    double? price,
    String? category,
  }) {
    final params = <String, String>{};
    if (name != null) params['name'] = name;
    if (image != null) params['image'] = image;
    if (price != null) params['price'] = price.toString();
    if (category != null) params['category'] = category;
    
    return createDeepLink('/product/$productId', params: params);
  }

  /// Check if URI is a valid deep link
  static bool isValidDeepLink(Uri uri) {
    return uri.scheme == 'buyv' || 
           uri.scheme == 'https' && uri.host.contains('buyv');
  }

  /// Extract route from deep link
  static String? extractRoute(Uri uri) {
    if (!isValidDeepLink(uri)) return null;
    return uri.path;
  }
}
