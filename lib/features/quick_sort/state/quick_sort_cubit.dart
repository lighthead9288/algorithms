import 'dart:math';

import 'package:algorithms/features/quick_sort/models/quick_sort_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuickSortCubit extends Cubit<QuickSortWidgetStateChanged> {
  final Future<void> Function(int prev, int next, Duration duration) onAnimateSwap;
  final Future<void> Function(int left, int right, Duration duration) onAnimateArrayBounds;
  final void Function(List<double> list, Duration duration) initAnimations;
  final void Function(int index, Duration duration) onAddAnimation;
  final void Function(int index) onRemoveAnimation;

  QuickSortCubit({
    required QuickSortWidgetStateChanged initialState,
    required this.onAnimateSwap,
    required this.onAnimateArrayBounds, 
    required this.initAnimations,
    required this.onAddAnimation, 
    required this.onRemoveAnimation
  }) : super(initialState) {
    list = List.generate(8, (index) => double.parse((Random().nextDouble() * 10).toStringAsFixed(3)));
   // list = [6, 7, 2, 5, 9, 1, 3, 8];
    //list = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3];
    initAnimations(list, _duration);
    emit(QuickSortWidgetStateChanged(list: list, state: _curState, stepByStepMode: _stepByStepMode));
  }

  List<double> list = [];
  List<double> _oldList = [];

  bool _stepByStepMode = false;
  bool _isStopped = false;

  Duration _duration = const Duration(milliseconds: 0);

  QuickSortItemState _curState = QuickSortItemState(
    status: QuickSortStatus.None,
    leftItemIndex: 0, 
    rightItemIndex: 0, 
    pivotItemIndex: 0
  );

  Future<List<double>> sort(List<double> list, int left, int right) async {
    onAnimateArrayBounds(left, right, _duration);
    var i = left;
    var j = right;
    var pivot = list[i];
    var pivotIndex = i;
    _onStateChange(
      QuickSortItemState(
        status: QuickSortStatus.Started, 
        leftItemIndex: i, 
        rightItemIndex: j, 
        pivotItemIndex: pivotIndex,
        leftInitialIndex: left,
        rightInitialIndex: right
      )
    );
    await Future.delayed(_duration);
    do {
      while  ((i < j) && (list[j] >= pivot) && (!_isStopped)) {
        j--;
        await _onShiftBound(i, j, pivotIndex, left, right);
      }    
      
      pivotIndex = await _onSwap(i, j, pivotIndex);
      
      while ((i < j) && (list[i] <= pivot) && (!_isStopped)) {
        i++;
        await _onShiftBound(i, j, pivotIndex, left, right);        
      }     
      pivotIndex = await _onSwap(i, j, pivotIndex);

      if (_isStopped) {
          // Stop
        _isStopped = false;
        _onStateChange(QuickSortItemState(status: QuickSortStatus.None));         
        return _oldList;
      }

    } while (i < j);

    if (i > left) {
      list = await sort(list, left, i - 1);
    }
    if (j < right) {
      list = await sort(list, i + 1, right);
    }
    _onStateChange(QuickSortItemState(status: QuickSortStatus.None));
    return list;
  }

  Future<void> _onShiftBound(int i, int j, int pivotIndex, int left, int right) async {
    _onStateChange(
      QuickSortItemState(
        status: QuickSortStatus.Started, 
        leftItemIndex: i, 
        rightItemIndex: j, 
        pivotItemIndex: pivotIndex,
        leftInitialIndex: left,
        rightInitialIndex: right
      )
    );
    await Future.delayed(_duration);
  }

  Future<int> _onSwap(int i, int j, int pivotIndex) async {
    await onAnimateSwap(i, j, _duration);

    var newPivot = pivotIndex;
    if (i == pivotIndex) {
      newPivot = j;
    }
    if (j == pivotIndex) {
      newPivot = i;
    }
    _swapElements(i, j);
    return newPivot;
  }

  void _onStateChange(QuickSortItemState newState) {
    _curState = newState;
    
    if (!_stepByStepMode) {
      emit(QuickSortWidgetStateChanged(state: newState, list: list, stepByStepMode: _stepByStepMode));
    } else {
    }
  }

  void _swapElements(int prev, int next) {
    var tmp = list[prev];
    list[prev] = list[next];
    list[next] = tmp;
  }

   Future<void> onPlay() async {
    _oldList = List<double>.from(list);
    list = await sort(list, 0 , list.length - 1);
    emit(QuickSortWidgetStateChanged(state: _curState, list: list, stepByStepMode: _stepByStepMode));
  }

  void onStop() {
    _isStopped = true;
  }

  void onAutoMode() {
    _stepByStepMode = false;
    emit(QuickSortWidgetStateChanged(state: _curState, list: list, stepByStepMode: _stepByStepMode));
  }

  Future<void> onStepByStepMode() async {
  }

  void onRemoveItem(int index) {
    list.removeAt(index);
    onRemoveAnimation(index);
  }

  void onDurationChange(int value) {
    _duration = Duration(milliseconds: value);
  }

  void onAddItem(double item) {
    list.add(item);
    onAddAnimation(list.length - 1, _duration);
    emit(QuickSortWidgetStateChanged(state: _curState, list: list, stepByStepMode: _stepByStepMode));
  }

  void onRandomNumbersGenerate(int count) {
    var newItems = List.generate(count, (index) => double.parse(Random().nextDouble().toStringAsFixed(3)));
    for(var item in newItems) {
      onAddItem(item);
    }
  }
}

abstract class QuickSortWidgetState {
  final QuickSortItemState state;
  final List<double> list;

  QuickSortWidgetState({required this.state, required this.list});
}

class QuickSortWidgetStateChanged extends QuickSortWidgetState {
  final bool stepByStepMode;

  QuickSortWidgetStateChanged({required QuickSortItemState state, required List<double> list, required this.stepByStepMode})
    : super(state: state, list: list);
}