import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GroupCreatePage extends StatefulWidget {
  final int userId;
  const GroupCreatePage({super.key, required this.userId});

  @override
  State<GroupCreatePage> createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends State<GroupCreatePage> {
  final ctrl = TextEditingController();
  String message = "";

  Future<void> createGroup() async {
    final res = await http.post(
      Uri.parse("http://10.251.197.125:8000/api/create_group/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": widget.userId,
        "group_name": ctrl.text,
      }),
    );

    final data = jsonDecode(res.body);
    setState(() => message = data["message"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("グループ作成")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: ctrl, decoration: const InputDecoration(labelText: "グループ名")),
            ElevatedButton(onPressed: createGroup, child: const Text("作成")),
            Text(message),
          ],
        ),
      ),
    );
  }
}
