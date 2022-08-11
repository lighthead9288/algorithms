import 'dart:math';

import 'package:algorithms/features/tree/models/binary_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TreePainter extends CustomPainter {
  final BinaryTreeNode? root;
  final BuildContext context;
  final List<String> markedNodes;
  final void Function(BinaryTreeNode node, Offset offset) onDrawNode;

  TreePainter(
      {required this.root,
      required this.markedNodes,
      required this.onDrawNode,
      required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 12.0;
    var dx = 280.0;
    var dy = 150.0;
    var offset = Offset(dx, dy);

    if (root != null) {
      _drawNode(canvas, size, offset, root!, radius);
      var bottomOffset = _drawTree(root, radius, canvas, size, offset, 13, 30);
      bottomOffset = Offset(20, bottomOffset.dy + 200);

      if (markedNodes.isNotEmpty) {
        final textPainter = TextPainter(
          text: TextSpan(text: markedNodes.toString(), style: const TextStyle(fontSize: 15, color: Colors.black)),
          textDirection: TextDirection.ltr);
        textPainter.layout(
          minWidth: 0,
          maxWidth: size.width,
        );
        textPainter.paint(canvas, Offset(bottomOffset.dx, bottomOffset.dy));
      }      
    }
  }

  Offset _drawTree(BinaryTreeNode? root, double radius, Canvas canvas, Size size,
      Offset offset, double angle, double height) {
    if (root == null) {
      return offset;
    }

    Offset result = offset;

    if (root.left != null) {
      var leftNodeOffset = _drawLeftChild(
          canvas, size, offset, root.left!, angle, height, radius);
      result = _drawTree(root.left, radius, canvas, size, leftNodeOffset, angle + 22,
          height + 15);
    }

    if (root.right != null) {
      var rightNodeOffset = _drawRightChild(
          canvas, size, offset, root.right!, angle, height, radius);
      result = _drawTree(root.right, radius, canvas, size, rightNodeOffset, angle + 22,
          height + 15);
    }

    return result;
  }

  Offset _drawLeftChild(Canvas canvas, Size size, Offset parent,
      BinaryTreeNode node, double angle, double height, double radius) {
    var paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..color = Colors.black;
    var width = height / tan(_angleToRadian(angle));
    canvas.drawLine(
        Offset(parent.dx - 2 - radius * cos(_angleToRadian(angle)),
            parent.dy + 2 + radius * sin(_angleToRadian(angle))),
        Offset(parent.dx - width + 2 + radius * cos(_angleToRadian(angle)),
            parent.dy + height - 2 - radius * sin(_angleToRadian(angle))),
        paint);
    return _drawNode(canvas, size,
        Offset(parent.dx - width, parent.dy + height), node, radius);
  }

  Offset _drawRightChild(Canvas canvas, Size size, Offset parent,
      BinaryTreeNode node, double angle, double height, double radius) {
    var paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..color = Colors.black;
    var width = height / tan(_angleToRadian(angle));
    canvas.drawLine(
        Offset(parent.dx + 2 + radius * cos(_angleToRadian(angle)),
            parent.dy + 2 + radius * sin(_angleToRadian(angle))),
        Offset(parent.dx + width - 2 - radius * cos(_angleToRadian(angle)),
            parent.dy + height - 2 - radius * sin(_angleToRadian(angle))),
        paint);
    return _drawNode(canvas, size,
        Offset(parent.dx + width, parent.dy + height), node, radius);
  }

  Offset _drawNode(Canvas canvas, Size size, Offset offset, BinaryTreeNode node,
      double radius) {
    var nodeOffset = Offset(offset.dx, offset.dy);
    var nodePaintingStyle = (markedNodes.contains(node.data))
        ? PaintingStyle.fill
        : PaintingStyle.stroke;
    var textColor =
        (markedNodes.contains(node.data)) ? Colors.white : Colors.black;

    var paint = Paint()
      ..strokeWidth = 3
      ..style = nodePaintingStyle
      ..strokeCap = StrokeCap.square
      ..color = Colors.brown;
    canvas.drawCircle(nodeOffset, radius, paint);

    final textPainter = TextPainter(
        text: TextSpan(
            text: node.data, style: TextStyle(fontSize: 13, color: textColor)),
        textDirection: TextDirection.ltr);
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    textPainter.paint(canvas, Offset(nodeOffset.dx - 6, nodeOffset.dy - 8));

    onDrawNode(node, nodeOffset);

    return nodeOffset;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  double _angleToRadian(double angle) => pi * angle / 180;
}