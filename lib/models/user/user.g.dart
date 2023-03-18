// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_User _$$_UserFromJson(Map<String, dynamic> json) => _$_User(
      email: json['email'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      region: json['region'] as String,
      blocked: json['blocked'] as bool,
      userId: json['user_id'] as int?,
    );

Map<String, dynamic> _$$_UserToJson(_$_User instance) => <String, dynamic>{
      'email': instance.email,
      'created_at': instance.createdAt.toIso8601String(),
      'region': instance.region,
      'blocked': instance.blocked,
      'user_id': instance.userId,
    };
