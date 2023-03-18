// ignore_for_file: public_member_api_docs

import 'package:postgres/postgres.dart';
import 'package:textly_auth/models/user/user.dart';
import 'package:textly_auth/repositories/user_repository.dart';

class PostgresUserDataSource implements UserRepository {
  PostgresUserDataSource(this.connection);

  final PostgreSQLConnection connection;
  @override
  Future<User> createUser({required User user}) async {
    final response = await connection.mappedResultsQuery(
      '''
      INSERT INTO users (email, created_at, region, blocked)
      VALUES (@email, @created_at, @region, @blocked)
      RETURNING *
      ''',
      substitutionValues: user.toJson(),
    );

    return User.fromPostgres(response.first['users'] ?? {});
  }

  @override
  Future<void> deleteUser({required String userId}) async {
    await connection.mappedResultsQuery(
      '''
      DELETE 
      FROM users
      WHERE user_id = @user_id
      ''',
      substitutionValues: {
        'user_id': userId,
      },
    );
    return;
  }

  @override
  Future<User?> getUserByEmail({required String email}) async {
    final result = await connection.mappedResultsQuery(
      '''
      SELECT *
      FROM users
      WHERE email = @email
      ''',
      substitutionValues: {
        'email': email,
      },
    );
    if (result.isEmpty) {
      return null;
    }
    return User.fromPostgres(result.first['users'] ?? {});
  }

  @override
  Future<User?> getUserById({required int userId}) async {
    final result = await connection.mappedResultsQuery(
      '''
      SELECT *
      FROM users
      WHERE user_id = @user_id
      ''',
      substitutionValues: {
        'user_id': userId,
      },
    );
    if (result.isEmpty) {
      return null;
    }
    return User.fromPostgres(result.first['users'] ?? {});
  }

  @override
  Future<User> updateUser({required User user}) async {
    final result = await connection.mappedResultsQuery(
      '''
      UPDATE users
      SET blocked = @blocked, region = @region
      WHERE users.email = @email
      RETURNING *
      ''',
      substitutionValues: user.toJson(),
    );
    return User.fromPostgres(result.first['users'] ?? {});
  }
}
