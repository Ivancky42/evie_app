import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:evie_test/widgets/evie_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';

import '../widgets/evie_button.dart';
import '../widgets/evie_checkbox.dart';
import '../widgets/evie_double_button_dialog.dart';
import '../widgets/evie_radio_button.dart';
import 'colours.dart';
import 'dialog.dart';
import 'fonts.dart';
import 'function.dart';

showFilterTreatStatus(BuildContext context, BikeProvider bikeProvider, bool isPickedStatusExpand, setState){

  bool warning = bikeProvider.threatFilterArray.contains("warning") ? true : false;
  bool fall = bikeProvider.threatFilterArray.contains("fall") ? true : false;
  bool danger = bikeProvider.threatFilterArray.contains("danger") ? true : false;
  bool lock = bikeProvider.threatFilterArray.contains("lock") ? true : false;
  bool unlock = bikeProvider.threatFilterArray.contains("unlock") ? true : false;

  if (bikeProvider.threatFilterArray.toSet().containsAll(['warning', 'fall', 'danger', 'lock', 'unlock'])) {
    warning = false;
    fall = false;
    danger = false;
    lock = false;
    unlock = false;
  }

  SmartDialog.show(
      backDismiss: false,
      keepSingle: true,
      builder: (context) => StatefulBuilder(
      builder: (context, setState){
        return  EvieDoubleButtonDialogFilter(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Filter by status", style: EvieTextStyles.headlineB),
                TextButton(
                    onPressed: () async {

                      setState(() {
                        warning = true;
                        fall = true;
                        danger = true;
                        lock = true;
                        unlock = true;
                      });

                  List<String> filter = ["warning","fall","danger", "lock", "unlock"];
                  await bikeProvider.applyThreatFilterStatus(filter);

                  SmartDialog.dismiss();
                }, child: Text("Clear", style: EvieTextStyles.body18.copyWith(color: EvieColors.primaryColor, fontWeight: FontWeight.w900),)
                )
              ],
            ),
            childContent: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 70.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                  ),
                  const EvieDivider(),
                  SizedBox(
                    height: 70.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                  ),
                  const EvieDivider(),
                  SizedBox(
                    height: 70.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                  ),
                  const EvieDivider(),
                  SizedBox(
                    height: 70.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Lock", style: EvieTextStyles.body18,
                        ),
                        EvieCheckBox(
                          onChanged: (value) {
                            setState(() {
                              lock = value!;
                            });
                          },
                          value: lock,
                        ),
                      ],
                    ),
                  ),
                 const EvieDivider(),
                  SizedBox(
                    height: 70.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Unlock", style: EvieTextStyles.body18,
                        ),
                        EvieCheckBox(
                          onChanged: (value) {
                            setState(() {
                              unlock = value!;
                            });
                          },
                          value: unlock,
                        ),
                      ],
                    ),
                  ),
                  const EvieDivider(),

                      ],),
                  ),

            leftContent: "Cancel",
            rightContent: "Apply Filter",
            onPressedLeft: (){
              setState(() {
                isPickedStatusExpand = true;
              });
              SmartDialog.dismiss();
            },
            onPressedRight: () async {

              List<String> filter = [];

              if(warning == true){filter.add("warning");}
              if(fall == true){filter.add("fall");}
              if(danger == true){filter.add("danger");}
              if(lock == true){filter.add("lock");}
              if(unlock == true){filter.add("unlock");}

              if (filter.isNotEmpty) {
                await bikeProvider.applyThreatFilterStatus(filter);
              }
              else {
                filter = ["warning","fall","danger", "lock", "unlock"];
                await bikeProvider.applyThreatFilterStatus(filter);
              }
              SmartDialog.dismiss();
            });
      }
      )
  );
}


