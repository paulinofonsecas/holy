import 'package:bloc/bloc.dart';

class ChangeMyNameState {
  final String name;

  ChangeMyNameState({required this.name});
}

class ChangeMyNameInitialState extends ChangeMyNameState {
  ChangeMyNameInitialState() : super(name: 'Amada/o');
}

class NameChanged extends ChangeMyNameState {
  NameChanged({required super.name});
}

class ChangeMyNameCubit extends Cubit<ChangeMyNameState> {
  ChangeMyNameCubit() : super(ChangeMyNameInitialState());

  void changeName(String newName) {
    emit(NameChanged(name: newName));
  }
}
