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

  int getMaxNumber(BinaryTreeNode? node, int max) {
    if (node == null) {
      return max;
    }

    var result = (int.parse(node.data) > max) ? int.parse(node.data) : max;

    result = getMaxNumber(node.left, result);
    result = getMaxNumber(node.right, result);
    
    return result;
  }

}