import 'dart:convert';
import 'package:http/http.dart' as http;

class GraphQLService {
  // Signin mutation
  Future<Map<String, dynamic>?> signin(String username, String password, String siteName) async {
    const String url = 'https://kf6iirlcgrbqdmr2b6nq5s6g3q.appsync-api.ca-central-1.amazonaws.com/graphql';
    const String apiKey = 'da2-gyewjbxhlvdarogtzp5mbyrm6m';

    final String query = r'''
      mutation ($user_name: String!, $password: String!, $site_name: String!) {
        signin(user_name: $user_name, password: $password, site_name: $site_name) {
          party {
            party_id
            user_name
            email
          }
          error_code
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
      body: jsonEncode({
        'query': query,
        'variables': {
          'user_name': username,
          'password': password,
          'site_name': siteName,
        }
      }),
    );

    final body = jsonDecode(response.body);
    print('==== SIGNIN RESPONSE ====');
    print(body);

    if (response.statusCode == 200) {
      if (body['errors'] != null) {
        print('[GraphQL ERROR - Signin] ${body['errors']}');
        return null;
      }
      return body['data']?['signin'];
    } else {
      print('[HTTP ERROR - Signin] Status: ${response.statusCode}');
      print(response.body);
      return null;
    }
  }

  // Signup mutation
  Future<Map<String, dynamic>?> signup(Map<String, dynamic> party, String siteName) async {
    const String url = 'https://l5a4sfcxxfbj3icqefjhoup4ti.appsync-api.ca-central-1.amazonaws.com/graphql';
    const String apiKey = 'da2-3g2r42737jf73igdhfsrp2mh2y';

    const String query = r'''
      mutation Signup($party: PartyInput!, $site_name: String!) {
        signup(party: $party, site_name: $site_name) {
          party_id
          user_name
          first_name
          last_name
          email
          mobile
          error_code
          message
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
      body: jsonEncode({
        'query': query,
        'variables': {
          'party': party,
          'site_name': siteName,
        }
      }),
    );

    final body = jsonDecode(response.body);
    print('==== SIGNUP RESPONSE ====');
    print(body);

    if (response.statusCode == 200) {
      if (body['errors'] != null) {
        print('[GraphQL ERROR - Signup] ${body['errors']}');
        return null;
      }
      return body['data']?['signup'];
    } else {
      print('[HTTP ERROR - Signup] Status: ${response.statusCode}');
      print(response.body);
      return null;
    }
  }

  // getAlerts query using updated schema and naming conventions
Future<List<Map<String, dynamic>>?> getAlerts({
  required String siteName,
  required String fromDate,
  required String toDate,
  int recordsPerPage = 10,
}) async {
  const String url = 'https://tb5xwefsybcitbefa3wksxrazm.appsync-api.ca-central-1.amazonaws.com/graphql';
  const String apiKey = 'da2-7lmmoz642fb3bakwqc4e5k6ytq';

  const String query = r'''
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

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
    },
    body: jsonEncode({
      'query': query,
      'variables': {
        'site': siteName,
        'from': fromDate,
        'to': toDate,
        'limit': recordsPerPage,
      }
    }),
  );

  final body = jsonDecode(response.body);
  print('==== GET ALERTS RESPONSE ====');
  print(body);

  if (response.statusCode == 200) {
    final alerts = body['data']?['getAlerts']?['alerts'];
    if (alerts is List) {
      return alerts.cast<Map<String, dynamic>>();
    } else {
      print('alerts field is missing or not a List: ${body['data']?['getAlerts']}');
    }
    return null;
  } else {
    print('[HTTP ERROR - getAlerts] Status: ${response.statusCode}');
    print(response.body);
    return null;
  }
}

}
