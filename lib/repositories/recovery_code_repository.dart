// ignore_for_file: public_member_api_docs

abstract class RecoveryCodeRepository {
  Future<String?> getRecoveryCodeByEmail({required String email});

  Future<String> updateRecoveryCode({
    required String code,
    required String email,
  });

  Future<String> createRecoveryCode({
    required String code,
    required String email,
  });

  Future<void> deleteRecoveryCode({required String email});
}
