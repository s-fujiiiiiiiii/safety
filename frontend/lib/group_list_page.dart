import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'group_member_list_page.dart';
import 'group_create_page.dart';
import 'api_service.dart';

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

  static const mainGreen = Color(0xFF2E7D32);
  static const lightGreen = Color(0xFFE8F5E9);

  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  Future<void> fetchGroups() async {
    try {
      final res = await http
          .get(
            Uri.parse(
              "${ApiService.baseUrl}/api/group_list/?user_id=${widget.userId}",
            ),
          )
          .timeout(const Duration(seconds: 5));

      if (!mounted) return;

      if (res.statusCode == 200) {
        setState(() {
          groups = jsonDecode(res.body);
          loading = false;
        });
      } else {
        setState(() => loading = false);
        _showError("グループ一覧の取得に失敗しました");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      _showError("通信エラーが発生しました");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _copyInviteCode(String inviteCode) async {
    if (inviteCode.trim().isEmpty) {
      _showError("招待コードがありません");
      return;
    }

    await Clipboard.setData(ClipboardData(text: inviteCode));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("招待コードをコピーしました")),
    );
  }

  Future<void> _shareInviteCode({
    required String inviteCode,
    required String groupName,
  }) async {
    if (inviteCode.trim().isEmpty) {
      _showError("招待コードがありません");
      return;
    }

    // 「よくある共有」で十分とのことなので、短いテキストだけ共有
    await Share.share("招待コード：$inviteCode");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreen,
      appBar: AppBar(
        title: const Text("グループ一覧"),
        backgroundColor: mainGreen,
        foregroundColor: Colors.white,
      ),

      /// リーダーのみ表示
      floatingActionButton: widget.isLeader
          ? FloatingActionButton(
              backgroundColor: mainGreen,
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupCreatePage(userId: widget.userId),
                  ),
                ).then((_) {
                  setState(() {
                    loading = true;
                  });
                  fetchGroups();
                });
              },
            )
          : null,

      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: mainGreen),
            )
          : groups.isEmpty
              ? _emptyView()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: groups.length,
                  itemBuilder: (context, i) {
                    final g = groups[i];

                    return _groupCard(
                      name: (g["name"] ?? "").toString(),
                      inviteCode: (g["invite_code"] ?? "").toString(),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GroupMemberListPage(
                              groupId: g["id"],
                              groupName: (g["name"] ?? "").toString(),
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

  // ===== グループカード =====
  Widget _groupCard({
    required String name,
    required String inviteCode,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: mainGreen.withOpacity(0.1),
                  child: const Icon(
                    Icons.groups,
                    color: mainGreen,
                    size: 28,
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "招待コード：$inviteCode",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Tooltip(
                            message: "コピー",
                            child: IconButton(
                              visualDensity: VisualDensity.compact,
                              iconSize: 18,
                              onPressed: () => _copyInviteCode(inviteCode),
                              icon: Icon(
                                Icons.copy,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          Tooltip(
                            message: "共有",
                            child: IconButton(
                              visualDensity: VisualDensity.compact,
                              iconSize: 18,
                              onPressed: () =>
                                  _shareInviteCode(inviteCode: inviteCode, groupName: name),
                              icon: Icon(
                                Icons.share_outlined,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

  // ===== 空状態 =====
  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.groups_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            "参加しているグループがありません",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
