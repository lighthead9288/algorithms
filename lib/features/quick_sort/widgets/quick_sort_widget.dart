import 'package:algorithms/core/models/models.dart';
import 'package:algorithms/core/widgets/new_array_value_dialog.dart';
import 'package:algorithms/core/widgets/playground_widget.dart';
import 'package:algorithms/core/widgets/random_values_dialog.dart';
import 'package:algorithms/features/quick_sort/models/quick_sort_models.dart';
import 'package:algorithms/features/quick_sort/state/quick_sort_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuickSortWidget extends StatefulWidget {
  const QuickSortWidget({ Key? key }) : super(key: key);

  @override
  State<QuickSortWidget> createState() => _QuickSortWidgetState();
}

class _QuickSortWidgetState extends State<QuickSortWidget> with TickerProviderStateMixin
    implements AlgorithmOperations<int> {

  late double _deviceHeight;
  late double _deviceWidth;

  List<AnimationController> _switchAnimationControllers = [];
  List<Tween<Offset>> _switchTweens = [];
  List<Animation<Offset>> _switchAnimations = [];

  List<AnimationController> _arrayBoundsFadeAnimationControllers = [];
  List<Animation<double>> _arrayBoundsFadeAnimations = [];

  late BuildContext _cubitContext;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return BlocProvider(
      create: (_) =>  QuickSortCubit(
        initialState: QuickSortWidgetStateChanged(
          list: [], 
          stepByStepMode: false, 
          state: QuickSortItemState(
            status: QuickSortStatus.None,
            leftItemIndex: 0, 
            rightItemIndex: 0, 
            pivotItemIndex: 0
          )
        ),
        initAnimations: (list, duration) => _onInitAnimations(list, duration),
        onAddAnimation: (index, duration) => _onAddAnimation(index, duration),
        onAnimateArrayBounds: (left, right, duration) => _onAnimateArrayBounds(left, right, duration),
        onRemoveAnimation: (index) => _onRemoveAnimation(index),
        onAnimateSwap: (prev, next, duration) => _onAnimateSwap(prev, next, duration),
      ),
      child: BlocBuilder<QuickSortCubit, QuickSortWidgetStateChanged>(
        builder: ((context, state) {
          _cubitContext = context;
          return PlaygroundWidget(
            operations: this, 
            widget: _quickSortArrayUI(state),
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
                      if (result != null) {
                         _cubitContext.read<QuickSortCubit>().onAddItem(
                            result, 
                            onError: (message) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
                            }
                          );
                      }                     
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
                      if (result != null) {
                        _cubitContext.read<QuickSortCubit>().onRandomNumbersGenerate(
                          result,
                          onError: (message) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
                          }
                        );
                      }                      
                    })
              ]
          );
        })
      )
    );
  }

  Widget _quickSortArrayUI(QuickSortWidgetStateChanged widgetState) {
    return Column(
      children: [
        SizedBox(
          height: _deviceHeight * 0.8,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(5),
              width: _deviceWidth * 0.6,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                shrinkWrap: true,
                itemCount: widgetState.list.length,
                itemBuilder: (_, index) {
                  var item = widgetState.list[index];
                  return _quickSortArrayItemUI(widgetState, item, index);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickSortArrayItemUI(QuickSortWidgetStateChanged widgetState, double item, int index) {
    bool isPivot = index == widgetState.state.pivotItemIndex;
    bool isLeft = index == widgetState.state.leftItemIndex;
    bool isRight = index == widgetState.state.rightItemIndex;
    bool isInitialLeft = index == widgetState.state.leftInitialIndex;
    bool isInitialRight = index == widgetState.state.rightInitialIndex;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [         
        SizedBox(
          height: _deviceWidth * 0.15,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                FadeTransition(
                  opacity: _arrayBoundsFadeAnimations[index],
                  child: Container(
                    width: _deviceWidth * 0.15,
                    height: 2,
                    color: isInitialLeft ? Colors.blue : null,
                  )
                ),
                Center(
                  child: SizedBox(
                    width: _deviceWidth * 0.1,
                    child: Text(
                      (isPivot) && (widgetState.state.status != QuickSortStatus.None) ? 'Pivot' : '', 
                      style: const TextStyle(color: Colors.brown)
                    )
                  ),
                ),
                FadeTransition(
                  opacity: _arrayBoundsFadeAnimations[index],
                  child: Container(
                    width: _deviceWidth * 0.15,
                    height: 2,
                    color: isInitialRight ? Colors.orange : null,
                  ),
                ),
            ],
          ),
        ), 
        const SizedBox(width: 10),
        SlideTransition(
          position: _switchAnimations[index],
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            width: _deviceWidth * 0.15,
            height: _deviceWidth * 0.15,
            decoration: BoxDecoration(
              border: Border.all(
                  color: (widgetState.state.status != QuickSortStatus.None)
                      ? (isLeft) 
                        ? Colors.blue
                        : (isRight) 
                          ? Colors.orange
                          : Colors.black
                      : Colors.black,
                  width: 5),
              borderRadius: BorderRadius.circular(5),
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
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: _deviceWidth * 0.1,
          child: (isLeft && (widgetState.state.status != QuickSortStatus.None)) 
            ? const Text('Left', style: TextStyle(color: Colors.blue))
            : (isRight && (widgetState.state.status != QuickSortStatus.None)) 
              ? const Text('Right', style: TextStyle(color: Colors.orange))
              : const Text('')
        )
      ],
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
    if (next == prev) {
      return;
    }
    var delta = next - prev;
    Offset offsetForLeft = Offset(0, delta.toDouble());
    Offset offsetForRight = Offset(0, - delta.toDouble());

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

  Future<void> _onAnimateArrayBounds(int left, int right, Duration duration) async {
    _arrayBoundsFadeAnimationControllers[left].animateTo(1);
    await Future.delayed(const Duration(milliseconds: 100));
    _arrayBoundsFadeAnimationControllers[left].animateTo(0);
    await Future.delayed(const Duration(milliseconds: 100));
    _arrayBoundsFadeAnimationControllers[left].animateTo(1);

    _arrayBoundsFadeAnimationControllers[right].animateTo(1);
    await Future.delayed(const Duration(milliseconds: 100));
    _arrayBoundsFadeAnimationControllers[right].animateTo(0);
    await Future.delayed(const Duration(milliseconds: 100));
    _arrayBoundsFadeAnimationControllers[right].animateTo(1);
  }

  void _onRemoveAnimation(int index) {
    _switchAnimationControllers.removeAt(index);
    _switchTweens.removeAt(index);
    _switchAnimations.removeAt(index);
  }

  void _onAddAnimation(int index, Duration duration) {
    _switchAnimationControllers.add(AnimationController(
        vsync: this,
        duration: duration,
        reverseDuration: const Duration(seconds: 0)));
    _switchTweens.add(Tween<Offset>(begin: Offset.zero, end: Offset.zero));
    _switchAnimations.add(_switchTweens[index].animate(_switchAnimationControllers[index]));

    _arrayBoundsFadeAnimationControllers.add(AnimationController(
      vsync: this,
      duration: duration
    ));
    _arrayBoundsFadeAnimations.add(CurvedAnimation(parent: _arrayBoundsFadeAnimationControllers[index], curve: Curves.easeOut));
  }

  void _onInitAnimations(List<double> list, Duration duration) {
    for (int i = 0; i < list.length; i++) {
      _onAddAnimation(i, duration);
    }
  }

  @override
  void onAutoMode() => _cubitContext.read<QuickSortCubit>().onAutoMode();

  @override
  void onDurationChange(int value) => _cubitContext.read<QuickSortCubit>().onDurationChange(value);

  @override
  Future<void> onPlay() async {
    return await _cubitContext.read<QuickSortCubit>().onPlay();
  }

  @override
  void onRemoveItem(int index) => _cubitContext.read<QuickSortCubit>().onRemoveItem(index);

  @override
  void onStepBack() => _cubitContext.read<QuickSortCubit>().onStepBack();

  @override
  Future<void> onStepByStepMode() => _cubitContext.read<QuickSortCubit>().onStepByStepMode();

  @override
  void onStepForward() => _cubitContext.read<QuickSortCubit>().onStepForward();

  @override
  void onStop() => _cubitContext.read<QuickSortCubit>().onStop();
}