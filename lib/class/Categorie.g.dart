// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Categorie.dart';

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
      id : fields[0] as int,
      designation : fields[1] as String,
      statut : fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Categorie obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.designation)
      ..writeByte(2)
      ..write(obj.statut);
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
