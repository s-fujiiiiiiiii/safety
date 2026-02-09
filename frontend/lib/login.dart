import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'home_page.dart';
import 'config_env.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final nameCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final FocusNode _passFocusNode = FocusNode();
  String message = "";

  bool _obscurePassword = true;

  @override
  void dispose() {
    nameCtrl.dispose();
    passCtrl.dispose();
    _passFocusNode.dispose();
    super.dispose();
  }
Future<void> login() async {
  debugPrint("🔥 login() START");
  debugPrint("👤 name='${nameCtrl.text}'");
  debugPrint("🔑 pass='${passCtrl.text}'");
  debugPrint("🔍 API Base URL: ${Env.apiBaseUrl}");

  try {
    debugPrint("🚀 POST送信開始");
    final res = await http.post(
      Uri.parse("${Env.apiBaseUrl}/api/login/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": nameCtrl.text,
        "password": passCtrl.text,
      }),
    );

    debugPrint("✅ POST完了");
    debugPrint("📡 statusCode: ${res.statusCode}");
    debugPrint("📦 response body: ${res.body}");

    if (!mounted) return;

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(
            userId: data["user_id"],
            isLeader: data["is_group_leader"],
          ),
        ),
      );
    } else {
      setState(() {
        message = data["message"] ?? "ログインに失敗しました";
      });
    }
  } catch (e) {
    debugPrint("❌ LOGIN ERROR: $e");

    if (!mounted) return;

    setState(() {
      message = "通信エラーが発生しました";
    });
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
          "ログイン",
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
                  Icons.lock_outline,
                  size: 80,
                  color: Color(0xFF2E7D32),
                ),
                const SizedBox(height: 30),

                // 名前
                TextField(
                  controller: nameCtrl,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _passFocusNode.requestFocus(),
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
                  focusNode: _passFocusNode,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => login(),
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

                const SizedBox(height: 30),

                // ログインボタン
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
                    onPressed: login,
                    child: const Text(
                      "ログイン",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // エラーメッセージ
                if (message.isNotEmpty)
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.red,
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
