// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class GroupCreatePage extends StatefulWidget {
//   final int userId; // ログイン中のユーザーID

//   const GroupCreatePage({super.key, required this.userId});

//   @override
//   State<GroupCreatePage> createState() => _GroupCreatePageState();
// }

// class _GroupCreatePageState extends State<GroupCreatePage> {
//   final TextEditingController _groupNameController = TextEditingController();

//   bool loading = false;
//   String resultMessage = "";

//   // 一覧用
//   List groups = [];
//   bool fetchingGroups = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchGroups();
//   }

//   // グループ作成
//   Future<void> createGroup() async {
//     if (_groupNameController.text.isEmpty) {
//       setState(() {
//         resultMessage = "グループ名を入力してください";
//       });
//       return;
//     }

//     setState(() {
//       loading = true;
//       resultMessage = "";
//     });

//     final url = Uri.parse("http://10.251.197.125:8000/api/create_group/");

//     try {
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "user_id": widget.userId,
//           "group_name": _groupNameController.text,
//         }),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 201) {
//         setState(() {
//           resultMessage = "グループ作成成功！招待コード: ${data['invite_code']}";
//           _groupNameController.clear();
//         });
//         // 作成成功したら一覧を再取得
//         await fetchGroups();
//       } else {
//         setState(() {
//           resultMessage = data["message"] ?? "作成に失敗しました";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         resultMessage = "通信エラー: $e";
//       });
//     }

//     setState(() => loading = false);
//   }

//   // グループ一覧取得
//   Future<void> fetchGroups() async {
//     setState(() => fetchingGroups = true);

//     final url = Uri.parse(
//       "http://10.251.197.125:8000/api/groups/?user_id=${widget.userId}",
//     );

//     try {
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         setState(() {
//           groups = jsonDecode(response.body);
//           fetchingGroups = false;
//         });
//       } else {
//         setState(() {
//           groups = [];
//           fetchingGroups = false;
//           resultMessage = "グループ取得に失敗しました";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         groups = [];
//         fetchingGroups = false;
//         resultMessage = "通信エラー: $e";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("グループ作成＆一覧")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "グループ名",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _groupNameController,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 hintText: "例：1年A組 / 開発部",
//               ),
//             ),
//             const SizedBox(height: 12),
//             ElevatedButton(
//               onPressed: loading ? null : () async {
//                 await createGroup(); // 作成して一覧を更新
//               },
//               child: loading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text("作成する"),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               resultMessage,
//               style: TextStyle(
//                 color: resultMessage.contains("成功") ? Colors.green : Colors.red,
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               "所属グループ一覧",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),

//             // 一覧部分
//             Expanded(
//               child: fetchingGroups
//                   ? const Center(child: CircularProgressIndicator())
//                   : groups.isEmpty
//                       ? const Center(child: Text("所属しているグループはありません"))
//                       : ListView.builder(
//                           itemCount: groups.length,
//                           itemBuilder: (context, index) {
//                             final group = groups[index];
//                             return Card(
//                               margin: const EdgeInsets.symmetric(vertical: 4),
//                               child: ListTile(
//                                 title: Text(group['name']),
//                                 subtitle:
//                                     Text("招待コード: ${group['invite_code']}"),
//                                 trailing: const Icon(Icons.arrow_forward_ios),
//                                 onTap: () {
//                                   // 将来的にグループ詳細ページへ遷移可能
//                                 },
//                               ),
//                             );
//                           },
//                         ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
