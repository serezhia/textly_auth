// ignore_for_file: public_member_api_docs

import 'package:textly_auth/models/user/user.dart';

abstract class UserRepository {
  Future<User?> getUserByEmail({required String email});

  Future<User?> getUserById({required int userId});

  Future<User> updateUser({required User user});

  Future<User> createUser({required User user});

  Future<void> deleteUser({required String userId});
}
