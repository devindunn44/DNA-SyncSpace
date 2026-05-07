// ═══════════════════════════════════════════════════════
// lib/presentation/screens/home/events_screen.dart
// ═══════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../data/models/shared_event_model.dart';
import '../../providers/events_provider.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(allUpcomingEventsProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Shared events')),
      body: eventsAsync.when(
        data: (events) => events.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.event_available, size: 48, color: colors.primary.withOpacity(0.4)),
                const SizedBox(height: 14),
                Text('No shared events yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: colors.onSurface)),
                const SizedBox(height: 6),
                Text('Tap + to create one', style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant)),
              ]))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                itemCount: events.length,
                itemBuilder: (_, i) => _EventCard(event: events[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/event/create'),
        icon: const Icon(Icons.add),
        label: const Text('New event', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _EventCard extends ConsumerWidget {
  final SharedEventModel event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final tagColor = _tagColor(event.tag, colors);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/event/${event.id}'),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(event.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.onSurface))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: tagColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                child: Text(event.tag, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: tagColor)),
              ),
            ]),
            const SizedBox(height: 5),
            Text(
              '${DateFormat('MMM d').format(event.dateTime)} · ${DateFormat('h:mm a').format(event.dateTime)}',
              style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
            ),
            if (event.notes != null && event.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(event.notes!, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant, height: 1.4)),
            ],
            const SizedBox(height: 10),
            Row(children: [
              _MiniAvatar(label: 'JA', color: colors.primary),
              const SizedBox(width: 4),
              _MiniAvatar(label: 'SA', color: colors.secondary),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/event/create', extra: null),
                style: TextButton.styleFrom(
                  foregroundColor: colors.primary,
                  minimumSize: const Size(60, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                child: const Text('Edit'),
              ),
              TextButton(
                onPressed: () async {
                  final ok = await showDialog<bool>(context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete event?'),
                      content: Text('"${event.title}" will be removed for both partners.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(foregroundColor: colors.error),
                          child: const Text('Delete')),
                      ],
                    ));
                  if (ok == true) await ref.read(eventsRepositoryProvider).deleteEvent(event.id);
                },
                style: TextButton.styleFrom(
                  foregroundColor: colors.error,
                  minimumSize: const Size(60, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                child: const Text('Delete'),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Color _tagColor(String tag, ColorScheme colors) {
    switch (tag) {
      case 'date night': return const Color(0xFF0E6B66);
      case 'family': return colors.primary;
      case 'errand': return const Color(0xFFD9A441);
      case 'fitness': return const Color(0xFFD4610C);
      case 'travel': return const Color(0xFF1565C0);
      default: return colors.onSurfaceVariant;
    }
  }
}

class _MiniAvatar extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniAvatar({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: 11, backgroundColor: color.withOpacity(0.18),
    child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: color)),
  );
}
