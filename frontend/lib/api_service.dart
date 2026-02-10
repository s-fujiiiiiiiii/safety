import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ApiService {
  static const String baseUrl =
      String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://10.251.197.126:8000',
      );

  /// 安否状況を登録する
  static Future<Map<String, dynamic>> registerSafetyStatus({
    required int userId,
    required String status,
    required String memo,
  }) async {
    try {
      print("🔵 APIリクエスト開始: $baseUrl/safetystatus/register/");
      print("リクエストボディ: userId=$userId, status=$status, memo=$memo");
      
      final response = await http.post(
        Uri.parse("$baseUrl/safetystatus/register/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "status": status,
          "memo": memo,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('サーバーへの接続がタイムアウトしました');
        },
      );

      print("✅ レスポンス: ${response.statusCode}");
      print("レスポンスボディ: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "data": jsonDecode(response.body),
        };
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {
            "success": false,
            "error": errorData["error"] ?? "登録に失敗しました（ステータス: ${response.statusCode}）",
          };
        } catch (e) {
          return {
            "success": false,
            "error": "登録に失敗しました（ステータス: ${response.statusCode}）",
          };
        }
      }
    } catch (e) {
      print("❌ エラー発生: $e");
      return {
        "success": false,
        "error": "通信エラー: $e",
      };
    }
  }

  /// その他のAPI（以降追加予定）
  // 例：ユーザー情報取得、グループ情報取得など

  /// 複数ユーザーの最新安否情報を取得する（user_id -> latest）
  /// POST /safetystatus/latest_bulk/ {"user_ids": [1,2,3]}
  static Future<Map<String, dynamic>> fetchLatestSafetyStatuses({
    required List<int> userIds,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/safetystatus/latest_bulk/"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "user_ids": userIds,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('サーバーへの接続がタイムアウトしました');
            },
          );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final latest = (decoded is Map) ? decoded["latest"] : null;
        return {
          "success": true,
          "data": latest ?? {},
        };
      }

      try {
        final errorData = jsonDecode(response.body);
        return {
          "success": false,
          "error": errorData["error"] ?? "取得に失敗しました（ステータス: ${response.statusCode}）",
        };
      } catch (_) {
        return {
          "success": false,
          "error": "取得に失敗しました（ステータス: ${response.statusCode}）",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "error": "通信エラー: $e",
      };
    }
  }
}
