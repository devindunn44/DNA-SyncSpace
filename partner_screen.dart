// ─── lib/presentation/screens/home/partner_screen.dart ───
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../presentation/providers/auth_provider.dart';

class PartnerScreen extends ConsumerWidget {
  const PartnerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final hasPartner = profile?['partnerUid'] != null;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Partner')),
      body: hasPartner
          ? const _PartnerContent()
          : _NoPartnerState(onLink: () => context.push('/partner-link')),
    );
  }
}

class _NoPartnerState extends StatelessWidget {
  final VoidCallback onLink;
  const _NoPartnerState({required this.onLink});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.people_outline, size: 34, color: colors.primary),
          ),
          const SizedBox(height: 20),
          Text('Connect with your partner', style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w600, color: colors.onSurface,
          )),
          const SizedBox(height: 10),
          Text('Share your code or enter your partner\'s code to sync schedules together.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: colors.onSurfaceVariant, height: 1.5)),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: onLink,
            icon: const Icon(Icons.link, size: 20),
            label: const Text('Link partner'),
          ),
        ]),
      ),
    );
  }
}

class _PartnerContent extends StatelessWidget {
  const _PartnerContent();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          CircleAvatar(backgroundColor: colors.secondary, radius: 26,
            child: const Text('SA', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Sam Archer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.onSurface)),
            Row(children: [
              Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 5),
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
              Text('Active now', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
            ]),
          ]),
        ]),
      )),
      const SizedBox(height: 12),
      Card(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Today's availability", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.onSurface)),
          const SizedBox(height: 12),
          _FreeSlotChip(time: '9:00 – 10:00 AM', label: 'Both free'),
          _FreeSlotChip(time: '2:30 – 3:00 PM', label: 'Both free'),
          _FreeSlotChip(time: 'After 5:00 PM', label: 'Both free'),
        ]),
      )),
    ]);
  }
}

class _FreeSlotChip extends StatelessWidget {
  final String time;
  final String label;
  const _FreeSlotChip({required this.time, required this.label});

  @override
  Widget build(BuildContext context) {
    final acc = const Color(0xFF0E6B66);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        border: Border.all(color: acc.withOpacity(0.35), width: 1.5),
        borderRadius: BorderRadius.circular(10),
        color: acc.withOpacity(0.06),
      ),
      child: Row(children: [
        Icon(Icons.access_time, size: 15, color: acc),
        const SizedBox(width: 8),
        Text('$label · $time', style: TextStyle(fontSize: 13, color: acc, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
