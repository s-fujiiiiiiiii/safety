import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLeader = false;
  String message = "";

  Future<void> register() async {
    final res = await http.post(
      Uri.parse("http://10.251.197.125:8000/api/create_user/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": nameCtrl.text,
        "password": passCtrl.text,
        "is_group_leader": isLeader,
      }),
    );

    final data = jsonDecode(res.body);
    setState(() => message = data["message"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("新規作成")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "名前")),
            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: "パスワード"), obscureText: true),
            SwitchListTile(
              title: const Text("グループリーダー"),
              value: isLeader,
              onChanged: (v) => setState(() => isLeader = v),
            ),
            ElevatedButton(onPressed: register, child: const Text("作成")),
            Text(message),
          ],
        ),
      ),
    );
  }
}
