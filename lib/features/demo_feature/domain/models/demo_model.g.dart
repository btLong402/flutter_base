// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DemoModel _$DemoModelFromJson(Map<String, dynamic> json) => _DemoModel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  count: (json['count'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? false,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$DemoModelToJson(_DemoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'count': instance.count,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
