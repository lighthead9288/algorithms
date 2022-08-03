class QuickSortItemState {
  final QuickSortStatus status;
  int? leftItemIndex;
  int? rightItemIndex;
  int? pivotItemIndex;

  QuickSortItemState({required this.status, this.leftItemIndex, this.rightItemIndex, this.pivotItemIndex});
}

enum QuickSortStatus {
  None, Started
}