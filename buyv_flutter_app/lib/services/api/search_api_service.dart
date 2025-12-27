import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants/app_constants.dart';
import '../security/secure_token_manager.dart';

class SearchApiService {
  static Uri _url(String path) =>
      Uri.parse('${AppConstants.fastApiBaseUrl}$path');

  static Future<Map<String, String>> _authHeaders() async {
    final token = await SecureTokenManager.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Map<String, dynamic> _parse(http.Response res) {
    final ok = res.statusCode >= 200 && res.statusCode < 300;
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (!ok) {
      final detail = body is Map && body['detail'] != null
          ? body['detail'].toString()
          : 'Request failed (${res.statusCode})';
      throw Exception(detail);
    }
    return body is Map<String, dynamic> ? body : {'data': body};
  }

  static List<Map<String, dynamic>> _parseList(http.Response res) {
    final ok = res.statusCode >= 200 && res.statusCode < 300;
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : [];
    if (!ok) {
      final msg = body is Map && body['detail'] != null
          ? body['detail'].toString()
          : 'Request failed (${res.statusCode})';
      throw Exception(msg);
    }
    if (body is List) {
      return List<Map<String, dynamic>>.from(
        body.map((e) => Map<String, dynamic>.from(e)),
      );
    }
    return [];
  }

  /// Search users by username or display name
  static Future<List<Map<String, dynamic>>> searchUsers({
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    final queryParams = {
      'q': query,
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    final uri = _url('/users/search').replace(queryParameters: queryParams);
    
    final res = await http.get(uri, headers: await _authHeaders());
    return _parseList(res);
  }

  /// Search posts by caption
  static Future<List<Map<String, dynamic>>> searchPosts({
    required String query,
    String? type, // 'reel', 'product', 'photo'
    int limit = 20,
    int offset = 0,
  }) async {
    final queryParams = {
      'q': query,
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (type != null && type.isNotEmpty) {
      queryParams['type'] = type;
    }
    final uri = _url('/posts/search').replace(queryParameters: queryParams);
    
    final res = await http.get(uri, headers: await _authHeaders());
    return _parseList(res);
  }
}

