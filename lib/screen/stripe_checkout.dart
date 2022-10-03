import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../api/constants.dart';
import '../widgets/evie_single_button_dialog.dart';

class StripeCheckoutPage extends StatefulWidget {
  final String sessionId;

  const StripeCheckoutPage({Key? key, required this.sessionId}) : super(key: key);

  @override
  _StripeCheckoutPageState createState() => _StripeCheckoutPageState();
}

class _StripeCheckoutPageState extends State<StripeCheckoutPage> {
  late WebViewController _webViewController;

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
            SmartDialog.show(widget: EvieSingleButtonDialog(title: 'Successfully subscribed', content: 'Plan Already subscribed.', rightContent: 'View Plan', onPressedRight: () {Navigator.of(context).pop();},));
          } else if (request.url.startsWith('https://evie-6952d.web.app/cancel.html')) {
            SmartDialog.show(widget: EvieSingleButtonDialog(title: 'Operation failed', content: 'User cancelled the action', rightContent: 'BACK', onPressedRight: () {Navigator.of(context).pop();},));
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