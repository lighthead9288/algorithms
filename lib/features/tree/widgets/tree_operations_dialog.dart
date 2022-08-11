import 'package:algorithms/features/tree/models/binary_tree.dart';
import 'package:flutter/material.dart';

class TreeOperationsDialog extends StatefulWidget {
  final BinaryTreeNode node;
  final void Function() onAddLeft;
  final void Function() onAddRight;
  final void Function() onRemove;

  const TreeOperationsDialog({Key? key, required this.node, required this.onAddLeft, required this.onAddRight, required this.onRemove}) : super(key: key);

  @override
  State<TreeOperationsDialog> createState() => _TreeOperationsDialogState();
}

class _TreeOperationsDialogState extends State<TreeOperationsDialog> {
  late double _deviceHeight;
  late double _deviceWidth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    bool isLastLevel = (widget.node.level == 5);
    return Dialog(
      child: Container(
        height: _deviceHeight * 0.25,
        width: _deviceWidth * 0.3,
        padding: const EdgeInsets.only(top: 15, left: 25),
        child: Column(
          children: [
            ListTile(
              enabled: (!isLastLevel) && (widget.node.left == null),
              leading: const Icon(Icons.add),
              title: const Text('Add left'),
              onTap: ()  {
                Navigator.of(context).pop();
                widget.onAddLeft();
              },
            ),
            ListTile(
              enabled: (!isLastLevel) && (widget.node.right == null),
              leading: const Icon(Icons.add),
              title: const Text('Add right'),
              onTap: () {
                Navigator.of(context).pop();
                widget.onAddRight();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Remove'),
              onTap: () {
                Navigator.of(context).pop();
                widget.onRemove();
              },
            ),
          ],
        ),
      ),
    );
  }
}
