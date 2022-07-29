import 'package:flutter/material.dart';

class EditDataOption {
  final String title;
  final Icon icon;
  final Future<void> Function() onTap;

  EditDataOption(
      {required this.title, required this.icon, required this.onTap});
}

class Swap {
  final int arraySourceIndex;
  final int arrayDestinationIndex;

  Swap({required this.arraySourceIndex, required this.arrayDestinationIndex});
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