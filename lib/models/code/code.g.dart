// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Code _$$_CodeFromJson(Map<String, dynamic> json) => _$_Code(
      email: json['email'] as String,
      code: json['code'] as String,
      endedAt: DateTime.parse(json['ended_at'] as String),
      ip: json['ip'] as String,
      numberAttempts: json['number_attempts'] as int,
    );

Map<String, dynamic> _$$_CodeToJson(_$_Code instance) => <String, dynamic>{
      'email': instance.email,
      'code': instance.code,
      'ended_at': instance.endedAt.toIso8601String(),
      'ip': instance.ip,
      'number_attempts': instance.numberAttempts,
    };
