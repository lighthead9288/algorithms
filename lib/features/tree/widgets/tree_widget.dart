import 'package:algorithms/core/models/models.dart';
import 'package:algorithms/core/widgets/playground_widget.dart';
import 'package:algorithms/features/tree/models/binary_tree.dart';
import 'package:algorithms/features/tree/models/traverse_algorithms.dart';
import 'package:algorithms/features/tree/widgets/traverse_algorithms_dialog.dart';
import 'package:algorithms/features/tree/widgets/tree_operations_dialog.dart';
import 'package:algorithms/features/tree/widgets/tree_painter.dart';
import 'package:flutter/material.dart';

class TreeWidget extends StatefulWidget {
  const TreeWidget({Key? key}) : super(key: key);

  @override
  State<TreeWidget> createState() => _TreeWidgetState();
}

class _TreeWidgetState extends State<TreeWidget>
    implements AlgorithmOperations<BinaryTreeNode> {
  late double _deviceHeight;
  late double _deviceWidth;

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

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

  late Map<BinaryTreeNode, Offset> nodesMap;
  List<String> _nodes = [];
  int _curNodeNumber = 26;
  Duration _duration = const Duration(milliseconds: 0);
  bool _isStopped = false;
  bool _stepByStepMode = false;

  List<TreeTraverseStep> _traverseSteps = [];
  int _curTraverseStepIndex = 0;

  @override
  void initState() {
    nodesMap = <BinaryTreeNode, Offset>{};

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return PlaygroundWidget(
      operations: this, widget: _treeWidgetUI(context), editOptions: []);
  }

  Widget _treeWidgetUI(BuildContext context) {
    return SizedBox(
      width: _deviceWidth,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            controller: _verticalScrollController,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _horizontalScrollController,
              child: SizedBox(
                  height: _deviceHeight * 0.9,
                  width: _deviceWidth * 1.5,
                  child: GestureDetector(
                    child: CustomPaint(
                      painter: TreePainter(
                          context: context,
                          root: _tree,
                          markedNodes: _nodes,
                          onDrawNode: (node, offset) {
                            nodesMap.putIfAbsent(node, () => offset);
                          }),
                    ),
                    onLongPressEnd: (details) {
                      print("Local position: dx = ${details.localPosition.dx}, dy = ${details.localPosition.dy}");
                      _checkCanvasPoint(details.localPosition);
                    },
                  )
              ),
            ),
          ),
    );
  }

  void _checkCanvasPoint(Offset offset) {
    var delta = 20;
    for (var item in nodesMap.entries) {
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
        print(key.data);        
        showDialog(
          context: context, 
          builder: (_) => TreeOperationsDialog(
            node: key,
            onAddLeft: () {
              setState(() {
                var curLevel = key.level;
                key.left = BinaryTreeNode(data: (++_curNodeNumber).toString(), level: ++curLevel);
              });
            },
            onAddRight: () {
              setState(() {
                var curLevel = key.level;
                key.right = BinaryTreeNode(data: (++_curNodeNumber).toString(), level: ++curLevel);
              });
            },
            onRemove: () {              
              onRemoveItem(key);
            },
          )
        );
        return;
      }
    }
  }

  Future<void> _preOrderTraverse(BinaryTreeNode? node) async {
    if (node == null) {
      return;
    }

    if (_isStopped) {
      _nodes.clear();
      setState(() {});
      return;
    }

    _nodes.add(node.data);
    setState(() {});
    await Future.delayed(_duration);
    await _preOrderTraverse(node.left);
    await _preOrderTraverse(node.right);

  }

  Future<void> _postOrderTraverse(BinaryTreeNode? node) async {
    if (node == null) {
      return;
    }

    await _postOrderTraverse(node.left);
    await _postOrderTraverse(node.right);

    if (_isStopped) {
      _nodes.clear();
      setState(() {});
      return;
    }

    _nodes.add(node.data);
    setState(() {});
    await Future.delayed(_duration);
  } 

  @override
  void onAutoMode() {
    setState(() {
      _stepByStepMode = false;
    });
  }

  @override
  void onDurationChange(int value) {
    setState(() {
      _duration = Duration(milliseconds: value);
    });
  }

  @override
  Future<void> onPlay() async {
    _nodes.clear();
    var algVariant = await showDialog<TraverseAlgorithms>(
      context: context, 
      builder: (_) => const TraverseAlgorithmsDialog());
    if (algVariant == TraverseAlgorithms.preOrder) {
      await _preOrderTraverse(_tree);
    } else if (algVariant == TraverseAlgorithms.postOrder) {
      await _postOrderTraverse(_tree);
    }
    _isStopped = false;
  }

  @override
  void onRemoveItem(BinaryTreeNode node) {
    setState(() {
      _tree = _tree?.remove(_tree, node.data);
    });
  }

  @override
  void onStepBack() {
    if (_curTraverseStepIndex > 0) {
      _nodes.removeLast();
      _curTraverseStepIndex--;
      setState(() {});
    }
  }

  @override
  Future<void> onStepByStepMode() async {
    setState(() {
      _stepByStepMode = true;
      _curTraverseStepIndex = 0;
    });
    Future.delayed(Duration.zero, () async {
      _duration = const Duration(milliseconds: 0);
      _traverseSteps.clear();
      await onPlay();
      _traverseSteps = _nodes.map((node) => TreeTraverseStep(nodeName: node)).toList();
      _nodes.clear();
    });
  }

  @override
  void onStepForward() {
    if (_curTraverseStepIndex < _traverseSteps.length) {
      _nodes.add(_traverseSteps[_curTraverseStepIndex].nodeName);
      _curTraverseStepIndex++;
      setState(() {});
    }    
  }

  @override
  void onStop() {
    setState(() {
      _isStopped = true;
    });
  }
}

class TreeTraverseStep {
  final String nodeName;

  TreeTraverseStep({required this.nodeName});
}