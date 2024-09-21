import 'package:digital_notepad/bloc/notepad_event.dart';
import 'package:digital_notepad/screen/notepad_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bloc/notepad_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notepad App',
      theme: ThemeData(
        textTheme: GoogleFonts.latoTextTheme(),
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => NotepadBloc()..add(LoadNotepad()),
        child: const NotepadPage(),
      ),
    );
  }
}