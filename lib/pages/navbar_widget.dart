import 'package:flutter/material.dart';

/// Compact top-right navbar: Alerts (left) • Push (middle) • Menu (right)
/// Uses InkWell with padding so taps are reliable inside AppBar.actions.
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
      children: const [
        _NavIcon(icon: Icons.notifications_active_outlined, which: _Which.alerts),
        SizedBox(width: 6),
        _NavIcon(icon: Icons.campaign_outlined, which: _Which.push),
        SizedBox(width: 6),
        _NavIcon(icon: Icons.menu, which: _Which.menu),
      ],
    )._wire(onAlertsTap, onPushTap, onMenuTap);
  }
}

enum _Which { alerts, push, menu }

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final _Which which;

  const _NavIcon({required this.icon, required this.which});

  @override
  Widget build(BuildContext context) {
    final _Dispatcher? d = context.dependOnInheritedWidgetOfExactType<_Dispatcher>();

    return InkWell(
      onTap: () {
        switch (which) {
          case _Which.alerts: d?.onAlertsTap(); break;
          case _Which.push:   d?.onPushTap();   break;
          case _Which.menu:   d?.onMenuTap();   break;
        }
      },
      customBorder: const CircleBorder(),
      child: const SizedBox(width: 36, height: 36),  // Fixed: real tap area
    )._withIcon(icon);
  }
}

extension _WithIcon on Widget {
  Widget _withIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(6.0), // ~36x36 hit area
      child: Icon(icon, color: Colors.white, size: 28),
    )._wrap(this);
  }

  Widget _wrap(Widget child) => Stack(alignment: Alignment.center, children: [this, child]);
}

class _Dispatcher extends InheritedWidget {
  final VoidCallback onAlertsTap;
  final VoidCallback onPushTap;
  final VoidCallback onMenuTap;

  const _Dispatcher({
    super.key,
    required this.onAlertsTap,
    required this.onPushTap,
    required this.onMenuTap,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant _Dispatcher oldWidget) => false;
}

extension _Wire on Widget {
  Widget _wire(VoidCallback a, VoidCallback p, VoidCallback m) =>
      _Dispatcher(onAlertsTap: a, onPushTap: p, onMenuTap: m, child: this);
}
