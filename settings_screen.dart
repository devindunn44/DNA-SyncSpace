// ═══════════════════════════════════════════════════════
// lib/presentation/screens/home/settings_screen.dart
// ═══════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final colors = Theme.of(context).colorScheme;
    final currentScheme = ref.watch(colorSchemeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Account
        _Section(title: 'Account', children: [
          _SettingsRow(
            icon: Icons.person_outline, iconBg: colors.primary.withOpacity(0.1),
            title: profile?['displayName'] ?? 'You',
            subtitle: profile?['email'] ?? '',
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: () {},
          ),
          _SettingsRow(
            icon: Icons.link, iconBg: const Color(0xFFD9A441).withOpacity(0.15),
            title: 'Partner link',
            subtitle: profile?['partnerUid'] != null ? 'Linked' : 'Not linked',
            trailing: profile?['partnerUid'] != null
                ? const Icon(Icons.check_circle, color: Colors.green, size: 18)
                : const Icon(Icons.chevron_right, size: 18),
            onTap: () => context.push('/partner-link'),
          ),
          _SettingsRow(
            icon: Icons.logout, iconBg: const Color(0xFFC0392B).withOpacity(0.1),
            title: 'Sign out', subtitle: '',
            titleColor: const Color(0xFFC0392B),
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: () async {
              await ref.read(authServiceProvider).signOut();
            },
          ),
        ]),
        const SizedBox(height: 16),

        // Calendars
        _Section(title: 'Calendars', children: [
          _SettingsRow(
            icon: Icons.calendar_today, iconBg: const Color(0xFFE8F0FE),
            title: 'Google Calendar', subtitle: 'Connected',
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text('Synced', style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.w500)),
            ]),
            onTap: () => context.go('/home/gcal'),
          ),
        ]),
        const SizedBox(height: 16),

        // Theme
        _Section(title: 'Appearance', children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Theme', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.onSurface)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 2.2,
                children: AppColorScheme.values.map((scheme) {
                  final p = AppPalettes.fromScheme(scheme);
                  final selected = scheme == currentScheme;
                  return GestureDetector(
                    onTap: () => ref.read(colorSchemeProvider.notifier).setScheme(scheme),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(int.parse(p.background.value.toRadixString(16).padLeft(8, 'f'), radix: 16)),
                        border: Border.all(
                          color: selected ? Color(int.parse(p.primary.value.toRadixString(16).padLeft(8, 'f'), radix: 16)) : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(children: [
                        ...[(p.primary), (p.secondary), (p.accent)].map((c) =>
                          Container(width: 14, height: 14, margin: const EdgeInsets.only(right: 3),
                            decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3)))),
                        const SizedBox(width: 4),
                        Expanded(child: Text(p.name, style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: Color(int.parse(p.textPrimary.value.toRadixString(16).padLeft(8, 'f'), radix: 16)),
                        ))),
                        if (selected) Icon(Icons.check_circle, size: 14,
                          color: Color(int.parse(p.primary.value.toRadixString(16).padLeft(8, 'f'), radix: 16))),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ]),
          ),
        ]),
        const SizedBox(height: 16),

        // Notifications
        _Section(title: 'Notifications', children: [
          _SwitchRow(title: 'Event reminders', subtitle: '30 min before events', value: true),
          _SwitchRow(title: 'Daily summary', subtitle: 'Every morning at 7:30 AM', value: true),
          _SwitchRow(title: 'Partner updates', subtitle: 'When your partner edits events', value: true),
          _SwitchRow(title: 'Smart suggestions', subtitle: 'Date night & errand ideas', value: false),
        ]),
        const SizedBox(height: 32),
        Text('SyncSpace v1.0.0', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
        const SizedBox(height: 20),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(title.toUpperCase(), style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        )),
      ),
      Card(child: Column(children: children.map((c) => c is Divider ? c : Column(children: [
        c,
        if (c != children.last) Divider(height: 0, indent: 56, endIndent: 0, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08)),
      ])).expand((x) => x is List ? x : [x]).toList())),
    ]);
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title, subtitle;
  final Color? titleColor;
  final Widget trailing;
  final VoidCallback onTap;

  const _SettingsRow({required this.icon, required this.iconBg, required this.title,
    required this.subtitle, this.titleColor, required this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(9)),
        child: Icon(icon, size: 18, color: titleColor ?? colors.primary)),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: titleColor ?? colors.onSurface)),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _SwitchRow extends StatefulWidget {
  final String title, subtitle;
  final bool value;
  const _SwitchRow({required this.title, required this.subtitle, required this.value});

  @override
  State<_SwitchRow> createState() => _SwitchRowState();
}

class _SwitchRowState extends State<_SwitchRow> {
  late bool _val;

  @override void initState() { super.initState(); _val = widget.value; }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      title: Text(widget.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: colors.onSurface)),
      subtitle: Text(widget.subtitle, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
      value: _val,
      onChanged: (v) => setState(() => _val = v),
      activeColor: colors.primary,
    );
  }
}
