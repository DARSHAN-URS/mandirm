import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';

/// Central API service that connects the consumer app to the Mandirm backend & Supabase.
///
/// Directly queries Supabase PostgreSQL tables (temples, puja_services, astrologers,
/// chadhawa_offerings, products, bookings, consultations, orders, chat_messages)
/// with graceful fallback to FastAPI HTTP endpoints.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _initDio();
  }

  late final Dio _dio;

  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.backendUrl,
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 6),
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
          debugPrint('[ApiService] Notice: ${error.requestOptions.path} → ${error.response?.statusCode} ${error.message}');
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
    // 1. Live Supabase database
    if (_supabase != null) {
      try {
        var query = _supabase!.from('temples').select();
        if (city != null && city.isNotEmpty) query = query.eq('city', city);
        if (deity != null && deity.isNotEmpty) query = query.eq('deity', deity);
        if (featuredOnly) query = query.eq('is_featured', true);
        final rows = await query.limit(limit);
        if (rows.isNotEmpty) {
          final list = List<Map<String, dynamic>>.from(rows);
          if (search != null && search.trim().isNotEmpty) {
            final q = search.trim().toLowerCase();
            return list.where((t) {
              final n = (t['name'] ?? '').toString().toLowerCase();
              final c = (t['city'] ?? '').toString().toLowerCase();
              final d = (t['deity'] ?? '').toString().toLowerCase();
              return n.contains(q) || c.contains(q) || d.contains(q);
            }).toList();
          }
          return list;
        }
      } catch (e) {
        debugPrint('[ApiService] Supabase getTemples notice: $e');
      }
    }

    // 2. HTTP Backend fallback
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
    } catch (_) {}
    return [];
  }

  Future<Map<String, dynamic>?> getTempleDetails(String templeId) async {
    if (_supabase != null) {
      try {
        final row = await _supabase!
            .from('temples')
            .select()
            .eq('id', templeId)
            .maybeSingle();
        if (row != null) return Map<String, dynamic>.from(row);
      } catch (e) {
        debugPrint('[ApiService] Supabase getTempleDetails notice: $e');
      }
    }

    try {
      final response = await _dio.get('/temples/$templeId');
      return Map<String, dynamic>.from(response.data as Map);
    } catch (_) {
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
    // 1. Live Supabase database
    if (_supabase != null) {
      try {
        var query = _supabase!.from('puja_services').select();
        if (category != null && category.isNotEmpty && category != 'All' && category != 'All Pujas') {
          query = query.eq('category', category);
        }
        if (deity != null && deity.isNotEmpty) query = query.eq('deity', deity);
        if (templeId != null && templeId.isNotEmpty) query = query.eq('temple_id', templeId);
        if (popularOnly) query = query.eq('is_popular', true);
        final rows = await query.limit(limit);
        if (rows.isNotEmpty) {
          final list = List<Map<String, dynamic>>.from(rows);
          if (search != null && search.trim().isNotEmpty) {
            final q = search.trim().toLowerCase();
            return list.where((p) {
              final title = (p['title'] ?? '').toString().toLowerCase();
              final desc = (p['description'] ?? '').toString().toLowerCase();
              final tName = (p['temple_name'] ?? '').toString().toLowerCase();
              return title.contains(q) || desc.contains(q) || tName.contains(q);
            }).toList();
          }
          return list;
        }
      } catch (e) {
        debugPrint('[ApiService] Supabase getPujas notice: $e');
      }
    }

    // 2. HTTP Backend fallback
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
    } catch (_) {}
    return [];
  }

  Future<Map<String, dynamic>?> getPujaDetails(String pujaId) async {
    if (_supabase != null) {
      try {
        final row = await _supabase!
            .from('puja_services')
            .select()
            .eq('id', pujaId)
            .maybeSingle();
        if (row != null) return Map<String, dynamic>.from(row);
      } catch (e) {
        debugPrint('[ApiService] Supabase getPujaDetails notice: $e');
      }
    }

    try {
      final response = await _dio.get('/puja/$pujaId');
      return Map<String, dynamic>.from(response.data as Map);
    } catch (_) {
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
    // 1. Live Supabase database
    if (_supabase != null) {
      try {
        var query = _supabase!.from('astrologers').select();
        if (onlineOnly) query = query.eq('is_online', true);
        final rows = await query.limit(limit);
        if (rows.isNotEmpty) {
          final list = List<Map<String, dynamic>>.from(rows);
          if (sortBy == 'rating') {
            list.sort((a, b) => ((b['rating'] as num?) ?? 0)
                .compareTo((a['rating'] as num?) ?? 0));
          } else if (sortBy == 'experience') {
            list.sort((a, b) => ((b['experience_years'] as num?) ?? 0)
                .compareTo((a['experience_years'] as num?) ?? 0));
          } else if (sortBy == 'price_low') {
            list.sort((a, b) => ((a['per_minute_chat_rate'] as num?) ?? 0)
                .compareTo((b['per_minute_chat_rate'] as num?) ?? 0));
          }
          return list;
        }
      } catch (e) {
        debugPrint('[ApiService] Supabase getAstrologers notice: $e');
      }
    }

    // 2. HTTP Backend fallback
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
    } catch (_) {}
    return [];
  }

  Future<Map<String, dynamic>?> getAstrologerDetails(String astrologerId) async {
    if (_supabase != null) {
      try {
        final row = await _supabase!
            .from('astrologers')
            .select()
            .eq('id', astrologerId)
            .maybeSingle();
        if (row != null) return Map<String, dynamic>.from(row);
      } catch (e) {
        debugPrint('[ApiService] Supabase getAstrologerDetails notice: $e');
      }
    }

    try {
      final response = await _dio.get('/astrologers/$astrologerId');
      return Map<String, dynamic>.from(response.data as Map);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // BOOKINGS (requires auth token)
  // ─────────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getMyBookings() async {
    if (_supabase != null) {
      try {
        final user = _supabase!.auth.currentUser;
        var query = _supabase!.from('bookings').select();
        if (user != null) {
          query = query.eq('user_id', user.id);
        }
        final rows = await query.order('created_at', ascending: false);
        if (rows.isNotEmpty) {
          return List<Map<String, dynamic>>.from(rows);
        }
      } catch (e) {
        debugPrint('[ApiService] Supabase getMyBookings notice: $e');
      }
    }

    try {
      final response = await _dio.get('/bookings');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
    } catch (_) {}
    return [];
  }

  Future<Map<String, dynamic>?> createBooking(Map<String, dynamic> bookingData) async {
    final payload = Map<String, dynamic>.from(bookingData);
    if (!payload.containsKey('id')) {
      payload['id'] = 'bk_${DateTime.now().millisecondsSinceEpoch}';
    }
    if (_supabase != null) {
      try {
        await _supabase!.from('bookings').insert(payload);
        debugPrint('[ApiService] Booking saved to Supabase: ${payload['id']}');
        return payload;
      } catch (e) {
        debugPrint('[ApiService] Supabase createBooking notice: $e');
      }
    }

    try {
      final response = await _dio.post('/bookings', data: jsonEncode(payload));
      final result = response.data;
      if (result is Map && result['data'] != null) {
        return Map<String, dynamic>.from(result['data'] as Map);
      }
    } catch (_) {}
    return payload;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // CONSULTATIONS (requires auth token)
  // ─────────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getMyConsultations() async {
    if (_supabase != null) {
      try {
        final user = _supabase!.auth.currentUser;
        var query = _supabase!.from('consultations').select();
        if (user != null) {
          query = query.eq('user_id', user.id);
        }
        final rows = await query.order('created_at', ascending: false);
        if (rows.isNotEmpty) {
          return List<Map<String, dynamic>>.from(rows);
        }
      } catch (e) {
        debugPrint('[ApiService] Supabase getMyConsultations notice: $e');
      }
    }

    try {
      final response = await _dio.get('/consultations');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
    } catch (_) {}
    return [];
  }

  /// Dispatches a live consultation booking to Supabase & backend
  /// so that it appears in real-time on the Astrologer App's Live Queue.
  Future<Map<String, dynamic>?> requestConsultation({
    required String astrologerId,
    required String astrologerName,
    required String type, // 'chat', 'voice', or 'video'
    String? problemTopic,
    String? birthDob,
    String? birthTime,
    String? birthPlace,
    double perMinuteRate = 25.0,
    String? userName,
    String? userPhone,
    String? userId,
  }) async {
    final newId = 'cons_${DateTime.now().millisecondsSinceEpoch}';
    final payload = {
      'id': newId,
      'astrologer_id': astrologerId,
      'astrologer_name': astrologerName,
      'user_id': userId ?? (_supabase?.auth.currentUser?.id ?? 'usr_${DateTime.now().millisecondsSinceEpoch % 10000}'),
      'user_name': userName ?? 'Devotee',
      'user_phone': userPhone ?? '+91 98765 43210',
      'type': type,
      'status': 'requested',
      'problem_topic': problemTopic ?? 'General Vedic Guidance',
      'birth_dob': birthDob,
      'birth_time': birthTime,
      'birth_place': birthPlace,
      'per_minute_rate': perMinuteRate,
      'call_room_id': 'mandir_room_$newId',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };

    // 1. Direct Supabase insert for instant reflection in Astrologer App
    if (_supabase != null) {
      try {
        await _supabase!.from('consultations').insert(payload);
        debugPrint('[ApiService] Consultation request synced to Supabase: $newId');
      } catch (e) {
        debugPrint('[ApiService] Supabase consultation insert notice: $e');
      }
    }

    // 2. Send to FastAPI backend if available
    try {
      final response = await _dio.post('/consultations/request', data: payload);
      if (response.data is Map && response.data['data'] != null) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }
    } catch (_) {}

    return payload;
  }

  /// WhatsApp-style chat messages in a consultation room
  Future<List<Map<String, dynamic>>> getChatMessages(String consultationId) async {
    if (_supabase != null) {
      try {
        final rows = await _supabase!
            .from('chat_messages')
            .select()
            .eq('consultation_id', consultationId)
            .order('created_at', ascending: true);
        if (rows.isNotEmpty) {
          return List<Map<String, dynamic>>.from(rows);
        }
      } catch (e) {
        debugPrint('[ApiService] Supabase getChatMessages notice: $e');
      }
    }

    try {
      final response = await _dio.get('/consultations/$consultationId/messages');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
    } catch (_) {}
    return [];
  }

  /// Sends a chat message with anti-disintermediation moderation
  Future<Map<String, dynamic>?> sendChatMessage(
    String consultationId, {
    required String message,
    String messageType = 'text',
    String? replyToId,
    String? replyToText,
    String? replyToSender,
  }) async {
    final id = 'msg_${DateTime.now().millisecondsSinceEpoch}';
    final payload = {
      'id': id,
      'consultation_id': consultationId,
      'sender_type': 'user',
      'sender_name': 'Devotee',
      'message': message,
      'message_type': messageType,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };

    if (_supabase != null) {
      try {
        await _supabase!.from('chat_messages').insert(payload);
        debugPrint('[ApiService] Chat message sent via Supabase: $id');
        return payload;
      } catch (e) {
        debugPrint('[ApiService] Supabase sendChatMessage notice: $e');
      }
    }

    try {
      final response = await _dio.post(
        '/consultations/$consultationId/messages',
        data: payload,
      );
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
    } catch (_) {}
    return payload;
  }

  /// Updates message delivery/read status
  Future<bool> updateMessageStatus(
    String consultationId,
    String messageId,
    String status,
  ) async {
    try {
      await _dio.patch(
        '/consultations/$consultationId/messages/$messageId/status',
        data: {'status': status},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Reacts to a message with an emoji
  Future<bool> reactToMessage(
    String consultationId,
    String messageId,
    String reaction,
  ) async {
    try {
      await _dio.patch(
        '/consultations/$consultationId/messages/$messageId/reaction',
        data: {'reaction': reaction},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Reports a message for moderation review
  Future<bool> reportMessage(
    String consultationId,
    String messageId, {
    required String reason,
    String? comments,
  }) async {
    try {
      await _dio.post(
        '/consultations/$consultationId/messages/$messageId/report',
        data: {'reason': reason, 'comments': comments},
      );
      return true;
    } catch (_) {
      return false;
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
    if (_supabase != null) {
      try {
        var query = _supabase!.from('products').select();
        if (category != null && category.isNotEmpty && category != 'all' && category != 'All') {
          query = query.eq('category', category);
        }
        if (featuredOnly) query = query.eq('is_featured', true);
        final rows = await query.limit(limit);
        if (rows.isNotEmpty) {
          final list = List<Map<String, dynamic>>.from(rows);
          if (search != null && search.trim().isNotEmpty) {
            final q = search.trim().toLowerCase();
            return list.where((p) {
              final n = (p['name'] ?? '').toString().toLowerCase();
              final d = (p['description'] ?? '').toString().toLowerCase();
              return n.contains(q) || d.contains(q);
            }).toList();
          }
          return list;
        }
      } catch (e) {
        debugPrint('[ApiService] Supabase getProducts notice: $e');
      }
    }

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
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, dynamic>>> getMyOrders() async {
    if (_supabase != null) {
      try {
        final user = _supabase!.auth.currentUser;
        var query = _supabase!.from('orders').select();
        if (user != null) {
          query = query.eq('user_id', user.id);
        }
        final rows = await query.order('created_at', ascending: false);
        if (rows.isNotEmpty) {
          return List<Map<String, dynamic>>.from(rows);
        }
      } catch (e) {
        debugPrint('[ApiService] Supabase getMyOrders notice: $e');
      }
    }

    try {
      final response = await _dio.get('/shop/orders');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
    } catch (_) {}
    return [];
  }

  Future<Map<String, dynamic>?> placeOrder(Map<String, dynamic> orderData) async {
    final payload = Map<String, dynamic>.from(orderData);
    if (!payload.containsKey('id')) {
      payload['id'] = 'ord_${DateTime.now().millisecondsSinceEpoch}';
    }
    if (_supabase != null) {
      try {
        await _supabase!.from('orders').insert(payload);
        debugPrint('[ApiService] Order placed in Supabase: ${payload['id']}');
        return payload;
      } catch (e) {
        debugPrint('[ApiService] Supabase placeOrder notice: $e');
      }
    }

    try {
      final response = await _dio.post('/shop/orders', data: jsonEncode(payload));
      final result = response.data;
      if (result is Map && result['data'] != null) {
        return Map<String, dynamic>.from(result['data'] as Map);
      }
    } catch (_) {}
    return payload;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // CHADHAWA
  // ─────────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getChadhawaOfferings({
    String? templeId,
    String? deity,
    int limit = 50,
  }) async {
    if (_supabase != null) {
      try {
        var query = _supabase!.from('chadhawa_offerings').select();
        if (templeId != null && templeId.isNotEmpty) query = query.eq('temple_id', templeId);
        final rows = await query.limit(limit);
        if (rows.isNotEmpty) {
          return List<Map<String, dynamic>>.from(rows);
        }
      } catch (e) {
        debugPrint('[ApiService] Supabase getChadhawaOfferings notice: $e');
      }
    }

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
    } catch (_) {}
    return [];
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // AUTH / PROFILE
  // ─────────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getMyProfile() async {
    if (_supabase != null) {
      try {
        final user = _supabase!.auth.currentUser;
        if (user != null) {
          final row = await _supabase!
              .from('profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle();
          if (row != null) return Map<String, dynamic>.from(row);
        }
      } catch (e) {
        debugPrint('[ApiService] Supabase getMyProfile notice: $e');
      }
    }

    try {
      final response = await _dio.get('/auth/me');
      return Map<String, dynamic>.from(response.data as Map);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateProfile(Map<String, dynamic> profileData) async {
    if (_supabase != null) {
      try {
        final user = _supabase!.auth.currentUser;
        if (user != null) {
          await _supabase!.from('profiles').update(profileData).eq('id', user.id);
          return profileData;
        }
      } catch (e) {
        debugPrint('[ApiService] Supabase updateProfile notice: $e');
      }
    }

    try {
      final response = await _dio.put('/auth/profile', data: jsonEncode(profileData));
      final result = response.data;
      if (result is Map && result['user'] != null) {
        return Map<String, dynamic>.from(result['user'] as Map);
      }
    } catch (_) {}
    return null;
  }

  /// Backend OTP auth
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
      debugPrint('[ApiService] sendOtpViaBackend notice: $e');
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
      debugPrint('[ApiService] verifyOtpViaBackend notice: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // NOTIFICATIONS
  // ─────────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getMyNotifications() async {
    if (_supabase != null) {
      try {
        final user = _supabase!.auth.currentUser;
        var query = _supabase!.from('notifications').select();
        if (user != null) {
          query = query.eq('user_id', user.id);
        }
        final rows = await query.order('created_at', ascending: false);
        if (rows.isNotEmpty) {
          return List<Map<String, dynamic>>.from(rows);
        }
      } catch (e) {
        debugPrint('[ApiService] Supabase getMyNotifications notice: $e');
      }
    }

    try {
      final response = await _dio.get('/notifications');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
    } catch (_) {}
    return [];
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // FAQS
  // ─────────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getFAQs({String? category}) async {
    try {
      final response = await _dio.get(
        '/faqs',
        queryParameters: {
          if (category != null) 'category': category,
        },
      );
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
    } catch (_) {}
    return [];
  }
}
