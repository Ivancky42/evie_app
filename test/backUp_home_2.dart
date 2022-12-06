 // Container(
 //                                decoration: BoxDecoration(
 //                                  color: const Color(0xFFECEDEB),
 //                                  borderRadius: BorderRadius.circular(16),
 //                                ),
 //                                child: ListView(
 //                                  controller: _scrollController,
 //                                  children: [
 //                                    //             SingleChildScrollView(
 //                                    //              controller: ModalScrollController.of(context),
 //                                    //              child:
 //                                    SizedBox(
 //                                      height: 60.h,
 //                                      child: Center(
 //                                        child: Column(
 //                                          mainAxisAlignment:
 //                                              MainAxisAlignment.start,
 //                                          children: <Widget>[
 //                                            Transform.translate(
 //                                              child: Container(
 //                                                child: Stack(
 //                                                  children: [
 //                                                    SvgPicture.asset(
 //                                                      "assets/buttons/home_indicator.svg",
 //                                                    ),
 //                                                  ],
 //                                                ),
 //                                              ),
 //                                              offset: const Offset(0, -25),
 //                                            ),
 //
 //                                            Padding(
 //                                              padding:
 //                                                  const EdgeInsets.all(10.0),
 //                                              child: Row(
 //                                                mainAxisAlignment:
 //                                                    MainAxisAlignment
 //                                                        .spaceBetween,
 //                                                children: [
 //                                                  Column(
 //                                                    mainAxisAlignment:
 //                                                        MainAxisAlignment.start,
 //                                                    children: [
 //                                                      Text(
 //                                                        _bikeProvider
 //                                                                .currentBikeModel!
 //                                                                .deviceName! ??
 //                                                            "",
 //                                                        style: TextStyle(
 //                                                            fontSize: 13.sp,
 //                                                            fontWeight:
 //                                                                FontWeight
 //                                                                    .w500),
 //                                                      ),
 //                                                      Text(
 //                                                        "Est. ${distanceBetween}m",
 //                                                        style: TextStyle(
 //                                                            fontSize: 10.sp,
 //                                                            fontWeight:
 //                                                                FontWeight
 //                                                                    .w400),
 //                                                      ),
 //                                                    ],
 //                                                  ),
 //                                                  Image(
 //                                                    image: AssetImage(
 //                                                        currentBikeStatusImage),
 //                                                    height: 7.h,
 //                                                    width: 20.w,
 //                                                  ),
 //                                                ],
 //                                              ),
 //                                            ),
 //                                            SizedBox(height: 1.h),
 //                                            Padding(
 //                                              padding:
 //                                                  const EdgeInsets.all(10.0),
 //                                              child: Row(children: [
 //                                                Container(
 //                                                  width: 10.w,
 //                                                  child: Image(
 //                                                    image: AssetImage(
 //                                                        currentSecurityIcon),
 //                                                    height: 24.0,
 //                                                  ),
 //                                                ),
 //                                                Column(
 //                                                  crossAxisAlignment:
 //                                                      CrossAxisAlignment.start,
 //                                                  children: [
 //                                                    const Text(
 //                                                      "Last Seen",
 //                                                      style: TextStyle(
 //                                                          fontWeight:
 //                                                              FontWeight.w400,
 //                                                          fontSize: 12),
 //                                                    ),
 //                                                    SizedBox(
 //                                                      height: 0.5.h,
 //                                                    ),
 //                                                    const Text(
 //                                                      "BIKE NOT CONNECTED",
 //                                                      style: TextStyle(
 //                                                          fontWeight:
 //                                                              FontWeight.bold,
 //                                                          fontSize: 16),
 //                                                    ),
 //                                                  ],
 //                                                ),
 //                                                const VerticalDivider(
 //                                                  thickness: 1,
 //                                                ),
 //                                                const Text(
 //                                                  "battery",
 //                                                  style: TextStyle(
 //                                                      fontWeight:
 //                                                          FontWeight.bold,
 //                                                      fontSize: 16),
 //                                                ),
 //                                              ]),
 //                                            ),
 //                                            //           )
 //                                            Align(
 //                                              alignment: Alignment.bottomCenter,
 //                                              child: Column(
 //                                                children: [
 //                                                  SizedBox(
 //                                                    height: 8.8.h,
 //                                                    width: 8.8.h,
 //                                                    child: FittedBox(
 //                                                      child:
 //                                                          FloatingActionButton(
 //                                                        elevation: 0,
 //                                                        backgroundColor:
 //                                                            cableLockState
 //                                                                        ?.lockState ==
 //                                                                    LockState
 //                                                                        .lock
 //                                                                ? lockColour
 //                                                                : const Color(
 //                                                                    0xffC1B7E8),
 //                                                        onPressed: cableLockState
 //                                                                    ?.lockState ==
 //                                                                LockState.lock
 //                                                            ? () {
 //                                                                ///Check is connected
 //
 //                                                                SmartDialog
 //                                                                    .showLoading(
 //                                                                        msg:
 //                                                                            "Unlocking");
 //                                                                StreamSubscription?
 //                                                                    subscription;
 //                                                                subscription =
 //                                                                    _bluetoothProvider
 //                                                                        .cableUnlock()
 //                                                                        .listen(
 //                                                                            (unlockResult) {
 //                                                                  SmartDialog.dismiss(
 //                                                                      status: SmartStatus
 //                                                                          .loading);
 //                                                                  subscription
 //                                                                      ?.cancel();
 //                                                                  if (unlockResult
 //                                                                          .result ==
 //                                                                      CommandResult
 //                                                                          .success) {
 //                                                                    subscription
 //                                                                        ?.cancel();
 //                                                                    ScaffoldMessenger.of(
 //                                                                            context)
 //                                                                        .showSnackBar(
 //                                                                      const SnackBar(
 //                                                                        content:
 //                                                                            Text('Bike is unlocked. To lock bike......'),
 //                                                                        duration:
 //                                                                            Duration(seconds: 2),
 //                                                                      ),
 //                                                                    );
 //                                                                  } else {
 //                                                                    SmartDialog.dismiss(
 //                                                                        status:
 //                                                                            SmartStatus.loading);
 //                                                                    subscription
 //                                                                        ?.cancel();
 //                                                                    ScaffoldMessenger.of(
 //                                                                            context)
 //                                                                        .showSnackBar(
 //                                                                      SnackBar(
 //                                                                        width:
 //                                                                            90.w,
 //                                                                        behavior:
 //                                                                            SnackBarBehavior.floating,
 //                                                                        shape: const RoundedRectangleBorder(
 //                                                                            borderRadius:
 //                                                                                BorderRadius.all(Radius.circular(10))),
 //                                                                        content:
 //                                                                            Container(
 //                                                                          height:
 //                                                                              9.h,
 //                                                                          child:
 //                                                                              Column(
 //                                                                            children: [
 //                                                                              const Align(
 //                                                                                alignment: Alignment.topLeft,
 //                                                                                child: Text('Bike is unlocked. To lock bike......'),
 //                                                                              ),
 //                                                                              Align(
 //                                                                                alignment: Alignment.centerRight,
 //                                                                                child: TextButton(
 //                                                                                  child: const Text(
 //                                                                                    'LEARN MORE',
 //                                                                                    style: TextStyle(color: Color(0xff836ED3)),
 //                                                                                  ),
 //                                                                                  onPressed: () {},
 //                                                                                ),
 //                                                                              ),
 //                                                                            ],
 //                                                                          ),
 //                                                                        ),
 //                                                                        duration:
 //                                                                            const Duration(seconds: 4),
 //                                                                      ),
 //                                                                    );
 //                                                                  }
 //                                                                }, onError: (error) {
 //                                                                  SmartDialog.dismiss(
 //                                                                      status: SmartStatus
 //                                                                          .loading);
 //                                                                  subscription
 //                                                                      ?.cancel();
 //                                                                  SmartDialog.show(
 //                                                                      widget: EvieSingleButtonDialogCupertino(
 //                                                                          title: "Error",
 //                                                                          content: "Cannot unlock bike, please place the phone near the bike and try again.",
 //                                                                          rightContent: "OK",
 //                                                                          onPressedRight: () {
 //                                                                            SmartDialog.dismiss();
 //                                                                          }));
 //                                                                });
 //                                                              }
 //                                                            : null,
 //                                                        //icon inside button
 //                                                        child: lockImage,
 //                                                      ),
 //                                                    ),
 //                                                  ),
 //                                                ],
 //                                              ),
 //                                            ),
 //                                          ],
 //                                        ),
 //                                      ),
 //                                    )
 //                                  ],
 //                                )),