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

  // Renamed backend: use the same endpoint/key but call getProducts
  static const _productsUrl = 'https://glpt3ohk3zbyfdlla3fnj2r6ny.appsync-api.ca-central-1.amazonaws.com/graphql';
  static const _productsKey = 'da2-hykzcqryevbrjjwc56jbsjcg3m';

  static const _productStatusUrl   = 'https://jnnyyvz3prfudoenrzuudwdtea.appsync-api.ca-central-1.amazonaws.com/graphql';
  static const _productStatusKey   = 'da2-7tsjq7tch5e2xojhguyhc6pwm4';

  String? _authToken;
  void setAuthToken(String token) => _authToken = token;

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

    print('[GraphQLService:_post] POST $url vars=${jsonEncode(variables)}');

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
      print('[GraphQLService:_post] Non-JSON (code=${resp.statusCode}): ${resp.body}');
      throw Exception('Non-JSON response from $url (HTTP ${resp.statusCode})');
    }

    print('[GraphQLService:_post] Raw response from $url:\n${const JsonEncoder.withIndent('  ').convert(body)}');

    if (resp.statusCode != 200) throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    if (body['errors'] != null) throw Exception(jsonEncode(body['errors']));

    final data = body['data'];
    if (data is! Map<String, dynamic>) throw Exception('Missing "data" in GraphQL response.');
    return data;
  }

  Future<Map<String, dynamic>?> signin(String username, String password, String siteName) async {
    const query = r'''
      mutation ($user_name: String!, $password: String!, $site_name: String!) {
        signin(user_name: $user_name, password: $password, site_name: $site_name) {
          party { party_id user_name email }
          error_code
        }
      }
    ''';

    print('[GraphQLService:signin] user=$username site=$siteName');
    try {
      final data = await _post(
        url: _signinUrl,
        apiKey: _signinKey,
        query: query,
        variables: {
          'user_name': username,
          'password': password,
          'site_name': siteName.toUpperCase(),
        },
      );
      return data['signin'] as Map<String, dynamic>?;
    } catch (e) {
      print('[GraphQLService:signin] $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> signup(Map<String, dynamic> party, String siteName) async {
    const query = r'''
      mutation Signup($party: PartyInput!, $site_name: String!) {
        signup(party: $party, site_name: $site_name) {
          party_id user_name first_name last_name email mobile error_code message
        }
      }
    ''';

    print('[GraphQLService:signup] party=$party');
    try {
      final data = await _post(
        url: _signupUrl,
        apiKey: _signupKey,
        query: query,
        variables: {
          'party': party,
          'site_name': siteName.toUpperCase(),
        },
      );
      return data['signup'] as Map<String, dynamic>?;
    } catch (e) {
      print('[GraphQLService:signup] $e');
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

    print('[GraphQLService:getAlerts] site=$siteName');
    try {
      final data = await _post(
        url: _alertsUrl,
        apiKey: _alertsKey,
        query: query,
        variables: {
          'site': siteName.toUpperCase(),
          'from': fromDate,
          'to': toDate,
          'limit': recordsPerPage,
        },
      );
      return (data['getAlerts']?['alerts'])?.cast<Map<String, dynamic>>();
    } catch (e) {
      print('[GraphQLService:getAlerts] $e');
      return null;
    }
  }

  // =========================
  // PRODUCTS (renamed API)
  // =========================

  /// New canonical method: fetch product codes for a user on a site.
  Future<List<String>> getProducts({
    required String siteName,
    required int partyId,
  }) async {
    const query = r'''
      query GetProducts($site_name: String!, $party_id: Int!) {
        getProducts(site_name: $site_name, party_id: $party_id) {
          product_code
        }
      }
    ''';

    print('[GraphQLService:getProducts] site=$siteName partyId=$partyId');
    try {
      final data = await _post(
        url: _productsUrl,
        apiKey: _productsKey,
        query: query,
        variables: {
          'site_name': siteName.toUpperCase(),
          'party_id': partyId,
        },
      );

      final raw = data['getProducts'];
      if (raw is! List) {
        print('[GraphQLService:getProducts] Unexpected shape: $raw');
        return <String>[];
      }
      final list = raw
          .map((e) => (e as Map<String, dynamic>)['product_code']?.toString())
          .whereType<String>()
          .toList();
      print('[GraphQLService:getProducts] $list');
      return list;
    } catch (e) {
      print('[GraphQLService:getProducts] $e');
      return <String>[];
    }
  }

  /// Backward-compat wrapper. Remove once all callers are migrated.
  @Deprecated('Use getProducts(siteName: ..., partyId: ...) instead.')
  Future<List<String>> getProductLicenses(String siteName, int partyId, {String? productCode}) {
    // Backend no longer supports filtering by product_code in this call.
    // We ignore productCode and delegate to getProducts.
    return getProducts(siteName: siteName, partyId: partyId);
  }

  // =========================
  // PRODUCT STATUS
  // =========================

  Future<Map<String, dynamic>?> getProductStatus({
    required String siteName,
    required int partyId,
    required String productCode,
  }) async {
    const query = r'''
      query GetProductStatus($site_name: String!, $party_id: Int!, $product_code: String!) {
        getProductStatus(site_name: $site_name, party_id: $party_id, product_code: $product_code) {
          product_code
          product_status_name
          product_status_value
          product_status_flag
        }
      }
    ''';

    print('[GraphQLService:getProductStatus] code=$productCode');
    try {
      final data = await _post(
        url: _productStatusUrl,
        apiKey: _productStatusKey,
        query: query,
        variables: {
          'site_name': siteName.toUpperCase(),
          'party_id': partyId,
          'product_code': productCode,
        },
      );

      final raw = data['getProductStatus'];
      if (raw is List && raw.isNotEmpty) {
        print('[GraphQLService:getProductStatus] $raw');
        return {
          'product_status_flag': raw[0]['product_status_flag'],
          'statuses': raw.map((item) => {
                'product_status_name': item['product_status_name'],
                'product_status_value': item['product_status_value'],
              }).toList(),
        };
      }

      print('[GraphQLService:getProductStatus] Unexpected format: $raw');
      return null;
    } catch (e) {
      print('[GraphQLService:getProductStatus] $e');
      return null;
    }
  }
}
