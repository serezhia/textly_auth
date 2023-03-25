// ignore_for_file: public_member_api_docs

import 'package:mailer/mailer.dart';
import 'package:textly_auth/utils/env_utils.dart';

Message generateCodeMessage({
  required String region,
  required String code,
  required String email,
}) {
  return Message()
    ..from = Address(mailLogin(), 'Textly')
    ..recipients.add(email)
    ..subject = region == 'ru' ? 'Код подтверждения Textly' : 'Auth code Textly'
    ..text = region == 'ru'
        ? 'Ваш код подтверждения: $code'
        : 'Your auth code: $code';
}
