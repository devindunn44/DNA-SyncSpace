import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const HomeShell({super.key, required this.shell});

  static const _tabs = [
    _TabItem(label: 'Today', icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today),
    _TabItem(label: 'Partner', icon: Icons.people_outline, activeIcon: Icons.people),
    _TabItem(label: 'Google', icon: Icons.event_outlined, activeIcon: Icons.event),
    _TabItem(label: 'Events', icon: Icons.list_alt_outlined, activeIcon: Icons.list_alt),
    _TabItem(label: 'Settings', icon: Icons.settings_outlined, activeIcon: Icons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(
          i,
          initialLocation: i == shell.currentIndex,
        ),
        backgroundColor: colors.surface,
        indicatorColor: colors.primary.withOpacity(0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: _tabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.icon, size: 22),
                  selectedIcon: Icon(t.activeIcon, size: 22, color: colors.primary),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _TabItem({required this.label, required this.icon, required this.activeIcon});
}
