// ignore_for_file: public_member_api_docs

import 'package:postgres/postgres.dart';
import 'package:textly_auth/models/code/code.dart';
import 'package:textly_auth/repositories/code_repository.dart';

class PostgresCodeDataSouce extends CodeRepository {
  PostgresCodeDataSouce({
    required this.connection,
  });

  final PostgreSQLConnection connection;

  @override
  Future<Code> createCode({required Code code}) async {
    final result = await connection.mappedResultsQuery(
      '''
      INSERT INTO codes (email, code, ended_at, ip, number_attempts)
      VALUES (@email, @code, @ended_at, @ip, @number_attempts)
      RETURNING *
      ''',
      substitutionValues: code.toJson(),
    );
    return Code.fromPostgres(result.first['codes'] ?? {});
  }

  @override
  Future<void> deleteCode({required String email}) async {
    await connection.mappedResultsQuery(
      '''
      DELETE 
      FROM codes
      WHERE email = @email
      ''',
      substitutionValues: {
        'email': email,
      },
    );
    return;
  }

  @override
  Future<Code?> getCodeByEmail({required String email}) async {
    final result = await connection.mappedResultsQuery(
      '''
      SELECT *
      FROM codes
      WHERE codes.email = @email
      ''',
      substitutionValues: {
        'email': email,
      },
    );
    if (result.isEmpty) {
      return null;
    }
    return Code.fromPostgres(result.first['codes'] ?? {});
  }

  @override
  Future<Code> updateCode({required Code code}) async {
    final result = await connection.mappedResultsQuery(
      '''
      UPDATE codes
      SET code = @code, ended_at = @ended_at, ip = @ip, number_attempts = @number_attempts
      WHERE codes.email = @email
      RETURNING *
      ''',
      substitutionValues: code.toJson(),
    );
    return Code.fromPostgres(result.first['codes'] ?? {});
  }
}
