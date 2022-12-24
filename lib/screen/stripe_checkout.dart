import 'package:evie_test/api/backend/sim_api_caller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../api/backend/stripe_api_caller.dart';
import '../api/model/bike_model.dart';
import '../api/model/plan_model.dart';
import '../api/model/price_model.dart';
import '../api/provider/bike_provider.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bikeProvider = context.read<BikeProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          if (request.url.startsWith('https://evie-6952d.web.app/success.html')) {
            // ///Added BikePlanModel in firestore.
            // _bikeProvider.updatePurchasedPlan(widget.bikeModel.deviceIMEI!, widget.planModel).then((result) {
            //   if (result) {
            //     SimApiCaller.getAccessToken().then((accessToken) {
            //       SimApiCaller.activateSim(accessToken, widget.bikeModel.simSetting!.iccid!).then((value) {
            //         if (value['status']['primary'] == "PENDING" && value['status']['secondary'] == "LIVE") {
            //           ///Successfully activate sim but in pending state.
            //           SmartDialog.show(widget: EvieSingleButtonDialogCupertino(title: 'Successfully subscribed', content: 'Plan Already subscribed.', rightContent: 'View Plan', onPressedRight: () {Navigator.of(context).pop();},));
            //         }
            //       });
            //     });
            //   }
            // });

            SmartDialog.show(widget: EvieSingleButtonDialogCupertino(title: 'Successfully subscribed', content: 'Plan Already subscribed.', rightContent: 'View Plan', onPressedRight: () {Navigator.of(context).pop();},));


          } else if (request.url.startsWith('https://evie-6952d.web.app/cancel.html')) {
            SmartDialog.show(widget: EvieSingleButtonDialogCupertino(title: 'Operation failed', content: 'User cancelled the action', rightContent: 'BACK', onPressedRight: () {Navigator.of(context).pop();},));
          }
          return NavigationDecision.navigate;
        },
      ),
    );
  }

  String get initialUrl => 'https://evie-6952d.web.app/';

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