import 'package:freezed_annotation/freezed_annotation.dart';

part 'demo_model.freezed.dart';
part 'demo_model.g.dart';

@freezed
abstract class DemoModel with _$DemoModel {
  const factory DemoModel({
    required String id,
    required String name,
    String? description,
    @Default(0) int count,
    @Default(false) bool isActive,
    DateTime? createdAt,
  }) = _DemoModel;

  factory DemoModel.fromJson(Map<String, dynamic> json) =>
      _$DemoModelFromJson(json);
}
