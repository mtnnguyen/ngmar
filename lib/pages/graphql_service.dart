import 'dart:convert';
import 'package:http/http.dart' as http;

class GraphQLService {
  // Signin mutation
  Future<Map<String, dynamic>?> signin(String username, String password, String siteName) async {
    const String url = 'https://kf6iirlcgrbqdmr2b6nq5s6g3q.appsync-api.ca-central-1.amazonaws.com/graphql';
    const String apiKey = 'da2-gyewjbxhlvdarogtzp5mbyrm6m';

    final String rawQuery = '''
      mutation {
        signin(user_name: "$username", password: "$password", site_name: "$siteName") {
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
      body: jsonEncode({'query': rawQuery}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final data = body['data']?['signin'];
      return data;
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

    const String rawQuery = r'''
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
        'query': rawQuery,
        'variables': {
          'party': party,
          'site_name': siteName,
        }
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final data = body['data']?['signup'];
      return data;
    } else {
      print('[HTTP ERROR - Signup] Status: ${response.statusCode}');
      print(response.body);
      return null;
    }
  }

  // getAlerts query using site_name (not site_id)
  Future<List<Map<String, dynamic>>?> getAlerts({
    required String siteName,
    required String fromDate,
    required String toDate,
    int recordsPerPage = 10,
  }) async {
    const String url = 'https://tb5xwefsybcitbefa3wksxrazm.appsync-api.ca-central-1.amazonaws.com/graphql';
    const String apiKey = 'da2-7lmmoz642fb3bakwqc4e5k6ytq';

    const String query = r'''
      query GetAlerts($site_name: String!, $from_date: AWSDateTime!, $to_date: AWSDateTime!, $records_per_page: Int!) {
        getAlerts(site_name: $site_name, from_date: $from_date, to_date: $to_date, records_per_page: $records_per_page) {
          alerts {
            alert_id
            alert_uuid
            triggering_event_id
            site_id
            alert_type
            alert_severity
            alert_description
            alert_status
            acknowledged_at
            resolved_at
            create_timestamp
            raw_payload
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
          'site_name': siteName,
          'from_date': fromDate,
          'to_date': toDate,
          'records_per_page': recordsPerPage,
        }
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);

      // Debug print full response
      print('getAlerts full response: $body');

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
