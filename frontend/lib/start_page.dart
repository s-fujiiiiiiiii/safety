// import 'package:flutter/material.dart';
// import 'login.dart';
// import 'register.dart';

// class StartPage extends StatelessWidget {
//   const StartPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("ようこそ")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               child: const Text("ログイン"),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LoginPage()),
//                 );
//               },
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               child: const Text("新規アカウント作成"),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const RegisterPage()),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
