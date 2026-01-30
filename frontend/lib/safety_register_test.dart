import 'package:flutter/material.dart';
import 'api_service.dart';

class SafetyRegisterTestPage extends StatefulWidget {
  final int userId;

  const SafetyRegisterTestPage({
    super.key,
    required this.userId,
  });

  @override
  State<SafetyRegisterTestPage> createState() =>
      _SafetyRegisterTestPageState();
}

class _SafetyRegisterTestPageState extends State<SafetyRegisterTestPage> {
  String selectedStatus = "無事";
  final TextEditingController memoController = TextEditingController();
  bool isLoading = false;

  final List<String> statusOptions = ["無事", "怪我", "危険", "その他"];

  final Color mainGreen = const Color(0xFF2E7D32); // 濃い緑
  final Color lightGreen = const Color(0xFFE8F5E9); // 薄い緑

  Future<void> registerSafetyStatus() async {
    setState(() => isLoading = true);

    final result = await ApiService.registerSafetyStatus(
      userId: widget.userId,
      status: selectedStatus,
      memo: memoController.text,
    );

    setState(() => isLoading = false);

    if (!mounted) return;

    if (result["success"]) {
      _showSnackBar("安否登録が完了しました！");
      memoController.clear();
      setState(() => selectedStatus = "無事");
    } else {
      _showSnackBar("エラー: ${result["error"]}");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: mainGreen,
      ),
    );
  }

  @override
  void dispose() {
    memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreen,
      appBar: AppBar(
        title: const Text("安否登録"),
        backgroundColor: mainGreen,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "あなたの状況を選択してください",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// 状況選択
                      Wrap(
                        spacing: 8,
                        children: statusOptions.map((status) {
                          final isSelected = selectedStatus == status;
                          return ChoiceChip(
                            label: Text(status),
                            selected: isSelected,
                            selectedColor: mainGreen,
                            backgroundColor: lightGreen,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            onSelected: (_) {
                              setState(() => selectedStatus = status);
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        "メモ（任意）",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      /// メモ入力
                      TextField(
                        controller: memoController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "詳細情報があれば入力してください",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// 送信ボタン
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: registerSafetyStatus,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "送信する",
                            style: TextStyle(fontSize: 16),
                          ),
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
