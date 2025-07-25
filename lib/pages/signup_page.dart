import 'package:flutter/material.dart';
import 'validate_mobile_page.dart';

// SignUpPage is a screen for user registration.
// It includes fields for username, password, first name, last name, email, and mobile number.
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

// _SignUpPageState manages the state of SignUpPage.
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
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        leading: const BackButton(),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  'https://images.squarespace-cdn.com/content/v1/67fa8c0fe003dd6c78c62313/da9f915c-8ad6-4e53-93b4-8ac733863bcf/Artboard+1survei%402x.png?format=1500w',
                  height: 100,
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Sign Up',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),

              _buildDisabledField('Customer', 'Display but not editable'),
              _buildDropdownField('Site', _selectedSite),
              _buildInputField('User name', _usernameController),
              _buildInputField('Password', _passwordController, obscure: true),
              _buildInputField('First Name', _firstNameController),
              _buildInputField('Last Name', _lastNameController),
              _buildInputField('Email', _emailController),
              _buildInputField('Mobile', _mobileController),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final mobile = _mobileController.text.trim();
                    if (mobile.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ValidateMobilePage(mobileNumber: mobile),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid mobile number'),
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

  // Uses a dropdown field
  Widget _buildDropdownField(String label, String selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.grey[900], // dropdown background
          ),
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

  // Helper method
  Widget _buildInputField(String label, TextEditingController controller,
      {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Helper method
  Widget _buildLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      );

  // Helper method
  InputDecoration _inputDecoration() {
    return const InputDecoration(
      filled: true,
      fillColor: Colors.grey,
      contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide.none,
      ),
    );
  }
}
