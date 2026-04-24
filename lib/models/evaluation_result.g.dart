// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'evaluation_result.dart';

// ──────────────────────────────────────────────
// AnswerRecord  typeId: 0
// ──────────────────────────────────────────────
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

// ──────────────────────────────────────────────
// AreaAttempt  typeId: 1
// ──────────────────────────────────────────────
class AreaAttemptAdapter extends TypeAdapter<AreaAttempt> {
  @override
  final int typeId = 1;

  @override
  AreaAttempt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AreaAttempt(
      attemptNumber: fields[0] as int,
      date: fields[1] as DateTime,
      area: fields[2] as String,
      answers: (fields[3] as List).cast<AnswerRecord>(),
      totalScore: fields[4] as int,
      maxPossibleScore: fields[5] as int,
      afinidadPrimaria: fields[6] as String,
      afinidadSecundaria: fields[7] as String,
      afinidadTerciaria: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AreaAttempt obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.attemptNumber)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.area)
      ..writeByte(3)
      ..write(obj.answers)
      ..writeByte(4)
      ..write(obj.totalScore)
      ..writeByte(5)
      ..write(obj.maxPossibleScore)
      ..writeByte(6)
      ..write(obj.afinidadPrimaria)
      ..writeByte(7)
      ..write(obj.afinidadSecundaria)
      ..writeByte(8)
      ..write(obj.afinidadTerciaria);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AreaAttemptAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// ──────────────────────────────────────────────
// AreaProgress  typeId: 2
// ──────────────────────────────────────────────
class AreaProgressAdapter extends TypeAdapter<AreaProgress> {
  @override
  final int typeId = 2;

  @override
  AreaProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AreaProgress(
      profileId: fields[0] as String,
      area: fields[1] as String,
      attempts: (fields[2] as List).cast<AreaAttempt>(),
      draftAnswers: (fields[3] as List).cast<AnswerRecord>(),
      draftLastIndex: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AreaProgress obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.profileId)
      ..writeByte(1)
      ..write(obj.area)
      ..writeByte(2)
      ..write(obj.attempts)
      ..writeByte(3)
      ..write(obj.draftAnswers)
      ..writeByte(4)
      ..write(obj.draftLastIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AreaProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}