import 'package:flutter/material.dart';
import 'package:slim_web/components/pallete.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, this.bottom});

  final PreferredSizeWidget? bottom;



  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 80,
      elevation: 0,
      
      backgroundColor: Pallete.pink,
      title: Image.asset(
        'lib/images/logo_appbar.png',
        fit: BoxFit.contain,
        height: 40,
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
