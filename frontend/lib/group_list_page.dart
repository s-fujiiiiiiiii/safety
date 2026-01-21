import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'group_member_list_page.dart';
import 'group_create_page.dart';

class GroupListPage extends StatefulWidget {
  final int userId;
  final bool isLeader;

  const GroupListPage({
    super.key,
    required this.userId,
    required this.isLeader,
  });

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  List groups = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  Future<void> fetchGroups() async {
    final res = await http.get(
      Uri.parse("http://10.251.197.125:8000/api/group_list/?user_id=${widget.userId}"),
    );

    if (res.statusCode == 200) {
      setState(() {
        groups = jsonDecode(res.body);
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("グループ一覧")),
      floatingActionButton: widget.isLeader
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupCreatePage(userId: widget.userId),
                  ),
                );
              },
            )
          : null,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, i) {
                final g = groups[i];
                return ListTile(
                  title: Text(g["name"]),
                  subtitle: Text("招待コード: ${g["invite_code"]}"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupMemberListPage(
                          groupId: g["id"],
                          groupName: g["name"],
                          loginUserId: widget.userId,
                          isLeader: widget.isLeader,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
