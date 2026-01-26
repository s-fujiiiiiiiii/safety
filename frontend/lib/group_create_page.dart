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
    final mainGreen = Colors.green.shade700;

    return Scaffold(
      appBar: AppBar(
        title: const Text("グループ作成"),
        backgroundColor: mainGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // タイトル
            Text(
              "新しいグループを作成",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: mainGreen,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // グループ名入力
            TextField(
              controller: ctrl,
              decoration: InputDecoration(
                labelText: "グループ名",
                prefixIcon: const Icon(Icons.group),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: mainGreen, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 作成ボタン
            ElevatedButton(
              onPressed: createGroup,
              style: ElevatedButton.styleFrom(
                backgroundColor: mainGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "グループを作成",
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),

            // メッセージ表示
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
