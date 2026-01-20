import 'package:flutter/material.dart';
import 'group_list_page.dart';
import 'group_join_page.dart';

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
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (isLeader)
              ElevatedButton(
                child: const Text("自分のグループ一覧"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupListPage(userId: userId),
                    ),
                  );
                },
              ),
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
