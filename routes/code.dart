// ignore_for_file: cast_nullable_to_non_nullable

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dart_frog/dart_frog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:logger/logger.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:postgres/postgres.dart';
import 'package:textly_auth/models/code/code.dart';
import 'package:textly_auth/repositories/code_repository.dart';
import 'package:textly_auth/templates/code_message_tamplate.dart';
import 'package:textly_auth/utils/code_utils.dart';
import 'package:textly_core/textly_core.dart';

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
  ///1. Получаем почту
  ///2. Проверяем не заблокирвоана ли она
  ///3.Если заблокирована то выдать ошибку
  ///4. Если не заблокирована - генерируем код
  ///5. Записываем в бд
  ///6. Генерируем и отправляем пиьсмо

  final body = jsonDecode(await context.request.body()) as Map<String, Object?>;
  final reqEmail = body['mail'] as String?;
  final reqRegion = body['region'] as String?;

  const authCodeTTL = Duration(minutes: 10);

  final logger = context.read<Logger>();
  final uuid = context.read<String>();

  final ip = context.request.connectionInfo.remoteAddress.address;

  final userRepository = context.read<UserRepository>();
  final codeRepository = context.read<CodeRepository>();
  final smtpServer = context.read<SmtpServer>();

  /// Проверяем все параметры
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

  if (!EmailValidator.validate(reqEmail)) {
    logger.i('$uuid: Bad email');
    return Response.json(
      statusCode: 400,
      body: {
        'status': 'error',
        'message': 'Bad email',
        'uuid': uuid,
      },
    );
  }

  //2. Проверяем не заблокирвоана ли она

  final user = await userRepository.getUserByEmail(email: reqEmail);

  if (user != null && user.blocked) {
    //3.Если заблокирована то выдать ошибку

    return Response.json(
      statusCode: 401,
      body: {
        'status': 'error',
        'message': 'Your account is blocked, please check your mail',
        'uuid': uuid,
      },
    );
  }

  //4. Если не заблокирована - генерируем код
  /// Генерируем шестизначный код для подтверждения
  final generatedDigitCode = Random().getDigitCode(6);

  ///5. Записываем в бд
  logger.d('$uuid: codeExists? in db');
  final codeExists =
      (await codeRepository.getCodeByEmail(email: reqEmail)) != null;
  late final Code code;
  final endedAt = DateTime.now().add(authCodeTTL).toUtc();
  try {
    if (codeExists) {
      logger.d('$uuid: GetCodeByMail from db');
      final tempCode =
          await codeRepository.getCodeByEmail(email: reqEmail) as Code;

      /// Ограничение на 2 минуты от спама
      if (DateTime.now()
          .isAfter(tempCode.endedAt.subtract(const Duration(minutes: 8)))) {
        logger.d('$uuid: Update code into db');
        code = await codeRepository.updateCode(
          code: Code(
            email: reqEmail,
            code: generatedDigitCode,
            endedAt: endedAt,
            ip: ip,
            numberAttempts: 0,
          ),
        );
      } else {
        logger.i('$uuid: You can send the code every two minutes');
        return Response.json(
          statusCode: 429,
          body: {
            'status': 'wait',
            'message': 'You can send the code every two minutes',
            'uuid': uuid,
          },
        );
      }
    } else {
      logger.d('$uuid: Update code into db');
      code = await codeRepository.createCode(
        code: Code(
          email: reqEmail,
          code: generatedDigitCode,
          endedAt: endedAt,
          ip: ip,
          numberAttempts: 0,
        ),
      );
    }
  } on PostgreSQLException catch (e) {
    logger.e('$uuid: Code not add/update: ${e.message}');
    return Response.json(
      statusCode: 500,
      body: {
        'status': 'error',
        'message': 'Code not add/update: ${e.message}',
        'exception': 'PostgreSQLException',
        'uuid': uuid,
      },
    );
  } catch (e) {
    logger.e('$uuid: Code not add/update: $e');
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
  //6. Генерируем и отправляем пиьсмо
  /// Генерируем сообщение
  final message = generateCodeMessage(
    region: reqRegion ?? 'en',
    code: code.code,
    email: reqEmail,
  );

  /// Отправляем сообщение
  try {
    final sendReport = send(message, smtpServer);

    logger.d(sendReport.toString());

    return Response.json(body: 'Email sent');
  } on MailerException catch (e) {
    logger.e('$uuid: Message not sent: ${e.message}, problems: ${e.problems}');
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
