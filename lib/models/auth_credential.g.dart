// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_credential.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuthCredentialAdapter extends TypeAdapter<AuthCredential> {
  @override
  final int typeId = 0;

  @override
  AuthCredential read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthCredential(
      email: fields[0] as String,
      password: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AuthCredential obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.password);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthCredentialAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthCredentialImpl _$$AuthCredentialImplFromJson(Map<String, dynamic> json) =>
    _$AuthCredentialImpl(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$$AuthCredentialImplToJson(
        _$AuthCredentialImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };
