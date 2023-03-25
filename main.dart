import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:logger/logger.dart';
import 'package:mailer/smtp_server.dart';
import 'package:postgres/postgres.dart';
import 'package:textly_auth/data_sources/postgres_code_data_source.dart';
import 'package:textly_auth/data_sources/postgres_recovery_code_data_source.dart';
import 'package:textly_auth/data_sources/postgres_user_data_source.dart';
import 'package:textly_auth/repositories/code_repository.dart';
import 'package:textly_auth/repositories/recovery_code_repository.dart';
import 'package:textly_auth/utils/env_utils.dart';
import 'package:textly_core/textly_core.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  final logger = Logger(
    filter: ProductionFilter(),
    printer: PrettyPrinter(
      methodCount: 0,
      noBoxingByDefault: true,
    ),
  );

  /// Создаем соединение с SMTP
  final smtpServer = SmtpServer(
    mailSMTP(),
    port: 465,
    ssl: true,
    username: mailLogin(),
    password: mailPassword(),
  );

  /// Подключаемся к БД
  final dbConection = PostgreSQLConnection(
    dbHost(),
    // '0.0.0.0',
    dbPort(),
    dbName(),
    username: dbUsername(),
    password: dbPassword(),
  );

  try {
    await dbConection.open();
    logger.i('Database connect success');
  } catch (e) {
    logger.e('Error connecting to database');
    Future.delayed(
      const Duration(seconds: 3),
      () => exit(1),
    );
  }

  final userRepository = PostgresUserDataSource(dbConection);
  final codeRepository = PostgresCodeDataSouce(connection: dbConection);
  final recoveryCodeRepository = PostgresRecoveryCodeDataSource(dbConection);

  final newHandler = handler
      .use(
        provider<SmtpServer>(
          (context) => smtpServer,
        ),
      )
      .use(
        provider<Logger>(
          (context) => logger,
        ),
      )
      .use(
        provider<UserRepository>(
          (context) => userRepository,
        ),
      )
      .use(
        provider<CodeRepository>(
          (context) => codeRepository,
        ),
      )
      .use(
        provider<RecoveryCodeRepository>(
          (context) => recoveryCodeRepository,
        ),
      );

  return serve(newHandler, serviceHost(), servicePort());
}
