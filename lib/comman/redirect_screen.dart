import 'package:flutter/material.dart';
import 'package:raising_india/features/admin/pagination/main_screen_a.dart';
import 'package:raising_india/features/user/main_screen_u.dart';

class RedirectScreen extends StatefulWidget {
  const RedirectScreen({super.key, required this.isAdmin});
  final bool isAdmin;

  @override
  State<RedirectScreen> createState() => _RedirectScreenState();
}

class _RedirectScreenState extends State<RedirectScreen> {

  @override
  void initState() {
    super.initState();
    if (widget.isAdmin) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MainScreenA()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MainScreenU()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('Redirect screen'),
    );
  }
}
