// ignore_for_file: cast_nullable_to_non_nullable

import 'dart:async';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:logger/logger.dart';
import 'package:textly_auth/utils/env_utils.dart';
import 'package:textly_auth/utils/tokens_utils.dart';
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
  final logger = context.read<Logger>();
  final uuid = context.read<String>();

  if (context.request.headers['Authorization'] == null ||
      context.request.headers['Authorization']!.isEmpty) {
    logger.i('$uuid: The "token" field is required in the Autorization header');
    return Response.json(
      statusCode: 400,
      body: {
        'status': 'error',
        'message': 'The "token" field is required in the Autorization header',
        'uuid': uuid,
      },
    );
  }
  final header = context.request.headers['Authorization']!.split(' ');
  late final String refreshTokenFromHeader;
  if (header[0] == 'Bearer') {
    refreshTokenFromHeader = header[1];
  } else {
    logger.i('$uuid: The "token" field is required in the Autorization header');
    return Response.json(
      statusCode: 400,
      body: {
        'status': 'error',
        'message': 'The "token" field is required in the Autorization header',
        'uuid': uuid,
      },
    );
  }
  final JWT jwt;
  try {
    jwt = JWT.verify(
      refreshTokenFromHeader,
      SecretKey(secretKey()),
      issuer: 'textly_auth_refresh',
    );
  } catch (e) {
    logger.i('$uuid: Incorrect token');
    return Response.json(
      statusCode: 400,
      body: {
        'status': 'error',
        'message': 'Incorrect token',
        'uuid': uuid,
      },
    );
  }

  final userId = int.parse(jwt.subject ?? '-1');
  final oAuth2Token = OAuth2Token(
    accessToken: generateToken(userId: userId),
    refreshToken: generateToken(userId: userId, refreshToken: true),
    tokenType: 'Bearer',
  );

  logger.i('$uuid: Successful refresh');
  return Response.json(
    body: {
      'status': 'success',
      'message': 'Successful refresh',
      'data': oAuth2Token.toJson(),
    },
  );
}
