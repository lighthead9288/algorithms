import 'package:flutter/material.dart';

class AutoControlPanel extends StatefulWidget {
  final Future<void> Function() onPlay;
  final void Function() onStop;
  final void Function(int duration) onDurationChange;

  const AutoControlPanel({ 
    Key? key, 
    required this.onPlay,
    required this.onStop, 
    required this.onDurationChange 
  }) : super(key: key);

  @override
  State<AutoControlPanel> createState() => _AutoControlPanelState();
}

class _AutoControlPanelState extends State<AutoControlPanel> {
  late double _deviceHeight;
  late double _deviceWidth;
  
  double _delay = 0;
  bool _isStarted = false;
  
  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Container(
      height: _deviceHeight * 0.1,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(        
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(            
            width: _deviceWidth * 0.8,
            child: Slider(
              label: "${_delay.toString()}, ms",
              value: _delay,
              min: 0,
              max: 5000,
              divisions: 10, 
              onChanged: (value) {
                setState(() {
                  _delay = value;
                });
                widget.onDurationChange(value.toInt());
              },
            ),
          ),
          (!_isStarted) 
            ? IconButton(
                onPressed: () async {
                  setState(() {
                    _isStarted = !_isStarted;
                  });
                  await widget.onPlay();
                  setState(() {
                    _isStarted = false;
                  });
                },
                icon: const Icon(Icons.play_arrow), 
              )
            : IconButton(
                onPressed: () {
                  setState(() {
                    _isStarted = !_isStarted;
                  });
                  widget.onStop();
                },
                icon: const Icon(Icons.stop), 
              )
        ],
      )
    );
  }
}