showFilterTreatDate(BuildContext context, BikeProvider bikeProvider, bool isPickedDateExpand , setState){
  int selectedRadio = -1;

  if (bikeProvider.threatFilterDate == ThreatFilterDate.today){
    selectedRadio = 0;
  }else if(bikeProvider.threatFilterDate == ThreatFilterDate.yesterday){
    selectedRadio = 1;
  }else if(bikeProvider.threatFilterDate == ThreatFilterDate.last7days){
    selectedRadio = 2;
  }else if(bikeProvider.threatFilterDate == ThreatFilterDate.custom){
    selectedRadio = 3;
  }

  ///all, today, yesterday, last7days, custom
  ThreatFilterDate pickedDate = bikeProvider.threatFilterDate;
  DateTimeRange? pickedDateRange;
  DateTime? pickedDate1;
  DateTime? pickedDate2;

  SmartDialog.show(
      useSystem: true,
      backDismiss: false,
      builder: (context) => StatefulBuilder(
          builder: (context, setState){
            return  EvieDoubleButtonDialogFilter(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Filter by date", style: EvieTextStyles.headlineB),
                    TextButton(onPressed: (){
                      setState(() {
                        selectedRadio = -1;
                        pickedDate = ThreatFilterDate.today;
                        pickedDate1 != null ? pickedDate1 = null : -1;
                        pickedDate2 != null ? pickedDate2 = null : -1;
                        pickedDateRange = null;
                      });
                      bikeProvider.applyThreatFilterDate(ThreatFilterDate.all, DateTime.now(), DateTime.now());

                      SmartDialog.dismiss();
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
                          groupValue: selectedRadio,
                          onChanged: (value){
                            setState(() {
                              selectedRadio = value;
                              pickedDate = ThreatFilterDate.today;
                              pickedDate1 != null ? pickedDate1 = null : -1;
                              pickedDate2 != null ? pickedDate2 = null : -1;
                            });
                          }),
                      const EvieDivider(),

                      EvieRadioButton(
                          text: "Yesterday",
                          value: 1,
                          groupValue: selectedRadio,
                          onChanged: (value){
                            setState(() {
                              selectedRadio = value;
                              pickedDate =ThreatFilterDate.yesterday;
                              pickedDate1 != null ? pickedDate1 = null : -1;
                              pickedDate2 != null ? pickedDate2 = null : -1;
                            });
                          }),

                      const EvieDivider(),
                      EvieRadioButton(
                          text: "Last 7 days",
                          value: 2,
                          groupValue: selectedRadio,
                          onChanged: (value){

                            setState(() {
                              selectedRadio = value;
                              pickedDate = ThreatFilterDate.last7days;
                              pickedDate1 != null ? pickedDate1 = null : -1;
                              pickedDate2 != null ? pickedDate2 = null : -1;
                            });
                          }),

                      const EvieDivider(),
                      EvieRadioButton(
                          text: "Custom Date",
                          value: 3,
                          groupValue: selectedRadio,
                          onChanged: (value){
                            setState(() {
                              selectedRadio = value;
                              pickedDate = ThreatFilterDate.custom;
                            });
                          }),

                      Visibility(
                        visible: selectedRadio == 3,
                        child: Padding(
                          padding: EdgeInsets.only(top: 0, bottom: 12.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              EvieButton_PickDate(
                                width: 155.w,
                                height: 48.h,
                                onPressed: () async {
                                  if(selectedRadio == 3){
                                    var range = await showDateRangePicker(
                                      context: context,
                                      initialDateRange: pickedDateRange,
                                      firstDate: DateTime(DateTime.now().year-2),
                                      lastDate: DateTime.now(),
                                      builder: (context, child) {
                                        return Theme(
                                          data: ThemeData(
                                            colorScheme: ColorScheme.light(
                                              primary: EvieColors.primaryColor,  // Adjust primary color for headers
                                              onPrimary: Colors.white, // Adjust text color on primary
                                              onSurface: Colors.black, // Adjust text color on body
                                              onSecondary: Colors.white,
                                              secondary: EvieColors.primaryColor,
                                              surface: EvieColors.primaryColor,
                                            ),
                                            datePickerTheme: const DatePickerThemeData(
                                              rangePickerHeaderBackgroundColor: EvieColors.primaryColor,
                                              rangePickerHeaderForegroundColor: Colors.white,
                                              rangePickerBackgroundColor: Colors.white,
                                            ),
                                          ),
                                          child: child!,
                                        );
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
                                child: Container(
                                  width: 170.w,
                                  padding: EdgeInsets.all(6.w),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(pickedDate1 != null ? "${monthsInYear[pickedDate1!.month]} ${pickedDate1!.day} ${pickedDate1!.year}": "-",
                                        style: TextStyle(color: EvieColors.darkGrayishCyan),),
                                      SvgPicture.asset(
                                        "assets/buttons/calendar.svg",
                                        height: 24.h,
                                        width: 24.w,
                                      ),
                                    ],
                                  ),
                                )
                              ),

                              SizedBox(
                                child: Container(
                                  padding: EdgeInsets.only(left: 6.w, right: 6.w),
                                  color: Colors.black,
                                  width: 8.w,
                                  height: 1.h,
                                )
                              ),

                              EvieButton_PickDate(
                                width: 155.w,
                                height: 48.h,
                                onPressed: () async {
                                  if(selectedRadio == 3){

                                    var range = await showDateRangePicker(
                                      context: context,
                                      initialDateRange: pickedDateRange,
                                      firstDate: DateTime(DateTime.now().year-2),
                                      lastDate: DateTime.now(),
                                      builder: (context, child) {
                                        return Theme(
                                          data: ThemeData(
                                            colorScheme: ColorScheme.light(
                                              primary: EvieColors.primaryColor,  // Adjust primary color for headers
                                              onPrimary: Colors.white, // Adjust text color on primary
                                              onSurface: Colors.black, // Adjust text color on body
                                              onSecondary: Colors.white,
                                              secondary: EvieColors.primaryColor,
                                              surface: EvieColors.primaryColor,
                                            ),
                                            datePickerTheme: const DatePickerThemeData(
                                              rangePickerHeaderBackgroundColor: EvieColors.primaryColor,
                                              rangePickerHeaderForegroundColor: Colors.white,
                                              rangePickerBackgroundColor: Colors.white,
                                            ),
                                          ),
                                          child: SizedBox(
                                            width: 300.w,
                                            child: child!,
                                          ),
                                        );
                                      },
                                    );

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
                                child: Container(
                                  width: 170.w,
                                  padding: EdgeInsets.all(6.w),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(pickedDate2 != null ? "${monthsInYear[pickedDate2!.month]} ${pickedDate2!.day} ${pickedDate2!.year}": "-",
                                        style: const TextStyle(color: EvieColors.darkGrayishCyan),),
                                      SvgPicture.asset(
                                        "assets/buttons/calendar.svg",
                                        height: 24.h,
                                        width: 24.w,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],),
                        )
                      ),
                      const EvieDivider(),
                    ],
                  ),
                ),
                leftContent: "Cancel",
                rightContent: "Apply Filter",
                onPressedLeft: (){
                  setState(() {
                    isPickedDateExpand = true;
                  });
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