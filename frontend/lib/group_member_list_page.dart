import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

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
  String errorMessage = "";

  static const mainGreen = Color(0xFF2E7D32);
  static const lightGreen = Color(0xFFE8F5E9);

  @override
  void initState() {
    super.initState();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    try {
      final res = await http
          .get(
            Uri.parse(
              "${ApiService.baseUrl}/api/group_members/?group_id=${widget.groupId}",
            ),
          )
          .timeout(const Duration(seconds: 8));

      if (!mounted) return;

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is! List) {
          setState(() {
            loading = false;
            errorMessage = "メンバー取得に失敗しました（不正なレスポンス）";
          });
          return;
        }
        setState(() {
          members = decoded;
          loading = false;
        });
      } else {
        String serverMessage = "";
        try {
          final data = jsonDecode(res.body);
          if (data is Map && data["message"] is String) {
            serverMessage = data["message"] as String;
          }
        } catch (_) {}
        setState(() {
          loading = false;
          errorMessage = serverMessage.isNotEmpty
              ? serverMessage
              : "メンバー取得に失敗しました（${res.statusCode}）";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        errorMessage = "通信エラーが発生しました";
      });
    }
  }

  Future<void> removeMember(int targetUserId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("メンバー削除"),
        content: const Text("このメンバーをグループから削除しますか？"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("キャンセル"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("削除"),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      final res = await http.post(
        Uri.parse("${ApiService.baseUrl}/api/remove_group_member/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "leader_id": widget.loginUserId,
          "group_id": widget.groupId,
          "target_user_id": targetUserId,
        }),
      ).timeout(const Duration(seconds: 8));

      if (!mounted) return;

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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("通信エラーが発生しました")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreen,
      appBar: AppBar(
        title: Text(widget.groupName),
        backgroundColor: mainGreen,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: mainGreen),
            )
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : members.isEmpty
                  ? _emptyView()
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: members.length,
                      itemBuilder: (context, i) {
                        final m = members[i];
                        final isLeaderUser = m["is_group_leader"];

                        return _memberCard(
                          name: m["name"],
                          isLeaderUser: isLeaderUser,
                          canDelete:
                              widget.isLeader && m["id"] != widget.loginUserId,
                          onDelete: () => removeMember(m["id"]),
                        );
                      },
                    ),
    );
  }

  // ===== メンバーカード =====
  Widget _memberCard({
    required String name,
    required bool isLeaderUser,
    required bool canDelete,
    required VoidCallback onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    isLeaderUser ? mainGreen : Colors.grey.shade400,
                child: Icon(
                  isLeaderUser ? Icons.star : Icons.person,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isLeaderUser)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          "リーダー",
                          style: TextStyle(
                            color: mainGreen,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (canDelete)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== 空状態 =====
  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.person_outline, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            "メンバーがいません",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
