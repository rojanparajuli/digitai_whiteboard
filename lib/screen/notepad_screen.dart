import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';

class NotepadPage extends StatefulWidget {
  const NotepadPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotepadPageState createState() => _NotepadPageState();
}

class _NotepadPageState extends State<NotepadPage> {
  Color _selectedColor = Colors.black;
  bool _isDrawingMode = false;
  bool _isImageMode = false;
  final List<List<Offset?>> _drawings = [];
  List<Offset?> _currentPoints = [];
  String _text = '';
  final Offset _textPosition = const Offset(20, 100);
  ui.Image? _selectedImage; // Change to ui.Image type

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
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _drawings.clear();
                  _text = '';
                  _selectedImage = null; // Clear the selected image
                });
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  if (_isDrawingMode) _isImageMode = false; // Switch off image mode
                });
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(_isDrawingMode ? 'Text Mode' : 'Draw Mode'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isImageMode = !_isImageMode;
                  if (_isImageMode) _isDrawingMode = false; // Switch off drawing mode
                });
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(_isImageMode ? 'Text Mode' : 'Image Mode'),
            ),
          ),
          if (_isDrawingMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(Icons.color_lens, color: Colors.blue, size: 28),
                onPressed: () => _showColorPicker(context),
              ),
            ),
          if (_isImageMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(Icons.photo, color: Colors.blue, size: 28),
                onPressed: _pickImage,
              ),
            ),
        ],
      ),
      body: _isImageMode ? _buildImageMode() : _isDrawingMode ? _buildDrawingMode() : _buildTextMode(),
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
          image: _selectedImage,
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
        image: _selectedImage,
      ),
    );
  }

  Widget _buildImageMode() {
    return Stack(
      children: [
        DrawingCanvas(
          drawings: _drawings,
          color: _selectedColor,
          text: _text,
          textPosition: _textPosition,
          image: _selectedImage,
        ),
      ],
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imageFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (imageFile != null) {
      // Load image from file
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frameInfo = await codec.getNextFrame();
      
      setState(() {
        _selectedImage = frameInfo.image; // Store the loaded image
      });
    }
  }
}

class DrawingCanvas extends StatelessWidget {
  final List<List<Offset?>> drawings;
  final Color color;
  final String text;
  final Offset textPosition;
  final ui.Image? image; // Change to ui.Image type

  const DrawingCanvas({
    super.key,
    required this.drawings,
    required this.color,
    required this.text,
    required this.textPosition,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DrawingPainter(drawings, color, text, textPosition, image),
      child: Container(),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<List<Offset?>> drawings;
  final Color color;
  final String text;
  final Offset textPosition;
  final ui.Image? image; // Change to ui.Image type

  DrawingPainter(this.drawings, this.color, this.text, this.textPosition, this.image);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    // Draw the image if available
    if (image != null) {
      canvas.drawImage(image!, Offset.zero, Paint());
    }

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
