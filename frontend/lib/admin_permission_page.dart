// import 'package:flutter/material.dart';
// import 'group_create_page.dart';
// import 'group_join_page.dart';
// import 'group_list_page.dart';

// class AdminPermissionPage extends StatelessWidget {
//   final int userId;
//   const AdminPermissionPage({super.key, required this.userId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("管理者ページ")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             ElevatedButton(
//               child: const Text("グループ作成"),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => GroupCreatePage(userId: userId),
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               child: const Text("グループ一覧"),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => GroupListPage(userId: userId),
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               child: const Text("グループ参加"),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => GroupJoinPage(userId: userId),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
