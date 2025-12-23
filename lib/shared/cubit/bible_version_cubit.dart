import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'bible_version_state.dart';

class BibleVersionCubit extends Cubit<BibleVersionState> {
  BibleVersionCubit() : super(BibleVersionStateKJA());

  void changeVersion(BibleVersions e) {
    switch (e) {
      case BibleVersions.acf:
        emit(BibleVersionStateACF());
        break;
      case BibleVersions.jfaa:
        emit(BibleVersionStateJFAA());
        break;
      case BibleVersions.kja:
        emit(BibleVersionStateKJA());
        break;
      case BibleVersions.kjf:
        emit(BibleVersionStateKJF());
        break;
      // case BibleVersions.ntlh:
      //   emit(BibleVersionStateNTLH());
      //   break;
      case BibleVersions.nvi:
        emit(BibleVersionStateNVI());
        break;
    }
  }
}
