import 'package:flutter_bloc/flutter_bloc.dart';

class TabControllerCubit extends Cubit<int> {
  TabControllerCubit() : super(0);

  void changeTo(int index) {
    emit(index);
  }

  void goToBible() {
    emit(0);
  }

  void goToSearch() {
    emit(2);
  }

  void goToDeepUnderstanding() {
    emit(1);
  }
}
