import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'auth_credential.freezed.dart';
part 'auth_credential.g.dart';

@freezed
@HiveType(typeId: 0) // 🔥 Unique typeId
class AuthCredential with _$AuthCredential {
  const factory AuthCredential({
    @HiveField(0) required String email,
    @HiveField(1) required String password,
  }) = _AuthCredential;

  factory AuthCredential.fromJson(Map<String, dynamic> json) =>
      _$AuthCredentialFromJson(json);
}