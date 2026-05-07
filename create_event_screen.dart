import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/shared_event_model.dart';
import '../../providers/events_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_button.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  final SharedEventModel? existingEvent;

  const CreateEventScreen({super.key, this.initialDate, this.existingEvent});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  String _selectedTag = EventTag.dateNight;
  bool _saving = false;

  bool get _isEditing => widget.existingEvent != null;

  @override
  void initState() {
    super.initState();
    final ev = widget.existingEvent;
    if (ev != null) {
      _titleCtrl.text = ev.title;
      _notesCtrl.text = ev.notes ?? '';
      _selectedDate = ev.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(ev.dateTime);
      _selectedTag = ev.tag;
    } else {
      _selectedDate = widget.initialDate ?? DateTime.now();
      _selectedTime = const TimeOfDay(hour: 19, minute: 0);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    setState(() => _saving = true);
    final user = ref.read(currentUserProvider);

    final dt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final event = SharedEventModel(
      id: widget.existingEvent?.id ?? const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      dateTime: dt,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      tag: _selectedTag,
      createdByUid: user?.uid ?? '',
      createdAt: widget.existingEvent?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final repo = ref.read(eventsRepositoryProvider);
      if (_isEditing) {
        await repo.updateEvent(event);
      } else {
        await repo.createEvent(event);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save event: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit event' : 'New shared event'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              TextFormField(
                controller: _titleCtrl,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Date night at Valentino\'s',
                ),
              ),
              const SizedBox(height: 16),

              // Date & Time row
              Row(children: [
                Expanded(
                  child: _PickerCard(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: DateFormat('MMM d, yyyy').format(_selectedDate),
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PickerCard(
                    icon: Icons.access_time_outlined,
                    label: 'Time',
                    value: _selectedTime.format(context),
                    onTap: _pickTime,
                  ),
                ),
              ]),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesCtrl,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Optional details...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),

              // Tag selector
              Text('Tag', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
                letterSpacing: 0.5,
              )),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: EventTag.all.map((tag) {
                  final selected = _selectedTag == tag;
                  return FilterChip(
                    label: Text(tag),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedTag = tag),
                    backgroundColor: colors.surface,
                    selectedColor: colors.primary.withOpacity(0.12),
                    checkmarkColor: colors.primary,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: selected ? colors.primary : colors.onSurfaceVariant,
                    ),
                    side: BorderSide(
                      color: selected
                          ? colors.primary.withOpacity(0.4)
                          : colors.onSurfaceVariant.withOpacity(0.2),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Save button
              LoadingButton(
                loading: _saving,
                onPressed: _save,
                child: Text(_isEditing ? 'Update event' : 'Save event'),
              ),
              if (_isEditing) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => _confirmDelete(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                    side: BorderSide(color: colors.error, width: 1.5),
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: const Text('Delete event'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete event?'),
        content: Text('"${widget.existingEvent!.title}" will be removed for both partners.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(eventsRepositoryProvider).deleteEvent(widget.existingEvent!.id);
      context.pop();
    }
  }
}

class _PickerCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickerCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.onSurfaceVariant.withOpacity(0.25)),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
              letterSpacing: 0.5,
            )),
            const SizedBox(height: 6),
            Row(children: [
              Icon(icon, size: 15, color: colors.primary),
              const SizedBox(width: 6),
              Text(value, style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: colors.onSurface,
              )),
            ]),
          ],
        ),
      ),
    );
  }
}
