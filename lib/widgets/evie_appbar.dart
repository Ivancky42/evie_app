import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


import '../api/colours.dart';
import '../api/fonts.dart';
import '../api/provider/setting_provider.dart';

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
        icon: SettingProvider().isDarkMode(context) == true
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



class PageAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onPressed;

  const PageAppbar({
    Key? key,
    required this.title,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: SettingProvider().isDarkMode(context) == true
            ? SvgPicture.asset("assets/buttons/back_big.svg")
            : SvgPicture.asset("assets/buttons/back_big.svg"),
        onPressed: onPressed,
      ),
      centerTitle: true,
      title: Text(
        title, style: EvieTextStyles.h2.copyWith(color: EvieColors.mediumBlack, letterSpacing: 0.1.w),
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(48.h);
}