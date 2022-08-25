import 'package:algorithms/core/models/models.dart';
import 'package:algorithms/core/widgets/playground_widget.dart';
import 'package:algorithms/features/tree/models/binary_tree.dart';
import 'package:algorithms/features/tree/models/traverse_algorithms.dart';
import 'package:algorithms/features/tree/state/tree_cubit.dart';
import 'package:algorithms/features/tree/widgets/traverse_algorithms_dialog.dart';
import 'package:algorithms/features/tree/widgets/tree_operations_dialog.dart';
import 'package:algorithms/features/tree/widgets/tree_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  late BuildContext _cubitContext;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return PlaygroundWidget(
      operations: this, widget: _treeWidgetUI(context), editOptions: const []);
  }

  Widget _treeWidgetUI(BuildContext context) {
    return BlocProvider(
      create: (_) => TreeCubit(
        initialState: TreeTraverseState(tree: BinaryTreeNode(data: '', level: 0), selectedNodes: const []), 
        showTreeOperationsDialog: (key, addLeft, addRight, remove) async {
          showDialog(
            context: context, 
            builder: (_) => TreeOperationsDialog(
              node: key!,
              onAddLeft: () {
                addLeft();
              },
              onAddRight: () {
                addRight();
              },
              onRemove: () {              
                remove();
              },
            )
          );
        },
        onSelectAlgorithm: () async {
          return showDialog<TraverseAlgorithms>(
            context: context, 
            builder: (_) => const TraverseAlgorithmsDialog()
          );
        }
      ),
      child: BlocBuilder<TreeCubit, TreeTraverseState>(
        builder: (_context, state) {
          _cubitContext = _context;
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
                                root: state.tree,
                                markedNodes: state.selectedNodes,
                                onDrawNode: (node, offset) {
                                  _cubitContext.read<TreeCubit>().onDrawNode(node, offset);
                                }),
                          ),
                          onLongPressEnd: (details) {
                            _cubitContext.read<TreeCubit>().checkCanvasPoint(details.localPosition);
                          },
                        )
                    ),
                  ),
                ),
          );
        }
      ),
    );
  }

  @override
  void onAutoMode() => _cubitContext.read<TreeCubit>().onAutoMode();

  @override
  void onDurationChange(int value) => _cubitContext.read<TreeCubit>().onDurationChange(value);

  @override
  Future<void> onPlay() async => await _cubitContext.read<TreeCubit>().onPlay();

  @override
  void onRemoveItem(BinaryTreeNode node) => _cubitContext.read<TreeCubit>().onRemoveItem(node);

  @override
  void onStepBack() => _cubitContext.read<TreeCubit>().onStepBack();

  @override
  Future<void> onStepByStepMode() async => await _cubitContext.read<TreeCubit>().onStepByStepMode();

  @override
  void onStepForward() => _cubitContext.read<TreeCubit>().onStepForward();    

  @override
  void onStop() => _cubitContext.read<TreeCubit>().onStop();
}