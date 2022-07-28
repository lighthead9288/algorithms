import 'package:flutter/material.dart';

class RandomValuesDialog extends StatefulWidget {
  const RandomValuesDialog({ Key? key }) : super(key: key);

  @override
  State<RandomValuesDialog> createState() => _RandomValuesDialogState();
}

class _RandomValuesDialogState extends State<RandomValuesDialog> {
  int _newRandomValuesCount = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Random values count:'),
      content: TextField(
        keyboardType: TextInputType.number,
        onChanged: (value) {
          _newRandomValuesCount = int.parse(value);
        },
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel')),
        TextButton(
            onPressed: () {
              Navigator.pop(context, _newRandomValuesCount);
            },
            child: const Text('Yes'))
      ],
    );
  }
}