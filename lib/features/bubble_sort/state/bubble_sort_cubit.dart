import 'dart:math';

import 'package:algorithms/core/models/models.dart';
import 'package:algorithms/features/bubble_sort/models/bubble_sort_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BubbleSortCubit extends Cubit<BubbleSortItemState> {
  final Future<void> Function(int prev, int next, Duration duration) onAnimateSwap;
  final void Function(List<double> list) initAnimations;
  final void Function(double item, int index) onAddAnimation;
  final Future<void> Function(int index) onRemoveAnimation;

  BubbleSortCubit({
    required BubbleSortItemState initialState, 
    required this.onAnimateSwap, 
    required this.initAnimations,
    required this.onAddAnimation, 
    required this.onRemoveAnimation
  }) : super(initialState) {
    list = List.generate(10, (index) => double.parse(Random().nextDouble().toStringAsFixed(3)));
    initAnimations(list);
  }

  List<double> list = [];

  bool _stepByStepMode = false;
  bool _isStopped = false;

  Duration _duration = const Duration(milliseconds: 0);

  List<BubbleSortStep> _arraySortSteps = [];
  int _curArraySortStepIndex = 0;

  BubbleSortItemState _curState = BubbleSortItemState(state: BubbleSortState.None);

  Future<List<double>> _sort(List<double> list) async {
    var oldList = List<double>.from(list);
    _curArraySortStepIndex = 0;
    for(int i = 0; i < list.length - 1; i++) {
      var isNormalOrder = true;
      for(int j = 0; j < list.length - 1; j++) {
        if (_isStopped) {
          // Stop
          _isStopped = false;
          _curState = BubbleSortItemState(state: BubbleSortState.None);
          _onStateChange(_curState);
          return oldList;
        }
        if (list[j] > list[j+1]) {
          // Swap
          isNormalOrder = false;
          _curState = BubbleSortItemState(state: BubbleSortState.Swap, index: j);
          _onStateChange(_curState);
          await Future.delayed(_duration);

          await onAnimateSwap(j, j+1, _duration);
          _swapElements(j, j+1);
         
        } else {
          // Normal
          _curState = BubbleSortItemState(state: BubbleSortState.Normal, index: j);
          _onStateChange(_curState);
          await Future.delayed(_duration);
        } 
      }
      if (isNormalOrder) break;
    }
    // Finish
    _curState = BubbleSortItemState(state: BubbleSortState.None); 
    _onStateChange(_curState);
    return (!_stepByStepMode) ? list : oldList;
  }

  Future<void> onStepByStepMode() async {
    _stepByStepMode = true;
    _duration = const Duration(milliseconds: 0);
    _arraySortSteps.clear();
    _arraySortSteps.add(BubbleSortStep(state: BubbleSortItemState(state: BubbleSortState.None)));
    list = await _sort(list);
  }

  void _swapElements(int prev, int next) {
    var tmp = list[prev];
    list[prev] = list[next];
    list[next] = tmp;
  }

  void _onStateChange(BubbleSortItemState newState) {
    if (!_stepByStepMode) {
      emit(newState);
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

  void onStepForward() async {
    var curStep = _arraySortSteps[_curArraySortStepIndex];
    emit(curStep.state);
    await Future.delayed(const Duration(milliseconds: 500));
    if (curStep.state.state == BubbleSortState.Swap) {            
      for (var swap in curStep.swaps) {
        onAnimateSwap(swap.arraySourceIndex, swap.arrayDestinationIndex, const Duration(milliseconds: 500));
        _swapElements(swap.arraySourceIndex, swap.arrayDestinationIndex);
      }
      emit(curStep.state);      
    }
    _curArraySortStepIndex = (_curArraySortStepIndex == _arraySortSteps.length - 1) ? _arraySortSteps.length - 1 : _curArraySortStepIndex + 1;
  }

  void onStepBack() async {
    var curStep = _arraySortSteps[_curArraySortStepIndex];
    emit(curStep.state);
    await Future.delayed(const Duration(milliseconds: 500));
    if (curStep.state.state == BubbleSortState.Swap) {            
      for (var swap in curStep.swaps) {
        onAnimateSwap(swap.arraySourceIndex, swap.arrayDestinationIndex, const Duration(milliseconds: 500));
        _swapElements(swap.arrayDestinationIndex, swap.arraySourceIndex);
      }
      emit(curStep.state);      
    }
    _curArraySortStepIndex = (_curArraySortStepIndex == 0) ? 0 : _curArraySortStepIndex - 1;
  }

  void onRemoveItem(int index) {
    list.removeAt(index);
    onRemoveAnimation(index);
  }

  void onDurationChange(int value) {
    _duration = Duration(milliseconds: value);
  }

  void _addItem(double item) {
    list.add(item);
    onAddAnimation(item, list.length - 1);
  }
}

