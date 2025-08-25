import 'dart:convert';
import 'package:http/http.dart' as http;

class GraphQLService {
  // --- Endpoints & API keys ---
  static const _signinUrl   = 'https://kf6iirlcgrbqdmr2b6nq5s6g3q.appsync-api.ca-central-1.amazonaws.com/graphql';
  static const _signinKey   = 'da2-gyewjbxhlvdarogtzp5mbyrm6m';

  static const _signupUrl   = 'https://l5a4sfcxxfbj3icqefjhoup4ti.appsync-api.ca-central-1.amazonaws.com/graphql';
  static const _signupKey   = 'da2-3g2r42737jf73igdhfsrp2mh2y';

  static const _alertsUrl   = 'https://tb5xwefsybcitbefa3wksxrazm.appsync-api.ca-central-1.amazonaws.com/graphql';
  static const _alertsKey   = 'da2-7lmmoz642fb3bakwqc4e5k6ytq';

  static const _productsUrl = 'https://glpt3ohk3zbyfdlla3fnj2r6ny.appsync-api.ca-central-1.amazonaws.com/graphql';
  static const _productsKey = 'da2-hykzcqryevbrjjwc56jbsjcg3m';

  // --- Auth token (set after signin) ---
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  // Core POST helper
  Future<Map<String, dynamic>> _post({
    required String url,
    required String apiKey,
    required String query,
    Map<String, dynamic>? variables,
    Map<String, String>? extraHeaders,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'x-api-key': apiKey,
      if (_authToken != null) 'authorization': 'Bearer $_authToken',
      if (extraHeaders != null) ...extraHeaders,
    };

    final resp = await http
        .post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode({'query': query, 'variables': variables ?? {}}),
        )
        .timeout(const Duration(seconds: 25));

    late final Map<String, dynamic> body;
    try {
      body = jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Non-JSON response from $url (HTTP ${resp.statusCode})');
    }

