import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../theme/ThemeChangeNotifier.dart';

class EvieAppbar_Back extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onPressed;

  const EvieAppbar_Back({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: ThemeChangeNotifier().isDarkMode(context) == true
            ? Image.asset('assets/buttons/back_darkMode.png')
            : Image.asset('assets/buttons/back.png'),
        onPressed: onPressed,
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(8.h);
}
