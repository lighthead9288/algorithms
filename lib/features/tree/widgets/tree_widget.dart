import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:algorithms/core/models/models.dart';
import 'package:algorithms/core/widgets/playground_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TreeWidget extends StatefulWidget {
  const TreeWidget({ Key? key }) : super(key: key);

  @override
  State<TreeWidget> createState() => _TreeWidgetState();
}

class _TreeWidgetState extends State<TreeWidget> implements AlgorithmOperations {
  late double _deviceHeight;
  late double _deviceWidth;

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return PlaygroundWidget(
      operations: this, 
      widget: _treeWidgetUI(),
      editOptions: []
    );
  }

  Widget _treeWidgetUI() {
    return SizedBox(
        width: _deviceWidth,
        child: AdaptiveScrollbar(
          controller: _verticalScrollController,
          child: AdaptiveScrollbar(
            controller: _horizontalScrollController,
            position: ScrollbarPosition.top,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: _verticalScrollController,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScrollController,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                  child: SizedBox(
                    height: _deviceHeight * 0.9,
                    width: _deviceWidth,
                    child: CustomPaint(
                      painter: TreePainter(),
                    )
                  )
                ),
              ),
            ),
          ),
        ),
      );
  }


  @override
  void onAutoMode() {
    // TODO: implement onAutoMode
  }

  @override
  void onDurationChange(int value) {
    // TODO: implement onDurationChange
  }

  @override
  Future<void> onPlay() {
    // TODO: implement onPlay
    throw UnimplementedError();
  }

  @override
  void onRemoveItem(int index) {
    // TODO: implement onRemoveItem
  }

  @override
  void onStepBack() {
    // TODO: implement onStepBack
  }

  @override
  Future<void> onStepByStepMode() {
    // TODO: implement onStepByStepMode
    throw UnimplementedError();
  }

  @override
  void onStepForward() {
    // TODO: implement onStepForward
  }

  @override
  void onStop() {
    // TODO: implement onStop
  }
}

class TreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var rootNodeOffset = _drawNode(canvas, size, const Offset(180, 50), 'A');
    var aNodeOffset = _drawLeftChild(canvas, size, rootNodeOffset, 'B');
    var bNodeOffset = _drawRightChild(canvas, size, rootNodeOffset, 'C');
    _drawLeftChild(canvas, size, aNodeOffset, 'D');
    _drawRightChild(canvas, size, aNodeOffset, 'E');
  }

  Offset _drawLeftChild(Canvas canvas, Size size, Offset parent, String text) {
    var paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..color = Colors.black;
    canvas.drawLine(Offset(parent.dx - 10, parent.dy + 20), Offset(parent.dx - 30, parent.dy + 40), paint);
    return _drawNode(canvas, size, Offset(parent.dx - 40, parent.dy + 60), text);
  }

  Offset _drawRightChild(Canvas canvas, Size size, Offset parent, String text) {
    var paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..color = Colors.black;
    canvas.drawLine(Offset(parent.dx + 10, parent.dy + 20), Offset(parent.dx + 30, parent.dy + 40), paint);
    return _drawNode(canvas, size, Offset(parent.dx + 40, parent.dy + 60), text);
  }

  Offset _drawNode(Canvas canvas, Size size, Offset offset, String text) {
    var nodeOffset = Offset(offset.dx, offset.dy);
    var paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..color = Colors.brown;
    canvas.drawCircle(nodeOffset, 20, paint);

    final textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: const TextStyle(fontSize: 30, color: Colors.black)),
          textDirection: TextDirection.ltr);
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
    textPainter.paint(canvas, Offset(nodeOffset.dx - 10, nodeOffset.dy - 20));
    return nodeOffset;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
