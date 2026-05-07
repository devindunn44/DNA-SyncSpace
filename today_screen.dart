import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/models/shared_event_model.dart';
import '../../providers/events_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/week_strip.dart';
import '../../widgets/event_tile.dart';
import '../../widgets/sync_app_bar.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final eventsAsync = ref.watch(eventsForDateProvider(_selectedDate));

    return Scaffold(
      appBar: SyncAppBar(
        title: 'SyncSpace',
        subtitle: DateFormat('EEEE, MMMM d').format(_selectedDate),
        profile: profile,
      ),
      body: Column(
        children: [
          // Week strip
          WeekStrip(
            selectedDate: _selectedDate,
            onDateSelected: (date) => setState(() => _selectedDate = date),
          ),

          // Timeline
          Expanded(
            child: eventsAsync.when(
              data: (events) => events.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      itemCount: events.length,
                      itemBuilder: (_, i) => EventTile(
                        event: events[i],
                        onTap: () => context.push('/event/${events[i].id}'),
                        onDelete: () => _confirmDelete(context, events[i]),
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/event/create', extra: _selectedDate),
        icon: const Icon(Icons.add, size: 22),
        label: const Text('New event', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.calendar_today_outlined, color: colors.primary, size: 28),
          ),
          const SizedBox(height: 16),
          Text('Nothing scheduled', style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: colors.onSurface,
          )),
          const SizedBox(height: 6),
          Text('Tap the button below to add an event', style: TextStyle(
            fontSize: 14, color: colors.onSurfaceVariant,
          )),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, SharedEventModel event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete event?'),
        content: Text('"${event.title}" will be removed for both you and your partner.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep it')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(eventsRepositoryProvider).deleteEvent(event.id);
    }
  }
}
