import 'package:flutter/material.dart';
import 'product_status_page.dart';

class PharmacyGovernancePage extends StatelessWidget {
  final String siteName;
  final int partyId;
  final String username;
  final String password;
  final String fullName;
  final String email;

  const PharmacyGovernancePage({
    super.key,
    required this.siteName,
    required this.partyId,
    required this.username,
    required this.password,
    required this.fullName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return ProductStatusPage(
      productCode: 'PHA_GOV',
      siteName: siteName,
      partyId: partyId,
      username: username,
      password: password,
      fullName: fullName,
      email: email,
    );
  }
}
