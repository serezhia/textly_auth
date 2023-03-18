// ignore_for_file: avoid_catching_errors, public_member_api_docs

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:textly_auth/utils/env_utils.dart';

String generateToken({required int userId, bool refreshToken = false}) {
  final jwt = JWT(
    {
      'iat': DateTime.now(),
    },
    issuer: refreshToken ? 'textly_auth_refresh' : 'textly_auth',
    subject: '$userId',
  );
  return jwt.sign(
    SecretKey(secretKey()),
    expiresIn:
        refreshToken ? const Duration(days: 30) : const Duration(minutes: 15),
  );
}

JWT? verifyToken(String token, {bool isRefreshToken = false}) {
  try {
    return JWT.verify(
      token,
      SecretKey(secretKey()),
      issuer: isRefreshToken ? 'textly_auth_refresh' : 'textly_auth',
    );
  } catch (e) {
    return null;
  }
}
