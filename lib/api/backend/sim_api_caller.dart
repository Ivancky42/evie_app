
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:evie_test/api/backend/server_api_base.dart';

class SimApiCaller {

  static const String base_url = 'https://api.1ot.mobi/v1';
  // TODO: Please add client ID and password to env file.
  static String clientId = "API_USER_76759";
  static String password = "380364f739e8735330e03afb8b375f6e631d586359ea512ca5921ff2c3c95597";

  static Future getAccessToken() async {
    const auth = 'Bearer ';
    const header = Headers.formUrlEncodedContentType;
    final body = {
      "grant_type": "password",
      "username": clientId,
      "client_id": clientId,
      "password": password,
    };

    var accessToken;
    await ServerApiBase.postRequest(auth, base_url + "/oauth/token", body, header).then((value) {
      accessToken = value['access_token'];
    });
    return accessToken;
  }

  static Future getSimStatus(String accessToken, String iccid) async {
    final auth = 'Bearer ' + accessToken;
    const header = Headers.jsonContentType;
    Map<String, dynamic> query = {
      "iccid": iccid,
    };
    var result;
    await ServerApiBase.getRequest(auth, base_url + "/get_sim", query, header).then((value) {
      result = value;
    });

    return result;
  }

  static Future setDataLimit(String accessToken, int limit) async {
    final auth = 'Bearer $accessToken';
    const header = Headers.jsonContentType;

    String jsonData = '''{
  "values": [
    "8944502701221973016",
    "8944502701221973024",
    "8944502701221973032",
    "8944502701221973040",
    "8944502701221973057",
    "8944502701221973065",
    "8944502701221973073",
    "8944502701221973081",  
  ]
}''';

    // Parse the JSON string
    Map<String, dynamic> data = json.decode(jsonData);

// Access the "values" field and convert it to a List<String>
    List<String> iccidList = List<String>.from(data['values']);

    // Join the ICCID list into a comma-separated string
    final iccidParam = iccidList.join(',');

    Map<String, dynamic> query = {
      'iccid': iccidParam,
      'limit': limit,
    };

    var result;

    try {
      final response = await ServerApiBase.putRequestWithQuery(auth, base_url + "/set_data_limit", query, header);
      result = response.data;
    } catch (e) {
      // Handle error
      print('Error: $e');
    }

    return result;
  }

  static Future activateSim(String accessToken, String iccid) async {
    final auth = 'Bearer ' + accessToken;
    const header = Headers.jsonContentType;
    Map<String, dynamic> query = {
      "iccid": iccid,
    };
    var result;
    await ServerApiBase.putRequestWithQuery(auth, base_url + "/activate", query, header).then((value) {
      result = value;
    });

    return result;
  }

  static Future deactivateSim(String accessToken, String iccid) async {
    final auth = 'Bearer ' + accessToken;
    const header = Headers.jsonContentType;
    Map<String, dynamic> query = {
      "iccid": iccid,
    };
    var result;
    await ServerApiBase.putRequestWithQuery(auth, base_url + "/deactivate", query, header).then((value) {
      result = value;
    });

    return result;
  }
}