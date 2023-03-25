// ignore_for_file: cast_nullable_to_non_nullable

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:logger/logger.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:textly_auth/repositories/code_repository.dart';
import 'package:textly_auth/repositories/recovery_code_repository.dart';
import 'package:textly_auth/tamplates/unblock_message_tamplate.dart';
import 'package:textly_auth/utils/tokens_utils.dart';
import 'package:textly_core/textly_core.dart';
import 'package:uuid/uuid.dart';

FutureOr<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.post:
      return _post(context);
    case HttpMethod.get:
    case HttpMethod.put:
    case HttpMethod.delete:
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _post(RequestContext context) async {
  final body = jsonDecode(await context.request.body()) as Map<String, Object?>;
  final reqEmail = body['mail'] as String?;
  final authCode = body['code'] as String?;

  ///1. Получаем почту
  ///2. Проверяем не заблокирована ли она
  ///3. Если заблокирована то вернуть ошибку
  ///4. Если не заблокирована, ищем код в бд при отсуствие возвращаем ошибку
  ///5. Смотри количество попыток, при 10 баним аккаунт и возвращаем ошибку
  ///6. Проверяем пользователя на наличие при отсутствии создаем аккаунт
  ///7. Генерируем токены и отправляем пиьсмо

  final logger = context.read<Logger>();
  final uuid = context.read<String>();

  final userRepository = context.read<UserRepository>();
  final codeRepository = context.read<CodeRepository>();
  final recoveryCodeRepository = context.read<RecoveryCodeRepository>();
  final smtpServer = context.read<SmtpServer>();

  if (reqEmail == null) {
    logger.i('$uuid: The "mail" field is required in the body');
    return Response.json(
      statusCode: 400,
      body: {
        'status': 'error',
        'message': 'The "mail" field is required in the body',
        'uuid': uuid,
      },
    );
  }

  if (authCode == null) {
    logger.i('$uuid: The "code" field is required in the body');
    return Response.json(
      statusCode: 400,
      body: {
        'status': 'error',
        'message': 'The "code" field is required in the body',
        'uuid': uuid,
      },
    );
  }

  //2. Проверяем не заблокирвоана ли она

  final userFromEmail = await userRepository.getUserByEmail(email: reqEmail);

  if (userFromEmail != null && userFromEmail.blocked) {
    logger.i('$uuid: Your user account is blocked, please check your mail');
    return Response.json(
      statusCode: 400,
      body: {
        'status': 'error',
        'message': 'Your user account is blocked, please check your mail',
        'uuid': uuid,
      },
    );
  }

  ///4. Если не заблокирована, ищем код в бд при отсуствие возвращаем ошибку

  final code = await codeRepository.getCodeByEmail(email: reqEmail);

  if (code == null) {
    logger.i('$uuid: Code not found, please try get code');
    return Response.json(
      statusCode: 400,
      body: {
        'status': 'error',
        'message': 'Code not found, please try get code',
        'uuid': uuid,
      },
    );
  }

  ///5. Сравниваем код

  if (code.code != authCode) {
    /// при неверном коде приплюсовые значние количества попыток
    final newCode = code.copyWith(numberAttempts: code.numberAttempts + 1);
    //Обновляем в бд
    await codeRepository.updateCode(code: newCode);

    ///Сравниваем количество попыток с максимально возможным
    if (newCode.numberAttempts > 5) {
      //Удаляем код при достижении порога
      await codeRepository.deleteCode(email: reqEmail);

      // Ищем юзера
      final user = await userRepository.getUserByEmail(email: reqEmail);
      // При нахождении блокируем аккаунт и выкидываем ошибку
      if (user != null) {
        await userRepository.updateUser(user: user.copyWith(blocked: true));

        /// Генерируем линку
        final recoveryCode = const Uuid().v4();

        final recoveryLink =
            'https://textly.dev/api/auth/unlock?email=$reqEmail&code=$recoveryCode';

        /// Отправляем пиьсмо с ссылкой

        final recoveryCodeFromDb = await recoveryCodeRepository
            .getRecoveryCodeByEmail(email: reqEmail);

        if (recoveryCodeFromDb == null) {
          await recoveryCodeRepository.createRecoveryCode(
            code: recoveryCode,
            email: reqEmail,
          );
        } else {
          await recoveryCodeRepository.updateRecoveryCode(
            code: recoveryCode,
            email: reqEmail,
          );
        }

        final message = generateUnblockMessage(
          region: 'ru',
          link: recoveryLink,
          email: reqEmail,
        );

        try {
          final sendReport = send(message, smtpServer);

          logger.d(sendReport.toString());

          return Response.json(
            statusCode: 401,
            body: {
              'status': 'error',
              'message': 'Your account is blocked, please check your mail',
              'uuid': uuid,
            },
          );
        } on MailerException catch (e) {
          logger.e(
            '$uuid: Message not sent: ${e.message}, problems: ${e.problems}',
          );
          return Response.json(
            statusCode: 500,
            body: {
              'status': 'error',
              'message': 'Message not sent: ${e.message}',
              'exception': 'MailerException',
              'uuid': uuid,
            },
          );
        } catch (e) {
          logger.e('$uuid: Message not sent: $e');
          return Response.json(
            statusCode: 500,
            body: {
              'status': 'error',
              'message': 'Message not sent: $e',
              'exception': 'unknown',
              'uuid': uuid,
            },
          );
        }
      }
      // Выкидываем ошибку о неправильнмо коде
      return Response.json(
        statusCode: 400,
        body: {
          'status': 'error',
          'message': 'Incorrect code, please get new code',
          'uuid': uuid,
        },
      );
    }

    logger.i('$uuid: Incorrect code');
    return Response.json(
      statusCode: 400,
      body: {
        'status': 'error',
        'message': 'Incorrect code',
        'uuid': uuid,
      },
    );
  }

  /// Удаляем токен из бд
  try {
    logger.d('$uuid: delete code from db');
    await codeRepository.deleteCode(email: reqEmail);
  } catch (e) {
    logger.e('$uuid: error delete code from db');
    return Response.json(
      statusCode: 500,
      body: {
        'status': 'error',
        'message': 'error delete code from db, error: $e',
        'uuid': uuid,
      },
    );
  }

  ///6. Проверяем пользователя на наличие при отсутствии создаем аккаунт
  final User user;
  if (userFromEmail == null) {
    user = await userRepository.createUser(
      user: User(
        email: reqEmail,
        createdAt: DateTime.now(),
        region: 'ru',
        blocked: false,
      ),
    );
  } else {
    user = await userRepository.getUserByEmail(email: reqEmail) as User;
  }

  ///7. Генерируем токены и отправляем пиьсмо

  final oAuth2Token = OAuth2Token(
    accessToken: generateToken(userId: user.userId ?? -1),
    refreshToken: generateToken(userId: user.userId ?? -1, refreshToken: true),
    tokenType: 'Bearer',
  );

  logger.i('$uuid: Successful login');
  return Response.json(
    body: {
      'status': 'success',
      'message': 'Successful login',
      'data': oAuth2Token.toJson(),
    },
  );
}
