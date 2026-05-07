// ═══════════════════════════════════════════════════════
// lib/presentation/screens/home/gcal_screen.dart
// ═══════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GCalScreen extends ConsumerWidget {
  const GCalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    final calendars = [
      _CalItem('Personal', const Color(0xFF0F9D58), true),
      _CalItem('Work', const Color(0xFF4285F4), true),
      _CalItem('Holidays', const Color(0xFFF4511E), false),
      _CalItem('Birthdays', const Color(0xFFE91E63), false),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Google Calendar')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('G', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF4285F4)))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Google Calendar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.onSurface)),
              Row(children: [
                Container(width: 7, height: 7, margin: const EdgeInsets.only(right: 5),
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                Text('Connected & synced', style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.w500)),
              ]),
            ])),
          ]),
        )),
        const SizedBox(height: 16),
        Text('Your calendars', style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: colors.onSurfaceVariant,
          letterSpacing: 0.5, height: 1,
        )),
        const SizedBox(height: 10),
        ...calendars.map((c) => _CalendarRow(item: c)),
        const SizedBox(height: 20),
        Text('Today\'s events', style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: colors.onSurfaceVariant, letterSpacing: 0.5,
        )),
        const SizedBox(height: 10),
        _GCalEventCard(title: 'Team standup', cal: 'Work', color: const Color(0xFF4285F4), time: '8:00 AM', dur: '30m'),
        _GCalEventCard(title: 'Dentist appointment', cal: 'Personal', color: const Color(0xFF0F9D58), time: '11:00 AM', dur: '1h'),
        _GCalEventCard(title: 'Project deadline', cal: 'Work', color: const Color(0xFF4285F4), time: '5:00 PM', dur: ''),
      ]),
    );
  }
}

class _CalItem {
  final String name;
  final Color color;
  bool subscribed;
  _CalItem(this.name, this.color, this.subscribed);
}

class _CalendarRow extends StatefulWidget {
  final _CalItem item;
  const _CalendarRow({required this.item});

  @override
  State<_CalendarRow> createState() => _CalendarRowState();
}

class _CalendarRowState extends State<_CalendarRow> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          Container(width: 14, height: 14, decoration: BoxDecoration(color: widget.item.color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.item.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
            Text(widget.item.subscribed ? 'Subscribed' : 'Not subscribed', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ])),
          Switch(
            value: widget.item.subscribed,
            onChanged: (v) => setState(() => widget.item.subscribed = v),
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ]),
      ),
    );
  }
}

class _GCalEventCard extends StatelessWidget {
  final String title, cal, time, dur;
  final Color color;
  const _GCalEventCard({required this.title, required this.cal, required this.color, required this.time, required this.dur});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(width: 4, margin: const EdgeInsets.only(right: 12), height: 44, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$cal · $time${dur.isNotEmpty ? " ($dur)" : ""}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
            const SizedBox(height: 2),
            Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
          ])),
        ]),
      ),
    );
  }
}
