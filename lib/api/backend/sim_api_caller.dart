
import 'package:evie_test/api/backend/server_api_base.dart';

class SimApiCaller {

  static const String base_url = 'https://api.1ot.mobi/v1';
  // TODO: Please add client ID and password to env file.
  static String clientId = "API_USER_76759";
  static String password = "bcfb80a8a502913cea94b670c532060c034baf48725cb57702f2e67b4135cdd3";

  static Future getAccessToken() async {
    const auth = 'Bearer ';
    final body = {
      "grant_type": "password",
      "username": clientId,
      "client_id": clientId,
      "password": password,
    };

    var accessToken;
    await ServerApiBase.postRequest(auth, base_url + "/oauth/token", body).then((value) {
      accessToken = value['access_token'];
    });
    return accessToken;
  }

  static Future getSimStatus(String accessToken, String iccid) async {
    final auth = 'Bearer ' + accessToken;
    Map<String, dynamic> query = {
      "iccid": iccid,
    };
    var result;
    await ServerApiBase.getRequest(auth, base_url + "/get_sim", query).then((value) {
      result = value;
    });

    return result;
  }

  static Future activateSim(String accessToken, String iccid) async {
    final auth = 'Bearer ' + accessToken;
    Map<String, dynamic> query = {
      "iccid": iccid,
    };
    var result;
    await ServerApiBase.putRequestWithQuery(auth, base_url + "/activate", query).then((value) {
      result = value;
    });

    return result;
  }

  static Future deactivateSim(String accessToken, String iccid) async {
    final auth = 'Bearer ' + accessToken;
    Map<String, dynamic> query = {
      "iccid": iccid,
    };
    var result;
    await ServerApiBase.putRequestWithQuery(auth, base_url + "/deactivate", query).then((value) {
      result = value;
    });

    return result;
  }
}