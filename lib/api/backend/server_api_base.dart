import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:evie_test/api/colours.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ServerApiBase {

  static showServerErrorMsg(message) {
    Fluttertoast.showToast(
        msg: message,
        backgroundColor: EvieColors.greyFill.withOpacity(0.8),
        textColor: Colors.black);
  }

  static Future getRequest(String auth, String url, Map<String, dynamic> query) async {
    try {
      bool _hasConnection = await checkInternetConnection();
      if (!_hasConnection) {
        showServerErrorMsg('No internet connection');
        return "No internet connection";
      }

      try {
        final result = await Dio().get(
          url,
          queryParameters: query,
          options: Options(
            headers: {HttpHeaders.authorizationHeader: auth},
            contentType: Headers.jsonContentType,
          ),
        );
        return result.data;
      } on DioError catch (e, s) {
        var errorMessage = e.response?.data['error_description'];
        showServerErrorMsg(errorMessage);
        return errorMessage;
      }

    } on TimeoutException catch (err) {
      log('timeout exception: $err');
      showServerErrorMsg(
          'Connection timed out. Please try switch to other internet connection or check your internet connection.');
      return null;
    } on SocketException catch (eror) {
      log('timeout exception: $eror');
      showServerErrorMsg(
          'Connection timed out. Please try switch to other internet connection or check your internet connection.');
      return null;
    } on Exception catch (e) {
      log('exception: $e');
      showServerErrorMsg('Something went wrong');
      return null;
    }
  }

  static Future postRequest(String auth, String url, Map<dynamic, dynamic> body) async {
    try {
      bool _hasConnection = await checkInternetConnection();
      if (!_hasConnection) {
        showServerErrorMsg('No internet connection');
        return "No internet connection";
      }

      try {
        final result = await Dio().post(
          url,
          data: body,
          options: Options(
            headers: {HttpHeaders.authorizationHeader: auth},
            contentType: Headers.jsonContentType,
          ),
        );
        return result.data;
      } on DioError catch (e, s) {
        var errorMessage = e.response?.data['error_description'];
        showServerErrorMsg(errorMessage);
        return errorMessage;
      }

    } on TimeoutException catch (err) {
      log('timeout exception: $err');
      showServerErrorMsg(
          'Connection timed out. Please try switch to other internet connection or check your internet connection.');
      return null;
    } on SocketException catch (eror) {
      log('timeout exception: $eror');
      showServerErrorMsg(
          'Connection timed out. Please try switch to other internet connection or check your internet connection.');
      return null;
    } on Exception catch (e) {
      log('exception: $e');
      showServerErrorMsg('Something went wrong');
      return null;
    }
  }

  static Future putRequestWithQuery(String auth, String url, Map<String, dynamic> query) async {

    try {
      bool _hasConnection = await checkInternetConnection();
      if (!_hasConnection) {
        showServerErrorMsg('No internet connection');
        return "No internet connection";
      }

      try {
        final result = await Dio().put(
          url,
          queryParameters: query,
          options: Options(
            headers: {HttpHeaders.authorizationHeader: auth},
            contentType: Headers.jsonContentType,
          ),
        );
        return result.data;
      } on DioError catch (e, s) {
        var errorMessage = e.response?.data['error_description'];
        showServerErrorMsg(errorMessage);
        return errorMessage;
      }

    } on TimeoutException catch (err) {
      log('timeout exception: $err');
      showServerErrorMsg(
          'Connection timed out. Please try switch to other internet connection or check your internet connection.');
      return null;
    } on SocketException catch (eror) {
      log('timeout exception: $eror');
      showServerErrorMsg(
          'Connection timed out. Please try switch to other internet connection or check your internet connection.');
      return null;
    } on Exception catch (e) {
      log('exception: $e');
      showServerErrorMsg('Something went wrong');
      return null;
    }
  }

  static Future deleteRequest(String auth, String url, Map<dynamic, dynamic> body) async {
    try {
      bool _hasConnection = await checkInternetConnection();
      if (!_hasConnection) {
        showServerErrorMsg('No internet connection');
        return "No internet connection";
      }

      try {
        final result = await Dio().delete(
          url,
          data: body,
          options: Options(
            headers: {HttpHeaders.authorizationHeader: auth},
            contentType: "application/x-www-form-urlencoded",
          ),
        );
        return result.data;
      } on DioError catch (e, s) {
        print(e.response);
        throw e;
      }

    } on TimeoutException catch (err) {
      log('timeout exception: $err');
      showServerErrorMsg(
          'Connection timed out. Please try switch to other internet connection or check your internet connection.');
      return null;
    } on SocketException catch (eror) {
      log('timeout exception: $eror');
      showServerErrorMsg(
          'Connection timed out. Please try switch to other internet connection or check your internet connection.');
      return null;
    } on Exception catch (e) {
      log('exception: $e');
      showServerErrorMsg('Something went wrong');
      return null;
    }
  }

  static Future<bool> checkInternetConnection() async {
    bool isConnected = false;
    bool hasConnection = false;
    // connectivity package only able to capture whether user is connected to a network
    // but it doesn't provide any information about network connection
    // so by using connectivity alone is not reliable for knowing the user's network connection
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile) {
        // connected to a mobile network.
        isConnected = true;
      } else if (connectivityResult == ConnectivityResult.wifi) {
        // connected to a wifi network.
        isConnected = true;
      } else {
        // not connected to any network.
        isConnected = false;
      }
    } catch (err) {
      print('connectivity package error: $err');
      isConnected = false;
    }

    // after knowing user is connected to a network source,
    // then below function will try to ping the host
    // the reason why ping to `example.com` is under consideration of china region
    // whereby google.com (or other website) is blocked by china
    if (isConnected) {
      try {
        // don't change the lookup host
        final result = await InternetAddress.lookup('example.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          hasConnection = true;
        } else {
          hasConnection = false;
        }
      } on SocketException catch (_) {
        hasConnection = false;
      }
    } else {
      hasConnection = false;
    }
    return hasConnection;
  }
}