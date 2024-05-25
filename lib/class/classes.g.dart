// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classes.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategorieAdapter extends TypeAdapter<Categorie> {
  @override
  final int typeId = 0;

  @override
  Categorie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Categorie(
      fields[0] as int,
      fields[1] as String,
      fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Categorie obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.idCategory)
      ..writeByte(1)
      ..write(obj.categoryName)
      ..writeByte(2)
      ..write(obj.iconName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategorieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
      fields[5] as String,
      fields[6] as bool,
      fields[7] as int,
      fields[8] as String,
      fields[9] as double,
      fields[10] as double,
      fields[11] as int,
      fields[12] as Categorie,
    );
  }

  @override
  void write(BinaryWriter writer, Wonder obj) {
    writer
      ..writeByte(13)
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
      ..write(obj.altitude)
      ..writeByte(10)
      ..write(obj.latitude)
      ..writeByte(11)
      ..write(obj.note)
      ..writeByte(12)
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
