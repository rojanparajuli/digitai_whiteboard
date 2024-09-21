abstract class NotepadState {}

class NotepadInitial extends NotepadState {}

class NotepadLoaded extends NotepadState {
  final String text;

  NotepadLoaded({required this.text});
}