// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: flutter pub run build_runner build

part of 'shared_event_model.dart';

class SharedEventModelAdapter extends TypeAdapter<SharedEventModel> {
  @override
  final int typeId = 0;

  @override
  SharedEventModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SharedEventModel(
      id: fields[0] as String,
      title: fields[1] as String,
      dateTime: fields[2] as DateTime,
      notes: fields[3] as String?,
      tag: fields[4] as String,
      createdByUid: fields[5] as String,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
      synced: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SharedEventModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.dateTime)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.tag)
      ..writeByte(5)
      ..write(obj.createdByUid)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharedEventModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
