import 'package:evie_test/api/backend/sim_api_caller.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../api/backend/stripe_api_caller.dart';
import '../api/dialog.dart';
import '../api/function.dart';
import '../api/model/bike_model.dart';
import '../api/model/plan_model.dart';
import '../api/model/price_model.dart';
import '../api/provider/bike_provider.dart';
import '../api/provider/notification_provider.dart';
import '../api/provider/notification_provider.dart';
import '../api/provider/notification_provider.dart';
import '../widgets/evie_single_button_dialog.dart';

class StripeCheckoutScreen extends StatefulWidget {
  final String sessionId;
  final PlanModel planModel;
  final PriceModel priceModel;
  final BikeModel bikeModel;

  const StripeCheckoutScreen({Key? key,
    required this.sessionId,
    required this.planModel,
    required this.priceModel,
    required this.bikeModel,
  }) : super(key: key);

  @override
  _StripeCheckoutScreenState createState() => _StripeCheckoutScreenState();
}

class _StripeCheckoutScreenState extends State<StripeCheckoutScreen> {
  late WebViewController _webViewController;
  late BikeProvider _bikeProvider;
  late NotificationProvider _notificationProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bikeProvider = context.read<BikeProvider>();
    _notificationProvider = context.read<NotificationProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: WebView(
        initialUrl: initialUrl,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (webViewController) =>
        _webViewController = webViewController,
        onPageFinished: (String url) {
          if (url == initialUrl) {
            _redirectToStripe(widget.sessionId);
          }
        },

        navigationDelegate: (NavigationRequest request) {
          if (request.url.startsWith('https://evie-126a6.web.app/success.html')) {
            // _notificationProvider.showNotification(FlutterLocalNotificationsPlugin(),
            //     'You’ve Upgraded to EV-Secure!',
            //     'You’ve subscribed to EV-Secure! Now you can enjoy exclusive EV+ perks until '
            //         '${monthsInYear[_bikeProvider.currentBikePlanModel!.expiredAt?.toDate().month]} ${_bikeProvider.currentBikePlanModel!.expiredAt?.toDate().day}, ${_bikeProvider.currentBikePlanModel!.expiredAt?.toDate().year}');
            changeToUserHomePageScreen(context);
            showWelcomeToEVClub(context);
          } else if (request.url.startsWith('https://evie-126a6.web.app/cancel.html')) {
            // SmartDialog.show(widget:
            // EvieSingleButtonDialog(title: 'Operation failed', content: 'User cancelled the action', rightContent: 'BACK', onPressedRight: () {SmartDialog.dismiss();},));
            changeToUserHomePageScreen(context);
          }
          return NavigationDecision.navigate;
        },
      ),
    ));
  }

  String get initialUrl => 'https://evie-126a6.web.app/stripe';

  Future<void> _redirectToStripe(String sessionId) async {
    final redirectToCheckoutJs = '''
    var stripe = Stripe(\'$apiKey\');
        
    stripe.redirectToCheckout({
      sessionId: '$sessionId'
    }).then(function (result) {
      result.error.message = 'Error'
    });
    ''';

    try {
      await _webViewController.runJavascript(redirectToCheckoutJs);
    } on PlatformException catch (e) {
      if (!e.details.contains(
          'JavaScript execution returned a result of an unsupported type')) {
        rethrow;
      }
    }
  }
}