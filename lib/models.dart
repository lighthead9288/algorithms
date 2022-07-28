import 'package:flutter/material.dart';

class EditDataOption {
  final String title;
  final Icon icon;
  final Future<void> Function() onTap;

  EditDataOption(
      {required this.title, required this.icon, required this.onTap});
}

class ArraySortChange {
  final BubbleSortItemState state;
  List<Swap> swaps;

  ArraySortChange({required this.state, this.swaps = const []});
}

class Swap {
  final int arraySourceIndex;
  final int arrayDestinationIndex;

  Swap({required this.arraySourceIndex, required this.arrayDestinationIndex});
}

class BubbleSortItemState {
  final BubbleSortState state;
  int? index;

  BubbleSortItemState({required this.state, this.index});
}

enum BubbleSortState {
  None, Normal, Swap
}

abstract class AlgorithmOperations {
  Future<void> onPlay();
  void onStop();
  void onAutoMode();
  Future<void> onStepByStepMode();
  void onRemoveItem(int index);
  void onDurationChange(int value);
  void onStepForward();
  void onStepBack();
}