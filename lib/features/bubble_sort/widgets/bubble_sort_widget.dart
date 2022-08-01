import 'dart:math';

import 'package:algorithms/core/models/models.dart';
import 'package:algorithms/core/widgets/new_array_value_dialog.dart';
import 'package:algorithms/core/widgets/playground_widget.dart';
import 'package:algorithms/core/widgets/random_values_dialog.dart';
import 'package:algorithms/features/bubble_sort/models/bubble_sort_models.dart';
import 'package:algorithms/features/bubble_sort/state/bubble_sort_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  List<AnimationController> _switchAnimationControllers = [];
  List<Tween<Offset>> _switchTweens = [];
  List<Animation<Offset>> _switchAnimations = [];

  late BuildContext _cubitContext;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return BlocProvider(
        create: (_) => BubbleSortCubit(
            initialState: BubbleSortWidgetStateChanged(
                state: BubbleSortItemState(status: BubbleSortStatus.None),
                list: [],
                stepByStepMode: false),
            initAnimations: (list, duration) =>
                _onInitAnimations(list, duration),
            onAddAnimation: (item, index, duration) =>
                _onAddAnimation(item, index, duration),
            onRemoveAnimation: (index) => _onRemoveAnimation(index),
            onAnimateSwap: (prev, next, duration) =>
                _onAnimateSwap(prev, next, duration)),
        child: BlocBuilder<BubbleSortCubit, BubbleSortWidgetStateChanged>(
            builder: ((_context, widgetState) {
          _cubitContext = _context;
          return PlaygroundWidget(
              operations: this,
              widget: _bubbleSortArrayUI(widgetState),
              editOptions: [
                EditDataOption(
                    title: 'Add number',
                    icon: const Icon(Icons.add),
                    onTap: () async {
                      Navigator.pop(context);
                      var result = await showDialog<double>(
                          context: context,
                          builder: (_) => const NewArrayValueDialog());
                      _cubitContext.read<BubbleSortCubit>().onAddItem(result!);
                    }),
                EditDataOption(
                    title: 'Random numbers',
                    icon: const Icon(Icons.numbers),
                    onTap: () async {
                      Navigator.pop(context);
                      var result = await showDialog<int>(
                          context: context,
                          builder: (_) => const RandomValuesDialog());
                      _cubitContext
                          .read<BubbleSortCubit>()
                          .onRandomNumbersGenerate(result!);
                    })
              ]);
        })));
  }

  Widget _bubbleSortArrayUI(BubbleSortWidgetStateChanged widgetState) {
    return Column(
      children: [
        SizedBox(
          height: _deviceHeight * 0.8,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(5),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                padding: const EdgeInsets.all(20),
                shrinkWrap: true,
                itemCount: widgetState.list.length,
                itemBuilder: (_, index) {
                  var item = widgetState.list[index];
                  return _bubbleSortArrayItemUI(widgetState, item, index);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bubbleSortArrayItemUI(
      BubbleSortWidgetStateChanged widgetState, double item, int index) {
    return SlideTransition(
      position: _switchAnimations[index],
      child: Container(
        decoration: BoxDecoration(
          //  color: Colors.red,
          border: Border.all(
              color: (widgetState.state.status != BubbleSortStatus.None)
                  ? (widgetState.state.status == BubbleSortStatus.Normal)
                      ? ((index == widgetState.state.index) ||
                              (index == (widgetState.state.index ?? 0) + 1))
                          ? Colors.green
                          : Colors.black
                      : ((index == widgetState.state.index) ||
                              (index == (widgetState.state.index ?? 0) + 1))
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
                            right: BorderSide(color: Colors.black),
                            bottom: BorderSide(color: Colors.black))),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(index.toString(),
                          style: const TextStyle(
                              color: Colors.black, fontSize: 10)),
                    ),
                  ),
                  top: 0,
                  left: 0),
              Center(
                child: Text(item.toString(),
                    style: const TextStyle(color: Colors.black)),
              )
            ],
          ),
          onLongPressUp: (!widgetState.stepByStepMode)
              ? () {
                  _onLongPressUp(index);
                }
              : null,
        ),
      ),
    );
  }

  void _onLongPressUp(int index) {
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

  Future<void> _onAnimateSwap(int prev, int next, Duration duration) async {
    Offset offsetForLeft =
        ((next) % 5 == 0) ? const Offset(-4.6, 1.15) : const Offset(1.15, 0);
    Offset offsetForRight =
        ((next) % 5 == 0) ? const Offset(4.6, -1.15) : const Offset(-1.15, 0);

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

  void _onRemoveAnimation(int index) {
    _switchAnimationControllers.removeAt(index);
    _switchTweens.removeAt(index);
    _switchAnimations.removeAt(index);
  }

  void _onAddAnimation(double item, int index, Duration duration) {
    _switchAnimationControllers.add(AnimationController(
        vsync: this,
        duration: duration,
        reverseDuration: const Duration(seconds: 0)));
    _switchTweens.add(Tween<Offset>(begin: Offset.zero, end: Offset.zero));
    _switchAnimations
        .add(_switchTweens[index].animate(_switchAnimationControllers[index]));
  }

  void _onInitAnimations(List<double> list, Duration duration) {
    for (int i = 0; i < list.length; i++) {
      _onAddAnimation(list[i], i, duration);
    }
  }

  @override
  Future<void> onPlay() async =>
      await _cubitContext.read<BubbleSortCubit>().onPlay();

  @override
  void onStop() => _cubitContext.read<BubbleSortCubit>().onStop();

  @override
  void onAutoMode() => _cubitContext.read<BubbleSortCubit>().onAutoMode();

  @override
  Future<void> onStepByStepMode() async =>
      _cubitContext.read<BubbleSortCubit>().onStepByStepMode();

  @override
  void onRemoveItem(int index) =>
      _cubitContext.read<BubbleSortCubit>().onRemoveItem(index);

  @override
  void onDurationChange(int value) =>
      _cubitContext.read<BubbleSortCubit>().onDurationChange(value);

  @override
  void onStepForward() async =>
      _cubitContext.read<BubbleSortCubit>().onStepForward();

  @override
  void onStepBack() async => _cubitContext.read<BubbleSortCubit>().onStepBack();
}
