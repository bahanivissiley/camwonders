// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Wonder.dart';

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
      idWonder: fields[0] as String,
      wonderName: fields[1] as String,
      description: fields[2] as String,
      imagePath: fields[3] as String,
      city: fields[4] as String,
      region: fields[5] as String,
      free: fields[6] as bool,
      price: fields[7] as int,
      horaire: fields[8] as String,
      latitude: fields[9] as String,
      longitude: fields[10] as String,
      note: fields[11] as double,
      categorie: fields[12] as String,
      isreservable: fields[13] as bool,
      acces: fields[14] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Wonder obj) {
    writer
      ..writeByte(14)
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
      ..write(obj.region)
      ..writeByte(6)
      ..write(obj.free)
      ..writeByte(7)
      ..write(obj.price)
      ..writeByte(8)
      ..write(obj.horaire)
      ..writeByte(9)
      ..write(obj.latitude)
      ..writeByte(10)
      ..write(obj.longitude)
      ..writeByte(11)
      ..write(obj.note)
      ..writeByte(12)
      ..write(obj.categorie)
      ..writeByte(13)
      ..write(obj.isreservable);
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
