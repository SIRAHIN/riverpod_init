// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_credential.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AuthCredential _$AuthCredentialFromJson(Map<String, dynamic> json) {
  return _AuthCredential.fromJson(json);
}

/// @nodoc
mixin _$AuthCredential {
  @HiveField(0)
  String get email => throw _privateConstructorUsedError;
  @HiveField(1)
  String get password => throw _privateConstructorUsedError;

  /// Serializes this AuthCredential to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthCredential
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthCredentialCopyWith<AuthCredential> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthCredentialCopyWith<$Res> {
  factory $AuthCredentialCopyWith(
          AuthCredential value, $Res Function(AuthCredential) then) =
      _$AuthCredentialCopyWithImpl<$Res, AuthCredential>;
  @useResult
  $Res call({@HiveField(0) String email, @HiveField(1) String password});
}

/// @nodoc
class _$AuthCredentialCopyWithImpl<$Res, $Val extends AuthCredential>
    implements $AuthCredentialCopyWith<$Res> {
  _$AuthCredentialCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthCredential
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
  }) {
    return _then(_value.copyWith(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuthCredentialImplCopyWith<$Res>
    implements $AuthCredentialCopyWith<$Res> {
  factory _$$AuthCredentialImplCopyWith(_$AuthCredentialImpl value,
          $Res Function(_$AuthCredentialImpl) then) =
      __$$AuthCredentialImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@HiveField(0) String email, @HiveField(1) String password});
}

/// @nodoc
class __$$AuthCredentialImplCopyWithImpl<$Res>
    extends _$AuthCredentialCopyWithImpl<$Res, _$AuthCredentialImpl>
    implements _$$AuthCredentialImplCopyWith<$Res> {
  __$$AuthCredentialImplCopyWithImpl(
      _$AuthCredentialImpl _value, $Res Function(_$AuthCredentialImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthCredential
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
  }) {
    return _then(_$AuthCredentialImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthCredentialImpl implements _AuthCredential {
  const _$AuthCredentialImpl(
      {@HiveField(0) required this.email,
      @HiveField(1) required this.password});

  factory _$AuthCredentialImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthCredentialImplFromJson(json);

  @override
  @HiveField(0)
  final String email;
  @override
  @HiveField(1)
  final String password;

  @override
  String toString() {
    return 'AuthCredential(email: $email, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthCredentialImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email, password);

  /// Create a copy of AuthCredential
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthCredentialImplCopyWith<_$AuthCredentialImpl> get copyWith =>
      __$$AuthCredentialImplCopyWithImpl<_$AuthCredentialImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthCredentialImplToJson(
      this,
    );
  }
}

abstract class _AuthCredential implements AuthCredential {
  const factory _AuthCredential(
      {@HiveField(0) required final String email,
      @HiveField(1) required final String password}) = _$AuthCredentialImpl;

  factory _AuthCredential.fromJson(Map<String, dynamic> json) =
      _$AuthCredentialImpl.fromJson;

  @override
  @HiveField(0)
  String get email;
  @override
  @HiveField(1)
  String get password;

  /// Create a copy of AuthCredential
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthCredentialImplCopyWith<_$AuthCredentialImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
