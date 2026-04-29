 import 'package:hive/hive.dart';
import 'package:riverpod_practice/models/auth_credential.dart';

abstract class AuthLocalService {
  Future<void> setUserCredential({required String email, required String password});
  Future<AuthCredential?> getUserCredential();
}


class AuthLocalServiceImpl implements AuthLocalService {
  static const String _boxName = 'authBox';
  static const String _key = 'user';

  Future<Box<AuthCredential>> _openBox() async {
    return await Hive.openBox<AuthCredential>(_boxName);
  }

  @override
  Future<void> setUserCredential({
    required String email,
    required String password,
  }) async {
    final box = await _openBox();

    final credential = AuthCredential(
      email: email,
      password: password,
    );

    await box.put(_key, credential);
  }

  @override
  Future<AuthCredential?> getUserCredential() async {
    final box = await _openBox();
    return box.get(_key);
  }
}