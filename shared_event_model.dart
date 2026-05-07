import 'package:hive/hive.dart';

part 'shared_event_model.g.dart';

@HiveType(typeId: 0)
class SharedEventModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime dateTime;

  @HiveField(3)
  final String? notes;

  @HiveField(4)
  final String tag;

  @HiveField(5)
  final String createdByUid;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  @HiveField(8)
  final bool synced;

  SharedEventModel({
    required this.id,
    required this.title,
    required this.dateTime,
    this.notes,
    required this.tag,
    required this.createdByUid,
    required this.createdAt,
    required this.updatedAt,
    this.synced = false,
  });

  SharedEventModel copyWith({
    String? id,
    String? title,
    DateTime? dateTime,
    String? notes,
    String? tag,
    String? createdByUid,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) {
    return SharedEventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
      tag: tag ?? this.tag,
      createdByUid: createdByUid ?? this.createdByUid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'title': title,
        'dateTime': dateTime.toIso8601String(),
        'notes': notes,
        'tag': tag,
        'createdByUid': createdByUid,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory SharedEventModel.fromFirestore(Map<String, dynamic> data) =>
      SharedEventModel(
        id: data['id'],
        title: data['title'],
        dateTime: DateTime.parse(data['dateTime']),
        notes: data['notes'],
        tag: data['tag'],
        createdByUid: data['createdByUid'],
        createdAt: DateTime.parse(data['createdAt']),
        updatedAt: DateTime.parse(data['updatedAt']),
        synced: true,
      );
}

// Event tags
class EventTag {
  static const String dateNight = 'date night';
  static const String family = 'family';
  static const String errand = 'errand';
  static const String fitness = 'fitness';
  static const String travel = 'travel';
  static const String other = 'other';

  static const List<String> all = [
    dateNight,
    family,
    errand,
    fitness,
    travel,
    other,
  ];
}
