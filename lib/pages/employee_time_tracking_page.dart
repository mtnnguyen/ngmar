import 'package:flutter/material.dart';
import 'product_status_page.dart';

class EmployeeTimeTrackingPage extends StatelessWidget {
  final String siteName;
  final int partyId;
  const EmployeeTimeTrackingPage({super.key, required this.siteName, required this.partyId});

  @override
  Widget build(BuildContext context) {
    return ProductStatusPage(
      productCode: 'TIM_TRA',
      productTitle: 'Employee Time Tracking',
      siteName: siteName,
      partyId: partyId,
    );
  }
}
