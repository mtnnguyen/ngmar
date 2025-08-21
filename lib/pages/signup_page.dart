import 'package:flutter/material.dart';
import 'graphql_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();

  String _selectedSite = 'Site 1';
  final List<String> _sites = ['Site 1', 'Site 2', 'Site 3', 'Site 4'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text(
          'Sign Up',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 1,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'lib/images/logo.jpeg',
                  height: 100,
                ),
              ),
              const SizedBox(height: 30),
              _buildDisabledField('Customer', 'Display but not editable'),
              _buildDropdownField('Site', _selectedSite),
              _buildInputField('User name', _usernameController, hintText: 'JohnDoe123'),
              _buildInputField('Password', _passwordController, obscure: true, hintText: '••••••••'),
              _buildInputField('First Name', _firstNameController, hintText: 'John'),
              _buildInputField('Last Name', _lastNameController, hintText: 'Doe'),
              _buildInputField('Email', _emailController, hintText: 'john@example.com'),
              _buildInputField('Mobile', _mobileController, hintText: '+1234567890'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final mobile = _mobileController.text.trim();

                    if (mobile.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid mobile number'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final party = {
                      'first_name': _firstNameController.text.trim(),
                      'middle_name': '',
                      'last_name': _lastNameController.text.trim(),
                      'user_name': _usernameController.text.trim(),
                      'password': _passwordController.text.trim(),
                      'email': _emailController.text.trim(),
                      'mobile': mobile,
                      'phone': '',
                    };

                    final graphqlService = GraphQLService();
                    final result = await graphqlService.signup(party, 'TEST_SITE');
                    print('party: $party');
                    print('signup result: $result');

                    if (result != null && result['error_code'] == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Signup successful!')),
                      );
                      Navigator.pop(context); // ⬅ Go back to login
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Signup failed: ${result?['message'] ?? 'Unknown error'}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisabledField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextField(
          controller: TextEditingController(text: value),
          enabled: false,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdownField(String label, String selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.grey[900]),
          child: DropdownButtonFormField<String>(
            value: selected,
            iconEnabledColor: Colors.white,
            dropdownColor: Colors.black87,
            decoration: _inputDecoration(),
            items: _sites.map((site) {
              return DropdownMenuItem(
                value: site,
                child: Text(site, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSite = value!;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool obscure = false, String? hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(hintText: hintText),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      );

  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey,
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white38),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide.none,
      ),
    );
  }
}
