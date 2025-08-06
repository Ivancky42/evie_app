import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/provider/ride_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:evie_test/screen/ride/ride_history_data2.dart';
import 'package:flutter/material.dart';
import '../../api/fonts.dart';

class RideHistory extends StatefulWidget {
  const RideHistory({super.key});

  @override
  _RideHistoryState createState() => _RideHistoryState();
}

class _RideHistoryState extends State<RideHistory> with SingleTickerProviderStateMixin {

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    checkSelectedTab();

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: DefaultTabController( // Uncomment this line
        length: 4,
        child: Scaffold(
          body: Container(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification) {
                  // Handle scroll updates here
                  // The user is scrolling
                  //print('User is scrolling');
                }
                return false; // Continue notifying other listeners
              },
              child: Scaffold(
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0.h, 0.w, 22.h),
                      child: Container(
                        child: Text(
                          "Ride History",
                          style: EvieTextStyles.target_reference_h1,
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 30.h),
                      child: Container(
                        decoration: BoxDecoration(
                            color: EvieColors.lightGrayishCyan,
                            border: Border.all(
                              color: EvieColors.lightGrayishCyan,
                            ),
                            borderRadius: const BorderRadius.all(Radius.circular(30)
                            )
                        ),
                        child: SizedBox(
                          height: 40.h,
                          child: TabBar(
                            controller: _tabController,
                            labelColor: EvieColors.primaryColor,
                            unselectedLabelColor: EvieColors.lightBlack,
                            indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                color: EvieColors.dividerWhite),
                            indicatorSize: TabBarIndicatorSize.tab,
                            tabs: [
                              Tab(
                                child: SizedBox(
                                  //width: double.infinity,
                                  height: double.infinity,
                                  //color: Colors.red,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 2.h),
                                        child: Text(
                                          "Day",
                                          style: EvieTextStyles.ctaSmall,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Tab(
                                child: SizedBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 2.h),
                                        child: Text(
                                          "Week",
                                          style: EvieTextStyles.ctaSmall,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Tab(
                                child: SizedBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 2.h),
                                        child: Text(
                                          "Month",
                                          style: EvieTextStyles.ctaSmall,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Tab(
                                child: SizedBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 2.h),
                                        child: Text(
                                          "Year",
                                          style: EvieTextStyles.ctaSmall,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: TabBarView(
                          controller: _tabController,
                          children: [
                            RideHistoryData2(RideFormat.day),
                            RideHistoryData2(RideFormat.week),
                            RideHistoryData2(RideFormat.month),
                            RideHistoryData2(RideFormat.year),
                          ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );
  }

  void checkSelectedTab() {
    //print("Selected Tab: ${_tabController?.index}");
  }
}

