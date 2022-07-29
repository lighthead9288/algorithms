import 'dart:math';

import 'package:algorithms/core/models/models.dart';
import 'package:algorithms/core/widgets/new_array_value_dialog.dart';
import 'package:algorithms/core/widgets/playground_widget.dart';
import 'package:algorithms/core/widgets/random_values_dialog.dart';
import 'package:algorithms/features/bubble_sort/models/bubble_sort_models.dart';
import 'package:flutter/material.dart';

class BubbleSortWidget extends StatefulWidget {
  const BubbleSortWidget({Key? key}) : super(key: key);

  @override
  State<BubbleSortWidget> createState() => _BubbleSortWidgetState();
}

class _BubbleSortWidgetState extends State<BubbleSortWidget>
    with TickerProviderStateMixin
    implements AlgorithmOperations {
  late double _deviceHeight;
  late double _deviceWidth;

  List<double> list = List.generate(10, (index) => double.parse(Random().nextDouble().toStringAsFixed(3)));

  List<AnimationController> _switchAnimationControllers = [];
  List<Tween<Offset>> _switchTweens = [];
  List<Animation<Offset>> _switchAnimations = [];

  bool _stepByStepMode = false;
  bool _isStopped = false;

  Duration _duration = const Duration(milliseconds: 0);

  List<BubbleSortStep> _arraySortSteps = [];
  int _curArraySortStepIndex = 0;

  BubbleSortItemState? state = BubbleSortItemState(state: BubbleSortState.None);

  @override
  void initState() {
    for (int i = 0; i < list.length; i++) {
      _addAnimation(list[i], i);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return PlaygroundWidget(
        operations: this,
        widget: Column(
          children: [
            SizedBox(
              height: _deviceHeight * 0.8,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10),
                    padding: const EdgeInsets.all(20),
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (_, index) {
                      var item = list[index];
                      return SlideTransition(
                        position: _switchAnimations[index],
                        child: Container(
                          decoration: BoxDecoration(
                            //  color: Colors.red,
                            border: Border.all(
                                color: (state?.state != BubbleSortState.None)
                                    ? (state?.state == BubbleSortState.Normal)
                                        ? ((index == state?.index) ||
                                                (index ==
                                                    (state?.index ?? 0) + 1))
                                            ? Colors.green
                                            : Colors.black
                                        : ((index == state?.index) ||
                                                (index ==
                                                    (state?.index ?? 0) + 1))
                                            ? Colors.red
                                            : Colors.black
                                    : Colors.black,
                                width: 5),
                            borderRadius: BorderRadius.circular(5),
                            //  shape: BoxShape.circle
                          ),
                          child: GestureDetector(
                            child: Stack(
                              children: [
                                Positioned(
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          border: Border(
                                              right: BorderSide(
                                                  color: Colors.black),
                                              bottom: BorderSide(
                                                  color: Colors.black))),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text(index.toString(),
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 10)),
                                      ),
                                    ),
                                    top: 0,
                                    left: 0),
                                Center(
                                  child: Text(item.toString(),
                                      style:
                                          const TextStyle(color: Colors.black)),
                                )
                              ],
                            ),
                            onLongPressUp: (!_stepByStepMode)
                                ? () {
                                    showDialog(
                                        context: context,
                                        builder: (_) {
                                          return AlertDialog(
                                            title: const Text('Remove?'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Cancel')),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    onRemoveItem(index);
                                                    setState(() {});
                                                  },
                                                  child: const Text('Yes'))
                                            ],
                                          );
                                        });
                                  }
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        editOptions: [
          EditDataOption(
              title: 'Add number',
              icon: const Icon(Icons.add),
              onTap: () async {
                Navigator.pop(context);
                var result = await showDialog<double>(
                  context: context, 
                  builder: (_) => const NewArrayValueDialog()
                );
                _addItem(result!);
                setState(() {});
              }),
          EditDataOption(
              title: 'Random numbers',
              icon: const Icon(Icons.numbers),
              onTap: () async {
                Navigator.pop(context);
                var result = await showDialog<int>(
                  context: context, 
                  builder: (_) => const RandomValuesDialog()
                );
                var newItems = List.generate(result!, (index) => double.parse(Random().nextDouble().toStringAsFixed(3)));
                for(var item in newItems) {
                  _addItem(item);
                }
                setState(() {});
              })
        ]);
  }

  @override
  Future<void> onPlay() async {
    list = await _sort(list);
  }

  @override
  void onStop() {
    setState(() {
      _isStopped = true;
    });
  }

  @override
  void onAutoMode() {
    setState(() {
      _stepByStepMode = false;
    });
  }

  @override
  Future<void> onStepByStepMode() async {
    _stepByStepMode = true;
    _duration = const Duration(milliseconds: 0);
    _arraySortSteps.clear();
    _arraySortSteps.add(BubbleSortStep(state: BubbleSortItemState(state: BubbleSortState.None)));
    list = await _sort(list);
  }

  @override
  void onRemoveItem(int index) {
    list.removeAt(index);
    _removeAnimation(index);
  }

  @override
  void onDurationChange(int value) {
    setState(() {
      _duration = Duration(milliseconds: value);
    });
  }

  @override
  void onStepForward() async {
    var curStep = _arraySortSteps[_curArraySortStepIndex];
    _raiseStateChange(curStep.state);
    await Future.delayed(const Duration(milliseconds: 500));
    if (curStep.state.state == BubbleSortState.Swap) {            
      for (var swap in curStep.swaps) {
        _animateSwap(swap.arraySourceIndex, swap.arrayDestinationIndex, const Duration(milliseconds: 500));
        _swapElements(swap.arraySourceIndex, swap.arrayDestinationIndex);
      }
      _raiseStateChange(curStep.state);      
    }
    _curArraySortStepIndex = (_curArraySortStepIndex == _arraySortSteps.length - 1) ? _arraySortSteps.length - 1 : _curArraySortStepIndex + 1;
  }

  @override
  void onStepBack() async {
    var curStep = _arraySortSteps[_curArraySortStepIndex];
    _raiseStateChange(curStep.state);
    await Future.delayed(const Duration(milliseconds: 500));
    if (curStep.state.state == BubbleSortState.Swap) {            
      for (var swap in curStep.swaps) {
        _animateSwap(swap.arraySourceIndex, swap.arrayDestinationIndex, const Duration(milliseconds: 500));
        _swapElements(swap.arrayDestinationIndex, swap.arraySourceIndex);
      }
      _raiseStateChange(curStep.state);      
    }
    _curArraySortStepIndex = (_curArraySortStepIndex == 0) ? 0 : _curArraySortStepIndex - 1;
  }

  Future<List<double>> _sort(List<double> list) async {
    var oldList = List<double>.from(list);
    _curArraySortStepIndex = 0;
    for(int i = 0; i < list.length - 1; i++) {
      var isNormalOrder = true;
      for(int j = 0; j < list.length - 1; j++) {
        if (_isStopped) {
          // Stop
          _isStopped = false;
          _onStateChange(BubbleSortItemState(state: BubbleSortState.None));
          return oldList;
        }
        if (list[j] > list[j+1]) {
          // Swap
          isNormalOrder = false;
          _onStateChange(BubbleSortItemState(state: BubbleSortState.Swap, index: j));
          await Future.delayed(_duration);

          await _animateSwap(j, j+1, _duration);
          _swapElements(j, j+1);
         
        } else {
          // Normal
          _onStateChange(BubbleSortItemState(state: BubbleSortState.Normal, index: j));
          await Future.delayed(_duration);
        } 
      }
      if (isNormalOrder) break;
    }
    // Finish  
    _onStateChange(BubbleSortItemState(state: BubbleSortState.None));
    return (!_stepByStepMode) ? list : oldList;
  }

  void _swapElements(int prev, int next) {
    var tmp = list[prev];
    list[prev] = list[next];
    list[next] = tmp;
  }

  void _onStateChange(BubbleSortItemState newState) {
    if (!_stepByStepMode) {
      _raiseStateChange(newState);
    } else {
      _arraySortSteps.add(
        BubbleSortStep(
          state: newState, 
          swaps: (newState.index != null) 
            ? [ Swap(arraySourceIndex: newState.index!, arrayDestinationIndex: newState.index! + 1) ]
            : []
        )
      );
    }
  }

  void _raiseStateChange(BubbleSortItemState newState) {
    setState(() {
      state = newState;
    });
  }

  Future<void> _animateSwap(int prev, int next, Duration duration) async {
    Offset offsetForLeft = ((next) % 5 == 0) ? const Offset(-4.6, 1.15) : const Offset(1.15, 0) ;
    Offset offsetForRight = ((next) % 5 == 0) ? const Offset(4.6, -1.15) : const Offset(-1.15, 0);
    
    _switchTweens[prev].end = offsetForLeft;
    _switchAnimationControllers[prev].duration = duration;
    _switchAnimationControllers[prev].forward();

    _switchTweens[next].end = offsetForRight;
    _switchAnimationControllers[next].duration = duration;
    _switchAnimationControllers[next].forward();

    await Future.delayed(duration);

    _switchAnimationControllers[prev].reverse();
    _switchAnimationControllers[next].reverse();    
  }

  void _addItem(double item) {
    list.add(item);
    _addAnimation(item, list.length - 1);
  }

  void _removeAnimation(int index) {
    _switchAnimationControllers.removeAt(index);
    _switchTweens.removeAt(index);
    _switchAnimations.removeAt(index);
  }

  void _addAnimation(double item, int index) {
    _switchAnimationControllers.add(AnimationController(
        vsync: this,
        duration: _duration,
        reverseDuration: const Duration(seconds: 0)));
    _switchTweens.add(Tween<Offset>(begin: Offset.zero, end: Offset.zero));
    _switchAnimations
        .add(_switchTweens[index].animate(_switchAnimationControllers[index]));
  }
}