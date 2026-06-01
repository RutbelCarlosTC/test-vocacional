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

class DimensionScoreAdapter extends TypeAdapter<DimensionScore> {
  @override
  final int typeId = 3;

  @override
  DimensionScore read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DimensionScore(
      key: fields[0] as String,
      label: fields[1] as String,
      score: fields[2] as int,
      maxScore: fields[3] as int,
      level: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DimensionScore obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.score)
      ..writeByte(3)
      ..write(obj.maxScore)
      ..writeByte(4)
      ..write(obj.level);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DimensionScoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
      afinidadPrimaria: fields[6] as String?,
      afinidadSecundaria: fields[7] as String?,
      afinidadTerciaria: fields[8] as String?,
      dimensionScores: (fields[9] as List).cast<DimensionScore>(),
      isValid: fields[10] as bool,
      scoringType: fields[11] as String,
      isSynced: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AreaAttempt obj) {
    writer
      ..writeByte(13)
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
      ..write(obj.afinidadTerciaria)
      ..writeByte(9)
      ..write(obj.dimensionScores)
      ..writeByte(10)
      ..write(obj.isValid)
      ..writeByte(11)
      ..write(obj.scoringType)
      ..writeByte(12)
      ..write(obj.isSynced);
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
