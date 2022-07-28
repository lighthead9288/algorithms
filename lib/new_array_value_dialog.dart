import 'package:flutter/material.dart';

class NewArrayValueDialog extends StatefulWidget {
  const NewArrayValueDialog({Key? key}) : super(key: key);

  @override
  State<NewArrayValueDialog> createState() => _NewArrayValueDialogState();
}

class _NewArrayValueDialogState extends State<NewArrayValueDialog> {

  double _newArrayValue = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add value'),
      content: TextField(
        keyboardType: TextInputType.number,
        onChanged: (value) {
          _newArrayValue = double.parse(value);
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
              Navigator.pop(context, _newArrayValue);
            },
            child: const Text('Yes'))
      ],
    );
  }
}
