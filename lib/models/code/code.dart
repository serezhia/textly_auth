// ignore_for_file: avoid_dynamic_calls

import 'package:freezed_annotation/freezed_annotation.dart';

part 'code.freezed.dart';
part 'code.g.dart';

@freezed

///
class Code with _$Code {
  ///
  factory Code({
    @JsonKey(name: 'email') required String email,
    @JsonKey(name: 'code') required String code,
    @JsonKey(name: 'ended_at') required DateTime endedAt,
    @JsonKey(name: 'ip') required String ip,
    @JsonKey(name: 'number_attempts') required int numberAttempts,
  }) = _Code;

  ///
  factory Code.fromJson(Map<String, dynamic> json) => _$CodeFromJson(json);

  ///
  factory Code.fromPostgres(Map<String, dynamic> row) {
    row['ended_at'] = row['ended_at'].toString();
    return _$CodeFromJson(row);
  }
}
