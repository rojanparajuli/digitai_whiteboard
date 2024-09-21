import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class NotepadPage extends StatefulWidget {
  const NotepadPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotepadPageState createState() => _NotepadPageState();
}

class _NotepadPageState extends State<NotepadPage> {
  Color _selectedColor = Colors.black;
  bool _isDrawingMode = false;
  final List<List<Offset?>> _drawings = [];
  List<Offset?> _currentPoints = [];
  String _text = '';
  final Offset _textPosition = const Offset(20, 100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(Icons.photo,
                    color: Colors.blue, size: 28), 
                onPressed: (){},
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _drawings.clear();
                  _text = '';
                });
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Delete All'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isDrawingMode = !_isDrawingMode;
                });
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(_isDrawingMode ? 'Text Mode' : 'Draw Mode'),
            ),
          ),
          if (_isDrawingMode) 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(Icons.color_lens,
                    color: Colors.blue, size: 28), 
                onPressed: () => _showColorPicker(context),
              ),
            ),
        ],
      ),
      body: _isDrawingMode ? _buildDrawingMode() : _buildTextMode(),
    );
  }

  Widget _buildTextMode() {
    return Stack(
      children: [
        DrawingCanvas(
          drawings: _drawings,
          color: _selectedColor,
          text: _text,
          textPosition: _textPosition,
        ),
        TextField(
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            hintText: 'Start typing...',
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(20),
          ),
          style: const TextStyle(fontSize: 18, color: Colors.black),
          onChanged: (value) {
            setState(() {
              _text = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDrawingMode() {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: DrawingCanvas(
        drawings: _drawings,
        color: _selectedColor,
        text: _text,
        textPosition: _textPosition,
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _currentPoints = [details.localPosition];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentPoints.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      if (_currentPoints.isNotEmpty) {
        _drawings.add(List.from(_currentPoints));
      }
      _currentPoints.clear();
    });
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) {
                setState(() {
                  _selectedColor = color;
                });
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }
}

class DrawingCanvas extends StatelessWidget {
  final List<List<Offset?>> drawings;
  final Color color;
  final String text;
  final Offset textPosition;

  const DrawingCanvas({
    super.key,
    required this.drawings,
    required this.color,
    required this.text,
    required this.textPosition,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DrawingPainter(drawings, color, text, textPosition),
      child: Container(),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<List<Offset?>> drawings;
  final Color color;
  final String text;
  final Offset textPosition;

  DrawingPainter(this.drawings, this.color, this.text, this.textPosition);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (final path in drawings) {
      for (int i = 0; i < path.length - 1; i++) {
        if (path[i] != null && path[i + 1] != null) {
          canvas.drawLine(path[i]!, path[i + 1]!, paint);
        }
      }
    }

    if (text.isNotEmpty) {
      final textStyle = ui.TextStyle(color: Colors.black, fontSize: 18);
      final paragraphStyle = ui.ParagraphStyle(textAlign: TextAlign.left);
      final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
        ..pushStyle(textStyle)
        ..addText(text);

      final paragraph = paragraphBuilder.build()
        ..layout(ui.ParagraphConstraints(width: size.width));

      canvas.drawParagraph(paragraph, textPosition);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
