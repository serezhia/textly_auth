// ignore_for_file: public_member_api_docs

import 'package:textly_auth/models/code/code.dart';

abstract class CodeRepository {
  Future<Code?> getCodeByEmail({required String email});

  Future<Code> updateCode({required Code code});

  Future<Code> createCode({required Code code});

  Future<void> deleteCode({required String email});
}
