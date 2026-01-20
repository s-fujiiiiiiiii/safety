// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class GroupMemberListPage extends StatefulWidget {
//   final int groupId;
//   final String groupName;
//   final int loginUserId;

//   const GroupMemberListPage({
//     super.key,
//     required this.groupId,
//     required this.groupName,
//     required this.loginUserId,
//   });

//   @override
//   State<GroupMemberListPage> createState() => _GroupMemberListPageState();
// }

// class _GroupMemberListPageState extends State<GroupMemberListPage> {
//   List members = [];
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchMembers();
//   }

//   Future<void> fetchMembers() async {
//     final res = await http.get(
//       Uri.parse("http://10.251.197.125:8000/api/group_members/?group_id=${widget.groupId}"),
//     );

//     if (res.statusCode == 200) {
//       setState(() {
//         members = jsonDecode(res.body);
//         loading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.groupName)),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: members.length,
//               itemBuilder: (_, i) {
//                 final u = members[i];
//                 return ListTile(
//                   leading: const Icon(Icons.person),
//                   title: Text(u["name"]),
//                   subtitle: Text(
//                     u["is_group_leader"] ? "リーダー" : "メンバー",
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
