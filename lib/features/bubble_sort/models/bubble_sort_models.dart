import 'package:algorithms/core/models/models.dart';

class BubbleSortStep {
  final BubbleSortItemState state;
  List<Swap> swaps;

  BubbleSortStep({required this.state, this.swaps = const []});
}

class BubbleSortItemState {
  final BubbleSortState state;
  int? index;

  BubbleSortItemState({required this.state, this.index});
}

enum BubbleSortState {
  None, Normal, Swap
}