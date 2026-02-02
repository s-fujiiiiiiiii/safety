import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../shelter.dart';
import 'config_env.dart';
Future<List<Shelter>> fetchShelters() async {
  try {
    final res = await http.get(
      Uri.parse('${Env.apiBaseUrl}/api/shelters/'),
    );

    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => Shelter.fromJson(e)).toList();
    }
    return [];
  } catch (e) {
    debugPrint('API error: $e');
    return [];
  }
}
