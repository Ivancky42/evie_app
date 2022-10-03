import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:evie_test/api/backend/server_api_base.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../colours.dart';
import '../constants.dart';

class StripeApiCaller {

  static Future redirectToCheckout(String priceId, String customerId) async {
    const auth = 'Bearer ' + secretKey;
    final body = {
      'line_items': [
        {
          'price': priceId,
          'quantity': 1,
        }
      ],
      'mode': 'subscription',
      'success_url': 'https://evie-6952d.web.app/success.html',
      'cancel_url': 'https://evie-6952d.web.app/cancel.html',
      "customer" : customerId,
    };

    var sessionId;
    await ServerApiBase.postRequest(auth, "https://api.stripe.com/v1/checkout/sessions", body).then((value) {
      sessionId = value['id'];
    });
    return sessionId;
  }

  static Future cancelSubscription(String subscriptionId) async {
    const auth = 'Bearer ' + secretKey;
    final body = {};
    String url = "https://api.stripe.com/v1/subscriptions/" + subscriptionId;

    var response;
    await ServerApiBase.deleteRequest(auth, url, body).then((value) async {
      response = value;
    });
    return response;
  }
}