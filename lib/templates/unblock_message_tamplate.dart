// ignore_for_file: public_member_api_docs

import 'package:mailer/mailer.dart';
import 'package:textly_auth/utils/env_utils.dart';

Message generateUnblockMessage({
  required String region,
  required String link,
  required String email,
}) {
  return Message()
    ..from = Address(mailLogin(), 'Textly')
    ..recipients.add(email)
    ..subject = region == 'ru' ? 'Восстановление аккаунта' : 'Unblock account'
    ..text = region == 'ru'
        ? 'Ваша ссылка для восставноления аккаунта: $link'
        : 'Your link for unblock account: $link';
}
