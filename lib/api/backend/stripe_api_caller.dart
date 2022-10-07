import 'dart:async';
import 'package:evie_test/api/backend/server_api_base.dart';

///These keys are revoked. Use keys and product ids from Stripe dashboard.
const apiKey =
    'pk_test_51LjzhfBjvoM881zM0adsmftcWyPvdhW0wZ8yVB572DACYrc5k9hxPiBtpOQU84kLSgq7e08Ju0YFIcD4FpR2VFFn00dtiD6bU9';
const secretKey =
    'sk_test_51LjzhfBjvoM881zMsw8IwpBDjhaeSP95cNjmi759OFcISxhNyGNaHo3uWwBOdZaSNKTetxwrgCmJSqZvnDlz7KgR00pEbKQ166';

class StripeApiCaller {

  ///$plans > $prices[0]id ---> priceId /// price_1Lp0yCBjvoM881zMsahs6rkP
  ///$users > user.stripeId ----> customerId /// cus_MWhzvDMk1TI57G
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
      // "subscription_data": {
      //   "trial_period_days":1
      // },
    };

    var sessionId;
    await ServerApiBase.postRequest(auth, "https://api.stripe.com/v1/checkout/sessions", body).then((value) {
      sessionId = value['id'];
    });
    return sessionId;
  }

  /// $users > $subscriptions[0]id ----> currentSubId /// sub_1Lp1PjBjvoM881zMuyOFI50l
  /// $plans > $prices[0]id ----> newPriceId  /// price_1Lp11KBjvoM881zM7rIdanjj
  /// $users > $subscriptions.items[0].id  ----> currentSubItemId /// si_MY7fGJWs01DGF5
  static Future changeSubscription(String currentSubId, String newPriceId, String currentSubItemId) async {
    const auth = 'Bearer ' + secretKey;
    final body = {
      "cancel_at_period_end": false,
      "proration_behavior": 'create_prorations',
      'items': [
        {
          'id': "si_MY7fGJWs01DGF5",
          'price': 'price_1Lp11KBjvoM881zM7rIdanjj',
        },
      ],
    };
    String url = 'https://api.stripe.com/v1/subscriptions/' + currentSubId;

    var sessionId;
    await ServerApiBase.postRequest(auth, url, body).then((value) {
      sessionId = value;
    });
    return sessionId;
  }

  ///$users > $subscriptions[0]id ---> subscriptionId /// sub_1Lp1PjBjvoM881zMuyOFI50l
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