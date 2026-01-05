// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verse_resolver.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VerseReference _$VerseReferenceFromJson(Map<String, dynamic> json) {
  return _VerseReference.fromJson(json);
}

/// @nodoc
mixin _$VerseReference {
  String get book => throw _privateConstructorUsedError;
  int get chapter => throw _privateConstructorUsedError;
  int get verse => throw _privateConstructorUsedError;
  String? get version => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VerseReferenceCopyWith<VerseReference> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VerseReferenceCopyWith<$Res> {
  factory $VerseReferenceCopyWith(
          VerseReference value, $Res Function(VerseReference) then) =
      _$VerseReferenceCopyWithImpl<$Res, VerseReference>;
  @useResult
  $Res call({String book, int chapter, int verse, String? version});
}

/// @nodoc
class _$VerseReferenceCopyWithImpl<$Res, $Val extends VerseReference>
    implements $VerseReferenceCopyWith<$Res> {
  _$VerseReferenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? book = null,
    Object? chapter = null,
    Object? verse = null,
    Object? version = freezed,
  }) {
    return _then(_value.copyWith(
      book: null == book
          ? _value.book
          : book // ignore: cast_nullable_to_non_nullable
              as String,
      chapter: null == chapter
          ? _value.chapter
          : chapter // ignore: cast_nullable_to_non_nullable
              as int,
      verse: null == verse
          ? _value.verse
          : verse // ignore: cast_nullable_to_non_nullable
              as int,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VerseReferenceImplCopyWith<$Res>
    implements $VerseReferenceCopyWith<$Res> {
  factory _$$VerseReferenceImplCopyWith(_$VerseReferenceImpl value,
          $Res Function(_$VerseReferenceImpl) then) =
      __$$VerseReferenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String book, int chapter, int verse, String? version});
}

/// @nodoc
class __$$VerseReferenceImplCopyWithImpl<$Res>
    extends _$VerseReferenceCopyWithImpl<$Res, _$VerseReferenceImpl>
    implements _$$VerseReferenceImplCopyWith<$Res> {
  __$$VerseReferenceImplCopyWithImpl(
      _$VerseReferenceImpl _value, $Res Function(_$VerseReferenceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? book = null,
    Object? chapter = null,
    Object? verse = null,
    Object? version = freezed,
  }) {
    return _then(_$VerseReferenceImpl(
      book: null == book
          ? _value.book
          : book // ignore: cast_nullable_to_non_nullable
              as String,
      chapter: null == chapter
          ? _value.chapter
          : chapter // ignore: cast_nullable_to_non_nullable
              as int,
      verse: null == verse
          ? _value.verse
          : verse // ignore: cast_nullable_to_non_nullable
              as int,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VerseReferenceImpl implements _VerseReference {
  const _$VerseReferenceImpl(
      {required this.book,
      required this.chapter,
      required this.verse,
      this.version});

  factory _$VerseReferenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$VerseReferenceImplFromJson(json);

  @override
  final String book;
  @override
  final int chapter;
  @override
  final int verse;
  @override
  final String? version;

  @override
  String toString() {
    return 'VerseReference(book: $book, chapter: $chapter, verse: $verse, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerseReferenceImpl &&
            (identical(other.book, book) || other.book == book) &&
            (identical(other.chapter, chapter) || other.chapter == chapter) &&
            (identical(other.verse, verse) || other.verse == verse) &&
            (identical(other.version, version) || other.version == version));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, book, chapter, verse, version);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VerseReferenceImplCopyWith<_$VerseReferenceImpl> get copyWith =>
      __$$VerseReferenceImplCopyWithImpl<_$VerseReferenceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VerseReferenceImplToJson(
      this,
    );
  }
}

abstract class _VerseReference implements VerseReference {
  const factory _VerseReference(
      {required final String book,
      required final int chapter,
      required final int verse,
      final String? version}) = _$VerseReferenceImpl;

  factory _VerseReference.fromJson(Map<String, dynamic> json) =
      _$VerseReferenceImpl.fromJson;

  @override
  String get book;
  @override
  int get chapter;
  @override
  int get verse;
  @override
  String? get version;
  @override
  @JsonKey(ignore: true)
  _$$VerseReferenceImplCopyWith<_$VerseReferenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
