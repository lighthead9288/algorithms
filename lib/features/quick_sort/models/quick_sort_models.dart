class QuickSortItemState {
  final QuickSortStatus status;
  final int leftItemIndex;
  final int rightItemIndex;
  final int pivotItemIndex;

  QuickSortItemState({required this.status, required this.leftItemIndex, required this.rightItemIndex, required this.pivotItemIndex});
}

enum QuickSortStatus {
  None, Started
}