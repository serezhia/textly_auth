// ignore_for_file: public_member_api_docs

import 'package:postgres/postgres.dart';
import 'package:textly_auth/repositories/recovery_code_repository.dart';

class PostgresRecoveryCodeDataSource implements RecoveryCodeRepository {
  PostgresRecoveryCodeDataSource(this.connection);

  final PostgreSQLConnection connection;
  @override
  Future<String> createRecoveryCode({
    required String code,
    required String email,
  }) async {
    await connection.mappedResultsQuery(
      '''
      INSERT INTO recovery_codes (email, recovery_code)
      VALUES (@email, @recovery_code)
      RETURNING *
      ''',
      substitutionValues: {
        'email': email,
        'recovery_code': code,
      },
    );
    return code;
  }

  @override
  Future<void> deleteRecoveryCode({required String email}) async {
    await connection.mappedResultsQuery(
      '''
      DELETE 
      FROM recovery_codes
      WHERE email = @email
      ''',
      substitutionValues: {
        'email': email,
      },
    );
    return;
  }

  @override
  Future<String?> getRecoveryCodeByEmail({required String email}) async {
    final result = await connection.mappedResultsQuery(
      '''
      SELECT *
      FROM recovery_codes
      WHERE email = @email
      ''',
      substitutionValues: {
        'email': email,
      },
    );
    if (result.isEmpty) {
      return null;
    }
    return result.first['recovery_codes']?['recovery_code'] as String?;
  }

  @override
  Future<String> updateRecoveryCode({
    required String code,
    required String email,
  }) async {
    await connection.mappedResultsQuery(
      '''
      UPDATE recovery_codes
      SET recovery_code = @recovery_code
      WHERE email = @email
      RETURNING *
      ''',
      substitutionValues: {
        'email': email,
        'recovery_code': code,
      },
    );
    return code;
  }
}
