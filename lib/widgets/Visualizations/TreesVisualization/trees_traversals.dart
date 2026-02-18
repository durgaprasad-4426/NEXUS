import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nexus/Providers/trees_operations_provider.dart';
import 'package:nexus/widgets/Visualizations/TreesVisualization/trees_visualizer.dart';
import 'package:provider/provider.dart';

class TreesTraversals extends StatefulWidget {
  const TreesTraversals({super.key});

  @override
  State<TreesTraversals> createState() => _TreesTraversalsState();
}

class _TreesTraversalsState extends State<TreesTraversals> {
 
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<TreesOperationsProvider>(context, listen: false);
    return LayoutBuilder(builder: (_, constraints) {
      if (constraints.maxWidth <= 700) {
        return mobileView(size, context, provider);
      }
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 15, 26, 33),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 15, 26, 33),
          title: const Text("Binary Tree", style: TextStyle(color: Colors.white),),
          actions: [
            IconButton(onPressed: (){
              provider.buildSampleTree();
            }, icon: Text("Build", style: TextStyle(color:Colors.white ),))
          ],
        ),
        body: Column(
          children: [
            visualizerMethod(size),
            stepMsgMethod(),
            Expanded(
              flex: 1,
              child: Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  operationsMethod(
                    context,
                    "Preorder",
                    "Start",
                    (){ provider.preOrder(provider.root);},
                    Iconsax.box_remove,
                  ),
                  operationsMethod(
                    context,
                    "Postorder",
                    "Start",
                    () { provider.postorder(provider.root);},
                    Iconsax.search_favorite,
                  ),
                  operationsMethod(
                    context,
                    "Inorder",
                    "Start",
                    () { provider.inorder(provider.root);},
                    Iconsax.search_favorite,
                  ),
                  operationsMethod(
                    context,
                    "Level Order",
                    "Start",
                    () { provider.levelOrder(provider.root);},
                    Iconsax.search_favorite,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Scaffold mobileView(Size size, BuildContext context, TreesOperationsProvider provider) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 26, 33),
      appBar: AppBar(title: const Text("Binary Tree")),
      body: Column(
        children: [
          visualizerMethod(size),
          stepMsgMethod(),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  operationsMethod(
                    context,
                    "Build",
                    "build",
                    () { provider.buildSampleTree();},
                    Iconsax.additem,
                    
                  ),
                  operationsMethod(
                    context,
                    "Preorder",
                    "Start",
                    () { provider.preOrder(provider.root);},
                    Iconsax.box_remove,
                  ),
                  operationsMethod(
                    context,
                    "Postorder",
                    "Start",
                    () {provider.postorder(provider.root);
                        },
                    Iconsax.search_favorite,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Consumer<TreesOperationsProvider> stepMsgMethod() {
    return Consumer<TreesOperationsProvider>(builder: (_, provider, __) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: provider.stepMsg.isEmpty
            ? const SizedBox.shrink()
            : Column(
                key: ValueKey(provider.stepMsg),
                children: [
                  stepMessageWidget(provider.stepMsg),
                  if (provider.timeComplexity.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: Text(
                        provider.timeComplexity,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ),
                ],
              ),
      );
    });
  }

  Expanded visualizerMethod(Size size) {
    return Expanded(
      flex: 1,
      child: Container(
        height: size.height * 0.5,
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 58, 88, 103),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.lightBlueAccent, width: 1),
        ),
        child: InteractiveViewer(
          constrained: false,
          boundaryMargin: const EdgeInsets.all(200),
          minScale: 0.5,
          maxScale: 3,
          child: Consumer<TreesOperationsProvider>(
            builder: (_, provider, __) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    width: size.width * 0.8,
                    height: size.height,
                    child: CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: TreePainter(
                        root: provider.root,
                        currentNode: provider.currentNode,
                        targetNode: provider.targetNode,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget stepMessageWidget(String stepMsg) {
    Color bgColor = Colors.grey.shade800;
    IconData icon = Icons.info;

    if (stepMsg.contains("Insert")) {
      bgColor = Colors.green.shade400;
      icon = Icons.add_circle;
    } else if (stepMsg.contains("Delete")) {
      bgColor = Colors.red.shade400;
      icon = Icons.remove_circle;
    } else if (stepMsg.contains("Searching") ||
        stepMsg.contains("Visiting") ||
        stepMsg.contains("Checking")) {
      bgColor = Colors.blue.shade400;
      icon = Icons.search;
    } else if (stepMsg.contains("Found")) {
      bgColor = Colors.purple.shade400;
      icon = Icons.check_circle;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [bgColor.withOpacity(0.2), bgColor]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              stepMsg,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

 Container operationsMethod(
  BuildContext context,
  String operationType,
  String btnText,
  void Function()? onPressed,
  IconData icon,
) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isMobile = screenWidth <= 700;

  return Container(
    width: isMobile ? screenWidth - 24 : MediaQuery.of(context).size.width*0.28,
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
          colors: [Colors.grey, Color.fromARGB(255, 228, 227, 227)]),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(
              operationType,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        ElevatedButton(onPressed: onPressed, child: Text(btnText)),
      ],
    ),
  );
}
}