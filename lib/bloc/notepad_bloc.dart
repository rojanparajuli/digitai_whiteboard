import 'package:flutter_bloc/flutter_bloc.dart';
import 'notepad_event.dart';
import 'notepad_state.dart';

class NotepadBloc extends Bloc<NotepadEvent, NotepadState> {
  NotepadBloc() : super(NotepadInitial()) {
    on<LoadNotepad>((event, emit) {
      emit(NotepadLoaded(text: '')); 
    });
    on<UpdateNotepad>((event, emit) {
      emit(NotepadLoaded(text: event.text));
    });
  }
}
