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

  bool statusLoading = false;
  String statusErrorMessage = "";
  Map<int, dynamic> latestStatusByUserId = {};

  static const mainGreen = Color(0xFF2E7D32);
  static const lightGreen = Color(0xFFE8F5E9);

@override
void initState() {
  super.initState();
  fetchMembers();
}

int? _extractUserId(dynamic member) {
  if (member is! Map) return null;
  final raw = member["id"];
  if (raw is int) return raw;
  return int.tryParse(raw?.toString() ?? "");
}

  DateTime? _extractLatestCreatedAt(int userId) {
    final latest = latestStatusByUserId[userId];
    if (latest is! Map) return null;

    final raw = latest["created_at"];
    if (raw == null) return null;
    if (raw is String) return DateTime.tryParse(raw);

    // 念のため（型が想定と違う場合）
    return DateTime.tryParse(raw.toString());
  }

  void _sortMembersByLatestStatusDesc() {
    members.sort((a, b) {
      final aId = _extractUserId(a);
      final bId = _extractUserId(b);

      final aAt = aId == null ? null : _extractLatestCreatedAt(aId);
      final bAt = bId == null ? null : _extractLatestCreatedAt(bId);

      // 未登録（null）は下へ
      if (aAt == null && bAt == null) {
        final aName = (a is Map ? a["name"] : "")?.toString() ?? "";
        final bName = (b is Map ? b["name"] : "")?.toString() ?? "";
        return aName.compareTo(bName);
      }
      if (aAt == null) return 1;
      if (bAt == null) return -1;

      // 新しい順（降順）
      final cmp = bAt.compareTo(aAt);
      if (cmp != 0) return cmp;

      // 同時刻なら名前で安定化
      final aName = (a is Map ? a["name"] : "")?.toString() ?? "";
      final bName = (b is Map ? b["name"] : "")?.toString() ?? "";
      return aName.compareTo(bName);
    });
  }

  Future<void> fetchLatestStatuses() async {
    if (members.isEmpty) return;

    final userIds = <int>[];
    for (final m in members) {
      final id = m["id"];
      if (id is int) {
        userIds.add(id);
      } else {
        final parsed = int.tryParse(id?.toString() ?? "");
        if (parsed != null) userIds.add(parsed);
      }
    }

    if (userIds.isEmpty) return;

    if (!mounted) return;
    setState(() {
      statusLoading = true;
      statusErrorMessage = "";
    });

    final result = await ApiService.fetchLatestSafetyStatuses(userIds: userIds);
    if (!mounted) return;

    if (result["success"] == true) {
      final data = result["data"];
      if (data is Map) {
        final mapped = <int, dynamic>{};
        data.forEach((key, value) {
          final uid = int.tryParse(key.toString());
          if (uid != null) mapped[uid] = value;
        });
        setState(() {
          latestStatusByUserId = mapped;
          _sortMembersByLatestStatusDesc();
          statusLoading = false;
        });
      } else {
        setState(() {
          statusLoading = false;
          statusErrorMessage = "安否情報の取得に失敗しました";
        });
      }
    } else {
      setState(() {
        statusLoading = false;
        statusErrorMessage = result["error"]?.toString() ?? "安否情報の取得に失敗しました";
      });
    }
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

        // メンバー取得後に、最新の安否情報もまとめて取得
        await fetchLatestStatuses();
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
                  : RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          loading = true;
                          errorMessage = "";
                        });
                        await fetchMembers();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: members.length + (statusErrorMessage.isNotEmpty ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (statusErrorMessage.isNotEmpty && i == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                "安否情報: $statusErrorMessage",
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          final index = statusErrorMessage.isNotEmpty ? i - 1 : i;
                          final m = members[index];
                          final isLeaderUser = m["is_group_leader"] == true;
                          final userIdRaw = m["id"];
                          final userId = (userIdRaw is int)
                              ? userIdRaw
                              : int.tryParse(userIdRaw?.toString() ?? "");

                          final latest = (userId != null) ? latestStatusByUserId[userId] : null;
                          final latestStatus = (latest is Map) ? latest["status"]?.toString() : null;
                          final latestMemo = (latest is Map) ? latest["memo"]?.toString() : null;
                          final latestCreatedAt = (latest is Map) ? latest["created_at"]?.toString() : null;

                          return _memberCard(
                            name: m["name"],
                            isLeaderUser: isLeaderUser,
                            canDelete: widget.isLeader && userId != null && userId != widget.loginUserId,
                            onDelete: () => removeMember(userId ?? 0),
                            safetyStatus: latestStatus,
                            safetyMemo: latestMemo,
                            safetyCreatedAt: latestCreatedAt,
                            safetyLoading: statusLoading,
                          );
                        },
                      ),
                    ),
    );
  }

  // ===== メンバーカード =====
  Widget _memberCard({
    required String name,
    required bool isLeaderUser,
    required bool canDelete,
    required VoidCallback onDelete,
    required String? safetyStatus,
    required String? safetyMemo,
    required String? safetyCreatedAt,
    required bool safetyLoading,
  }) {
    final statusLabel = safetyLoading
        ? "取得中..."
        : (safetyStatus == null || safetyStatus.isEmpty)
            ? "未登録"
            : safetyStatus;

    final memoText = (safetyMemo ?? "").trim();
    final timeText = (safetyCreatedAt ?? "").trim();

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
                    const SizedBox(height: 6),
                    Text(
                      "安否：$statusLabel",
                      style: TextStyle(
                        fontSize: 13,
                        color: safetyLoading
                            ? Colors.grey.shade600
                            : (statusLabel == "未登録" ? Colors.grey.shade700 : mainGreen),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (memoText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          memoText,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (timeText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          "更新: $timeText",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
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
