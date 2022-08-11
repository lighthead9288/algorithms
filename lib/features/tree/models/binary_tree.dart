class BinaryTreeNode {
  String data;
  int level;
  BinaryTreeNode? left;
  BinaryTreeNode? right;

  BinaryTreeNode({required this.data, required this.level, this.left, this.right});

  BinaryTreeNode? remove(BinaryTreeNode? node, String nodeName) {
    if (node?.data == nodeName) {
      return null;
    } 

    if (node?.left != null) {
      node?.left = remove(node.left, nodeName);
    }

    if (node?.right != null) {
      node?.right = remove(node.right, nodeName);
    }

    return node;
  }

}