import 'dart:async';
import 'package:dio/dio.dart';
import 'package:evie_test/api/backend/server_api_base.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

///These keys are revoked. Use keys and product ids from Stripe dashboard.

final apiKey = dotenv.env['STRIPE_API_KEY'] ?? 'SAK not found';
final secretKey = dotenv.env['STRIPE_SECRET_KEY'] ?? 'SSK secret not found';

class StripeApiCaller {

  ///$plans > $prices[0]id ---> priceId /// price_1Lp0yCBjvoM881zMsahs6rkP
  ///$users > user.stripeId ----> customerId /// cus_MWhzvDMk1TI57G
  static Future redirectToCheckout(String deviceIMEI, String planId, String priceId, String customerId) async {
    final auth = 'Bearer ' + secretKey;
    const header = Headers.formUrlEncodedContentType;
    final body = {
      'line_items': [
        {
          'price': priceId,
          'quantity': 1,
        }
      ],
      'mode': 'payment',
      'success_url': 'https://evie-6952d.web.app/success.html',
      'cancel_url': 'https://evie-6952d.web.app/cancel.html',
      "customer" : customerId,
      "client_reference_id": deviceIMEI + "," + planId,
    };

    var sessionId;
    await ServerApiBase.postRequest(auth, "https://api.stripe.com/v1/checkout/sessions", body, header).then((value) {
      sessionId = value['id'];
    });
    return sessionId;
  }

  // /// $users > $subscriptions[0]id ----> currentSubId /// sub_1Lp1PjBjvoM881zMuyOFI50l
  // /// $plans > $prices[0]id ----> newPriceId  /// price_1Lp11KBjvoM881zM7rIdanjj
  // /// $users > $subscriptions.items[0].id  ----> currentSubItemId /// si_MY7fGJWs01DGF5
  // static Future changeSubscription(String currentSubId, String newPriceId, String currentSubItemId) async {
  //   final auth = 'Bearer ' + secretKey;
  //   final body = {
  //     "cancel_at_period_end": false,
  //     "proration_behavior": 'create_prorations',
  //     'items': [
  //       {
  //         'id': "si_MY7fGJWs01DGF5",
  //         'price': 'price_1Lp11KBjvoM881zM7rIdanjj',
  //       },
  //     ],
  //   };
  //   String url = 'https://api.stripe.com/v1/subscriptions/' + currentSubId;
  //
  //   var sessionId;
  //   await ServerApiBase.postRequest(auth, url, body).then((value) {
  //     sessionId = value;
  //   });
  //   return sessionId;
  // }
  //
  // ///$users > $subscriptions[0]id ---> subscriptionId /// sub_1Lp1PjBjvoM881zMuyOFI50l
  // static Future cancelSubscription(String subscriptionId) async {
  //   final auth = 'Bearer ' + secretKey;
  //   final body = {};
  //   String url = "https://api.stripe.com/v1/subscriptions/" + subscriptionId;
  //
  //   var response;
  //   await ServerApiBase.deleteRequest(auth, url, body).then((value) async {
  //     response = value;
  //   });
  //   return response;
  // }
}