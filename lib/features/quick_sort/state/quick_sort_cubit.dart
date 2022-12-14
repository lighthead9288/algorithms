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
    _list = List.generate(8, (index) => double.parse((Random().nextDouble() * 10).toStringAsFixed(3)));
    initAnimations(_list, _duration);
    emit(QuickSortWidgetStateChanged(list: _list, state: _curState, stepByStepMode: _stepByStepMode));
  }

  static const int _maximumArrayLength = 10;

  List<double> _list = [];
  List<double> _oldList = [];

  bool _stepByStepMode = false;
  bool _isStopped = false;

  List<QuickSortItemState> _arraySortSteps = [];
  int _curArraySortStepIndex = 0;
  
  QuickSortItemState _curState = QuickSortItemState(
    status: QuickSortStatus.None,
    leftItemIndex: 0, 
    rightItemIndex: 0, 
    pivotItemIndex: 0
  );

  Duration _duration = const Duration(milliseconds: 0);

  Future<void> onPlay() async {
    _oldList = List<double>.from(_list);
    _list = await _sort(_list, 0, _list.length - 1);
    _onStateChange(QuickSortItemState(status: QuickSortStatus.None));
  }

  void onStop() {
    _isStopped = true;
  }

  void onAutoMode() {
    _stepByStepMode = false;
    emit(QuickSortWidgetStateChanged(state: _curState, list: _list, stepByStepMode: _stepByStepMode));
  }

  Future<void> onStepByStepMode() async {
    _stepByStepMode = true;
    emit(QuickSortWidgetStateChanged(state: _curState, list: _list, stepByStepMode: _stepByStepMode));
    _duration = const Duration(milliseconds: 0);
    _arraySortSteps.clear();
    _arraySortSteps.add(QuickSortItemState(status: QuickSortStatus.None));
    _oldList = List<double>.from(_list);
    _curArraySortStepIndex = 0;
    _list = await _sort(_list, 0, _list.length - 1);
    _list = _oldList;
    _onStateChange(QuickSortItemState(status: QuickSortStatus.None));
    emit(QuickSortWidgetStateChanged(state: _curState, list: _list, stepByStepMode: _stepByStepMode));
  }

  void onStepForward() async {
    var curStep = _arraySortSteps[_curArraySortStepIndex];
    emit(QuickSortWidgetStateChanged(state: curStep, list: _list, stepByStepMode: _stepByStepMode));
    await Future.delayed(const Duration(milliseconds: 500));
    if (curStep.status == QuickSortStatus.Swap) {            
      _onSwap(curStep.leftItemIndex!, curStep.rightItemIndex!, curStep.pivotItemIndex!, const Duration(milliseconds: 500));
      emit(QuickSortWidgetStateChanged(state: curStep, list: _list, stepByStepMode: _stepByStepMode));      
    } else if (curStep.status == QuickSortStatus.InitBorders) {
      onAnimateArrayBounds(curStep.leftInitialIndex!, curStep.rightInitialIndex!, const Duration(milliseconds: 500));
    }
    _curArraySortStepIndex = (_curArraySortStepIndex == _arraySortSteps.length - 1) ? _arraySortSteps.length - 1 : _curArraySortStepIndex + 1;
  }

  void onStepBack() async {
    var curStep = _arraySortSteps[_curArraySortStepIndex];
    emit(QuickSortWidgetStateChanged(state: curStep, list: _list, stepByStepMode: _stepByStepMode));
    await Future.delayed(const Duration(milliseconds: 500));
    if (curStep.status == QuickSortStatus.Swap) {            
      _onSwap(curStep.rightItemIndex!, curStep.leftItemIndex!, curStep.pivotItemIndex!, const Duration(milliseconds: 500));
      emit(QuickSortWidgetStateChanged(state: curStep, list: _list, stepByStepMode: _stepByStepMode));      
    } else if (curStep.status == QuickSortStatus.InitBorders) {
      onAnimateArrayBounds(curStep.leftInitialIndex!, curStep.rightInitialIndex!, const Duration(milliseconds: 500));
    }
    _curArraySortStepIndex = (_curArraySortStepIndex == 0) ? 0 : _curArraySortStepIndex - 1;
  }

  void onRemoveItem(int index) {
    _list.removeAt(index);
    onRemoveAnimation(index);
  }

  void onDurationChange(int value) {
    _duration = Duration(milliseconds: value);
  }

  void onAddItem(double item, {void Function(String message)? onError}) {
    if ((_list.length == _maximumArrayLength) && (onError != null)) {
      onError("Array length cannot be higher than $_maximumArrayLength");
      return;
    }

    _list.add(item);
    onAddAnimation(_list.length - 1, _duration);
    emit(QuickSortWidgetStateChanged(state: _curState, list: _list, stepByStepMode: _stepByStepMode));
  }

  void onRandomNumbersGenerate(int count, {void Function(String message)? onError}) {
    if ((_list.length + count > _maximumArrayLength) && (onError != null)) {
      onError("Array length cannot be higher than $_maximumArrayLength");
      return;
    }

    var newItems = List.generate(count, (index) => double.parse(Random().nextDouble().toStringAsFixed(3)));
    for(var item in newItems) {
      onAddItem(item);
    }
  }

  Future<List<double>> _sort(List<double> list, int left, int right) async {
    onAnimateArrayBounds(left, right, _duration);
    var i = left;
    var j = right;
    var pivot = list[i];
    var pivotIndex = i;
    _onStateChange(
      QuickSortItemState(
        status: QuickSortStatus.InitBorders, 
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
      
      pivotIndex = await _onSwap(i, j, pivotIndex, _duration);
      _onStateChange(
        QuickSortItemState(
          status: QuickSortStatus.Swap, 
          leftItemIndex: i, 
          rightItemIndex: j, 
          pivotItemIndex: pivotIndex,
          leftInitialIndex: left,
          rightInitialIndex: right
        )
      );
      
      while ((i < j) && (list[i] <= pivot) && (!_isStopped)) {
        i++;
        await _onShiftBound(i, j, pivotIndex, left, right);        
      }     
      pivotIndex = await _onSwap(i, j, pivotIndex, _duration);
      _onStateChange(
        QuickSortItemState(
          status: QuickSortStatus.Swap, 
          leftItemIndex: i, 
          rightItemIndex: j, 
          pivotItemIndex: pivotIndex,
          leftInitialIndex: left,
          rightInitialIndex: right
        )
      );

      if (_isStopped) {
          // Stop
        _isStopped = false;
        _onStateChange(QuickSortItemState(status: QuickSortStatus.None));         
        return _oldList;
      }

    } while (i < j);

    if (i > left) {
      list = await _sort(list, left, i - 1);
    }
    if (j < right) {
      list = await _sort(list, i + 1, right);
    }
    return list;
  }

  Future<void> _onShiftBound(int i, int j, int pivotIndex, int left, int right) async {
    _onStateChange(
      QuickSortItemState(
        status: QuickSortStatus.Normal, 
        leftItemIndex: i, 
        rightItemIndex: j, 
        pivotItemIndex: pivotIndex,
        leftInitialIndex: left,
        rightInitialIndex: right
      )
    );
    await Future.delayed(_duration);
  }

  Future<int> _onSwap(int i, int j, int pivotIndex, Duration duration) async {
    await onAnimateSwap(i, j, duration);

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
      emit(QuickSortWidgetStateChanged(state: newState, list: _list, stepByStepMode: _stepByStepMode));
    } else {
      _arraySortSteps.add(newState);
    }
  }

  void _swapElements(int prev, int next) {
    var tmp = _list[prev];
    _list[prev] = _list[next];
    _list[next] = tmp;
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