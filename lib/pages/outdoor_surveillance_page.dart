import 'package:flutter/material.dart';
import 'product_status_page.dart';

class OutdoorSurveillancePage extends StatelessWidget {
  final String siteName;
  final int partyId;
  const OutdoorSurveillancePage({super.key, required this.siteName, required this.partyId});

  @override
  Widget build(BuildContext context) {
    return ProductStatusPage(
      productCode: 'OUT_SUR',
      productTitle: 'Outdoor Surveillance',
      siteName: siteName,
      partyId: partyId,
    );
  }
}
