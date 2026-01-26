import 'package:flutter/material.dart';
import 'group_list_page.dart';
import 'group_join_page.dart';
import 'map_screen.dart';
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
    const mainGreen = Color(0xFF2E7D32);
    const lightGreen = Color(0xFFE8F5E9);

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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isLeader) ...[
              _greenButton(
                text: "グループ作成",
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
              _greenButton(
                text: "グループ一覧",
                onPressed: () {
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
              const SizedBox(height: 20),
            ],
            _greenButton(
              text: "グループ参加",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupJoinPage(userId: userId),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _greenButton(
              text: "避難所マップを見る",
              icon: Icons.map,
              onPressed: () {
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
    );
  }

  Widget _greenButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return ElevatedButton.icon(
      icon: icon != null ? Icon(icon, color: Colors.white) : const SizedBox(),
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    );
  }
}
