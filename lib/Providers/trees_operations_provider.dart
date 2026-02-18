import 'dart:collection';

import 'package:flutter/material.dart';
class TreeNode {
  int value;
  TreeNode? left;
  TreeNode? right;

  TreeNode({required this.value, this.left, this.right});
}

class TreesOperationsProvider extends ChangeNotifier{
  TreeNode? root;
  TreeNode? currentNode;
  TreeNode? targetNode;
  String stepMsg= "";
  String timeComplexity = "";

  void buildSampleTree(){
    root = TreeNode(value: 1,
    left: TreeNode(value: 2,
    left: TreeNode(value: 4),
    right: TreeNode(value: 5)),
    right: TreeNode(value: 3,
    left: TreeNode(value: 6),
    right: TreeNode(value: 7))
    );
    setStepMsg("Sample tree built");
    notifyListeners();
  }


  void setStepMsg(String msg){
    stepMsg = msg;
    notifyListeners();
  }

  void _setTimeComplexity(String complexity){
    timeComplexity = complexity;
    notifyListeners();
  }

  Future<void> _pause([int s = 3]) async {
    await Future.delayed(Duration(seconds: s));
  }

  Future<void> insert(int value) async {
    root = await _insertNode(root, value);
    setStepMsg("Inserted $value");

    await  _pause();
    clearAll();
  }

  Future<TreeNode> _insertNode(TreeNode? node, int value) async {
    if(node == null) return TreeNode(value: value);

    currentNode = node;
    setStepMsg("Checking node ${node.value}");
    await _pause();

    if(value < node.value){
      node.left = await _insertNode(node.left, value);
    }else{
      node.right = await _insertNode(node.right, value);
    }
    notifyListeners();

    return node;
  }


  Future<void> search(int value) async {
    await _searchNode(root, value);
  }

  Future<void> _searchNode(TreeNode? node, int value) async {
    if(node == null){
      setStepMsg("Value $value not found");
      await _pause();

      currentNode = null;
      targetNode = null;
      notifyListeners();
      return;
    }

    currentNode = node;
    setStepMsg("Visiting node ${node.value}");
    await _pause();

    if(node.value == value){
      targetNode = node;
      setStepMsg("Found $value");
      await _pause();
      return;
    }else if(value < node.value){
      await _searchNode(node.left, value);
    }else{
      await _searchNode(node.right, value);
    }

    currentNode = null;
    notifyListeners();

    await _pause();
    clearAll();
  }

  Future<TreeNode?> _deleteNode(TreeNode? root, int key) async {
  if (root == null) return null;
  currentNode = root;
  setStepMsg("Checking node ${root.value}");
  notifyListeners();
  await _pause();

  if (key < root.value) {
    setStepMsg("Searching left subtree of ${root.value} for $key"); 
    notifyListeners();
    await _pause();
    root.left = await _deleteNode(root.left, key);
  } else if (key > root.value) {
    setStepMsg("Searching right subtree of ${root.value} for $key");
    notifyListeners();
    await _pause();
    root.right = await _deleteNode(root.right, key);
  } else {
    targetNode = root;
    setStepMsg("Found node $key for deletion");
    notifyListeners();
    await _pause();

    if (root.left == null && root.right == null) {
      setStepMsg("Deleting leaf node $key");
      notifyListeners();
      await _pause();
      return null;
    } else if (root.left == null) {
      setStepMsg("Node $key has one child (right), replacing");
      notifyListeners();
      await _pause();
      return root.right;
    } else if (root.right == null) {
      setStepMsg("Node $key has one child (left), replacing");
      notifyListeners();
      await _pause();
      return root.left;
    }

    TreeNode successor = _minValueNode(root.right!);
    setStepMsg("Node $key has two children, replacing with inorder successor ${successor.value}");
    notifyListeners();
    await _pause();

    root.value = successor.value;
    root.right = await _deleteNode(root.right, successor.value);
  }

  return root;
}

TreeNode _minValueNode(TreeNode node) {
  TreeNode current = node;
  while (current.left != null) {
    current = current.left!;
  }
  return current;
}

Future<void> delete(int key) async {
  _setTimeComplexity("Time Complexity: Avg O(log n), Worst O(n)");
  root = await _deleteNode(root, key);
  targetNode = null;
  notifyListeners();
  _pause();
  clearAll();
}


  Future<void> preOrder(TreeNode? node) async {
    _setTimeComplexity("Time Complexity: Best O(n), Avg O(n), Worst O(n)");
    if(node == null) return;
    targetNode = node;
    setStepMsg("Visiting node ${node.value} (PreOrder)");
    notifyListeners();
    await _pause();

    await preOrder(node.left);
    await preOrder(node.right);
    await _pause();
    clearAll();
  }

   Future<void> inorder(TreeNode? node) async {
     _setTimeComplexity("Time Complexity: Best O(n), Avg O(n), Worst O(n)");
    if (node == null) return;
    await inorder(node.left);

    targetNode = node;
    setStepMsg("Visiting node ${node.value} (Inorder)");
    notifyListeners();
    await _pause();

    await inorder(node.right);
    await _pause();
    clearAll();
  }

  Future<void> postorder(TreeNode? node) async {
     _setTimeComplexity("Time Complexity: Best O(n), Avg O(n), Worst O(n)");
    if (node == null) return;
    await postorder(node.left);
    await postorder(node.right);

    currentNode = node;
    setStepMsg("Visiting node ${node.value} (Postorder)");
    notifyListeners();
    await _pause();
    clearAll();
  }


Future<void> levelOrder(TreeNode? root) async {
  if (root == null) return;
  final queue = Queue<TreeNode>()..add(root);

  while (queue.isNotEmpty) {
    final node = queue.removeFirst();
    targetNode = node;
    setStepMsg("Visiting node ${node.value} (Level Order)");
    await _pause();

    if (node.left != null) queue.add(node.left!);
    if (node.right != null) queue.add(node.right!);
  }

  await _pause();
  clearAll();
}

  void clearAll(){
    setStepMsg("");
    currentNode = null;
    targetNode = null;
    _setTimeComplexity("");
    notifyListeners();
  }
}