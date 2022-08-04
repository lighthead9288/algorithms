class QuickSortItemState {
  final QuickSortStatus status;
  int? leftItemIndex;
  int? rightItemIndex;
  int? pivotItemIndex;
  int? leftInitialIndex;
  int? rightInitialIndex;

  QuickSortItemState({required this.status, this.leftItemIndex, this.rightItemIndex, this.pivotItemIndex, this.leftInitialIndex, this.rightInitialIndex});
}

enum QuickSortStatus {
  None, Started
}