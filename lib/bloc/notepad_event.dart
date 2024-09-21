abstract class NotepadEvent {}

class LoadNotepad extends NotepadEvent {}

class UpdateNotepad extends NotepadEvent {
  final String text;

  UpdateNotepad(this.text);
}