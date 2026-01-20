import 'package:flutter/material.dart';
import 'group_list_page.dart';
import 'group_join_page.dart';
import 'group_create_page.dart';

class HomePage extends StatelessWidget {
  final int userId;
  final bool isLeader;

  const HomePage({
    super.key,
    required this.userId,
    required this.isLeader,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ホーム"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // ログアウト → スタート画面へ
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // =========================
            // グループリーダー専用
            // =========================
            if (isLeader) ...[
              ElevatedButton(
                child: const Text("グループ作成"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupCreatePage(userId: userId),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                child: const Text("グループ一覧"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupListPage(
                        userId: userId,
                        isLeader: isLeader, // ← 忘れず渡す
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],

            // =========================
            // 全ユーザー共通
            // =========================
            ElevatedButton(
              child: const Text("グループ参加"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupJoinPage(userId: userId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
