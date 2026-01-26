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
      Uri.parse(
        "http://10.251.197.125:8000/api/group_members/?group_id=${widget.groupId}",
      ),
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
      fetchMembers();
    } else {
      final data = jsonDecode(res.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data["message"] ?? "削除に失敗しました"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainGreen = Colors.green.shade700;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        backgroundColor: mainGreen,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: members.length,
              itemBuilder: (context, i) {
                final m = members[i];
                final isLeaderUser = m["is_group_leader"];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          isLeaderUser ? mainGreen : Colors.grey.shade400,
                      child: Icon(
                        isLeaderUser ? Icons.star : Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      m["name"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: isLeaderUser
                        ? const Text(
                            "リーダー",
                            style: TextStyle(color: Colors.green),
                          )
                        : null,
                    trailing: (widget.isLeader &&
                            m["id"] != widget.loginUserId)
                        ? IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => removeMember(m["id"]),
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
