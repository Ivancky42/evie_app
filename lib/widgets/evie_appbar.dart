import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


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
            : SvgPicture.asset('assets/buttons/back_big.svg',),

        onPressed: onPressed,
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(48.h);
}
