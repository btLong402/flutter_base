// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'demo_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DemoModel {

 String get id; String get name; String? get description; int get count; bool get isActive; DateTime? get createdAt;
/// Create a copy of DemoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DemoModelCopyWith<DemoModel> get copyWith => _$DemoModelCopyWithImpl<DemoModel>(this as DemoModel, _$identity);

  /// Serializes this DemoModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DemoModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.count, count) || other.count == count)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,count,isActive,createdAt);

@override
String toString() {
  return 'DemoModel(id: $id, name: $name, description: $description, count: $count, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $DemoModelCopyWith<$Res>  {
  factory $DemoModelCopyWith(DemoModel value, $Res Function(DemoModel) _then) = _$DemoModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, int count, bool isActive, DateTime? createdAt
});




}
/// @nodoc
class _$DemoModelCopyWithImpl<$Res>
    implements $DemoModelCopyWith<$Res> {
  _$DemoModelCopyWithImpl(this._self, this._then);

  final DemoModel _self;
  final $Res Function(DemoModel) _then;

/// Create a copy of DemoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? count = null,Object? isActive = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DemoModel].
extension DemoModelPatterns on DemoModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DemoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DemoModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DemoModel value)  $default,){
final _that = this;
switch (_that) {
case _DemoModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DemoModel value)?  $default,){
final _that = this;
switch (_that) {
case _DemoModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  int count,  bool isActive,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DemoModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.count,_that.isActive,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  int count,  bool isActive,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _DemoModel():
return $default(_that.id,_that.name,_that.description,_that.count,_that.isActive,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  int count,  bool isActive,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _DemoModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.count,_that.isActive,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DemoModel implements DemoModel {
  const _DemoModel({required this.id, required this.name, this.description, this.count = 0, this.isActive = false, this.createdAt});
  factory _DemoModel.fromJson(Map<String, dynamic> json) => _$DemoModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override@JsonKey() final  int count;
@override@JsonKey() final  bool isActive;
@override final  DateTime? createdAt;

/// Create a copy of DemoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DemoModelCopyWith<_DemoModel> get copyWith => __$DemoModelCopyWithImpl<_DemoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DemoModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DemoModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.count, count) || other.count == count)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,count,isActive,createdAt);

@override
String toString() {
  return 'DemoModel(id: $id, name: $name, description: $description, count: $count, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DemoModelCopyWith<$Res> implements $DemoModelCopyWith<$Res> {
  factory _$DemoModelCopyWith(_DemoModel value, $Res Function(_DemoModel) _then) = __$DemoModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, int count, bool isActive, DateTime? createdAt
});




}
/// @nodoc
class __$DemoModelCopyWithImpl<$Res>
    implements _$DemoModelCopyWith<$Res> {
  __$DemoModelCopyWithImpl(this._self, this._then);

  final _DemoModel _self;
  final $Res Function(_DemoModel) _then;

/// Create a copy of DemoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? count = null,Object? isActive = null,Object? createdAt = freezed,}) {
  return _then(_DemoModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
