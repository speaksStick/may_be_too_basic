// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'HabitsModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitsModelAdapter extends TypeAdapter<HabitsModel> {
  @override
  final int typeId = 0;

  @override
  HabitsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitsModel(
      habitName: fields[0] as String,
    )
      ..myHabitDescription = fields[1] as String
      ..habitColorInt = fields[2] as int
      ..myHabitCompletionDateTime = fields[3] as DateTime
      ..habitUId = fields[4] as String
      ..myHabitCompletionDates = (fields[5] as List).cast<DateTime>()
      ..myTotalHabitCompletionDatesForStreakCalendar =
          (fields[6] as List).cast<DateTime>();
  }

  @override
  void write(BinaryWriter writer, HabitsModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.habitName)
      ..writeByte(1)
      ..write(obj.myHabitDescription)
      ..writeByte(2)
      ..write(obj.habitColorInt)
      ..writeByte(3)
      ..write(obj.myHabitCompletionDateTime)
      ..writeByte(4)
      ..write(obj.habitUId)
      ..writeByte(5)
      ..write(obj.myHabitCompletionDates)
      ..writeByte(6)
      ..write(obj.myTotalHabitCompletionDatesForStreakCalendar);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
