import 'package:algorithms/features/tree/models/traverse_algorithms.dart';
import 'package:flutter/material.dart';

class TraverseAlgorithmsDialog extends StatefulWidget {
  const TraverseAlgorithmsDialog({ Key? key}) : super(key: key);

  @override
  State<TraverseAlgorithmsDialog> createState() => _TraverseAlgorithmsDialogState();
}

class _TraverseAlgorithmsDialogState extends State<TraverseAlgorithmsDialog> {
  late double _deviceHeight;
  late double _deviceWidth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Dialog(
      child: Container(
        height: _deviceHeight * 0.2,
        width: _deviceWidth * 0.2,
        padding: const EdgeInsets.only(top: 15, left: 25),
        child: Column(
          children: [
            ListTile(
              title: const Text('Pre-order traverse'),
              onTap: () {
                Navigator.of(context).pop<TraverseAlgorithms>(TraverseAlgorithms.preOrder);
              },
            ),
            ListTile(
              title: const Text('Post-order traverse'),
              onTap: () {
                Navigator.of(context).pop<TraverseAlgorithms>(TraverseAlgorithms.postOrder);
              },
            ),
          ],
        ),
      ),
    );
  }
}