import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GroupJoinPage extends StatefulWidget {
  final int userId;
  const GroupJoinPage({super.key, required this.userId});

  @override
  State<GroupJoinPage> createState() => _GroupJoinPageState();
}

class _GroupJoinPageState extends State<GroupJoinPage> {
  final ctrl = TextEditingController();
  String message = "";

  Future<void> joinGroup() async {
    final res = await http.post(
      Uri.parse("http://10.251.197.125:8000/api/join_group/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": widget.userId,
        "invite_code": ctrl.text,
      }),
    );

    final data = jsonDecode(res.body);
    setState(() => message = data["message"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("グループ参加")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: ctrl, decoration: const InputDecoration(labelText: "招待コード")),
            ElevatedButton(onPressed: joinGroup, child: const Text("参加")),
            Text(message),
          ],
        ),
      ),
    );
  }
}
