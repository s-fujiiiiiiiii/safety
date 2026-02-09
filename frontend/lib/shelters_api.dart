import 'dart:convert';
import 'package:http/http.dart' as http;
import '../shelter.dart';
import 'config_env.dart';

Future<List<Shelter>> fetchNearbyShelters() async {
  final res = await http.get(
    Uri.parse('${Env.apiBaseUrl}/api/shelters/'),
  );

  if (res.statusCode != 200) return [];

  final List data = json.decode(res.body);
  return data.map((e) => Shelter.fromJson(e)).toList();
}
