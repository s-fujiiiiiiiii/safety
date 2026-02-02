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
  bool loading = false;

  static const mainGreen = Color(0xFF2E7D32);
  static const lightGreen = Color(0xFFE8F5E9);

  Future<void> createGroup() async {
    if (ctrl.text.isEmpty) {
      setState(() => message = "グループ名を入力してください");
      return;
    }

    setState(() {
      loading = true;
      message = "";
    });

    try {
      final res = await http
          .post(
            Uri.parse("http://10.251.197.126:8000/api/create_group/"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "user_id": widget.userId,
              "group_name": ctrl.text,
            }),
          )
          .timeout(const Duration(seconds: 5));

      final data = jsonDecode(res.body);

      if (!mounted) return;

      setState(() {
        message = data["message"] ?? "作成しました";
        loading = false;
      });

      if (res.statusCode == 200 || res.statusCode == 201) {
        Future.delayed(const Duration(milliseconds: 800), () {
          Navigator.pop(context, true);
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        message = "通信エラーが発生しました";
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreen,
      appBar: AppBar(
        title: const Text("グループ作成"),
        backgroundColor: mainGreen,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.group_add, size: 48, color: mainGreen),
                  const SizedBox(height: 12),
                  const Text(
                    "新しいグループを作成",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 32),

                  TextField(
                    controller: ctrl,
                    decoration: InputDecoration(
                      labelText: "グループ名",
                      prefixIcon:
                          const Icon(Icons.group, color: mainGreen),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: mainGreen, width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  ElevatedButton(
                    onPressed: loading ? null : createGroup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "グループを作成",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),

                  const SizedBox(height: 20),

                  if (message.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: message.contains("成功") ||
                                message.contains("作成")
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: message.contains("成功") ||
                                  message.contains("作成")
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
