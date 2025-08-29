import 'package:flutter/material.dart';

/// Top-right navbar with 3 icons: Alerts • Push Notifications • Menu
/// Each icon is tappable and wired to its respective callback.
/// Sized and padded properly for reliable taps inside AppBar.actions.
class TopRightNavBar extends StatelessWidget {
  final VoidCallback onAlertsTap;
  final VoidCallback onPushTap;
  final VoidCallback onMenuTap;

  const TopRightNavBar({
    super.key,
    required this.onAlertsTap,
    required this.onPushTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NavIcon(
          icon: Icons.notifications_active_outlined,
          onTap: onAlertsTap,
        ),
        const SizedBox(width: 6),
        _NavIcon(
          icon: Icons.campaign_outlined,
          onTap: onPushTap,
        ),
        const SizedBox(width: 6),
        _NavIcon(
          icon: Icons.menu,
          onTap: onMenuTap,
        ),
      ],
    );
  }
}

/// Single navigation icon with built-in tap area and styling.
class _NavIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(6.0), // 36x36 hit area
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
