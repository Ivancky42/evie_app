import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/api/function.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/api/sizer.dart';

import 'package:evie_test/widgets/custom_search_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../api/backend/debouncer.dart';
import '../../../api/colours.dart';
import '../../../api/dialog.dart';
import '../../../api/fonts.dart';
import '../../../api/snackbar.dart';
import '../../../bluetooth/modelResult.dart';
import '../../../widgets/evie_appbar.dart';
import 'account_container.dart';
import 'account_model.dart';
import 'account_search_container.dart';

class MyAccount extends StatefulWidget {
  const MyAccount( {Key? key}) : super(key: key);

  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {

  late CurrentUserProvider _currentUserProvider;

  List<AccountModel> accountList = [];
  List<AccountModel> _searchFirstResult = [];
  LinkedHashMap<String, AccountModel> _searchSecondResult = LinkedHashMap<String, AccountModel>();

  bool _isSearching = false;
  bool isFirstTimeConnected = false;

  final searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);

  late Future loadDataFuture;
  late ScaffoldMessengerState _navigator;

  Future<List<AccountModel>> loadData() async {

    var data = json.decode(await rootBundle.loadString("assets/files/account.json"));

    accountList.clear();
    for (var element in (data as List)) {
      accountList.add(AccountModel.fromJson(element));
    }

    return accountList;
  }

  @override
  void initState() {
    super.initState();

    loadDataFuture = loadData();
  }

  @override
  void didChangeDependencies() {
    _navigator = ScaffoldMessenger.of(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    hideCurrentSnackBar(_navigator);
    searchController.dispose();
    super.dispose();
  }

  Widget secondSearchResult() {
    List<AccountSearchContainer> accountContainer2List = [];
    _searchSecondResult.forEach((key, value) {
      accountContainer2List.add(AccountSearchContainer(accountModel: value, searchResult: key, currentSearchString: searchController.text.trim().toString(),));
    });

    return Column(
      children: [
        ...accountContainer2List,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        bool? exitApp = await showQuitApp() as bool?;
        return exitApp ?? false;
      },


      child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 51.h, 0.w, 7.h),
            child: Container(
              child: Text(
                "My Account",
                style: EvieTextStyles.h1.copyWith(color: EvieColors.mediumBlack),
              ),
            ),
          ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 4.h),
                child: CustomSearchController(
                  suffixIcon: _isSearching ?
                  GestureDetector(
                    onTap: () {
                      _debouncer.run(() {
                        searchController.text = "";
                        _searchFirstResult.clear();
                        _searchSecondResult.clear();
                        _isSearching = false;
                        setState(() {
                        });
                      });
                    },
                    child: const Icon(Icons.cancel),
                  ) : null,
                  searchController: searchController,
                  onChanged: (value) {
                    if (value.trim().isEmpty) {
                      _debouncer.run(() {
                        _searchFirstResult.clear();
                        _searchSecondResult.clear();
                        _isSearching = false;
                        setState(() {
                        });
                      });
                    }
                    else {
                      _debouncer.run(() {
                        _searchFirstResult.clear();
                        _searchSecondResult.clear();
                        _isSearching = true;
                        _searchFirstResult.addAll(accountList
                            .where((AccountModel AccountModel) {
                          if (AccountModel.label.toLowerCase().contains(
                              searchController.text.trim().toLowerCase())) {
                            if (AccountModel.secondLevelLabel != null) {
                              for (var element in AccountModel
                                  .secondLevelLabel!) {
                                if (element.toString().toLowerCase().contains(
                                    searchController.text.trim()
                                        .toLowerCase())) {
                                  setState(() {
                                    _searchSecondResult.putIfAbsent(element.toString(), () => AccountModel);
                                  });
                                }
                              }
                            }
                            return true;
                          }
                          else if (AccountModel.secondLevelLabel != null) {
                            for (var element in AccountModel
                                .secondLevelLabel!) {
                              if (element.toString().toLowerCase().contains(
                                  searchController.text.trim().toLowerCase())) {
                                setState(() {
                                  _searchSecondResult.putIfAbsent(element.toString(), () => AccountModel);
                                });
                              }
                            }
                            return false;
                          }
                          else {
                            _searchFirstResult.clear();
                            return false;
                          }
                        }));
                        setState(() {});
                      });
                    }
                  },
                ),
              ),
              Container(
                height: 96.h,
                child: Row(
                  children: [
                    Padding(
                      padding:
                      EdgeInsets.fromLTRB(27.7.w, 14.67.h, 18.67.w, 14.67.h),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          //imageUrl: document['profileIMG'],
                          imageUrl: _currentUserProvider.currentUserModel != null ? _currentUserProvider.currentUserModel!.profileIMG : "",
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                          width: 66.67.h,
                          height: 66.67.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          _currentUserProvider.currentUserModel?.name ?? "",
                          style:EvieTextStyles.headline.copyWith(color:EvieColors.lightBlack),
                        ),
                        Text(
                          _currentUserProvider.currentUserModel?.email ?? "",
                          style:EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan),
                        ),

                      ],
                    )
                  ],
                ),
              ),
              Divider(
                thickness: 0.5.h,
                color: EvieColors.darkWhite,
                height: 0,
              ),
              FutureBuilder(
                  future: loadDataFuture,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    else if (snapshot.connectionState == ConnectionState.done) {
                      if (!_isSearching) {
                        return Expanded(
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                ...accountList.map((e) => AccountContainer(accountModel: e)).toList(),
                              ],
                            ),
                          )
                      );
                      } else {
                        return Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  ..._searchFirstResult.map((e) =>
                                      AccountContainer(accountModel: e))
                                      .toList(),
                                  secondSearchResult(),
                                ],
                              ),
                            )
                        );
                      }
                    }
                    else {
                      return Container(color: Colors.purple,);
                    }
                  }
              ),

            ],
          )),
    );
  }
}
