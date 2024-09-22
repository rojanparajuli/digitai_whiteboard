abstract class NotepadEvent {}

class ToggleModeEvent extends NotepadEvent {
  final bool isDrawingMode;
  ToggleModeEvent(this.isDrawingMode);
}

class UpdateTextEvent extends NotepadEvent {
  final String text;
  UpdateTextEvent(this.text);
}

class ClearAllEvent extends NotepadEvent {}
