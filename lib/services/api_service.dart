import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/model.dart';
import '../models/user_model.dart';

/// Service สำหรับเชื่อมต่อ REST API ของ Daily Accounting Backend
class ApiService {
  /// Bearer Token ของผู้ใช้ที่ล็อกอินอยู่ (กำหนดจากหน้าจอ Login)
  static String? token;

  // Base URL (สามารถกำหนดผ่าน --dart-define=API_BASE_URL=... ได้)
  // - Production: https://flutter-backend-iota.vercel.app/api
  // - Android Emulator: http://10.0.2.2:3000/api
  // - iOS Simulator / Web: http://localhost:3000/api
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://flutter-backend-iota.vercel.app/api',
  );

  /// Helper สำหรับสร้าง HTTP Header พร้อม Bearer Token (ถ้ามี)
  static Map<String, String> _headers([String? token]) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// แปลง HTTP Status Code เป็นข้อความ Error ภาษาไทย
  static String _statusMessage(int code) {
    switch (code) {
      case 400:
        return 'ข้อมูลที่ส่งมาไม่ถูกต้อง (Invalid payload)';
      case 401:
        return 'ไม่ได้รับอนุญาต: Token หมดอายุหรือไม่ได้แนบ Token';
      case 403:
        return 'ไม่มีสิทธิ์เข้าถึงข้อมูลนี้ (Forbidden)';
      case 404:
        return 'ไม่พบข้อมูลที่ต้องการ (Not Found)';
      case 429:
        return 'ส่งคำขอถี่เกินไป โปรดลองอีกครั้งภายหลัง (Rate Limit)';
      case 500:
        return 'เกิดข้อผิดพลาดฝั่งเซิร์ฟเวอร์ (Internal Server Error)';
      default:
        return 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์ ($code)';
    }
  }

  /// Helper ดึงข้อความ Error จาก Server Response
  static String _parseErrorMessage(http.Response response) {
    final int code = response.statusCode;
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data['error'] != null) {
        final msg = data['error'].toString();
        if (msg.isNotEmpty) return msg;
      }
    } catch (_) {}
    return _statusMessage(code);
  }

  /// Debug log แสดง Method + Endpoint + HTTP Status Code (เช่น [API] POST /auth/register → 201)
  /// แสดงเป็นสีเหลือง (ทอง) เพื่อให้มองเห็นง่ายใน debug console
  static void _logRequest(String method, String path, http.Response response) {
    const yellow = '\x1B[33m';
    const green = '\x1B[32m';
    const red = '\x1B[31m';
    const reset = '\x1B[0m';
    final int code = response.statusCode;
    final String codeColor =
        code >= 500 ? red : (code >= 400 ? yellow : green);
    debugPrint('$yellow[API] $reset$method $path → $codeColor$code$reset');
  }

  // ---------------------------------------------------------------------------
  // 1. Authentication Endpoints
  // ---------------------------------------------------------------------------

  /// Register new user (`POST /api/auth/register`)
  static Future<Map<String, dynamic>> register({
    required String fname,
    required String lname,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers(),
      body: jsonEncode({
        'fname': fname,
        'lname': lname,
        'email': email,
        'password': password,
      }),
    );
    _logRequest('POST', '/auth/register', response);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'token': data['token'],
        'user': UserModel.fromJson(data['user']),
      };
    } else {
      throw Exception(_parseErrorMessage(response));
    }
  }

  /// Login user (`POST /api/auth/login`)
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    _logRequest('POST', '/auth/login', response);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'token': data['token'],
        'user': UserModel.fromJson(data['user']),
      };
    } else {
      throw Exception(_parseErrorMessage(response));
    }
  }

  /// Get authenticated user profile (`GET /api/auth/me`)
  static Future<UserModel> getMe(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _headers(token),
    );
    _logRequest('GET', '/auth/me', response);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data['user']);
    } else {
      throw Exception(_parseErrorMessage(response));
    }
  }

  /// Update authenticated user profile (`PATCH /api/auth/me`)
  static Future<UserModel> updateProfile({
    required String token,
    String? fname,
    String? lname,
    String? email,
  }) async {
    final body = <String, String>{
      if (fname != null && fname.isNotEmpty) 'fname': fname,
      if (lname != null && lname.isNotEmpty) 'lname': lname,
      if (email != null && email.isNotEmpty) 'email': email,
    };

    final response = await http.patch(
      Uri.parse('$baseUrl/auth/me'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    _logRequest('PATCH', '/auth/me', response);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data['user'] ?? data);
    } else {
      throw Exception(_parseErrorMessage(response));
    }
  }

  /// Server-side Logout & Token Revocation (`POST /api/auth/logout`)
  static Future<bool> logout(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: _headers(token),
    );
    _logRequest('POST', '/auth/logout', response);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(_parseErrorMessage(response));
    }
  }

  // ---------------------------------------------------------------------------
  // 2. Categories & Analytics Endpoints
  // ---------------------------------------------------------------------------

  /// Get predefined standard categories (`GET /api/categories`)
  static Future<Map<String, List<CategoryModel>>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: _headers(),
    );
    _logRequest('GET', '/categories', response);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List incomeJson = data['income'] ?? [];
      final List expenseJson = data['expense'] ?? [];

      return {
        'income': incomeJson.map((e) => CategoryModel.fromJson(e)).toList(),
        'expense': expenseJson.map((e) => CategoryModel.fromJson(e)).toList(),
      };
    } else {
      throw Exception(_parseErrorMessage(response));
    }
  }

  /// Get monthly summary and category breakdown (`GET /api/reports/summary`)
  static Future<Map<String, dynamic>> getReportsSummary({
    required String token,
    String? month, // Format: YYYY-MM or null/empty for all-time
  }) async {
    final queryParams = <String, String>{};
    if (month != null && month.isNotEmpty) {
      queryParams['month'] = month;
    }

    final uri = Uri.parse('$baseUrl/reports/summary').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final response = await http.get(uri, headers: _headers(token));
    _logRequest('GET', '/reports/summary', response);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List breakdownJson = data['categoryBreakdown'] ?? [];

      return {
        'month': data['month'] ?? month ?? 'all',
        'summary': SummaryModel.fromJson(data['summary'] ?? {}),
        'categoryBreakdown': breakdownJson.map((e) => CategoryBreakdownModel.fromJson(e)).toList(),
      };
    } else {
      throw Exception(_parseErrorMessage(response));
    }
  }

  // ---------------------------------------------------------------------------
  // 3. Transactions CRUD Endpoints
  // ---------------------------------------------------------------------------

  /// Get list of transactions and summary (`GET /api/transactions`)
  /// Supports optional filters: type, startDate, endDate, category, page, limit
  static Future<Map<String, dynamic>> getTransactions({
    required String token,
    String? type,
    String? startDate,
    String? endDate,
    String? category,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (type != null && type.isNotEmpty) queryParams['type'] = type;
    if (startDate != null && startDate.isNotEmpty) queryParams['startDate'] = startDate;
    if (endDate != null && endDate.isNotEmpty) queryParams['endDate'] = endDate;
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (page != null && page > 0) queryParams['page'] = page.toString();
    if (limit != null && limit > 0) queryParams['limit'] = limit.toString();

    final uri = Uri.parse('$baseUrl/transactions').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final response = await http.get(uri, headers: _headers(token));
    _logRequest('GET', '/transactions', response);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List listJson = data['transactions'] ?? [];

      return {
        'summary': SummaryModel.fromJson(data['summary'] ?? {}),
        'pagination': PaginationModel.fromJson(data['pagination'] ?? {}),
        'transactions': listJson.map((e) => TransactionModel.fromJson(e)).toList(),
      };
    } else {
      throw Exception(_parseErrorMessage(response));
    }
  }

  /// Create new transaction (`POST /api/transactions`)
  static Future<TransactionModel> createTransaction({
    required String token,
    required String type,
    required double amount,
    required String category,
    String? description,
    String? date,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: _headers(token),
      body: jsonEncode({
        'type': type,
        'amount': amount,
        'category': category,
        'description': description ?? '',
        if (date != null && date.isNotEmpty) 'date': date,
      }),
    );
    _logRequest('POST', '/transactions', response);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return TransactionModel.fromJson(data['transaction']);
    } else {
      throw Exception(_parseErrorMessage(response));
    }
  }

  /// Update existing transaction (`PUT /api/transactions/:id`)
  static Future<TransactionModel> updateTransaction({
    required String token,
    required String id,
    required String type,
    required double amount,
    required String category,
    String? description,
    String? date,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/transactions/$id'),
      headers: _headers(token),
      body: jsonEncode({
        'type': type,
        'amount': amount,
        'category': category,
        'description': description ?? '',
        if (date != null && date.isNotEmpty) 'date': date,
      }),
    );
    _logRequest('PUT', '/transactions/$id', response);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return TransactionModel.fromJson(data['transaction']);
    } else {
      throw Exception(_parseErrorMessage(response));
    }
  }

  /// Delete transaction (`DELETE /api/transactions/:id`)
  static Future<bool> deleteTransaction({
    required String token,
    required String id,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/transactions/$id'),
      headers: _headers(token),
    );
    _logRequest('DELETE', '/transactions/$id', response);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(_parseErrorMessage(response));
    }
  }
}