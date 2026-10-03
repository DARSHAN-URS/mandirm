import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

/// Central API service that connects the consumer app to the Mandirm FastAPI backend.
///
/// Uses Dio for HTTP with automatic JWT token injection.
/// Falls back to an empty/mock response if the backend is unreachable.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _initDio();
  }

  late final Dio _dio;

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.backendUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Request interceptor: auto-attach JWT token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          debugPrint('[ApiService] Error: ${error.requestOptions.path} → ${error.response?.statusCode} ${error.message}');
          return handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (o) => debugPrint('[ApiService] $o'),
      ));
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyUserToken);
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserToken, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyUserToken);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TEMPLES
  // ─────────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getTemples({
    String? city,
    String? deity,
    String? search,
    bool featuredOnly = false,
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/temples',
        queryParameters: {
          if (city != null) 'city': city,
          if (deity != null) 'deity': deity,
          if (search != null) 'search': search,
          if (featuredOnly) 'featured_only': true,
          'limit': limit,
        },
      );
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
      return [];
    } catch (e) {
      debugPrint('[ApiService] getTemples error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getTempleDetails(String templeId) async {
    try {
      final response = await _dio.get('/temples/$templeId');
      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      debugPrint('[ApiService] getTempleDetails error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // PUJAS
  // ─────────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getPujas({
    String? category,
    String? deity,
    String? templeId,
    bool popularOnly = false,
    String? search,
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/puja',
        queryParameters: {
          if (category != null) 'category': category,
          if (deity != null) 'deity': deity,
          if (templeId != null) 'temple_id': templeId,
          if (popularOnly) 'popular_only': true,
          if (search != null) 'search': search,
          'limit': limit,
        },
      );
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
      return [];
    } catch (e) {
      debugPrint('[ApiService] getPujas error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPujaDetails(String pujaId) async {
    try {
      final response = await _dio.get('/puja/$pujaId');
      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      debugPrint('[ApiService] getPujaDetails error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ASTROLOGERS
  // ─────────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAstrologers({
    bool onlineOnly = false,
    String? speciality,
    String? language,
    String sortBy = 'rating',
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/astrologers',
        queryParameters: {
          if (onlineOnly) 'online_only': true,
          if (speciality != null) 'speciality': speciality,
          if (language != null) 'language': language,
          'sort_by': sortBy,
          'limit': limit,
        },
      );
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
      return [];
    } catch (e) {
      debugPrint('[ApiService] getAstrologers error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getAstrologerDetails(String astrologerId) async {
    try {
      final response = await _dio.get('/astrologers/$astrologerId');
      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      debugPrint('[ApiService] getAstrologerDetails error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // BOOKINGS (requires auth token)
  // ─────────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getMyBookings() async {
    try {
      final response = await _dio.get('/bookings');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
      return [];
    } catch (e) {
      debugPrint('[ApiService] getMyBookings error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final response = await _dio.post('/bookings', data: jsonEncode(bookingData));
      final result = response.data;
      if (result is Map && result['data'] != null) {
        return Map<String, dynamic>.from(result['data'] as Map);
      }
      return null;
    } catch (e) {
      debugPrint('[ApiService] createBooking error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // CONSULTATIONS (requires auth token)
  // ─────────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getMyConsultations() async {
    try {
      final response = await _dio.get('/consultations');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
      return [];
    } catch (e) {
      debugPrint('[ApiService] getMyConsultations error: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SHOP
  // ─────────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getProducts({
    String? category,
    bool featuredOnly = false,
    String? search,
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/shop/products',
        queryParameters: {
          if (category != null) 'category': category,
          if (featuredOnly) 'featured_only': true,
          if (search != null) 'search': search,
          'limit': limit,
        },
      );
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
      return [];
    } catch (e) {
      debugPrint('[ApiService] getProducts error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMyOrders() async {
    try {
      final response = await _dio.get('/shop/orders');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
      return [];
    } catch (e) {
      debugPrint('[ApiService] getMyOrders error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> placeOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _dio.post('/shop/orders', data: jsonEncode(orderData));
      final result = response.data;
      if (result is Map && result['data'] != null) {
        return Map<String, dynamic>.from(result['data'] as Map);
      }
      return null;
    } catch (e) {
      debugPrint('[ApiService] placeOrder error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // CHADHAWA
  // ─────────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getChadhawaOfferings({
    String? templeId,
    String? deity,
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/chadhawa',
        queryParameters: {
          if (templeId != null) 'temple_id': templeId,
          if (deity != null) 'deity': deity,
          'limit': limit,
        },
      );
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
      return [];
    } catch (e) {
      debugPrint('[ApiService] getChadhawaOfferings error: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // AUTH / PROFILE (requires auth token)
  // ─────────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getMyProfile() async {
    try {
      final response = await _dio.get('/auth/me');
      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      debugPrint('[ApiService] getMyProfile error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _dio.put('/auth/profile', data: jsonEncode(profileData));
      final result = response.data;
      if (result is Map && result['user'] != null) {
        return Map<String, dynamic>.from(result['user'] as Map);
      }
      return null;
    } catch (e) {
      debugPrint('[ApiService] updateProfile error: $e');
      return null;
    }
  }

  /// Backend OTP auth (used alongside Supabase in demo mode)
  Future<Map<String, dynamic>?> sendOtpViaBackend({
    String? email,
    String? phone,
  }) async {
    try {
      final response = await _dio.post('/auth/otp/send', data: jsonEncode({
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      }));
      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      debugPrint('[ApiService] sendOtpViaBackend error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> verifyOtpViaBackend({
    String? email,
    String? phone,
    required String otp,
    String? fullName,
  }) async {
    try {
      final response = await _dio.post('/auth/otp/verify', data: jsonEncode({
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        'otp': otp,
        if (fullName != null) 'full_name': fullName,
        'role': 'user',
      }));
      final result = response.data;
      if (result is Map && result['token'] != null) {
        await setToken(result['token'] as String);
      }
      return Map<String, dynamic>.from(result as Map);
    } catch (e) {
      debugPrint('[ApiService] verifyOtpViaBackend error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // NOTIFICATIONS
  // ─────────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getMyNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
      return [];
    } catch (e) {
      debugPrint('[ApiService] getMyNotifications error: $e');
      return [];
    }
  }
}
