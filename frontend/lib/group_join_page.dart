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
    final mainGreen = Colors.green.shade700;

    return Scaffold(
      appBar: AppBar(
        title: const Text("グループ参加"),
        backgroundColor: mainGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),

            const Icon(
              Icons.group_add,
              size: 80,
              color: Colors.green,
            ),

            const SizedBox(height: 30),

            TextField(
              controller: ctrl,
              decoration: InputDecoration(
                labelText: "招待コード",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.vpn_key),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: joinGroup,
              style: ElevatedButton.styleFrom(
                backgroundColor: mainGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "参加する",
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),

            if (message.isNotEmpty)
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: message.contains("成功")
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
