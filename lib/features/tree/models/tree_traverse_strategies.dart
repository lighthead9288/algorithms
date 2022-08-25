import 'package:algorithms/features/tree/models/binary_tree.dart';

class PreOrderTraverseStrategy implements TreeTraverseStrategy {
  @override
  Future<void> run(BinaryTreeNode? node, Future<void> Function(BinaryTreeNode node) onStepForward, bool Function() onStop) async {
    if (node == null) {
      return;
    }

    if (onStop()) {
      return;
    }

    await onStepForward(node);
    await run(node.left, onStepForward, onStop);
    await run(node.right, onStepForward, onStop);
  }

}

class PostOrderTraverseStrategy implements TreeTraverseStrategy {
  @override
  Future<void> run(BinaryTreeNode? node, Future<void> Function(BinaryTreeNode node) onStepForward, bool Function() onStop) async {
    if (node == null) {
      return;
    }

    await run(node.left, onStepForward, onStop);
    await run(node.right, onStepForward, onStop);

    if (onStop()) {
      return;
    }

    await onStepForward(node);
  }

}

abstract class TreeTraverseStrategy {
  Future<void> run(BinaryTreeNode? node, Future<void> Function(BinaryTreeNode node) onStepForward, bool Function() onStop);
}