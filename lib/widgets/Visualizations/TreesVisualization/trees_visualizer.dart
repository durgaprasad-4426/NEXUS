import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nexus/Providers/trees_operations_provider.dart';
import 'package:provider/provider.dart';

class TreesVisualizer extends StatelessWidget {
  const TreesVisualizer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TreesOperationsProvider>(
      builder: (_, provider, __) {
        return SizedBox(
          width: double.infinity,
          height: 600, 
          child: InteractiveViewer(
            constrained: false,
            boundaryMargin: const EdgeInsets.all(100),
            minScale: 0.5,
            maxScale: 3,
            child: CustomPaint(
              size: Size(2000, 600), 
              painter: TreePainter(
                root: provider.root,
                currentNode: provider.currentNode,
                targetNode: provider.targetNode,
              ),
            ),
          ),
        );
      },
    );
  }
}
class TreePainter extends CustomPainter {
  final TreeNode? root;
  final TreeNode? currentNode;
  final TreeNode? targetNode;

  TreePainter({this.root, this.currentNode, this.targetNode});

  @override
  void paint(Canvas canvas, Size size) {
    if (root != null) {
      _drawNode(canvas, root!, size.width / 2, 40, size.width / 4);
    }
  }

  void _drawNode(Canvas canvas, TreeNode node, double x, double y, double xOffset) {
    final paint = Paint()
      ..color = node == currentNode
          ? Colors.green
          : node == targetNode
              ? Colors.red
              : Colors.blue;

    canvas.drawCircle(Offset(x, y), 20, paint);

    final textPainter = TextPainter(
      text: TextSpan(text: node.value.toString(), style: const TextStyle(color: Colors.white, fontSize: 16)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));

    if (node.left != null) {
      final childX = x - xOffset;
      final childY = y + 80;
      _drawLineWithOffset(canvas, x, y, childX, childY, 20);
      _drawNode(canvas, node.left!, childX, childY, max(xOffset / 2, 40));
    }

    if (node.right != null) {
      final childX = x + xOffset;
      final childY = y + 80;
      _drawLineWithOffset(canvas, x, y, childX, childY, 20);
      _drawNode(canvas, node.right!, childX, childY, max(xOffset / 2, 40));
    }
  }

  void _drawLineWithOffset(Canvas canvas, double x1, double y1, double x2, double y2, double radius) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist == 0) return;

    final offsetX = dx / dist * radius;
    final offsetY = dy / dist * radius;

    final start = Offset(x1 + offsetX, y1 + offsetY);
    final end = Offset(x2 - offsetX, y2 - offsetY);

    canvas.drawLine(start, end, Paint()..color = Colors.black..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}