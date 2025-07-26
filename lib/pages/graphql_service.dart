import 'dart:convert';
import 'package:http/http.dart' as http;

class GraphQLService {
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
      print('[HTTP ERROR] Status: ${response.statusCode}');
      print(response.body);
      return null;
    }
  }
}
