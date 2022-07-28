import 'package:algorithms/auto_control_panel.dart';
import 'package:algorithms/models.dart';
import 'package:algorithms/step_by_step_control_panel.dart';
import 'package:flutter/material.dart';

class PlaygroundWidget extends StatefulWidget {
  final AlgorithmOperations operations;
  final Widget widget;
  final List<EditDataOption> editOptions;

  const PlaygroundWidget(
      {Key? key,
      required this.operations,
      required this.widget,
      this.editOptions = const []})
      : super(key: key);

  @override
  State<PlaygroundWidget> createState() => _PlaygroundWidgetState();
}

class _PlaygroundWidgetState extends State<PlaygroundWidget> {
  late double _deviceHeight;
  late double _deviceWidth;

  bool _stepByStepMode = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
          actions: (!_isLoading)
              ? [
                  (!_stepByStepMode)
                      ? PopupMenuButton(
                          icon: const Icon(Icons.edit),
                          itemBuilder: (_) {
                            return widget.editOptions
                                .map((item) => PopupMenuItem(
                                      child: ListTile(
                                        leading: item.icon,
                                        title: Text(item.title),
                                        onTap: () async => await item.onTap(),
                                      ),
                                    ))
                                .toList();
                          })
                      : const SizedBox(),
                  PopupMenuButton(itemBuilder: (_) {
                    return [
                      PopupMenuItem(
                        child: const ListTile(
                          leading: Icon(Icons.play_arrow),
                          title: Text('Auto mode'),
                        ),
                        onTap: () {
                          widget.operations.onAutoMode();
                          setState(() {
                            _stepByStepMode = false;
                          });
                        },
                      ),
                      PopupMenuItem(
                        child: const ListTile(
                          leading: Icon(Icons.front_hand),
                          title: Text('Step by step mode'),
                        ),
                        onTap: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          _stepByStepMode = true;
                          await widget.operations.onStepByStepMode();
                          setState(() {
                            _isLoading = false;
                          });
                        },
                      )
                    ];
                  })
                ]
              : []),
      body: (!_isLoading)
          ? Stack(
              children: [
                widget.widget,
                Positioned(
                  bottom: 0,
                  child: (!_stepByStepMode)
                    ? AutoControlPanel(
                        onPlay: () async {
                          await widget.operations.onPlay();
                        },
                        onStop: () {
                          widget.operations.onStop();
                        },
                        onDurationChange: (value) {
                          widget.operations.onDurationChange(value);
                        },
                      )
                    : StepByStepControlPanel(onStepForward: () {
                        widget.operations.onStepForward();
                      }, onStepBack: () {
                        widget.operations.onStepBack();
                      }),
                ),
                
                
              ],
            )
          : const Center(child: CircularProgressIndicator()),
      resizeToAvoidBottomInset: false,
    );
  }
}