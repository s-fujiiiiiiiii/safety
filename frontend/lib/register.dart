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
  bool loading = false;

  bool _obscurePassword = true;

  Future<void> register() async {
    if (nameCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      setState(() => message = "名前とパスワードを入力してください");
      return;
    }

    setState(() => loading = true);

    try {
      final res = await http.post(
        Uri.parse("http://10.251.197.126:8000/api/create_user/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameCtrl.text,
          "password": passCtrl.text,
          "is_group_leader": isLeader,
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        setState(() => message = data["message"] ?? "登録に成功しました");

        // 少し待って前の画面へ
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        setState(() => message = data["message"] ?? "登録に失敗しました");
      }
    } catch (e) {
      setState(() => message = "通信エラーが発生しました");
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        centerTitle: true,
        title: const Text(
          "新規作成",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.person_add_alt_1,
                  size: 80,
                  color: Color(0xFF2E7D32),
                ),
                const SizedBox(height: 30),

                // 名前
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: "名前",
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // パスワード
                TextField(
                  controller: passCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "パスワード",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // グループリーダー切り替え
                SwitchListTile(
                  title: const Text(
                    "グループリーダー",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("オンにすると管理者権限になります"),
                  value: isLeader,
                  activeColor: const Color(0xFF4CAF50),
                  onChanged: (v) => setState(() => isLeader = v),
                ),

                const SizedBox(height: 20),

                // 作成ボタン
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: loading ? null : register,
                    child: loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "作成",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // メッセージ
                if (message.isNotEmpty)
                  Text(
                    message,
                    style: TextStyle(
                      color: message.contains("成功")
                          ? const Color(0xFF2E7D32)
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
