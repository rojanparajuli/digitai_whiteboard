// notepad_bloc.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'notepad_event.dart';
import 'notepad_state.dart';

class NotepadBloc extends Bloc<NotepadEvent, NotepadState> {
  NotepadBloc()
      : super(NotepadState(
          isDrawingMode: false,
          text: '',
          selectedColor: Colors.black,
          drawings: [],
        ));

  @override
  Stream<NotepadState> mapEventToState(NotepadEvent event) async* {
    if (event is ToggleModeEvent) {
      yield state.copyWith(isDrawingMode: event.isDrawingMode);
    } else if (event is UpdateTextEvent) {
      yield state.copyWith(text: event.text);
    } else if (event is ClearAllEvent) {
      yield state.copyWith(drawings: [], text: '');
    }
  }
}
