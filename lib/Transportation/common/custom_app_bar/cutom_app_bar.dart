import 'package:Lisofy/resources/app_theme.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBackPressed;
  const CustomAppBar(
      {super.key, required this.title, required this.onBackPressed});
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    double appBarHeight = mediaQuery.size.height * 0.07;
    return Container(
      color: AppTheme.primary,
      height: appBarHeight,
      padding: EdgeInsets.symmetric(horizontal: mediaQuery.size.width * 0.01),
      child: Row(
        children: [
          IconButton(
            icon:
                const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
            onPressed: onBackPressed,
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
