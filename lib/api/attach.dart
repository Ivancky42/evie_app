import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_divider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';

import '../widgets/evie_button.dart';
import '../widgets/evie_checkbox.dart';
import '../widgets/evie_double_button_dialog.dart';
import '../widgets/evie_radio_button.dart';
import '../widgets/evie_switch.dart';
import 'colours.dart';
import 'dialog.dart';
import 'fonts.dart';
import 'function.dart';

showFilterTreatStatus(BuildContext context, BikeProvider bikeProvider, setState){

  bool warning = bikeProvider.threatFilterArray.contains("warning") ? true : false;
  bool fall = bikeProvider.threatFilterArray.contains("fall") ? true : false;
  bool danger = bikeProvider.threatFilterArray.contains("danger") ? true : false;
  bool crash = bikeProvider.threatFilterArray.contains("crash") ? true : false;


  SmartDialog.show(
      backDismiss: false,
      keepSingle: true,
      // maskColorTemp: Colors.transparent,
      // targetContext: context,
      // target: Offset(120, 200),

      widget: StatefulBuilder(
      builder: (context, setState){
        return  EvieDoubleButtonDialogFilter(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Filter by status", style: EvieTextStyles.headlineB),
                TextButton(
                    onPressed: () async {

                      setState(() {
                        warning = true;
                        fall = true;
                        danger = true;
                        crash = true;
                      });


                  List<String> filter = ["warning","fall","danger","crash"];
                  await bikeProvider.applyThreatFilterStatus(filter);

                }
                    , child: Text("Clear", style: EvieTextStyles.body18.copyWith(color: EvieColors.primaryColor, fontWeight: FontWeight.w900),))
              ],
            ),
            childContent: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Movement Detected", style: EvieTextStyles.body18,
                      ),
                      EvieCheckBox(
                        onChanged: (value) {
                          setState(() {
                            warning = value!;
                          });
                        },
                        value: warning,
                      ),
                    ],
                  ),
                  const EvieDivider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Fall Detected", style: EvieTextStyles.body18,
                      ),
                      EvieCheckBox(
                        onChanged: (value) {
                          setState(() {
                            fall = value!;
                          });
                        },
                        value: fall,
                      ),
                    ],
                  ),
                  const EvieDivider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Theft Attempt", style: EvieTextStyles.body18,
                      ),
                      EvieCheckBox(
                        onChanged: (value) {
                          setState(() {
                            danger = value!;
                          });
                        },
                        value: danger,
                      ),
                    ],
                  ),
                  const EvieDivider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Crash Alert", style: EvieTextStyles.body18,
                      ),
                      EvieCheckBox(
                        onChanged: (value) {
                          setState(() {
                            crash = value!;
                          });
                        },
                        value: crash,
                      ),
                    ],
                  ),
                 const EvieDivider(),

                      ],),
                  ),

            leftContent: "Cancel",
            rightContent: "Apply Filter",
            onPressedLeft: (){
              SmartDialog.dismiss();
            },
            onPressedRight: () async {

              List<String> filter = [];

              if(warning == true){filter.add("warning");}
              if(fall == true){filter.add("fall");}
              if(danger == true){filter.add("danger");}
              if(crash == true){filter.add("crash");}

              await bikeProvider.applyThreatFilterStatus(filter);

              SmartDialog.dismiss();
            });
      }
      )
  );
}


