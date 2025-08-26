import 'package:flutter/material.dart';
import 'product_status_page.dart';

class PharmacyGovernancePage extends StatelessWidget {
  final String siteName;
  final int partyId;
  const PharmacyGovernancePage({super.key, required this.siteName, required this.partyId});

  @override
  Widget build(BuildContext context) {
    return ProductStatusPage(
      productCode: 'PHA_GOV',
      productTitle: 'Pharmacy Governance',
      siteName: siteName,
      partyId: partyId,
    );
  }
}
