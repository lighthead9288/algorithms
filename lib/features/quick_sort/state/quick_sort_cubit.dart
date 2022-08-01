import 'dart:math';

import 'package:algorithms/features/quick_sort/models/quick_sort_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuickSortCubit extends Cubit<QuickSortWidgetStateChanged> {
  QuickSortCubit({required QuickSortWidgetStateChanged initialState}) : super(initialState) {
   // list = List.generate(8, (index) => double.parse((Random().nextDouble() * 10).toStringAsFixed(3)));
    list = [6, 7, 2, 5, 9, 1, 3, 8];
   // list = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3];
    emit(QuickSortWidgetStateChanged(list: list, state: _curState, stepByStepMode: _stepByStepMode));
  }

  List<double> list = [];

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
    var i = left;
    var j = right;
    var pivot = list[i];

    do {
      while (list[i] < pivot) {
        i++;
      }
      while(list[j] > pivot) {
        j--;
      }
      if (i <= j) {
        _swapElements(i, j);
        i++;
        j--;
      }
    } while (i <= j);

    if (j > right) {
      list = await sort(list, left, j);
    }
    if (right > i) {
      list = await sort(list, i, right - 1);
    }
    return list;
  }

  void _swapElements(int prev, int next) {
    var tmp = list[prev];
    list[prev] = list[next];
    list[next] = tmp;
  }

   Future<void> onPlay() async {
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

  void onRemoveItem(int index) {
    list.removeAt(index);
   // onRemoveAnimation(index);
  }

  void onDurationChange(int value) {
    _duration = Duration(milliseconds: value);
  }

  void onAddItem(double item) {
    list.add(item);
   // onAddAnimation(item, list.length - 1, _duration);
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