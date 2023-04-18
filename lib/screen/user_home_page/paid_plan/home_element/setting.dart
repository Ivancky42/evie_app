import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../../api/colours.dart';
import '../../../../api/fonts.dart';
import '../../../../api/sheet.dart';
import '../../../../widgets/evie_card.dart';

class Setting extends StatefulWidget {
  Setting({
    Key? key
  }) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {

  @override
  Widget build(BuildContext context) {

    return EvieCard(
      onPress: (){
        showBikeSettingSheet(context);
      },
      title: "Setting",
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SvgPicture.asset(
              "assets/icons/setting_black.svg",
              height: 36.h,
            ),
            Text("Bike Setting", style: EvieTextStyles.headlineB.copyWith(color: EvieColors.darkGray)),
            SizedBox(height: 16.h,),
          ],
        ),
      ),
    );
  }
}


