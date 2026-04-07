import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'bible_version_state.dart';

class BibleVersionCubit extends Cubit<BibleVersionState> {
  BibleVersionCubit()
      : super(kIsWeb
            ? const BibleVersionStateARC()
            : const BibleVersionStateJFAA());

  void changeVersion(BibleVersions e) {
    switch (e) {
      case BibleVersions.acf:
        emit(const BibleVersionStateACF());
        break;
      case BibleVersions.arc:
        emit(const BibleVersionStateARC());
        break;
      case BibleVersions.jfaa:
        emit(const BibleVersionStateJFAA());
        break;
      case BibleVersions.kja:
        emit(const BibleVersionStateKJA());
        break;
      case BibleVersions.kjf:
        emit(const BibleVersionStateKJF());
        break;
      // case BibleVersions.ntlh:
      //   emit(BibleVersionStateNTLH());
      //   break;
      case BibleVersions.nvi:
        emit(const BibleVersionStateNVI());
        break;
    }
  }

  void changeVersionById(String id) {
    try {
      final version = BibleVersions.values.firstWhere(
        (v) => v.id.toUpperCase() == id.toUpperCase(),
      );
      changeVersion(version);
    } catch (_) {
      // Version not found, ignore or handle as needed
    }
  }
}
