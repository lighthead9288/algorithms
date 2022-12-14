import 'dart:math';

import 'package:algorithms/core/models/models.dart';
import 'package:algorithms/features/bubble_sort/models/bubble_sort_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BubbleSortCubit extends Cubit<BubbleSortWidgetStateChanged> {
  final Future<void> Function(int prev, int next, Duration duration) onAnimateSwap;
  final void Function(List<double> list, Duration duration) initAnimations;
  final void Function(double item, int index, Duration duration) onAddAnimation;
  final void Function(int index) onRemoveAnimation;

  BubbleSortCubit({
    required BubbleSortWidgetStateChanged initialState, 
    required this.onAnimateSwap, 
    required this.initAnimations,
    required this.onAddAnimation, 
    required this.onRemoveAnimation
  }) : super(initialState) {
    _list = List.generate(10, (index) => double.parse(Random().nextDouble().toStringAsFixed(3)));
    initAnimations(_list, _duration);
    emit(BubbleSortWidgetStateChanged(state: BubbleSortItemState(status: BubbleSortStatus.None), list: _list, stepByStepMode: _stepByStepMode));
  }

  List<double> _list = [];

  bool _stepByStepMode = false;
  bool _isStopped = false;  

  List<BubbleSortStep> _arraySortSteps = [];
  int _curArraySortStepIndex = 0;

  BubbleSortItemState _curState = BubbleSortItemState(status: BubbleSortStatus.None);

  Duration _duration = const Duration(milliseconds: 0);

  Future<void> onStepByStepMode() async {
    _stepByStepMode = true;
    emit(BubbleSortWidgetStateChanged(state: _curState, list: _list, stepByStepMode: _stepByStepMode));
    _duration = const Duration(milliseconds: 0);
    _arraySortSteps.clear();
    _arraySortSteps.add(BubbleSortStep(state: BubbleSortItemState(status: BubbleSortStatus.None)));
    _list = await _sort(_list);
    emit(BubbleSortWidgetStateChanged(state: _curState, list: _list, stepByStepMode: _stepByStepMode));
  }  

  void _onStateChange(BubbleSortItemState newState) {
    if (!_stepByStepMode) {
      emit(BubbleSortWidgetStateChanged(state: newState, list: _list, stepByStepMode: _stepByStepMode));
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
    emit(BubbleSortWidgetStateChanged(state: curStep.state, list: _list, stepByStepMode: _stepByStepMode));
    await Future.delayed(const Duration(milliseconds: 500));
    if (curStep.state.status == BubbleSortStatus.Swap) {            
      for (var swap in curStep.swaps) {
        onAnimateSwap(swap.arraySourceIndex, swap.arrayDestinationIndex, const Duration(milliseconds: 500));
        _swapElements(swap.arraySourceIndex, swap.arrayDestinationIndex);
      }
      emit(BubbleSortWidgetStateChanged(state: curStep.state, list: _list, stepByStepMode: _stepByStepMode));      
    }
    _curArraySortStepIndex = (_curArraySortStepIndex == _arraySortSteps.length - 1) ? _arraySortSteps.length - 1 : _curArraySortStepIndex + 1;
  }

  void onStepBack() async {
    var curStep = _arraySortSteps[_curArraySortStepIndex];
    emit(BubbleSortWidgetStateChanged(state: curStep.state, list: _list, stepByStepMode: _stepByStepMode));
    await Future.delayed(const Duration(milliseconds: 500));
    if (curStep.state.status == BubbleSortStatus.Swap) {            
      for (var swap in curStep.swaps) {
        onAnimateSwap(swap.arraySourceIndex, swap.arrayDestinationIndex, const Duration(milliseconds: 500));
        _swapElements(swap.arrayDestinationIndex, swap.arraySourceIndex);
      }
      emit(BubbleSortWidgetStateChanged(state: curStep.state, list: _list, stepByStepMode: _stepByStepMode));      
    }
    _curArraySortStepIndex = (_curArraySortStepIndex == 0) ? 0 : _curArraySortStepIndex - 1;
  }

   Future<void> onPlay() async {
    _list = await _sort(_list);
    _onStateChange(_curState);
  }

  void onStop() {
    _isStopped = true;
  }

  void onAutoMode() {
    _stepByStepMode = false;
    emit(BubbleSortWidgetStateChanged(state: _curState, list: _list, stepByStepMode: _stepByStepMode));
  }

  void onRemoveItem(int index) {
    _list.removeAt(index);
    onRemoveAnimation(index);
  }

  void onDurationChange(int value) {
    _duration = Duration(milliseconds: value);
  }

  void onAddItem(double item) {
    _list.add(item);
    onAddAnimation(item, _list.length - 1, _duration);
    emit(BubbleSortWidgetStateChanged(state: _curState, list: _list, stepByStepMode: _stepByStepMode));
  }

  void onRandomNumbersGenerate(int count) {
    var newItems = List.generate(count, (index) => double.parse(Random().nextDouble().toStringAsFixed(3)));
    for(var item in newItems) {
      onAddItem(item);
    }
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
          _curState = BubbleSortItemState(status: BubbleSortStatus.None);          
          return oldList;
        }
        if (list[j] > list[j+1]) {
          // Swap
          isNormalOrder = false;
          _curState = BubbleSortItemState(status: BubbleSortStatus.Swap, index: j);
          _onStateChange(_curState);
          await Future.delayed(_duration);

          await onAnimateSwap(j, j+1, _duration);
          _swapElements(j, j+1);
         
        } else {
          // Normal
          _curState = BubbleSortItemState(status: BubbleSortStatus.Normal, index: j);
          _onStateChange(_curState);
          await Future.delayed(_duration);
        } 
      }
      if (isNormalOrder) break;
    }
    // Finish
    _curState = BubbleSortItemState(status: BubbleSortStatus.None); 
    _onStateChange(_curState);
    return (!_stepByStepMode) ? list : oldList;
  }

  void _swapElements(int prev, int next) {
    var tmp = _list[prev];
    _list[prev] = _list[next];
    _list[next] = tmp;
  }
}

abstract class BubbleSortWidgetState {
  final BubbleSortItemState state;
  final List<double> list;

  BubbleSortWidgetState({required this.state, required this.list});
}

class BubbleSortWidgetStateChanged extends BubbleSortWidgetState {
  final bool stepByStepMode;

  BubbleSortWidgetStateChanged({required BubbleSortItemState state, required List<double> list, required this.stepByStepMode}) : super(state: state, list: list);
}

