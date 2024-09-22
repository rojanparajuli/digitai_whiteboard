import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

class NotepadPage extends StatefulWidget {
  const NotepadPage({super.key});

  @override
  _NotepadPageState createState() => _NotepadPageState();
}

class _NotepadPageState extends State<NotepadPage> {
  Color _selectedColor = Colors.black;
  bool _isDrawingMode = false;
  bool _isTextMode = true; // Start with text mode by default
  TextAlign _textAlign = TextAlign.left;
  final List<List<Offset?>> _drawings = [];
  List<Offset?> _currentPoints = [];
  String _text = '';
  TextEditingController _textController = TextEditingController(); // Controller to manage text
  final Offset _textPosition = const Offset(20, 100);
  ui.Image? _selectedImage;
  Timer? _undoTimer;
  Duration _drawingDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _textController.text = _text; // Initialize the controller with the current text
  }

  @override
  void dispose() {
    _textController.dispose(); // Dispose of the controller when the widget is disposed
    super.dispose();
  }

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
                  _textController.clear(); // Clear the text from the TextField
                  _text = '';
                  _selectedImage = null;
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
        ],
      ),
      body: Column(
        children: [
          _buildToolbar(), // Toolbar below the AppBar
          Expanded(
            child: _isTextMode
                ? _buildTextMode()
                : _isDrawingMode
                    ? _buildDrawingMode()
                    : _buildImageMode(),
          ),
        ],
      ),
    );
  }

  // Toolbar for all options: text formatting, drawing, image picking, etc.
  Widget _buildToolbar() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        children: [
          // Text Alignment buttons
          IconButton(
            icon: const Icon(Icons.format_align_left, color: Colors.black),
            onPressed: () {
              setState(() {
                _textAlign = TextAlign.left;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.format_align_center, color: Colors.black),
            onPressed: () {
              setState(() {
                _textAlign = TextAlign.center;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.format_align_right, color: Colors.black),
            onPressed: () {
              setState(() {
                _textAlign = TextAlign.right;
              });
            },
          ),

          // Color picker
          IconButton(
            icon: const Icon(Icons.color_lens, color: Colors.black),
            onPressed: () {
              _showColorPicker(context);
            },
          ),

          // Toggle Draw Mode
          IconButton(
            icon: Icon(
              _isDrawingMode ? Icons.brush : Icons.text_fields,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _isDrawingMode = !_isDrawingMode;
                _isTextMode = !_isDrawingMode; // Toggle modes
                // Keep the text in the TextField
              });
            },
          ),

          // Undo button (shown only in Draw mode)
          if (_isDrawingMode)
            IconButton(
              icon: const Icon(Icons.undo, color: Colors.black),
              onPressed: _undoLastDrawing,
            ),

          // Image picker
          IconButton(
            icon: const Icon(Icons.photo, color: Colors.black),
            onPressed: _pickImage,
          ),
        ],
      ),
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
          textAlign: _textAlign,
          image: _selectedImage,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _textController, // Use the controller to manage the text
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
                    _text = value; // Update the text variable whenever the user types
                  });
                },
              ),
            ),
          ],
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
        textAlign: _textAlign,
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
          textAlign: _textAlign,
          image: _selectedImage,
        ),
      ],
    );
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _currentPoints = [details.localPosition];
      _drawingDuration = Duration.zero;
      _undoTimer?.cancel();
      _undoTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        _drawingDuration += const Duration(milliseconds: 100);
      });
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
    _undoTimer?.cancel();
  }

  void _undoLastDrawing() {
    if (_drawingDuration.inSeconds < 1) {
      setState(() {
        if (_drawings.isNotEmpty) {
          _drawings.removeLast();
        }
      });
    }
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
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frameInfo = await codec.getNextFrame();

      setState(() {
        _selectedImage = frameInfo.image;
      });
    }
  }
}

class DrawingCanvas extends StatelessWidget {
  final List<List<Offset?>> drawings;
  final Color color;
  final String text;
  final Offset textPosition;
  final TextAlign textAlign;
  final ui.Image? image;

  const DrawingCanvas({
    super.key,
    required this.drawings,
    required this.color,
    required this.text,
    required this.textPosition,
    required this.textAlign,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DrawingPainter(drawings, color, text, textPosition, textAlign, image),
      child: Container(),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<List<Offset?>> drawings;
  final Color color;
  final String text;
  final Offset textPosition;
  final TextAlign textAlign;
  final ui.Image? image;

  DrawingPainter(this.drawings, this.color, this.text, this.textPosition, this.textAlign, this.image);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

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
      final paragraphStyle = ui.ParagraphStyle(textAlign: textAlign);
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
