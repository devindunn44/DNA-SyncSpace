// ═══════════════════════════════════════════════════════
// lib/presentation/widgets/week_strip.dart
// ═══════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeekStrip extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  const WeekStrip({super.key, required this.selectedDate, required this.onDateSelected});

  @override
  State<WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends State<WeekStrip> {
  int _weekOffset = 0;
  final _today = DateTime.now();

  DateTime get _weekStart {
    final d = _today.add(Duration(days: _weekOffset * 7));
    return d.subtract(Duration(days: d.weekday % 7));
  }

  List<DateTime> get _days =>
      List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final days = _days;
    final monthLabel = DateFormat('MMMM yyyy').format(days[3]);

    return Container(
      color: colors.surface,
      child: Column(children: [
        // Month row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 4),
          child: Row(children: [
            Text(monthLabel, style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: colors.onSurface,
            )),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              iconSize: 20,
              onPressed: () => setState(() => _weekOffset--),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              iconSize: 20,
              onPressed: () => setState(() => _weekOffset++),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            TextButton(
              onPressed: () {
                setState(() => _weekOffset = 0);
                widget.onDateSelected(_today);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              child: const Text('Today'),
            ),
          ]),
        ),

        // Day chips
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
          child: Row(children: days.map((d) {
            final isToday = _isSameDay(d, _today);
            final isSelected = _isSameDay(d, widget.selectedDate);
            return Expanded(child: GestureDetector(
              onTap: () => widget.onDateSelected(d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 62,
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isToday && !isSelected
                      ? Border.all(color: colors.primary.withOpacity(0.3), width: 1.5)
                      : null,
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(DateFormat('E').format(d).substring(0, 2),
                    style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white.withOpacity(0.75) : colors.onSurfaceVariant,
                      letterSpacing: 0.3,
                    )),
                  const SizedBox(height: 3),
                  Text('${d.day}',
                    style: TextStyle(
                      fontSize: 17, fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : (isToday ? colors.primary : colors.onSurface),
                    )),
                  const SizedBox(height: 3),
                  Container(width: 5, height: 5, decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.6) : Colors.transparent,
                    shape: BoxShape.circle,
                  )),
                ]),
              ),
            ));
          }).toList()),
        ),
        Divider(height: 0, color: colors.onSurface.withOpacity(0.08)),
      ]),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}


// ═══════════════════════════════════════════════════════
// lib/presentation/widgets/event_tile.dart
// ═══════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/shared_event_model.dart';

class EventTile extends StatelessWidget {
  final SharedEventModel event;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const EventTile({
    super.key,
    required this.event,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = colors.tertiary ?? const Color(0xFF0E6B66);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Row(children: [
          Container(
            width: 4, height: 72,
            margin: const EdgeInsets.only(left: 0),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14), bottomLeft: Radius.circular(14),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(DateFormat('h:mm a').format(event.dateTime),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: accent, letterSpacing: 0.3)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text('shared', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: accent)),
                  ),
                ]),
                const SizedBox(height: 3),
                Text(event.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: colors.onSurface)),
                if (event.notes != null && event.notes!.isNotEmpty)
                  Text(event.notes!, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
              ]),
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline, size: 20, color: colors.error.withOpacity(0.7)),
            tooltip: 'Delete',
          ),
        ]),
      ),
    );
  }
}


// ═══════════════════════════════════════════════════════
// lib/presentation/widgets/sync_app_bar.dart
// ═══════════════════════════════════════════════════════
import 'package:flutter/material.dart';

class SyncAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title, subtitle;
  final Map<String, dynamic>? profile;

  const SyncAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.profile,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final name = profile?['displayName'] as String? ?? '';
    final initials = name.isNotEmpty
        ? name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : '?';

    return AppBar(
      toolbarHeight: 70,
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 22,
          fontWeight: FontWeight.w300,
          color: Colors.white,
          letterSpacing: -0.3,
        )),
        Text(subtitle, style: const TextStyle(
          fontSize: 12, color: Colors.white60, fontWeight: FontWeight.w400,
        )),
      ]),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 8, height: 8,
              decoration: const BoxDecoration(color: Color(0xFF4ADE80), shape: BoxShape.circle)),
            const SizedBox(width: 5),
            const Text('Synced', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
          ]),
        ),
        CircleAvatar(
          radius: 17,
          backgroundColor: Colors.white24,
          child: Text(initials, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}


// ═══════════════════════════════════════════════════════
// lib/presentation/widgets/loading_button.dart
// ═══════════════════════════════════════════════════════
import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;
  final Widget child;
  final ButtonStyle? style;

  const LoadingButton({
    super.key,
    required this.loading,
    required this.onPressed,
    required this.child,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: style,
      child: loading
          ? const SizedBox(width: 22, height: 22,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
          : child,
    );
  }
}


// ═══════════════════════════════════════════════════════
// lib/presentation/widgets/app_logo.dart
// ═══════════════════════════════════════════════════════
import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 34),
      ),
      const SizedBox(height: 16),
      Text('SyncSpace', style: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 34,
        fontWeight: FontWeight.w300,
        color: colors.primary,
        letterSpacing: -0.5,
      )),
      const SizedBox(height: 6),
      Text('A shared calendar for the two of you',
        style: TextStyle(fontSize: 15, color: colors.onSurfaceVariant)),
    ]);
  }
}