showFilterTreatDate(BuildContext context, BikeProvider bikeProvider, setState){
  int _selectedRadio = -1;

  ///all, today, yesterday, last7days, custom
  ThreatFilterDate pickedDate = ThreatFilterDate.all;
  DateTimeRange? pickedDateRange;
  DateTime? pickedDate1;
  DateTime? pickedDate2;


  SmartDialog.show(
      useSystem: true,
      backDismiss: false,
      // maskColorTemp: Colors.transparent,
      // targetContext: context,
      // target: Offset(120, 200),

      widget: StatefulBuilder(
          builder: (context, setState){
            return  EvieDoubleButtonDialogFilter(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Filter by date", style: EvieTextStyles.headlineB),
                    TextButton(onPressed: (){
                      setState(() {
                        _selectedRadio = -1;
                        pickedDate = ThreatFilterDate.today;
                        pickedDate1 != null ? pickedDate1 = null : -1;
                        pickedDate2 != null ? pickedDate2 = null : -1;
                        pickedDateRange = null;
                      });
                      bikeProvider.applyThreatFilterDate(ThreatFilterDate.all, DateTime.now(), DateTime.now());
                    }
                        , child: Text("Clear", style: EvieTextStyles.body18.copyWith(color: EvieColors.primaryColor, fontWeight: FontWeight.w900)))
                  ],
                ),
                childContent: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      EvieRadioButton(
                          text: "Today",
                          value: 0,
                          groupValue: _selectedRadio,
                          onChanged: (value){
                            setState(() {
                              _selectedRadio = value;
                              pickedDate = ThreatFilterDate.today;
                              pickedDate1 != null ? pickedDate1 = null : -1;
                              pickedDate2 != null ? pickedDate2 = null : -1;
                            });
                          }),
                      const EvieDivider(),

                      EvieRadioButton(
                          text: "Yesterday",
                          value: 1,
                          groupValue: _selectedRadio,
                          onChanged: (value){
                            setState(() {
                              _selectedRadio = value;
                              pickedDate =ThreatFilterDate.yesterday;
                              pickedDate1 != null ? pickedDate1 = null : -1;
                              pickedDate2 != null ? pickedDate2 = null : -1;
                            });
                          }),

                      const EvieDivider(),
                      EvieRadioButton(
                          text: "Last 7 days",
                          value: 2,
                          groupValue: _selectedRadio,
                          onChanged: (value){

                            setState(() {
                              _selectedRadio = value;
                              pickedDate = ThreatFilterDate.last7days;
                              pickedDate1 != null ? pickedDate1 = null : -1;
                              pickedDate2 != null ? pickedDate2 = null : -1;
                            });
                          }),

                      const EvieDivider(),
                      EvieRadioButton(
                          text: "Custom Date",
                          value: 3,
                          groupValue: _selectedRadio,
                          onChanged: (value){
                            setState(() {
                              _selectedRadio = value;
                              pickedDate = ThreatFilterDate.custom;
                            });
                          }),

                      Visibility(
                        visible: _selectedRadio == 3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: EvieButton_PickDate(
                                onPressed: () async {
                                  if(_selectedRadio == 3){

                                    var range = await showDateRangePicker(
                                      context: context,
                                      initialDateRange: pickedDateRange,
                                      firstDate: DateTime(DateTime.now().year-2),
                                      lastDate: pickedDate2 ?? DateTime.now(),
                                      builder: (context, child) {
                                        return Theme(data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: EvieColors.primaryColor,

                                          ), ), child: child!);
                                      },
                                    );

                                    // pickedDate1 = await showDatePicker(
                                    //     context: context,
                                    //     initialDate: bikeProvider.threatFilterDate1 ?? pickedDate2 ?? DateTime.now(),
                                    //     firstDate: DateTime(DateTime.now().year-2),
                                    //     lastDate: pickedDate2 ?? DateTime.now(),
                                    //     builder: (context, child) {
                                    //       return Theme(data: Theme.of(context).copyWith(
                                    //           colorScheme: ColorScheme.light(
                                    //             primary: EvieColors.primaryColor,
                                    //
                                    //           ), ), child: child!);
                                    //     },
                                    // );
                                    //
                                    if(range != null){
                                      pickedDateRange = range;
                                      pickedDate1 = range.start;
                                      pickedDate2 = range.end;
                                      // if (pickedDate1 != null) {
                                      setState(() {
                                        pickedDate1 = pickedDate1;
                                        pickedDate2 = pickedDate2;
                                      });
                                      //}
                                    }

                                  }
                                },
                                child: Row(
                                  children: [
                                    Text(pickedDate1 != null ? "${monthsInYear[pickedDate1!.month]} ${pickedDate1!.day} ${pickedDate1!.year}": "",
                                      style: TextStyle(color: EvieColors.darkGrayishCyan),),
                                    SvgPicture.asset(
                                      "assets/buttons/calendar.svg",
                                      height: 24.h,
                                      width: 24.w,
                                    ),
                                  ],
                                ),),
                            ),

                            // Expanded(child: const Text("-"),),

                            Expanded(
                              child:  EvieButton_PickDate(
                                width: 155.w,
                                onPressed: () async {
                                  if(_selectedRadio == 3){

                                    var range = await showDateRangePicker(
                                      context: context,
                                      initialDateRange: pickedDateRange,
                                      firstDate: DateTime(DateTime.now().year-2),
                                      lastDate: pickedDate2 ?? DateTime.now(),
                                      builder: (context, child) {
                                        return Theme(data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: EvieColors.primaryColor,

                                          ), ), child: child!);
                                      },
                                    );

                                    // pickedDate2 = await showDatePicker(
                                    //     context: context,
                                    //     initialDate: bikeProvider.threatFilterDate2 ?? pickedDate1 ?? DateTime.now(),
                                    //     firstDate: pickedDate1 ?? DateTime(DateTime.now().year-2),
                                    //     lastDate: DateTime.now(),
                                    //   builder: (context, child) {
                                    //     return Theme(data: Theme.of(context).copyWith(
                                    //       colorScheme: ColorScheme.light(
                                    //         primary: EvieColors.primaryColor,
                                    //
                                    //       ), ), child: child!);
                                    //   },
                                    // );

                                    if(range != null){
                                      pickedDateRange = range;
                                      pickedDate1 = range.start;
                                      pickedDate2 = range.end;
                                      // if (pickedDate1 != null) {
                                      setState(() {
                                        pickedDate1 = pickedDate1;
                                        pickedDate2 = pickedDate2;
                                      });
                                      //}
                                    }
                                    // if (pickedDate2 != null) {
                                    //   setState(() {
                                    //     pickedDate2 = pickedDate2;
                                    //   });
                                    // }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Text(pickedDate2 != null ? "${monthsInYear[pickedDate2!.month]} ${pickedDate2!.day} ${pickedDate2!.year}": "",
                                      style: const TextStyle(color: EvieColors.darkGrayishCyan),),
                                    SvgPicture.asset(
                                      "assets/buttons/calendar.svg",
                                      height: 24.h,
                                      width: 24.w,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],),
                      ),
                      const EvieDivider(),
                    ],
                  ),
                ),
                leftContent: "Cancel",
                rightContent: "Apply Filter",
                onPressedLeft: (){
                  SmartDialog.dismiss();
                },
                onPressedRight: () async {

                  if(pickedDate == ThreatFilterDate.custom){
                    if(pickedDate1 != null && pickedDate2 != null){
                      await bikeProvider.applyThreatFilterDate(pickedDate,pickedDate1, pickedDate2);
                      SmartDialog.dismiss();
                    }else{
                      showNoSelectDate();
                    }
                  }else{
                    await bikeProvider.applyThreatFilterDate(pickedDate, DateTime.now(), DateTime.now());
                    SmartDialog.dismiss();
                  }
                });
          }
      )
  );
}