    print(body);

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode} from $url: ${resp.body}');
    }
    if (body['errors'] != null) {
      throw Exception(jsonEncode(body['errors']));
    }

    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Missing "data" in GraphQL response from $url');
    }
    return data;
  }

  // ----------------- Public API calls -----------------

  Future<Map<String, dynamic>?> signin(
      String username, String password, String siteName) async {
    const query = r'''
      mutation ($user_name: String!, $password: String!, $site_name: String!) {
        signin(user_name: $user_name, password: $password, site_name: $site_name) {
          party { party_id user_name email }
          error_code
        }
      }
    ''';

    print('==== SIGNIN RESPONSE ====');
    try {
      final data = await _post(
        url: _signinUrl,
        apiKey: _signinKey,
        query: query,
        variables: {
          'user_name': username,
          'password': password,
          'site_name': siteName,
        },
      );

      final result = data['signin'] as Map<String, dynamic>?;

      // ✅ Store the auth token if it exists
      if (result != null) {
        if (result['token'] != null) {
          setAuthToken(result['token']);
          print('✅ Auth token saved: ${result['token']}');
        } else {
          print('⚠️ No token returned in signin response: $result');
        }
      }

      return result;
    } catch (e) {
      print('[Signin] $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> signup(
      Map<String, dynamic> party, String siteName) async {
    const query = r'''
      mutation Signup($party: PartyInput!, $site_name: String!) {
        signup(party: $party, site_name: $site_name) {
          party_id user_name first_name last_name email mobile error_code message
        }
      }
    ''';

    print('==== SIGNUP RESPONSE ====');
    try {
      final data = await _post(
        url: _signupUrl,
        apiKey: _signupKey,
        query: query,
        variables: {'party': party, 'site_name': siteName},
      );
      return data['signup'] as Map<String, dynamic>?;
    } catch (e) {
      print('[Signup] $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getAlerts({
    required String siteName,
    required String fromDate,
    required String toDate,
    int recordsPerPage = 10,
  }) async {
    const query = r'''
      query GetAlerts($site: String!, $from: AWSDateTime!, $to: AWSDateTime!, $limit: Int!) {
        getAlerts(site_name: $site, from_date: $from, to_date: $to, records_per_page: $limit) {
          alerts {
            alert_id
            timestamp_occurred
            triggering_event_id
            triggering_event_type
            site_id
            alert_type
            alert_severity
            alert_message_code
            created_at
            image_url
          }
          next_cursor
          total_no_of_pages
        }
      }
    ''';

    print('==== GET ALERTS RESPONSE ====');
    try {
      final data = await _post(
        url: _alertsUrl,
        apiKey: _alertsKey,
        query: query,
        variables: {
          'site': siteName,
          'from': fromDate,
          'to': toDate,
          'limit': recordsPerPage,
        },
      );
      final list = (data['getAlerts']?['alerts']) as List<dynamic>?;
      return list?.cast<Map<String, dynamic>>();
    } catch (e) {
      print('[getAlerts] $e');
      return null;
    }
  }

    Future<List<String>> getProductLicenses(
      String siteName,
      int partyId, {
      String? username,
      String? password,
    }) async {
      const queryA = r'''
        query GetProductLicenses($site_name: String!, $party_id: Int!) {
          getProductLicenses(site_name: $site_name, party_id: $party_id) {
            product_code
          }
        }
      ''';

      const queryB = r'''
        query GetProductLicenses($site_name: String!, $party_id: Int!) {
          getProductLicenses(site_name: $site_name, party_id: $party_id) {
            product_codes
          }
        }
      ''';

      print('==== GET PRODUCTS RESPONSE ====');
      print('Calling getProductLicenses for: $username | $siteName | partyId=$partyId');

      try {
        final dataA = await _post(
          url: _productsUrl,
          apiKey: _productsKey,
          query: queryA,
          variables: {'site_name': siteName, 'party_id': partyId},
        );
        final rawA = dataA['getProductLicenses'];

        if (rawA is List) {
          return rawA
              .map((item) => item is Map ? item['product_code'].toString() : item.toString())
              .toList();
        }

        if (rawA is Map && rawA['product_codes'] is List) {
          return (rawA['product_codes'] as List).map((e) => e.toString()).toList();
        }

        // Try fallback queryB
        final dataB = await _post(
          url: _productsUrl,
          apiKey: _productsKey,
          query: queryB,
          variables: {'site_name': siteName, 'party_id': partyId},
        );
        final rawB = dataB['getProductLicenses'];
        if (rawB is Map && rawB['product_codes'] is List) {
          return (rawB['product_codes'] as List).map((e) => e.toString()).toList();
        }

        print('[getProductLicenses] Unexpected shape: $rawA / $rawB');
        return <String>[];
      } catch (e) {
        print('[getProductLicenses] $e');
        return <String>[];
      }
    }

/*
  /// Temporarily mock product codes to unblock development.
  Future<List<String>> getProductLicenses(
    String siteName,
    int partyId, {
    String? username,
    String? password,
  }) async {
    print('==== MOCK GET PRODUCTS RESPONSE ====');
    print('Returning mocked product codes for partyId=$partyId');

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mocked product codes
    return [
      'IND_SUR',
      'OUT_SUR',
      'TIM_TRA',
      'PHA_GOV',
    ];
  }
*/
/*
  /// Get product list — tries shape A first, then falls back to shape B if needed.
  Future<List<String>> getProductLicenses(
    String siteName,
    int partyId, {
    String? username,
    String? password,
  }) async {
    const queryA = r'''
      query GetProductLicenses($site_name: String!, $party_id: Int!) {
        getProductLicenses(site_name: $site_name, party_id: $party_id) {
          product_code
        }
      }
    ''';

    const queryB = r'''
      query GetProductLicenses($site_name: String!, $party_id: Int!) {
        getProductLicenses(site_name: $site_name, party_id: $party_id) {
          product_codes
        }
      }
    ''';

    print('==== GET PRODUCTS RESPONSE ====');
    print('Calling getProductLicenses for: $username | $siteName | partyId=$partyId');

    try {
      final dataA = await _post(
        url: _productsUrl,
        apiKey: _productsKey,
        query: queryA,
        variables: {'site_name': siteName, 'party_id': partyId},
      );
      final rawA = dataA['getProductLicenses'];

      if (rawA is List) {
        return rawA
            .map((item) => item is Map ? item['product_code'].toString() : item.toString())
            .toList();
      }

      if (rawA is Map && rawA['product_codes'] is List) {
        return (rawA['product_codes'] as List).map((e) => e.toString()).toList();
      }

      // Try fallback queryB
      final dataB = await _post(
        url: _productsUrl,
        apiKey: _productsKey,
        query: queryB,
        variables: {'site_name': siteName, 'party_id': partyId},
      );
      final rawB = dataB['getProductLicenses'];
      if (rawB is Map && rawB['product_codes'] is List) {
        return (rawB['product_codes'] as List).map((e) => e.toString()).toList();
      }

      print('[getProductLicenses] Unexpected shape: $rawA / $rawB');
      return <String>[];
    } catch (e) {
      print('[getProductLicenses] $e');
      return <String>[];
    }
  }
*/

  Future<Map<String, dynamic>?> getProductStatus({
    required String siteName,
    required int partyId,
    required String productCode,
  }) async {
    const query = r'''
      query GetProductStatus($site_name: String!, $party_id: Int!, $product_code: String!) {
        getProductStatus(site_name: $site_name, party_id: $party_id, product_code: $product_code) {
          product_status_flag
          statuses {
            product_status_name
            product_status_value
          }
        }
      }
    ''';

    try {
      final data = await _post(
        url: _productsUrl,
        apiKey: _productsKey,
        query: query,
        variables: {
          'site_name': siteName,
          'party_id': partyId,
          'product_code': productCode,
        },
      );
      return data['getProductStatus'] as Map<String, dynamic>?;
    } catch (e) {
      print('[getProductStatus] $e');
      return null;
    }
  }
}
