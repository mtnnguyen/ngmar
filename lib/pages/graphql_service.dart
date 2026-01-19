import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

class GraphQLService {
  // --- Endpoints & API keys --- 
  // THESE ARE EXAMPLES
  static const _signinUrl = 'https://kf6iirlcgrbqdmr2b6nq5s6g3q.appsync-api.ca-central-1.amazonaws.com/graphql';
  static const _signinKey = 'da2-gyewjbxhlvdarogtzp5mbyrm6m';

  static const _signupUrl = 'https://l5a4sfcxxfbj3icqefjhoup4ti.appsync-api.ca-central-1.amazonaws.com/graphql';
  static const _signupKey = 'da2-3g2r42737jf73igdhfsrp2mh2y';

  static const _alertsUrl = 'https://tb5xwefsybcitbefa3wksxrazm.appsync-api.ca-central-1.amazonaws.com/graphql';
  static const _alertsKey = 'da2-7lmmoz642fb3bakwqc4e5k6ytq';

  static const _productsUrl = 'https://glpt3ohk3zbyfdlla3fnj2r6ny.appsync-api.ca-central-1.amazonaws.com/graphql';
  static const _productsKey = 'da2-hykzcqryevbrjjwc56jbsjcg3m';

  static const _productStatusUrl = 'https://jnnyyvz3prfudoenrzuudwdtea.appsync-api.ca-central-1.amazonaws.com/graphql';
  static const _productStatusKey = 'da2-7tsjq7tch5e2xojhguyhc6pwm4';

  String? _authToken;
  void setAuthToken(String token) => _authToken = token;

  /// Internal helper to post GraphQL requests with API key and optional auth token
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

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode({'query': query, 'variables': variables ?? {}}),
          )
          .timeout(const Duration(seconds: 25));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      print('[GraphQLService:_post] Raw response from $url:\n${const JsonEncoder.withIndent('  ').convert(body)}');

      if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}: ${response.body}');
      if (body['errors'] != null) throw Exception(jsonEncode(body['errors']));

      final data = body['data'];
      if (data is! Map<String, dynamic>) throw Exception('Missing "data" in GraphQL response.');
      return data;
    } on SocketException {
      throw Exception('No internet connection.');
    } on TimeoutException {
      throw Exception('Request to $url timed out.');
    } on FormatException {
      throw Exception('Non-JSON response from $url.');
    } catch (e) {
      print('[GraphQLService:_post] Unexpected error: $e');
      rethrow;
    }
  }

  /// Calls the signin mutation and returns user info and error code
  Future<Map<String, dynamic>?> signin(String username, String password, String siteName) async {
    const query = r'''
      mutation ($user_name: String!, $password: String!, $site_name: String!) {
        signin(user_name: $user_name, password: $password, site_name: $site_name) {
          party { party_id user_name email }
          error_code
        }
      }
    ''';

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

  /// Registers a new user via signup mutation
  Future<Map<String, dynamic>?> signup(Map<String, dynamic> party, String siteName) async {
    const query = r'''
      mutation Signup($party: PartyInput!, $site_name: String!) {
        signup(party: $party, site_name: $site_name) {
          party_id user_name first_name last_name email mobile error_code message
        }
      }
    ''';

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

  /// Fetches recent alerts for the given site and date range
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
        }
      }
    ''';

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

  /// Retrieves the list of licensed product codes for a user/site
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
      if (raw is! List) return <String>[];

      return raw
          .map((e) => (e as Map<String, dynamic>)['product_code']?.toString())
          .whereType<String>()
          .toList();
    } catch (e) {
      print('[GraphQLService:getProducts] $e');
      return <String>[];
    }
  }

  /// Fetches status values for a product; includes worst flag and all individual status entries
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
        final flags = raw.map((item) {
          final f = item['product_status_flag'];
          return f is int ? f : int.tryParse('$f') ?? 0;
        }).toList();

        final worstFlag = flags.reduce((a, b) => a > b ? a : b);

        return {
          'product_status_flag': worstFlag,
          'statuses': raw.map((item) => {
            'product_status_name': item['product_status_name'],
            'product_status_value': item['product_status_value'],
            'product_status_flag': item['product_status_flag'],
          }).toList(),
        };
      }

      return null;
    } catch (e) {
      print('[GraphQLService:getProductStatus] $e');
      return null;
    }
  }
}
