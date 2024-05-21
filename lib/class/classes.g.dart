// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classes.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WonderAdapter extends TypeAdapter<Wonder> {
  @override
  final int typeId = 1;

  @override
  Wonder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Wonder(
      fields[0] as int,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
      fields[5] as bool,
      fields[6] as int,
      fields[7] as String,
      fields[8] as double,
      fields[9] as double,
      fields[10] as int,
      fields[11] as Categorie,
    );
  }

  @override
  void write(BinaryWriter writer, Wonder obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.idWonder)
      ..writeByte(1)
      ..write(obj.wonderName)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.city)
      ..writeByte(5)
      ..write(obj.free)
      ..writeByte(6)
      ..write(obj.price)
      ..writeByte(7)
      ..write(obj.horaire)
      ..writeByte(8)
      ..write(obj.altitude)
      ..writeByte(9)
      ..write(obj.latitude)
      ..writeByte(10)
      ..write(obj.note)
      ..writeByte(11)
      ..write(obj.categorie);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WonderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
