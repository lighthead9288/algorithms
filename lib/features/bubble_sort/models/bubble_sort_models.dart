import 'package:algorithms/core/models/models.dart';

class BubbleSortStep {
  final BubbleSortItemState state;
  List<Swap> swaps;

  BubbleSortStep({required this.state, this.swaps = const []});
}

class BubbleSortItemState {
  final BubbleSortStatus status;
  int? index;

  BubbleSortItemState({required this.status, this.index});
}

enum BubbleSortStatus {
  None, Normal, Swap
}