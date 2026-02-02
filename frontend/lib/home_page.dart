// Flutter HomePage デザイン改善版
// ポイント:
// - 上に詰まらないよう Center + SingleChildScrollView
// - ボタンを「カード風」＋アイコン強調
// - セクション分けで視線誘導

import 'package:flutter/material.dart';
import 'group_list_page.dart';
import 'group_join_page.dart';
import 'map_screen.dart';
import 'group_create_page.dart';
import 'safety_register_test.dart';

class HomePage extends StatelessWidget {
  final int userId;
  final bool isLeader;

  const HomePage({
    super.key,
    required this.userId,
    required this.isLeader,
  });

  static const mainGreen = Color(0xFF2E7D32);
  static const lightGreen = Color(0xFFE8F5E9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreen,
      appBar: AppBar(
        title: const Text("ホーム"),
        backgroundColor: mainGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "メニュー",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              if (isLeader) ...[
                _menuCard(
                  icon: Icons.group_add,
                  title: "グループ作成",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupCreatePage(userId: userId),
                      ),
                    );
                  },
                ),
                _menuCard(
                  icon: Icons.groups,
                  title: "グループ一覧",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupListPage(
                          userId: userId,
                          isLeader: isLeader,
                        ),
                      ),
                    );
                  },
                ),
              ],

              _menuCard(
                icon: Icons.login,
                title: "グループ参加",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupJoinPage(userId: userId),
                    ),
                  );
                },
              ),

              _menuCard(
                icon: Icons.check_circle,
                title: "安否登録",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SafetyRegisterTestPage(userId: userId),
                    ),
                  );
                },
              ),

              _menuCard(
                icon: Icons.map,
                title: "避難所マップを見る",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MapScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: mainGreen.withOpacity(0.1),
                  child: Icon(icon, color: mainGreen, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
