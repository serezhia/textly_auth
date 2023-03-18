// ignore_for_file: avoid_dynamic_calls

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed

///
class User with _$User {
  ///
  factory User({
    @JsonKey(name: 'email') required String email,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'region') required String region,
    @JsonKey(name: 'blocked') required bool blocked,
    @JsonKey(name: 'user_id') int? userId,
  }) = _User;

  ///
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  ///
  factory User.fromPostgres(Map<String, dynamic> row) {
    row['created_at'] = row['created_at'].toString();
    return _$UserFromJson(row);
  }
}
