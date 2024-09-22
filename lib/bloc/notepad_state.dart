// notepad_state.dart
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class NotepadState {
  final bool isDrawingMode;
  final String text;
  final Color selectedColor;
  final List<List<Offset?>> drawings;
  final ui.Image? selectedImage;

  NotepadState({
    required this.isDrawingMode,
    required this.text,
    required this.selectedColor,
    required this.drawings,
    this.selectedImage,
  });

  NotepadState copyWith({
    bool? isDrawingMode,
    String? text,
    Color? selectedColor,
    List<List<Offset?>>? drawings,
    ui.Image? selectedImage,
  }) {
    return NotepadState(
      isDrawingMode: isDrawingMode ?? this.isDrawingMode,
      text: text ?? this.text,
      selectedColor: selectedColor ?? this.selectedColor,
      drawings: drawings ?? this.drawings,
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }
}
