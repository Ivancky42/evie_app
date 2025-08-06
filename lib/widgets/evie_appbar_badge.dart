import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../api/colours.dart';
import '../api/fonts.dart';

class PageAppbarWithBadge extends StatelessWidget implements PreferredSizeWidget {
  final bool? enable;
  final String title;
  final bool? withAction;
  final VoidCallback onPressedLeading;
  final VoidCallback? onPressedAction;

  const PageAppbarWithBadge({
    super.key,
    this.enable,
    required this.title,
    required this.onPressedLeading,
    this.onPressedAction,
    this.withAction,
  });

  @override
  Widget build(BuildContext context) {
    return enable == null || enable == true ? Padding(
      padding: EdgeInsets.all(6),
      child: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: GestureDetector(
          onTap: onPressedLeading,
          child: SizedBox(
            width: 36.w,
            height: 36.w,
            child: SvgPicture.asset("assets/buttons/back_big.svg"),
          )
        ),
        centerTitle: true,
        title: Center(
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title, style: EvieTextStyles.h2.copyWith(color: EvieColors.mediumBlack),
                ),
                SizedBox(width: 4,),
                SizedBox(
                  width: 30.w,
                  height: 30.h,
                  child: SvgPicture.asset(
                    "assets/icons/batch_tick.svg",
                  ),
                )
              ],
            ),
          )
        ),
        actions: [
          withAction != null ?
              withAction != false ?
          GestureDetector(
              onTap: onPressedAction,
              child: Container(
                child:  SvgPicture.asset(
                  "assets/buttons/more.svg", width: 36.w, height: 36.w,
                ),
              )
          ) : SizedBox(width: 36.w, height: 36.w) : SizedBox(width: 36.w, height: 36.w)
        ],
      ),
    ) : Container();
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => enable == null || enable == true ? Size.fromHeight(48.h) : Size.fromHeight(0);
}

class PageAppbarWithoutBadge extends StatelessWidget implements PreferredSizeWidget {
  final bool? enable;
  final String title;
  final bool? withAction;
  final VoidCallback onPressedLeading;
  final VoidCallback? onPressedAction;

  const PageAppbarWithoutBadge({
    super.key,
    this.enable,
    required this.title,
    required this.onPressedLeading,
    this.onPressedAction,
    this.withAction,
  });

  @override
  Widget build(BuildContext context) {
    return enable == null || enable == true ? Padding(
      padding: EdgeInsets.all(6),
      child: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: GestureDetector(
            onTap: onPressedLeading,
            child: SizedBox(
              width: 36.w,
              height: 36.w,
              child: SvgPicture.asset("assets/buttons/back_big.svg"),
            )
        ),
        centerTitle: true,
        title: Center(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title, style: EvieTextStyles.h2.copyWith(color: EvieColors.mediumBlack),
                  ),
                ],
              ),
            )
        ),
        actions: [
          withAction != null ?
          withAction != false ?
          GestureDetector(
              onTap: onPressedAction,
              child: Container(
                child:  SvgPicture.asset(
                  "assets/buttons/more.svg", width: 36.w, height: 36.w,
                ),
              )
          ) : SizedBox(width: 36.w, height: 36.w) : SizedBox(width: 36.w, height: 36.w)
        ],
      ),
    ) : Container();
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => enable == null || enable == true ? Size.fromHeight(48.h) : Size.fromHeight(0);
}