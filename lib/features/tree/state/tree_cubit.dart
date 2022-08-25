import 'package:algorithms/features/tree/models/binary_tree.dart';
import 'package:algorithms/features/tree/models/traverse_algorithms.dart';
import 'package:algorithms/features/tree/models/tree_traverse_strategies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TreeCubit extends Cubit<TreeTraverseState> {
  final Future<void> Function(
    BinaryTreeNode? key, 
    void Function() onAddLeft, 
    void Function() onAddRight, 
    void Function() onRemove) showTreeOperationsDialog;
  final Future<TraverseAlgorithms?> Function() onSelectAlgorithm;

  BinaryTreeNode? _tree = BinaryTreeNode(
      data: '1',
      level: 1,
      left: BinaryTreeNode(
          data: '2',
          level: 2,
          left: BinaryTreeNode(
              data: '4',
              level: 3,
              left: BinaryTreeNode(
                  data: '8',
                  level: 4,
                  left: BinaryTreeNode(data: '13', level: 5),
                  right: BinaryTreeNode(data: '14', level: 5)),
              right: BinaryTreeNode(
                  data: '9',
                  level: 4,
                  left: BinaryTreeNode(data: '15', level: 5),
                  right: BinaryTreeNode(data: '16', level: 5))
          ),
          right: BinaryTreeNode(
              data: '5',
              level: 3,
              left: BinaryTreeNode(
                  data: '10',
                  level: 4,
                  left: BinaryTreeNode(data: '17', level: 5),
                  right: BinaryTreeNode(data: '18', level: 5)),
              right: BinaryTreeNode(
                  data: '11',
                  level: 4,
                  left: BinaryTreeNode(data: '19', level: 5),
                  right: BinaryTreeNode(data: '20', level: 5)
                  )
              )
    ),
      right: BinaryTreeNode(
          data: '3',
          level: 2,
          left: BinaryTreeNode(
              data: '6',
              level: 3,
              left: BinaryTreeNode(
                  data: '12',
                  level: 4,
                  left: BinaryTreeNode(data: '21', level: 5),
                  right: BinaryTreeNode(data: '22', level: 5)),
              right:
                  BinaryTreeNode(data: '23', level: 4, left: BinaryTreeNode(data: '26', level: 5))
          ),
          right: BinaryTreeNode(
              data: '7',
              level: 3,
              left: BinaryTreeNode(data: '24', level: 4),
              right: BinaryTreeNode(data: '25', level: 4)
          )
      )
    );

  late Map<BinaryTreeNode, Offset> _nodesMap = <BinaryTreeNode, Offset>{};
  final List<String> _nodes = [];
  late int _curNodeNumber;
  Duration _duration = const Duration(milliseconds: 0);
  bool _isStopped = false;
  bool _stepByStepMode = false;
  TreeTraverseStrategy _treeTraverseStrategy = PreOrderTraverseStrategy();
  List<TreeTraverseStep> _traverseSteps = [];
  int _curTraverseStepIndex = 0;  

  TreeCubit({
    required TreeTraverseState initialState,
    required this.showTreeOperationsDialog,
    required this.onSelectAlgorithm
  }) : super(initialState) {
    _curNodeNumber = _tree!.getMaxNumber(_tree, int.parse(_tree!.data));
    emit(TreeTraverseState(tree: _tree!, selectedNodes: _nodes));
  }

  void onDrawNode(BinaryTreeNode node, Offset offset) {
    _nodesMap.putIfAbsent(node, () => offset);
  }
  
  void checkCanvasPoint(Offset offset) {
    var delta = 20;
    for (var item in _nodesMap.entries) {
      BinaryTreeNode? key = item.key;
      var value = item.value;
      var xLeft = value.dx - delta;
      var xRight = value.dx + delta;
      var yLow = value.dy - delta;
      var yHigh = value.dy + delta;
      if ((offset.dx >= xLeft) &&
          (offset.dx <= xRight) &&
          (offset.dy >= yLow) &&
          (offset.dy <= yHigh)) {
        showTreeOperationsDialog(
          key,
          () {
            var curLevel = key.level;
            var number = _tree!.getMaxNumber(_tree, int.parse(_tree!.data)) + 1;
            key.left = BinaryTreeNode(data: (number).toString(), level: ++curLevel);
            emit(TreeTraverseState(tree: _tree!, selectedNodes: _nodes));
          },
          () {
            var curLevel = key.level;
            var number = _tree!.getMaxNumber(_tree, int.parse(_tree!.data)) + 1;
            key.right = BinaryTreeNode(data: (number).toString(), level: ++curLevel);
            emit(TreeTraverseState(tree: _tree!, selectedNodes: _nodes));
          },
          () {
            onRemoveItem(key);
          }
        );
        return;
      }
    }
  }

  void onAutoMode() {
    _stepByStepMode = false;
    emit(TreeTraverseState(tree: _tree!, selectedNodes: _nodes));
  }

  void onDurationChange(int value) {
    _duration = Duration(milliseconds: value);
    emit(TreeTraverseState(tree: _tree!, selectedNodes: _nodes));
  }

  Future<void> onPlay() async {
    _nodes.clear();
    var algVariant = await onSelectAlgorithm();
    if (algVariant == TraverseAlgorithms.preOrder) {
      _treeTraverseStrategy = PreOrderTraverseStrategy();
    } else if (algVariant == TraverseAlgorithms.postOrder) {
      _treeTraverseStrategy = PostOrderTraverseStrategy();
    }
    await _treeTraverseStrategy.run(
      _tree, 
      (node) async {
        _nodes.add(node.data);
        emit(TreeTraverseState(tree: _tree!, selectedNodes: _nodes));
        await Future.delayed(_duration);
      }, 
      () { 
        if (_isStopped) {
          _nodes.clear();
          emit(TreeTraverseState(tree: _tree!, selectedNodes: _nodes));          
        }
        return _isStopped;        
      }
    );
    _isStopped = false;
  }

  void onRemoveItem(BinaryTreeNode node) {
    _tree = _tree?.remove(_tree, node.data);
    _nodesMap.remove(node);    
    emit(TreeTraverseState(tree: _tree!, selectedNodes: _nodes));
  }

  void onStepBack() {
    if (_curTraverseStepIndex > 0) {
      _nodes.removeLast();
      _curTraverseStepIndex--;
      emit(TreeTraverseState(tree: _tree!, selectedNodes: _nodes));
    }
  }

  Future<void> onStepByStepMode() async {
    _stepByStepMode = true;
    _curTraverseStepIndex = 0;
    emit(TreeTraverseState(tree: _tree!, selectedNodes: _nodes));
    Future.delayed(Duration.zero, () async {
      _duration = const Duration(milliseconds: 0);
      _traverseSteps.clear();
      await onPlay();
      _traverseSteps = _nodes.map((node) => TreeTraverseStep(nodeName: node)).toList();
      _nodes.clear();
    });
  }

  void onStepForward() {
    if (_curTraverseStepIndex < _traverseSteps.length) {
      _nodes.add(_traverseSteps[_curTraverseStepIndex].nodeName);
      _curTraverseStepIndex++;
      emit(TreeTraverseState(tree: _tree!, selectedNodes: _nodes));
    }    
  }

  void onStop() {
    _isStopped = true;
    emit(TreeTraverseState(tree: _tree!, selectedNodes: _nodes));
  }
}

class TreeTraverseState {
  final BinaryTreeNode tree;
  final List<String> selectedNodes;

  TreeTraverseState({required this.tree, required this.selectedNodes});
}

class TreeTraverseStep {
  final String nodeName;

  TreeTraverseStep({required this.nodeName});
}