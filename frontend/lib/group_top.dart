// import 'package:flutter/material.dart';

// class GroupTopPage extends StatelessWidget {
//   final int userId; // ★ ログインユーザーID

//   const GroupTopPage({
//     super.key,
//     required this.userId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("グループリーダー画面"),
//         backgroundColor: Colors.blue[800],
//         automaticallyImplyLeading: false,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             tooltip: "ログアウト",
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "グループリーダートップ",
//               style: Theme.of(context).textTheme.headlineSmall,
//             ),
//             const SizedBox(height: 20),

//             Text(
//               "あなたの userId： $userId",
//               style: const TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 30),

//             ElevatedButton.icon(
//               onPressed: () {
//                 // TODO: グループ作成画面へ
//               },
//               icon: const Icon(Icons.group_add),
//               label: const Text("グループを作成"),
//             ),
//             const SizedBox(height: 16),

//             ElevatedButton.icon(
//               onPressed: () {
//                 // TODO: グループ参加画面へ
//               },
//               icon: const Icon(Icons.login),
//               label: const Text("グループに参加"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
