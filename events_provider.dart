import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/shared_event_model.dart';
import 'auth_provider.dart';

// ─── Repository ───────────────────────────────────────────────────────────────

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  final profile = ref.watch(userProfileProvider).valueOrNull;
  return EventsRepository(
    userId: user?.uid ?? '',
    partnerUid: profile?['partnerUid'] as String?,
  );
});

class EventsRepository {
  final String userId;
  final String? partnerUid;
  final _db = FirebaseFirestore.instance;
  final _box = Hive.box<SharedEventModel>('shared_events');
  final _uuid = const Uuid();

  EventsRepository({required this.userId, this.partnerUid});

  String get _coupleId {
    if (partnerUid == null) return userId;
    final ids = [userId, partnerUid!]..sort();
    return ids.join('_');
  }

  CollectionReference get _eventsCol =>
      _db.collection('couples').doc(_coupleId).collection('events');

  // Stream all events for a specific date (local + remote)
  Stream<List<SharedEventModel>> eventsForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return _eventsCol
        .where('dateTime',
            isGreaterThanOrEqualTo: start.toIso8601String(),
            isLessThan: end.toIso8601String())
        .orderBy('dateTime')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => SharedEventModel.fromFirestore(
                d.data() as Map<String, dynamic>))
            .toList());
  }

  // Stream all upcoming events
  Stream<List<SharedEventModel>> allUpcomingEvents() {
    final now = DateTime.now();
    return _eventsCol
        .where('dateTime', isGreaterThanOrEqualTo: now.toIso8601String())
        .orderBy('dateTime')
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => SharedEventModel.fromFirestore(
                d.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> createEvent(SharedEventModel event) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final newEvent = event.copyWith(
      id: id,
      createdByUid: userId,
      createdAt: now,
      updatedAt: now,
    );
    // Save locally
    await _box.put(id, newEvent);
    // Sync to Firestore
    await _eventsCol.doc(id).set(newEvent.toFirestore());
  }

  Future<void> updateEvent(SharedEventModel event) async {
    final updated = event.copyWith(updatedAt: DateTime.now());
    await _box.put(event.id, updated);
    await _eventsCol.doc(event.id).update(updated.toFirestore());
  }

  Future<void> deleteEvent(String id) async {
    await _box.delete(id);
    await _eventsCol.doc(id).delete();
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

final eventsForDateProvider =
    StreamProvider.family<List<SharedEventModel>, DateTime>((ref, date) {
  return ref.watch(eventsRepositoryProvider).eventsForDate(date);
});

final allUpcomingEventsProvider =
    StreamProvider<List<SharedEventModel>>((ref) {
  return ref.watch(eventsRepositoryProvider).allUpcomingEvents();
});
