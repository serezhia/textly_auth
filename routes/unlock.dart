import 'dart:async';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:logger/logger.dart';
import 'package:textly_auth/repositories/recovery_code_repository.dart';
import '../../../core/lib/src/repositories/user_repository.dart';
import 'package:textly_auth/tamplates/unblock_page_tamplate.dart';

FutureOr<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context);
    case HttpMethod.post:
    case HttpMethod.put:
    case HttpMethod.delete:
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _get(RequestContext context) async {
  final params = context.request.uri.queryParameters;
  final reqCode = params['code'];
  final reqEmail = params['email'];

  final recoveryCodeRepository = context.read<RecoveryCodeRepository>();
  final userRepository = context.read<UserRepository>();

  final logger = context.read<Logger>();
  final uuid = context.read<String>();

  /// Проверяем все параметры
  if (reqEmail == null) {
    logger.i('$uuid: The "email" field is required in the params');
    return Response(
      body: generateUnblockErrorPage(),
      headers: {
        'Content-Type': 'text/html; charset=utf-8',
      },
    );
  }
  if (reqCode == null) {
    logger.i('$uuid: The "code" field is required in the params');
    return Response(
      body: generateUnblockErrorPage(),
      headers: {
        'Content-Type': 'text/html; charset=utf-8',
      },
    );
  }

  final codeFromDb =
      await recoveryCodeRepository.getRecoveryCodeByEmail(email: reqEmail);

  if (codeFromDb == null) {
    logger.i('$uuid: The code is not found');
    return Response(
      body: generateUnblockErrorPage(),
      headers: {
        'Content-Type': 'text/html; charset=utf-8',
      },
    );
  }

  if (codeFromDb != reqCode) {
    logger.i('$uuid: Wrong code');
    return Response(
      body: generateUnblockErrorPage(),
      headers: {
        'Content-Type': 'text/html; charset=utf-8',
      },
    );
  }

  final user = await userRepository.getUserByEmail(email: reqEmail);

  if (user == null) {
    logger.i('$uuid: user is not found');
    return Response(
      body: generateUnblockErrorPage(),
      headers: {
        'Content-Type': 'text/html; charset=utf-8',
      },
    );
  }
  try {
    await userRepository.updateUser(user: user.copyWith(blocked: false));
  } catch (e) {
    logger.e('$uuid: error update user');
    return Response(
      body: generateUnblockErrorPage(),
      headers: {
        'Content-Type': 'text/html; charset=utf-8',
      },
    );
  }
  try {
    await recoveryCodeRepository.deleteRecoveryCode(email: reqEmail);
  } catch (e) {
    logger.e('$uuid: error delete recovery code');
  }

  return Response(
    body: generateUnblockPage(),
    headers: {
      'Content-Type': 'text/html; charset=utf-8',
    },
  );
}
