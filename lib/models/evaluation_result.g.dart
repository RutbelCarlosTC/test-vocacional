// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evaluation_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnswerRecordAdapter extends TypeAdapter<AnswerRecord> {
  @override
  final int typeId = 0;

  @override
  AnswerRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnswerRecord(
      questionId: fields[0] as int,
      questionText: fields[1] as String,
      selectedOption: fields[2] as String,
      value: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AnswerRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.questionId)
      ..writeByte(1)
      ..write(obj.questionText)
      ..writeByte(2)
      ..write(obj.selectedOption)
      ..writeByte(3)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnswerRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AreaResultAdapter extends TypeAdapter<AreaResult> {
  @override
  final int typeId = 1;

  @override
  AreaResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AreaResult(
      area: fields[0] as String,
      answers: (fields[1] as List).cast<AnswerRecord>(),
      totalScore: fields[2] as int,
      maxPossibleScore: fields[3] as int,
      completed: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AreaResult obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.area)
      ..writeByte(1)
      ..write(obj.answers)
      ..writeByte(2)
      ..write(obj.totalScore)
      ..writeByte(3)
      ..write(obj.maxPossibleScore)
      ..writeByte(4)
      ..write(obj.completed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AreaResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EvaluationResultAdapter extends TypeAdapter<EvaluationResult> {
  @override
  final int typeId = 2;

  @override
  EvaluationResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EvaluationResult(
      id: fields[0] as String,
      profileId: fields[1] as String,
      area: fields[2] as String,
      date: fields[3] as DateTime,
      answers: (fields[4] as List).cast<AnswerRecord>(),
      totalScore: fields[5] as int,
      maxPossibleScore: fields[6] as int,
      completed: fields[7] as bool,
      lastAnsweredIndex: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, EvaluationResult obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.profileId)
      ..writeByte(2)
      ..write(obj.area)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.answers)
      ..writeByte(5)
      ..write(obj.totalScore)
      ..writeByte(6)
      ..write(obj.maxPossibleScore)
      ..writeByte(7)
      ..write(obj.completed)
      ..writeByte(8)
      ..write(obj.lastAnsweredIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
