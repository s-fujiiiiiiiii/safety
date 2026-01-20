import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GroupMemberListPage extends StatefulWidget {
  final int groupId;
  final String groupName;
  final int loginUserId;
  final bool isLeader;

  const GroupMemberListPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.loginUserId,
    required this.isLeader,
  });

  @override
  State<GroupMemberListPage> createState() => _GroupMemberListPageState();
}

class _GroupMemberListPageState extends State<GroupMemberListPage> {
  List members = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    final res = await http.get(
      Uri.parse("http://10.251.197.125:8000/api/group_members/?group_id=${widget.groupId}"),
    );

    if (res.statusCode == 200) {
      setState(() {
        members = jsonDecode(res.body);
        loading = false;
      });
    }
  }

  Future<void> removeMember(int targetUserId) async {
    final res = await http.post(
      Uri.parse("http://10.251.197.125:8000/api/remove_group_member/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "leader_id": widget.loginUserId,
        "group_id": widget.groupId,
        "target_user_id": targetUserId,
      }),
    );

    if (res.statusCode == 200) {
      fetchMembers(); // 更新
    } else {
      final data = jsonDecode(res.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "削除失敗")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, i) {
                final m = members[i];
                return ListTile(
                  title: Text(m["name"]),
                  subtitle: Text(m["is_group_leader"] ? "リーダー" : ""),
                  trailing: (widget.isLeader && m["id"] != widget.loginUserId)
                      ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => removeMember(m["id"]),
                        )
                      : null,
                );
              },
            ),
    );
  }
}
