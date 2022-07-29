import 'package:flutter/material.dart';

class StepByStepControlPanel extends StatefulWidget {
  final void Function() onStepForward;
  final void Function() onStepBack;

  const StepByStepControlPanel({ Key? key, required this.onStepForward, required this.onStepBack }) : super(key: key);

  @override
  State<StepByStepControlPanel> createState() => _StepByStepControlPanelState();
}

class _StepByStepControlPanelState extends State<StepByStepControlPanel> {
  late double _deviceHeight;
  late double _deviceWidth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Container(
      height: _deviceHeight * 0.1,
      alignment: Alignment.bottomCenter,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),              
            ),
            width: _deviceWidth * 0.5,
            child: IconButton(
              onPressed: () {
                widget.onStepBack();
              }, 
              icon: const Icon(Icons.skip_previous)
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),              
            ),
            width: _deviceWidth * 0.5,
            child: IconButton(
              onPressed: () {
                widget.onStepForward();
              }, 
              icon: const Icon(Icons.skip_next)
            ),
          )
        ],
      )
    );
  }
}